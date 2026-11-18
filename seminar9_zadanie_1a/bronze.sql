CREATE SCHEMA IF NOT EXISTS bronze;

CREATE TABLE bronze.age_group (
    id TEXT,
    name TEXT,
    _source_file TEXT DEFAULT 'age_group.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bronze.genres (
    id TEXT,
    name TEXT,
    _source_file TEXT DEFAULT 'genres.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bronze.genres_movies (
    id TEXT,
    movie_id TEXT,
    genre_id TEXT,
    _source_file TEXT DEFAULT 'genres_movies.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bronze.movies (
    id TEXT,
    title TEXT,
    release_year TEXT,
    _source_file TEXT DEFAULT 'movies.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bronze.occupations (
    id TEXT,
    name TEXT,
    _source_file TEXT DEFAULT 'occupations.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bronze.ratings (
    id TEXT,
    user_id TEXT,
    movie_id TEXT,
    rating TEXT,
    rated_at TEXT,
    _source_file TEXT DEFAULT 'ratings.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE bronze.users (
    id TEXT,
    age TEXT,
    gender TEXT,
    occupation_id TEXT,
    zip_code TEXT,
    _source_file TEXT DEFAULT 'users.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

\COPY bronze.age_group (id, name) FROM 'C:/Users/Student/Desktop/movielens/age_group.csv' WITH (FORMAT CSV, HEADER TRUE)
\COPY bronze.genres (id, name) FROM 'C:/Users/Student/Desktop/movielens/genres.csv' WITH (FORMAT CSV, HEADER TRUE)
\COPY bronze.genres_movies (id, title, release_year) FROM 'C:/Users/Student/Desktop/movielens/genres_movies.csv' WITH (FORMAT CSV, HEADER TRUE)
\COPY bronze.movies (id, title, release_year) FROM 'C:/Users/Student/Desktop/movielens/movies.csv' WITH (FORMAT CSV, HEADER TRUE)
\COPY bronze.occupations (id, name) FROM 'C:/Users/Student/Desktop/movielens/occupations.csv' WITH (FORMAT CSV, HEADER TRUE)
\COPY bronze.ratings (id, user_id, movie_id, rating, rated_at) FROM 'C:/Users/Student/Desktop/movielens/ratings.csv' WITH (FORMAT CSV, HEADER TRUE)
\COPY bronze.users (id, age, gender, occupation_id, zip_code) FROM 'C:/Users/Student/Desktop/movielens/users.csv' WITH (FORMAT CSV, HEADER TRUE)