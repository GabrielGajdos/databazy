CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_user (
    user_id INT PRIMARY KEY,
    gender CHAR(1),
    zip_code VARCHAR(10),
    age_group VARCHAR(20),
    occupation VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS gold.dim_movie (
    movie_id INT PRIMARY KEY,
    title VARCHAR(200),
    release_year INT,
    genre_name VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_id INT PRIMARY KEY,
    rated_at DATE NOT NULL,
    day INT,
    month INT,
    year INT,
    day_of_week INT,
    day_name VARCHAR(10),
    week INT,
    month_name VARCHAR(10),
    quarter INT
);

CREATE TABLE IF NOT EXISTS gold.dim_time (
    time_id INT PRIMARY KEY,
    rated_at TIME NOT NULL,
    second INT,
    minute INT,
    hour INT,
    time_of_day VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS gold.fact_rating (
    rating_id INT PRIMARY KEY,
    rating DECIMAL(2,1),
    rating_count INT,
    rating_percentage INT,

    user_id INT REFERENCES gold.dim_user(user_id),
    time_id INT REFERENCES gold.dim_time(time_id),
    date_id INT REFERENCES gold.dim_date(date_id),
    movie_id INT REFERENCES gold.dim_movie(movie_id)
);

TRUNCATE TABLE
    gold.fact_rating,
    gold.dim_user,
    gold.dim_movie,
    gold.dim_date,
    gold.dim_time;


INSERT INTO gold.dim_user (
    user_id,
    gender,
    zip_code,
    age_group,
    occupation
)
SELECT
    u.user_id,
    u.gender,
    u.zip_code,
    COALESCE(a.name_age_group, 'unknown'),
    COALESCE(o.name_occupations, 'unknown')
FROM silver.stg_users u
LEFT JOIN silver.stg_age_group a
    ON a.id_age_group = u.age
LEFT JOIN silver.stg_occupations o
    ON o.id_occupations = u.occupation_id
ORDER BY u.user_id;


INSERT INTO gold.dim_movie (
    movie_id,
    title,
    release_year,
    genre_name
)
SELECT
    m.id_movies,
    m.title_movies,
    m.release_year_movies,
    COALESCE(
        STRING_AGG(
            DISTINCT g.name_genres,
            ', ' ORDER BY g.name_genres
        ),
        'UNKNOWN'
    ) AS genre_name
FROM silver.stg_movies m
LEFT JOIN silver.stg_genres_movies gm
    ON gm.movie_id = m.id_movies
LEFT JOIN silver.stg_genres g
    ON g.id_genres = gm.genres_id
GROUP BY
    m.id_movies,
    m.title_movies,
    m.release_year_movies
ORDER BY m.id_movies;

INSERT INTO gold.dim_date (
    date_id,
    rated_at,
    day,
    month,
    year,
    day_of_week,
    day_name,
    week,
    month_name,
    quarter
)
SELECT DISTINCT
    TO_CHAR(ts, 'YYYYMMDD')::INT AS date_id,
    ts::DATE AS rated_at,
    EXTRACT(DAY FROM ts)::INT AS day,
    EXTRACT(MONTH FROM ts)::INT AS month,
    EXTRACT(YEAR FROM ts)::INT AS year,
    EXTRACT(ISODOW FROM ts)::INT AS day_of_week,
    TRIM(TO_CHAR(ts, 'Day')) AS day_name,
    EXTRACT(WEEK FROM ts)::INT AS week,
    TRIM(TO_CHAR(ts, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM ts)::INT AS quarter
FROM (
    SELECT
        rated_at_ratings::TIMESTAMP AS ts
    FROM silver.stg_ratings
) r
ORDER BY date_id;

INSERT INTO gold.dim_time (
    time_id,
    rated_at,
    second,
    minute,
    hour,
    time_of_day
)
SELECT DISTINCT
    TO_CHAR(ts, 'HH24MISS')::INT AS time_id,
    ts::TIME AS rated_at,
    EXTRACT(SECOND FROM ts)::INT AS second,
    EXTRACT(MINUTE FROM ts)::INT AS minute,
    EXTRACT(HOUR FROM ts)::INT AS hour,
    CASE
        WHEN EXTRACT(HOUR FROM ts) BETWEEN 5 AND 11
            THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM ts) BETWEEN 12 AND 17
            THEN 'AFTERNOON'
        WHEN EXTRACT(HOUR FROM ts) BETWEEN 18 AND 21
            THEN 'EVENING'
        ELSE 'NIGHT'
    END AS time_of_day
FROM (
    SELECT
        rated_at_ratings::TIMESTAMP AS ts
    FROM silver.stg_ratings
) r
ORDER BY time_id;

INSERT INTO gold.fact_rating (
    rating_id,
    rating,
    rating_count,
    rating_percentage,
    user_id,
    time_id,
    date_id,
    movie_id
)
SELECT
    r.id_ratings,
    r.rating_ratings::DECIMAL(2,1),
    1 AS rating_count,
    ROUND(r.rating_ratings::NUMERIC / 5 * 100)::INT
        AS rating_percentage,
    r.user_id_ratings,
    TO_CHAR(r.rated_at_ratings, 'HH24MISS')::INT AS time_id,
    TO_CHAR(r.rated_at_ratings, 'YYYYMMDD')::INT AS date_id,
    r.movie_id_ratings

FROM silver.stg_ratings r

JOIN gold.dim_user u
    ON u.user_id = r.user_id_ratings

JOIN gold.dim_movie m
    ON m.movie_id = r.movie_id_ratings

JOIN gold.dim_date d
    ON d.date_id = TO_CHAR(r.rated_at_ratings, 'YYYYMMDD')::INT

JOIN gold.dim_time tm
    ON tm.time_id = TO_CHAR(r.rated_at_ratings, 'HH24MISS')::INT

ORDER BY r.id_ratings;

CREATE INDEX IF NOT EXISTS idx_fact_rating_user
    ON gold.fact_rating(user_id);

CREATE INDEX IF NOT EXISTS idx_fact_rating_movie
    ON gold.fact_rating(movie_id);

CREATE INDEX IF NOT EXISTS idx_fact_rating_date
    ON gold.fact_rating(date_id);

CREATE INDEX IF NOT EXISTS idx_fact_rating_time
    ON gold.fact_rating(time_id);


SELECT * FROM gold.dim_user LIMIT 10;

SELECT * FROM gold.dim_movie LIMIT 10;

SELECT * FROM gold.dim_date LIMIT 10;

SELECT * FROM gold.dim_time LIMIT 10;

SELECT * FROM gold.fact_rating LIMIT 10;