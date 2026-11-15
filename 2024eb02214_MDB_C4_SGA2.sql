-- =====================================================================
-- Movie Database Assignment (MDB_C4_SGA2)
-- Name        : Dhruv Davda
-- BITS ID     : 2024eb02214
-- Database    : AWS RDS MySQL
-- Contents    : 1. Database and table creation
--               2. Sample data insertion
--               3. Solutions to SQL questions 1-10
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Create and select the database
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS MovieDB;
USE MovieDB;

-- Drop tables (child table first) so the script can be re-run safely
DROP TABLE IF EXISTS MoviePerson;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Movie;

-- ---------------------------------------------------------------------
-- 1. Table creation
-- ---------------------------------------------------------------------
CREATE TABLE Movie (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    year YEAR,
    rating FLOAT,
    genre VARCHAR(100)
);

CREATE TABLE Person (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    role ENUM('Actor', 'Actress', 'Director'),
    birth_year YEAR
);

CREATE TABLE MoviePerson (
    movie_id INT,
    person_id INT,
    FOREIGN KEY (movie_id) REFERENCES Movie(id),
    FOREIGN KEY (person_id) REFERENCES Person(id)
);

-- ---------------------------------------------------------------------
-- 2. Data insertion
-- ---------------------------------------------------------------------
-- Insert data into Movie table
INSERT INTO Movie VALUES
(1, 'Inception', 'A mind-bending sci-fi thriller', 2010, 8.8, 'Science Fiction'),
(2, 'The Dark Knight', 'Batman faces the Joker', 2008, 9.0, 'Action'),
(3, 'Interstellar', 'Space exploration drama', 2014, 8.6, 'Science Fiction'),
(4, 'Titanic', 'A love story on a doomed ship', 1997, 7.9, 'Romance'),
(5, 'The Shawshank Redemption', 'A tale of hope in a prison', 1994, 9.3, 'Drama');

-- Insert data into Person table
INSERT INTO Person VALUES
(1, 'Christopher Nolan', 'Director', 1970),
(2, 'Leonardo DiCaprio', 'Actor', 1974),
(3, 'Christian Bale', 'Actor', 1974),
(4, 'Anne Hathaway', 'Actress', 1982),
(5, 'Morgan Freeman', 'Actor', 1937),
(6, 'Kate Winslet', 'Actress', 1975),
(7, 'James Cameron', 'Director', 1954),
(8, 'Tim Robbins', 'Actor', 1958),
(9, 'Matthew McConaughey', 'Actor', 1969);

-- Insert data into MoviePerson table
INSERT INTO MoviePerson VALUES
(1, 1), (1, 2), (1, 4),
(2, 1), (2, 3),
(3, 1), (3, 4), (3, 9),
(4, 6), (4, 7),
(5, 5), (5, 8);

-- ---------------------------------------------------------------------
-- 3. SQL queries
-- ---------------------------------------------------------------------

-- Q1. Retrieve all movies released after the year 2000.
SELECT *
FROM Movie
WHERE year > 2000;

-- Q2. List all directors from the Person table.
SELECT name AS director_name
FROM Person
WHERE role = 'Director';

-- Q3. Find all movies with a rating greater than 8.0.
SELECT *
FROM Movie
WHERE rating > 8.0;

-- Q4. Count the number of movies in the Movie table.
SELECT COUNT(*) AS total_movies
FROM Movie;

-- Q5. Retrieve all movies along with the names of their directors.
--     LEFT JOIN keeps movies that have no director record (director = NULL).
--     The director filter is applied inside the derived table so that
--     actors linked to a movie do not create extra rows.
SELECT m.id,
       m.name AS movie_name,
       d.director_name
FROM Movie m
LEFT JOIN (
    SELECT mp.movie_id, p.name AS director_name
    FROM MoviePerson mp
    JOIN Person p ON p.id = mp.person_id
    WHERE p.role = 'Director'
) d ON d.movie_id = m.id
ORDER BY m.id;

-- Q6. Retrieve the total number of movies each actor or actress has been in.
--     LEFT JOIN so an actor/actress with no movies would still show 0.
SELECT p.name,
       p.role,
       COUNT(mp.movie_id) AS movie_count
FROM Person p
LEFT JOIN MoviePerson mp ON mp.person_id = p.id
WHERE p.role IN ('Actor', 'Actress')
GROUP BY p.id, p.name, p.role
ORDER BY movie_count DESC, p.name;

-- Q7. List the top 2 highest-rated movies.
SELECT *
FROM Movie
ORDER BY rating DESC
LIMIT 2;

-- Q8. Retrieve all actors and actresses born before 1975,
--     along with the movies they acted in.
SELECT p.name AS person_name,
       p.role,
       p.birth_year,
       m.name AS movie_name
FROM Person p
JOIN MoviePerson mp ON mp.person_id = p.id
JOIN Movie m        ON m.id = mp.movie_id
WHERE p.role IN ('Actor', 'Actress')
  AND p.birth_year < 1975
ORDER BY p.birth_year, p.name;

-- Q9. Find the average rating of movies grouped by genre.
--     ROUND is used because FLOAT averages can show long decimals.
SELECT genre,
       ROUND(AVG(rating), 2) AS average_rating,
       COUNT(*) AS movie_count
FROM Movie
GROUP BY genre
ORDER BY average_rating DESC;

-- Q10. List the names of actors/actresses who have acted in movies
--      directed by 'Christopher Nolan'.
SELECT DISTINCT a.name AS actor_name,
       a.role
FROM Person d
JOIN MoviePerson md ON md.person_id = d.id          -- movies Nolan directed
JOIN MoviePerson ma ON ma.movie_id  = md.movie_id   -- everyone in those movies
JOIN Person a       ON a.id = ma.person_id
WHERE d.name = 'Christopher Nolan'
  AND d.role = 'Director'
  AND a.role IN ('Actor', 'Actress')
ORDER BY a.name;
