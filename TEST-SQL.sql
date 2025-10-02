--DATA SOURCE = https://www.kaggle.com/datasets/mexwell/famous-paintings?select=work.csv

-- 1. Core CREATE SCHEMA & CREATE TABLE
-- Create a schema named artdb. 
 	CREATE SCHEMA artdb;

--Create a table artdb.artists with the same structure as artist.csv.
	CREATE TABLE artdb.artists(
		artist_id INT GENERATED ALWAYS AS IDENTITY (START WITH 500) PRIMARY KEY,
		full_name VARCHAR(255) NOT NULL,     
		first_name VARCHAR(100),             
		middle_names VARCHAR(150),           
		last_name VARCHAR(100),             
		nationality VARCHAR(100),            
		style VARCHAR(100),                  
		birth INT,                          
		death INT       
	);

--Create a table artdb.works with the same structure as work.csv.
 	CREATE TABLE artdb.works(
		work_id INT PRIMARY KEY,      
		name VARCHAR(255),     
		artist_id INT,         
		style VARCHAR(100),            
		museum_id INT              
	);

--Create a table artdb.museums with the same structure as museum.csv.
	CREATE TABLE artdb.museums(
		museum_id INT PRIMARY KEY,      
		name VARCHAR(255) NOT NULL,      
		address VARCHAR(255),            
		city VARCHAR(150),            
		state VARCHAR(150),             
		postal VARCHAR(100),                
		country VARCHAR(100),            
		phone VARCHAR(50),                 
		url VARCHAR(255)            
	);

--Create a schema sales_data for artwork pricing and move product_size into it.
	 CREATE SCHEMA sales_data;	
	 CREATE TABLE sales_data.product_size (
	    size_id INT PRIMARY KEY,          
	    work_id INT,                 
	    sale_price NUMERIC(10,2),   
	    regular_price NUMERIC(10,2)
	);

--Create a schema archive_data and copy all artist data born before 1600 into it.
	CREATE SCHEMA archive_data;
	
	CREATE TABLE archive_data.artists AS
	TABLE artdb.artists WITH NO DATA;
	
	INSERT INTO archive_data.artists
	SELECT *
	FROM artdb.artists
	WHERE birth < 1600;
--Create a schema analytics and add a table top_artists with artist_id, full_name, total_works.
	CREATE SCHEMA analytics;	
	CREATE TABLE analytics.top_artists (
		artist_id    INT PRIMARY KEY,
		full_name    VARCHAR(255) NOT NULL,
		total_works  INT NOT NULL
	);
	
--2. Altering Tables
--Add a column era VARCHAR(50) to the artist table.
	ALTER TABLE artdb.artists
	ADD COLUMN era VARCHAR(50);

--Drop the middle_names column from artist.
	ALTER TABLE artdb.artists
	DROP COLUMN middle_names;

--Rename column style in work to art_style.
	ALTER TABLE artdb.works
	RENAME COLUMN style TO  art_style;

--Add a column established_year INT to the museum table.
	ALTER TABLE artdb.museums
	ADD COLUMN established_year INT;

--Modify column sale_price in product_size to NUMERIC(12,2).
	ALTER TABLE sales_data.product_size
	ALTER COLUMN sale_price type NUMERIC(12,2);

--Remove column phone from museum.
	ALTER TABLE artdb.museums
	DROP COLUMN phone;

--Add a column is_open_weekends BOOLEAN to museum_hours.
	ALTER TABLE artdb.museum_hours
	ADD COLUMN is_open_weekends BOOLEAN;

--3. SELECT Basics
--Select all columns from the artist table.
	SELECT * FROM artdb.artists;

--Retrieve the first 10 rows of work.
	SELECT * FROM artdb.works
	LIMIT 10;

--Show only full_name and nationality from artist.
	SELECT full_name, nationality FROM artdb.artists;

--Select the name and city of all museums.
	SELECT name, city FROM artdb.museums;

--List all artworks (name) created by artist ID = 615.
	SELECT name
	FROM artdb.works
	WHERE artist_id = 615;

--Show all artists with nationality French.
	SELECT * FROM artdb.artists
	WHERE nationality = 'French';

--4. WHERE Clause
--Find all artists born after 1800.
	SELECT * FROM artdb.artists
	WHERE birth > 1800;

--List all Impressionist works.
	SELECT * FROM artdb.works
	WHERE art_style = 'Impressionism';

--Find museums located in the USA.
	SELECT * FROM artdb.museums
	WHERE country = 'USA';

--Show works created between 1700 and 1800.
	SELECT w.work_id, w.name AS work_name, w.art_style, w.museum_id, a.artist_id,
	a.birth, a.death
	FROM artdb.works w
	JOIN artdb.artists a ON w.artist_id = a.artist_id
	WHERE a.birth <= 1800
	AND a.death >= 1700;

