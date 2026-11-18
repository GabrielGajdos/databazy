CREATE SCHEMA IF NOT EXISTS silver;

CREATE VIEW silver.stg_users AS
    SELECT TRIM(id)::INT AS user_id,
    TRIM(age)::INT AS age,
    UPPER(TRIM(gender)) AS gender,
    TRIM(occupation_id)::INT AS occupation_id,
    TRIM(zip_code) AS zip_code
    FROM bronze.users;

CREATE VIEW silver.stg_genres_movies AS
    SELECT TRIM(id)::INT AS id_genres_movies,
    TRIM(movie_id)::INT AS movie_id,
    TRIM(genre_id):: INT AS genres_id
    FROM bronze.genres_movies;

CREATE VIEW silver.stg_age_group AS
    SELECT TRIM(id)::INT AS id_age_group,
    UPPER(TRIM(name)) AS name_age_group
    FROM bronze.age_group;

CREATE VIEW silver.stg_genres AS
    SELECT TRIM(id)::INT AS id_genres,
    UPPER(TRIM(name)) AS name_genres
    FROM bronze.genres;

CREATE VIEW silver.stg_movies AS
    SELECT TRIM(id)::INT AS id_movies,
    UPPER(TRIM(title)) AS title_movies,
    TRIM(release_year)::INT AS release_year_movies
    FROM bronze.movies;

CREATE VIEW silver.stg_occupations AS
    SELECT TRIM(id)::INT AS id_occupations,
    UPPER(TRIM(name)) AS name_occupations
    FROM bronze.occupations;

CREATE VIEW silver.stg_ratings AS
SELECT
    TRIM(id)::INT AS id_ratings,
    TRIM(user_id)::INT AS user_id_ratings,
    TRIM(movie_id)::INT AS movie_id_ratings,
    TRIM(rating)::NUMERIC AS rating_ratings,
    TRIM(rated_at)::TIMESTAMP AS rated_at_ratings
FROM bronze.ratings;