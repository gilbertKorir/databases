--DATA SOURCE = https://www.kaggle.com/datasets/mexwell/famous-paintings?select=work.csv

-- 1. Core CREATE SCHEMA & CREATE TABLE
-- Create a schema named artdb. 
 	CREATE SCHEMA artdb;

--Create a table artdb.artists with the same structure as artist.csv.
	CREATE TABLE artdb.artists(
		artist_id INT PRIMARY KEY,
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
		work_id INT REFERENCES artdb.works(work_id),
		size_id INT,                      
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
		artist_id  INT  REFERENCES artdb.artists(artist_id),
		full_name VARCHAR(255) NOT NULL,
		total_works INT NOT NULL
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


--10 SQL Subquery Questions
--Find all artists whose total number of artworks is greater than the average number of 
--artworks created by all artists.
SELECT a.artist_id, a.full_name, COUNT(w.work_id) AS total_artworks
FROM artdb.artists a
JOIN artdb.works w ON a.artist_id = w.artist_id
GROUP BY a.artist_id, a.full_name
HAVING COUNT(w.work_id) > (
    SELECT AVG(artist_work_count)
    FROM (
        SELECT COUNT(w2.work_id) AS artist_work_count
        FROM artdb.works w2
        GROUP BY w2.artist_id
    ) AS subquery
);

--List artworks whose price is higher than the average price of artworks in the same museum.
	SELECT w.work_id, w.name AS artwork_name, m.name AS museum_name, ps.sale_price
	FROM artdb.works w
	JOIN artdb.museums m ON w.museum_id = m.museum_id
	JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	WHERE  ps.sale_price > (
		SELECT AVG(ps.sale_price)
		FROM sales_data.product_size ps
		JOIN artdb.works w ON  ps.work_id = w.work_id
		WHERE ps.work_id = w.work_id
	);

--Show the museum(s) that display the most expensive artwork overall.
	SELECT m.museum_id, m.name AS museum_name, w.work_id, w.name AS artwork_name,  ps.regular_price
	FROM artdb.works w
	JOIN artdb.museums m ON w.museum_id = m.museum_id
	JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	WHERE ps.regular_price = (
	    SELECT MAX(ps2.regular_price)
	    FROM sales_data.product_size ps2
	);

--Retrieve the artist name who created the oldest artwork in the database.
	SELECT DISTINCT a.artist_id, a.full_name, w.work_id, a.birth
	FROM artdb.artists a
	JOIN artdb.works w ON a.artist_id = w.artist_id
	WHERE a.birth = (
		SELECT MIN(birth) FROM artdb.artists 
	);

--Find all artworks that belong to artists who have more than 5 paintings.
	SELECT w.work_id, w.name AS artwork_name, w.artist_id, a.full_name AS artist_name
	FROM artdb.works w
	JOIN artdb.artists a ON w.artist_id = a.artist_id
	WHERE w.artist_id IN (
	    SELECT artist_id
	    FROM artdb.works
	    GROUP BY artist_id
	    HAVING COUNT(work_id) > 5
	);

--List all artworks whose museum_id matches museums located in ‘Paris’.
	SELECT  w.work_id, w.name AS artwork_name, m.city
	FROM artdb.works w
	JOIN artdb.museums m ON w.museum_id = m.museum_id
	WHERE m.city = 'Paris';

--Show all artworks that are larger than the average canvas size for their medium.
	SELECT w.work_id, w.name AS artwork_name, c.label, (c.width * c.height) AS area
	FROM artdb.works w
	JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	JOIN artdb.canvas_size c ON ps.size_id = c.size_id
	WHERE (c.width * c.height) > (
	    SELECT AVG(c2.width * c2.height)
	    FROM sales_data.product_size ps2
	    JOIN artdb.canvas_size c2 ON ps2.size_id = c2.size_id
	);

--Find the names of artists who have never sold an artwork (assuming a work is unsold if it has no price).
	SELECT a.full_name AS artist_name
	FROM artdb.artists a
	WHERE a.artist_id NOT IN (
		SELECT DISTINCT w.artist_id
		FROM artdb.works w
		JOIN sales_data.product_size ps	ON w.work_id = ps.work_id
		WHERE ps.sale_price IS NOT NULL
	);	

--Retrieve the names of museums that host artworks by artists from Italy.
	SELECT DISTINCT name AS museum_name
	FROM artdb.museums
	WHERE museum_id IN (
		SELECT w.museum_id
		FROM artdb.works w
	    WHERE w.artist_id IN (
		SELECT artist_id
		FROM artdb.artists
		WHERE nationality = 'Italian'
	));


--Find the subject(s) that appear in artworks with prices above the 90th percentile of all artwork prices.
	SELECT DISTINCT s.subject
	FROM artdb.subject s
	JOIN sales_data.product_size ps ON s.work_id = ps.work_id
	WHERE ps.sale_price > (
		SELECT PERCENTILE_CONT(0.9) 
		WITHIN GROUP (ORDER BY sale_price)
		FROM sales_data.product_size
	);

--15 SQL CTE (Common Table Expression) Questions
--Use a CTE to list each artist and the total number of artworks they created.
	WITH ArtistWorks AS(
	 SELECT w.artist_id, COUNT(w.work_id) AS total_artworks
	 FROM artdb.works w
	 GROUP BY w.artist_id
	)
	SELECT a.full_name AS artist_name,	aw.total_artworks
	FROM artdb.artists a
	JOIN ArtistWorks aw ON a.artist_id = aw.artist_id
	ORDER BY aw.total_artworks DESC;

--Create a CTE that finds the average artwork price per museum, then select
--museums where the average price > $10,000.
	WITH AvgPricePerMuseum AS (
	    SELECT w.museum_id, ROUND(AVG(ps.sale_price),2) AS avg_price
	    FROM artdb.works w
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    WHERE ps.sale_price IS NOT NULL
	    GROUP BY w.museum_id
	)
	SELECT m.name AS museum_name, a.avg_price
	FROM AvgPricePerMuseum a
	JOIN artdb.museums m ON a.museum_id = m.museum_id
	WHERE a.avg_price > 10000
	ORDER BY a.avg_price DESC;

--Build a CTE that calculates the rank of artworks by price within each museum.
	WITH ArtPriceRanking AS (
    SELECT w.museum_id, w.work_id, w.name AS artwork_name, ps.sale_price,
        RANK() OVER (
            PARTITION BY w.museum_id 
            ORDER BY ps.sale_price DESC
        ) AS price_rank
    FROM artdb.works w
    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
    WHERE ps.sale_price IS NOT NULL
)
SELECT m.name AS museum_name, a.artwork_name, a.sale_price, a.price_rank
FROM ArtPriceRanking a
JOIN artdb.museums m ON a.museum_id = m.museum_id
ORDER BY m.name, a.price_rank;

--Using a CTE, calculate the average artwork size by canvas type.
	WITH AvgCanvasSize AS (
	    SELECT c.label AS canvas_type, AVG(c.width * c.height) AS avg_area
	    FROM artdb.canvas_size c
	    GROUP BY c.label
	)
	SELECT canvas_type, ROUND(avg_area, 2) AS average_canvas_area
	FROM AvgCanvasSize
	ORDER BY average_canvas_area DESC;

--Create a CTE that finds artists with multiple artworks in different museums.
	WITH ArtistArtworksCount AS (
		SELECT w.artist_id, COUNT(DISTINCT w.museum_id) AS museum_count
		FROM artdb.works w
		WHERE w.museum_id IS NOT NULL
		GROUP BY w.artist_id
	)
	SELECT a.full_name AS artist_name,	amc.museum_count
	FROM ArtistArtworksCount amc
	JOIN artdb.artists a 
	ON a.artist_id = amc.artist_id
	WHERE amc.museum_count > 1
	ORDER BY amc.museum_count DESC;

--With a CTE, compute total artworks per subject and filter subjects appearing in more than 3 artworks.
	WITH SubjectCount AS (
		SELECT subject,	COUNT(work_id) AS total_artworks
		FROM artdb.subject
		GROUP BY subject
	)
	SELECT subject,	total_artworks
	FROM SubjectCount
	WHERE total_artworks > 3
	ORDER BY total_artworks DESC;

--Use a recursive CTE to generate a series of exhibition years from 1900 to 2025.
	WITH RECURSIVE ExhibitionYears AS (
	    SELECT 1900 AS year
	    UNION ALL
	    SELECT year + 1 --one year keeps being added until it reaches 2025.
	    FROM ExhibitionYears 
	    WHERE year < 2025
	)
	SELECT year
	FROM ExhibitionYears;

--Use a CTE to find artists with above-average artwork prices.
--CTE #1 – ArtistAvg
--CTE #2 – OverallAvg
--Joins artists to their average prices.
	WITH ArtistAvgPrice AS (
	    SELECT w.artist_id, ROUND(AVG(ps.sale_price),2) AS avg_artist_price
	    FROM artdb.works w
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    WHERE ps.sale_price IS NOT NULL
	    GROUP BY w.artist_id
	),
	OverallAvgPrice AS (
	    SELECT AVG(sale_price) AS overall_avg_price
	    FROM sales_data.product_size
	    WHERE sale_price IS NOT NULL
	)
	SELECT a.full_name, aa.avg_artist_price
	FROM ArtistAvgPrice aa
	JOIN artdb.artists a ON aa.artist_id = a.artist_id
	CROSS JOIN OverallAvgPrice oa
	WHERE aa.avg_artist_price > oa.overall_avg_price
	ORDER BY aa.avg_artist_price DESC;

--Build a CTE to find the most common subject for each artist.
	WITH CommonSubject AS (
	    SELECT a.artist_id, a.full_name, s.subject, COUNT(*) AS subject_count,
	        RANK() OVER (PARTITION BY a.artist_id ORDER BY COUNT(*) DESC) AS subject_rank
	    FROM artdb.artists a
	    JOIN artdb.works w ON a.artist_id = w.artist_id
	    JOIN artdb.subject s ON w.work_id = s.work_id
	    GROUP BY a.artist_id, a.full_name, s.subject
	)
	SELECT artist_id, full_name, subject, subject_count
	FROM CommonSubject
	WHERE subject_rank = 1
	ORDER BY full_name;


--Use a CTE to find museums that are open on Sundays and display at least one artwork.
	WITH SundayArtMuseums AS (
    SELECT mh.museum_id, mh.day
    FROM artdb.museum_hours mh
    WHERE LOWER(mh.day) = 'sunday' AND mh.open IS NOT NULL
	)
	SELECT DISTINCT m.name AS museum_name, m.city, m.country
	FROM artdb.museums m
	JOIN SundayArtMuseums sm ON m.museum_id = sm.museum_id
	JOIN artdb.works w ON m.museum_id = w.museum_id
	ORDER BY m.name;

--Create a CTE to find top 5 most expensive artworks and the artists who made them.
	WITH Top5Artworks AS (
	    SELECT w.work_id, w.name AS artwork_name, w.artist_id, ps.sale_price,
	        RANK() OVER (ORDER BY ps.sale_price DESC) AS price_rank
	    FROM artdb.works w
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    WHERE ps.sale_price IS NOT NULL
	)
	SELECT tp5.price_rank, tp5.artwork_name, a.full_name AS artist_name, tp5.sale_price
	FROM Top5Artworks tp5
	JOIN artdb.artists a ON tp5.artist_id = a.artist_id
	WHERE tp5.price_rank <= 5
	ORDER BY tp5.price_rank;

--Use a CTE to calculate the percentage contribution of each artwork’s price to the artist’s total earnings.
	WITH ArtistEarnings AS (
    SELECT w.artist_id, w.work_id, w.name AS artwork_name, ps.sale_price,
        SUM(ps.sale_price) OVER (PARTITION BY w.artist_id) AS total_artist_earnings
    FROM artdb.works w
    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
    WHERE ps.sale_price IS NOT NULL
	)
	SELECT a.artist_id, a.artwork_name, a.sale_price, a.total_artist_earnings,
	    ROUND((a.sale_price / a.total_artist_earnings) * 100, 2) AS percent_contribution
	FROM ArtistEarnings a
	ORDER BY a.artist_id, percent_contribution DESC;

--Use multiple CTEs: one for average artwork price, one for average artwork size, and join them.
	WITH AvgPrice AS (
	    SELECT  AVG(sale_price) AS avg_sale_price
	    FROM sales_data.product_size
	    WHERE sale_price IS NOT NULL
   ),
	AvgSize AS (
		SELECT AVG(width * height) AS avg_canvas_area
		FROM artdb.canvas_size
	)
	SELECT ap.avg_sale_price, asz.avg_canvas_area
	FROM AvgPrice ap
	CROSS JOIN AvgSize asz;	

--Use a CTE to list artists whose first recorded artwork (min year) was before 1950.
	WITH EarlyArtwork AS (
	    SELECT artist_id, MIN(birth) AS first_year
	    FROM artdb.artists
	    GROUP BY artist_id
	)
	SELECT a.full_name, e.first_year
	FROM EarlyArtwork e
	JOIN artdb.artists a ON e.artist_id = a.artist_id
	WHERE e.first_year < 1950
	ORDER BY e.first_year;

--Create a CTE to find the largest canvas dimensions per artwork type.
	WITH LargestCanvasSize AS (
	    SELECT c.label AS artwork_type, MAX(c.width) AS max_width, MAX(c.height) AS max_height
	    FROM artdb.canvas_size c
	    GROUP BY c.label
	)
	SELECT artwork_type, max_width, max_height
	FROM LargestCanvasSize
	ORDER BY artwork_type;

--15 Stored Procedure Questions
--(You can create these in MySQL, PostgreSQL, or SQL Server syntax — examples below are general.)
--Write a stored procedure GetArtistWorks(artist_name) that returns all artworks by a given artist.
-- Return all artworks by the specified artist
	 CREATE OR REPLACE FUNCTION GetArtistWorks(p_artist_name TEXT)
		RETURNS TABLE (
		work_id INT,
		artwork_name VARCHAR(255),
    art_style VARCHAR(100)
		)
	LANGUAGE plpgsql
	AS $$
	BEGIN
		RETURN QUERY
		SELECT w.work_id, w.name AS artwork_name, w.art_style
		FROM artdb.works w
		JOIN artdb.artists a ON w.artist_id = a.artist_id
		WHERE a.full_name = p_artist_name;
	END;
	$$;

	SELECT * FROM GetArtistWorks('James Ensor');
	
--Create a stored procedure GetMuseumArtworks(museum_name) that lists all artworks displayed in a given museum.
	CREATE OR REPLACE FUNCTION GetMuseumArtworks(museum_name TEXT)
		RETURNS TABLE (
		work_id INT,
		artwork_name VARCHAR(255),
		art_style VARCHAR(100)
		)
	LANGUAGE plpgsql
	AS $$
	BEGIN
		RETURN QUERY
		SELECT w.work_id, w.name AS artwork_name, w.art_style
		FROM artdb.works w
		JOIN artdb.museums m ON w.museum_id = m.museum_id
		WHERE m.name = museum_name;
	END;
	$$;

	SELECT * FROM GetMuseumArtworks('National Gallery');
--Write a stored procedure GetTopExpensiveArtworks(limit_count) that returns the top n most expensive artworks.
	CREATE OR REPLACE FUNCTION GetTopExpensiveArtworks(p_limit_count INT)
		RETURNS TABLE (
		work_id INT,
		artwork_name VARCHAR(255),
		art_style VARCHAR(100),
		sale_price NUMERIC(10,2)
	)
	LANGUAGE plpgsql
	AS $$
	BEGIN
		RETURN QUERY
		SELECT w.work_id, w.name AS artwork_name, a.full_name AS artist_name, ps.sale_price
		FROM artdb.works w
		JOIN artdb.artists a ON w.artist_id = a.artist_id
		JOIN sales_data.product_size ps ON w.work_id = ps.work_id
		WHERE ps.sale_price IS NOT NULL
		ORDER BY ps.sale_price DESC
		LIMIT p_limit_count;
	END;
	$$;

	SELECT * FROM GetTopExpensiveArtworks(3);

--Write a stored procedure GetArtistTotalValue(artist_name) that returns the total market value 
--of all artworks by that artist.
	CREATE OR REPLACE PROCEDURE GetArtistTotalValue(p_artist_name TEXT)
	LANGUAGE plpgsql
	AS $$
	DECLARE
	    total_value NUMERIC(15,2);
	BEGIN
	    -- total sale value for all artworks by the artist
	    SELECT SUM(ps.sale_price)
	    INTO total_value
	    FROM artdb.works w
	    JOIN artdb.artists a ON w.artist_id = a.artist_id
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    WHERE a.full_name ILIKE p_artist_name;
	
	    --when artist has no recorded sales
	    IF total_value IS NULL THEN
	        RAISE NOTICE 'No recorded sales for artist: %', p_artist_name;
	    ELSE
	        RAISE NOTICE 'Total market value for %: $%', p_artist_name, total_value;
	    END IF;
	END;
	$$;

CALL GetArtistTotalValue('James Ensor');

--Write a stored procedure GetAveragePriceBySubject(subject_name) that calculates the 
--average artwork price for a given subject.
	CREATE OR REPLACE PROCEDURE GetAveragePriceBySubject(subject_name TEXT)
	LANGUAGE plpgsql
	AS $$
	DECLARE
	    average_price NUMERIC(15,2);
	BEGIN
	    -- average sale value for a given subject
	    SELECT AVG(ps.sale_price)
	    INTO average_price
	    FROM artdb.works w
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
		JOIN artdb.subject s ON w.work_id = s.work_id
	    WHERE s.subject ILIKE subject_name;
	
	    --when artist has no recorded sales
	    IF average_price IS NULL THEN
	        RAISE NOTICE 'No recorded average price for subject: %', subject_name;
	    ELSE
	        RAISE NOTICE 'Average value for %: $%', subject_name, average_price;
	    END IF;
	END;
	$$;

CALL GetAveragePriceBySubject('Portraits');

--Create a procedure GetArtworksByYearRange(start_year, end_year) to list artworks created between two years.
	DROP FUNCTION GetArtworksByYearRange(
    p_start_year INT,
    p_end_year INT
)
	
	CREATE OR REPLACE FUNCTION GetArtworksByYearRange(
    p_start_year INT,
    p_end_year INT
	)
	RETURNS TABLE (
	    work_id INT,
		artwork_name VARCHAR(255),
		art_style VARCHAR(100),
		artist_birth INT,
		artist_death INT
	)
	LANGUAGE plpgsql
	AS $$
	BEGIN
	    RETURN QUERY
	    SELECT w.work_id, w.name AS artwork_name, w.art_style, a.birth AS artist_birth, a.death AS artist_death
	    FROM artdb.works w
	    JOIN artdb.artists a ON w.artist_id = a.artist_id
	    --WHERE a.birth <= p_end_year  AND (a.death IS NULL OR a.death >= p_start_year) 
		WHERE a.birth >= p_start_year AND a.death <= p_end_year
	    ORDER BY a.birth;
	END;
	$$;
SELECT * FROM GetArtworksByYearRange(1820, 1900);

--Write a procedure UpdateArtworkPrice(artwork_id, new_price) that updates the price of an artwork.
	CREATE OR REPLACE PROCEDURE UpdateArtworkPrice(
	    p_artwork_id INT,
	    p_new_price NUMERIC
	)
	LANGUAGE plpgsql
	AS $$
	BEGIN
	    UPDATE sales_data.product_size
	    SET sale_price = p_new_price
	    WHERE work_id = p_artwork_id;
	END;
	$$;
	
	CALL UpdateArtworkPrice(160228, 90);

--Create a procedure AddNewArtist(name, country, birth_year) that inserts a new record into the artist table.
	CREATE OR REPLACE PROCEDURE AddNewArtist(
	    p_artist_id INT,
		p_full_name TEXT,
		p_first_name TEXT,
		p_last_name TEXT,
		p_nationality TEXT,
		p_style TEXT,
		p_birth INT,
		p_death INT,
		p_era VARCHAR(50)
	)
	LANGUAGE plpgsql
	AS $$
	BEGIN
	   INSERT INTO artdb.artists(artist_id,full_name,first_name,last_name, nationality, style,birth,death,era)
	   VALUES(p_artist_id, p_full_name,p_first_name,p_last_name, p_nationality, p_style,p_birth,p_death,p_era);
	END;
	$$;

	CALL AddNewArtist(921,'Phil kim', 'phil', 'kim','Kenyan','Impressionist',1910, 2020, '' );
	
--Write a procedure DeleteArtwork(artwork_id) that removes an artwork and related references.
	CREATE OR REPLACE PROCEDURE  DeleteArtwork(artwork_id INT)
	LANGUAGE plpgsql
	AS $$
	BEGIN
		DELETE FROM artdb.image_link
		WHERE work_id = artwork_id;
		
		DELETE FROM sales_data.product_size
		WHERE work_id = artwork_id;
		
		DELETE FROM artdb.subject
		WHERE work_id = artwork_id;
		
		DELETE FROM artdb.works
		WHERE work_id = artwork_id;
		
		RAISE NOTICE 'Artwork ID % and related records have been deleted.', artwork_id;
	END;
	$$;
	
	CALL DeleteArtwork(160228);

--Create a procedure GetArtistMuseumCount(artist_name) that counts how many museums host artworks by a given artist.
	CREATE OR REPLACE FUNCTION GetArtistMuseumCount(p_artist_name TEXT)
		RETURNS INT
	LANGUAGE plpgsql
	AS $$
		DECLARE	museum_count INT;
	BEGIN
		SELECT COUNT(DISTINCT w.museum_id)
		INTO museum_count
		FROM artdb.works w
		JOIN select * from artdb.artists a ON w.artist_id = a.artist_id
		WHERE a.full_name = p_artist_name;		
		RETURN museum_count;
	END;
	$$;
	SELECT GetArtistMuseumCount('Thomas Cole');

--Write a procedure ListArtistsAboveAvgValue() that lists all artists whose total artwork price is above average.
	CREATE OR REPLACE FUNCTION ListArtistsAboveAvgValue()
	RETURNS TABLE (artist_name VARCHAR(255), total_value NUMERIC)
	LANGUAGE plpgsql
	AS $$
	BEGIN
	    RETURN QUERY
	    WITH ArtistTotals AS (
	        SELECT a.artist_id, a.full_name, SUM(ps.sale_price) AS total_value
	        FROM artdb.artists a
	        JOIN artdb.works w ON a.artist_id = w.artist_id
	        JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	        WHERE ps.sale_price IS NOT NULL
	        GROUP BY a.artist_id, a.full_name
	    ),
	    avg_total AS (
	        SELECT AVG(ArtistTotals.total_value) AS avg_value FROM ArtistTotals
	    )
	    SELECT ArtistTotals.full_name, ArtistTotals.total_value
	    FROM ArtistTotals, avg_total
	    WHERE ArtistTotals.total_value > avg_total.avg_value
	    ORDER BY ArtistTotals.total_value DESC;
	END;
	$$;
	SELECT * FROM ListArtistsAboveAvgValue();

--Write a procedure GetMuseumRevenue(museum_name) that sums the total price of all artworks in that museum.
	CREATE OR REPLACE FUNCTION GetMuseumRevenue(p_museum_name TEXT)
	RETURNS NUMERIC
	LANGUAGE plpgsql
	AS $$
	DECLARE artworks_total NUMERIC;
	BEGIN
	    SELECT SUM(ps.sale_price)
	    INTO artworks_total
	    FROM artdb.museums m
	    JOIN artdb.works w ON m.museum_id = w.museum_id
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    WHERE m.name = p_museum_name;
	
	    RETURN COALESCE(artworks_total, 0);
	END;
	$$;
	SELECT GetMuseumRevenue('Army Museum');

--Create a procedure GetArtworksByCanvasSize(min_height, min_width) to return artworks exceeding those dimensions.
   CREATE OR REPLACE FUNCTION GetArtworksByCanvasSizeFn(
	    p_min_height INT,
	    p_min_width INT
   )
	RETURNS TABLE (
	    work_id INT,
	    artwork_name VARCHAR(255),
	    canvas_label VARCHAR(100),
	    height INT,
	    width INT
	)
	LANGUAGE plpgsql
	AS $$
	BEGIN
	    RETURN QUERY
	    SELECT w.work_id, w.name, c.label, c.height, c.width
	    FROM artdb.works w
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    JOIN artdb.canvas_size c ON ps.size_id = c.size_id
	    WHERE c.height > p_min_height AND c.width > p_min_width;
	END;
	$$;

SELECT * FROM GetArtworksByCanvasSizeFn(15, 22);

--Write a procedure GetTopSubjectByArtist(artist_name) to find the most frequent subject associated
--with that artist’s works.
	CREATE OR REPLACE FUNCTION GetTopSubjectByArtist(p_artist_name TEXT)
		RETURNS TABLE (
		subject VARCHAR(255),
		subject_count bigint
		)
	LANGUAGE plpgsql
	AS $$
	BEGIN
		RETURN QUERY
		SELECT s.subject, COUNT(*) AS subject_count
		FROM artdb.subject s
		JOIN artdb.works w ON s.work_id = w.work_id
		JOIN select * from artdb.artists a ON w.artist_id = a.artist_id
		WHERE a.full_name = p_artist_name
		GROUP BY s.subject
		ORDER BY subject_count DESC
		LIMIT 1;
	END;
	$$;

 SELECT * FROM GetTopSubjectByArtist('Peter Monamy');

--Write a procedure GetCountryArtStats(country_name) that summarizes (count, avg price, max price)
--for all artworks from that country’s artists.
	CREATE OR REPLACE FUNCTION GetCountryArtStats(country_name TEXT)
	RETURNS TABLE (
	    total_artworks BIGINT,
	    avg_sale_price NUMERIC,
	    max_sale_price NUMERIC
	)
	LANGUAGE sql
	AS $$
	     SELECT 
	        COUNT(ps.work_id) AS total_artworks,
	        AVG(ps.sale_price) AS avg_sale_price,
	        MAX(ps.sale_price) AS max_sale_price
	    FROM artdb.works w
	    JOIN artdb.artists a ON w.artist_id = a.artist_id
	    JOIN sales_data.product_size ps ON w.work_id = ps.work_id
	    JOIN artdb.museums m ON w.museum_id = m.museum_id
	    WHERE m.country = country_name
	    GROUP BY m.museum_id, m.name
	    ORDER BY total_artworks DESC;
	$$;
	
	SELECT * FROM GetCountryArtStats('France');