--Find all artists where last_name = 'Renoir'.
  	SELECT * FROM artdb.artists
	WHERE last_name = 'Renoir';

--Show all works not linked to any museum (museum_id IS NULL).
	SELECT * FROM artdb.works
	WHERE museum_id IS NULL;

--List artworks priced above 10,000 in product_size.
	SELECT * FROM  sales_data.product_size 
	WHERE sale_price > 10000;

--5. ORDER BY
--List all artists ordered by birth year (earliest first).
	SELECT * FROM artdb.artists
	ORDER BY birth ASC;

--Retrieve the top 5 most expensive artworks from product_size.
	SELECT * FROM  sales_data.product_size 
	ORDER BY sale_price DESC
	LIMIT 5;

--Order museums alphabetically by city.
	SELECT * FROM artdb.museums
	ORDER BY city ASC;

--Order all works by their style in descending order.
	SELECT * FROM artdb.works
	ORDER BY art_style DESC;

--Find the youngest 10 artists by sorting on birth DESC.
 	SELECT * FROM  artdb.artists
	ORDER BY birth DESC
	LIMIT 10;

--6. Aggregations + GROUP BY
--Count how many artists exist per nationality.
	SELECT nationality, COUNT(*) AS total_artists
	FROM artdb.artists
	GROUP BY nationality
	ORDER BY total_artists DESC;

--Find the average sale price of artworks per style.
	SELECT art_style, AVG()	

--Count the number of works per museum.
	SELECT museum_id, COUNT(*) AS total_works
	FROM artdb.works
	GROUP BY museum_id
	ORDER BY total_works DESC;

--Find the number of works created per century (birth grouped by 100 years).
	SELECT 
	(a.birth/100 + 1) || 'th Century' AS birth_century,
	COUNT(w.work_id) AS total_works
	FROM artdb.works w
	JOIN artdb.artists a 
	ON w.artist_id = a.artist_id
	WHERE a.birth IS NOT NULL
	GROUP BY (a.birth/100 + 1)
	ORDER BY (a.birth/100 + 1);

--Show the maximum canvas width for each size_id.
	SELECT size_id, MAX(width) AS max_width
	FROM artdb.canvas_size
	GROUP BY size_id
	ORDER BY size_id;	

--Count how many artworks have Portraits as their subject.
	SELECT COUNT(*) AS portrait_count
	FROM artdb.subject s
	JOIN artdb.works w ON s.work_id = w.work_id
	WHERE s.subject = 'Portraits';

--Find how many works belong to each style.
	SELECT art_style, COUNT(*) AS total_works
	FROM artdb.works
	GROUP BY art_style
	ORDER BY total_works DESC;

--7. HAVING Clause
--Show nationalities with more than 50 artists.
	SELECT nationality, COUNT(*) AS total_artists
	FROM artdb.artists
	GROUP BY nationality
	HAVING COUNT(*) > 50
	ORDER BY total_artists DESC;

--Show museums that house more than 200 works.
	SELECT m.museum_id, m.name AS museum_name, COUNT(w.work_id) AS total_works
	FROM artdb.works w
	JOIN artdb.museums m ON w.museum_id = m.museum_id
	GROUP BY m.museum_id, m.name
	HAVING COUNT(w.work_id) > 200
	ORDER BY total_works DESC;

--List art styles that have an average price greater than 50,000.
	SELECT w.art_style, AVG(ps.sale_price) AS avg_price
	FROM sales_data.product_size ps
	JOIN artdb.works w ON ps.work_id = w.work_id
	GROUP BY w.art_style
	HAVING AVG(ps.sale_price) > 50000
	ORDER BY avg_price DESC;

--Find all subject types that appear in more than 1,000 works.
	SELECT name, COUNT(*) AS total_works
	FROM artdb.works 
	GROUP BY name
	HAVING COUNT(*) > 1000
	ORDER BY total_works;

--Show nationalities that have more than 5 Impressionist artists.
	SELECT nationality, COUNT(*) AS impressionists
	FROM artdb.artists
	WHERE style = 'Impressionism'
	GROUP BY nationality
	HAVING COUNT(*) > 5
	ORDER BY impressionists DESC;	

--Find cities that host more than 2 museums.
	SELECT city, COUNT(*) AS total_museums
	FROM artdb.museums
	WHERE city IS NOT NULL
	GROUP BY city
	HAVING COUNT(*) > 2
	ORDER BY total_museums DESC;

--8. JOINs
--Show each artwork with its artist’s full name (work JOIN artist).
	SELECT w.work_id,  w.name AS artwork_name,
	   a.full_name AS artist_name
	FROM artdb.works w
	JOIN artdb.artists a ON w.artist_id = a.artist_id
	ORDER BY artist_name;

--Show each work with its museum name (work JOIN museum).
	SELECT w.work_id,  w.name AS artwork_name,
	   m.name AS museum_name
	FROM artdb.works w
	JOIN artdb.museums m ON w.museum_id = m.museum_id
	ORDER BY museum_name;

--Get artworks, their artist’s nationality, and museum city (work JOIN artist JOIN museum).
	SELECT w.work_id,  w.name AS artwork_name, a.nationality,  m.city AS museum_city
	FROM artdb.works w
	JOIN artdb.artists a ON w.artist_id = a.artist_id
	JOIN artdb.museums m ON w.museum_id = m.museum_id;

--Show all works with size details (work JOIN product_size JOIN canvas_size).
	SELECT w.work_id, w.name AS artwork_name, ps.size_id, cs.width, cs.height,
	   cs.label, ps.sale_price, ps.regular_price
	FROM artdb.works w
	JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	JOIN artdb.canvas_size cs ON ps.size_id = cs.size_id
	ORDER BY w.work_id;

--List all museums and their open/close times (museum JOIN museum_hours).
	SELECT m.museum_id, name AS museum_name,
	       mh.open, mh.close
	FROM artdb.museums m
	JOIN artdb.museum_hours mh ON m.museum_id = mh.museum_id 
	ORDER BY name;

--Find artworks that do not have image links (LEFT JOIN imagelink).
	SELECT w.work_id, w.name AS artwork_name
	FROM artdb.works w
	LEFT JOIN artdb.image_link il ON w.work_id = il.work_id
	WHERE il.work_id IS NULL
	ORDER BY w.work_id;

--Show all artists and the number of works they created (JOIN + GROUP BY).
	SELECT a.artist_id, a.full_name, COUNT(w.work_id) AS number_of_works
	FROM  artdb.artists a
	LEFT JOIN artdb.works w ON a.artist_id = w.artist_id
	GROUP BY a.artist_id, a.full_name
	ORDER BY number_of_works DESC;

--9. Subqueries
--Find all artists who created more works than the average artist.
	SELECT a.artist_id, a.full_name, COUNT(w.work_id) AS number_of_works
	FROM artdb.artists a
	LEFT JOIN artdb.works w ON a.artist_id = w.artist_id
	GROUP BY a.artist_id, a.full_name
	HAVING 
	    COUNT(w.work_id) > (
	        SELECT AVG(work_count)
	        FROM (
	            SELECT COUNT(*) AS work_count
	            FROM artdb.works
	            GROUP BY artist_id
	        ) AS sub
	    )
	ORDER BY number_of_works DESC;

--Get the most expensive artwork in the database.
	SELECT w.work_id, w.name, ps.sale_price
	FROM artdb.works w
	JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	WHERE ps.sale_price = (SELECT MAX(sale_price)FROM sales_data.product_size);

--Show all artists whose birth year is earlier than the average birth year.
	SELECT * FROM artdb.artists
	WHERE birth < (
	SELECT AVG(birth)
	FROM artdb.artists
	);

--Find all museums that have at least one Impressionist work.
	SELECT * FROM artdb.museums m
	WHERE EXISTS (
		SELECT 1
		FROM artdb.works w
		WHERE w.museum_id = m.museum_id
		  AND w.art_style = 'Impressionism'
	);

--List artworks whose sale price is above the average sale price.
	SELECT w.work_id, w.name, w.artist_id, w.art_style, w.museum_id, 
	ps.sale_price
	FROM artdb.works w
	JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	WHERE ps.sale_price > (
		SELECT AVG(sale_price)
		FROM sales_data.product_size
	);

--Find artists who have no recorded death year.
	SELECT * FROM artdb.artists
	WHERE death IS NULL;

--Get the museum that holds the maximum number of works.
	SELECT m.museum_id, m.name, COUNT(w.work_id) AS num_of_works
	FROM artdb.museums m
	JOIN artdb.works w ON m.museum_id = w.museum_id
	GROUP BY m.museum_id, m.name
	HAVING COUNT(w.work_id) = (
		SELECT MAX(work_count)
		FROM (
			SELECT COUNT(*) AS work_count
			FROM artdb.works
			GROUP BY museum_id
		) AS sub
	);

--Find all artworks that share the same style as "Still Life with Flowers and a Watch".
	SELECT * FROM artdb.works
	WHERE art_style = (
		SELECT art_style
		FROM artdb.works
		WHERE name = 'Still Life with Flowers and a Watch'
	)
	AND name <> 'Still Life with Flowers and a Watch'; --excludes the original artwork itself.



