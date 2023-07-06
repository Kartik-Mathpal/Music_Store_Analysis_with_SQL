SELECT * FROM ALBUM

-- Q1. Who is the senior most employee based on job title?

SELECT * FROM EMPLOYEE 
ORDER BY levels DESC
LIMIT 1;

-- Q2. Which country has the most invoices?

SELECT COUNT(invoice_id) c, billing_country FROM invoice
GROUP BY billing_country
ORDER BY C DESC;

-- Q3. What are top 3 values of total invoice?

SELECT * FROM invoice
ORDER BY total DESC
limit 3;

-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we 
-- made the most money. Write a query that returns one city that has the highest sum of invoices totals. 
-- Return both the city name and the sum of all invoices total.

SELECT billing_city, SUM(total) as Total FROM invoice
GROUP BY billing_city
ORDER BY Total DESC
Limit 1;

-- Q5. Who is the best customer? The customer who has spent the most money is the best customer.

SELECT c.customer_id, c.first_name, c.last_name, ROUND(SUM(i.total)) T FROM
customer c
JOIN invoice i
on c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY T DESC;

-- Q6. Write a query to return email, first_name, last_name, & genre of all rock music listners. return your list
-- ordered alphabetically by email starting with A.

SELECT c.customer_id, email, first_name, last_name from customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
WHERE track_id IN(
	SELECT track_id from track T
	INNER JOIN genre g
	ON t.genre_id = g.genre_id
	WHERE g.name like 'Rock'
)
ORDER BY email;

-- without sub query

SELECT c.customer_id, email, first_name, last_name from customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN genre g
ON t.genre_id = g.genre_id
WHERE g.name like 'Rock'
Order by email;


-- Q6. Lets invite the artists who have written the most rock music in our dataset. Write a query that returns the 
-- artist name and total track count of the top 10 rock bands.

SELECT a.artist_id, a.name, COUNT(t.track_id) Track_count FROM artist a
JOIN album ab
ON a.artist_id = ab.artist_id
JOIN track t
ON ab.album_id = t.album_id
JOIN genre g
ON t.genre_id = g.genre_id 
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id
ORDER BY Track_count DESC
limit 10;

-- Q7 Return all the song names that have song length longer than average song length. Return the Name and 
-- Milliseconds for each track. Order by song lenght in descreasing order.

SELECT name, milliseconds FROM track
WHERE milliseconds > (
SELECT AVG(milliseconds) as avg_length
FROM track)
ORDER BY milliseconds DESC;

-- 	Q8 Find out how much amount spent by each customer on artists? Write a query to return customer name, artist name 
-- and total spent.

SELECT c.customer_id, c.first_name, c.last_name, at.name, sum(il.unit_price*il.quantity) total_spent FROM customer c
JOIN invoice iv
ON c.customer_id = iv.customer_id
JOIN invoice_line il
ON iv.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN album ab
ON t.album_id = ab.album_id
JOIN artist at
ON ab.artist_id = at.artist_id
GROUP BY 1,2,3,4
ORDER BY total_spent DESC;

-- by using temporary table

WITH best_selling_artist AS (
	SELECT at.artist_id, at.name artist_name, SUM(il.unit_price*il.quantity) total_sales
	FROM invoice_line il
	JOIN track t
	ON il.track_id = t.track_id
	JOIN album ab
	ON t.album_id = ab.album_id
	JOIN artist at
	ON ab.artist_id = at.artist_id
	GROUP BY 1
	ORDER BY total_sales DESC
)
SELECT c.customer_id, first_name, last_name, bsa.artist_name, sum(il.unit_price*il.quantity) total_spent FROM customer c
JOIN invoice iv
ON c.customer_id = iv.customer_id
JOIN invoice_line il
ON iv.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN album ab
ON t.album_id = ab.album_id
JOIN best_selling_artist bsa
ON ab.artist_id = bsa.artist_id
GROUP BY 1,2,3,4
ORDER BY total_spent DESC;

-- Q9 We want to find the most popular music genre for each country. Most popular genre is the genre with most amount of 
-- purchases. Write a query that returns each country along with top genre. For countries where maximum number of 
-- purchases is shared return all genre.  

WITH top_genre AS(
SELECT c.country, g.name, g.genre_id, COUNT(il.quantity) total_purchases,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) desc) AS row_no 
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line  il
ON i.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN genre g
ON t.genre_id = g.genre_id
GROUP BY 1,2,3
ORDER BY c.country, total_purchases DESC
)
SELECT * FROM top_genre
WHERE row_no = 1

-- using recursive function

WITH RECURSIVE sales_per_country AS(
	SELECT COUNT(g.name) As purchase_per_genre, c.country, g.name, g.genre_id
	FROM customer c
	JOIN invoice i
	ON c.customer_id = i.customer_id
	JOIN invoice_line  il
	ON i.invoice_id = il.invoice_id
	JOIN track t
	ON il.track_id = t.track_id
	JOIN genre g
	ON t.genre_id = g.genre_id
	GROUP BY 2,3,4
	ORDER BY 2
),
top_genre_per_country AS(
	SELECT MAX(purchase_per_genre) max_genre_sales, country 
	FROM sales_per_country 
	GROUP BY country
	ORDER BY country
)
SELECT spc.* FROM sales_per_country spc
JOIN top_genre_per_country tgpc
ON spc.country =tgpc.country
WHERE spc.purchase_per_genre = tgpc.max_genre_sales

-- without recursive

WITH sales_per_country AS(
	SELECT COUNT(g.name) As purchase_per_genre, c.country, g.name, g.genre_id
	FROM customer c
	JOIN invoice i
	ON c.customer_id = i.customer_id
	JOIN invoice_line  il
	ON i.invoice_id = il.invoice_id
	JOIN track t
	ON il.track_id = t.track_id
	JOIN genre g
	ON t.genre_id = g.genre_id
	GROUP BY 2,3,4
	ORDER BY 2
),
top_genre_per_country AS(
	SELECT MAX(purchase_per_genre) max_genre_sales, country 
	FROM sales_per_country 
	GROUP BY country
	ORDER BY country
)
SELECT spc.* FROM sales_per_country spc
JOIN top_genre_per_country tgpc
ON spc.country =tgpc.country
WHERE spc.purchase_per_genre = tgpc.max_genre_sales

--Q10 Write a query that determines the customer that has spent the most on music for each country. Write a query that
-- returns the country along with top customers and how much they spend? For countries where the top amount spent is
-- shared. Provide all customers who spent this amount.

WITH country_wise_spending AS(
	SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, ROUND(SUM(i.total)) total_spend
	FROM customer c
	JOIN invoice i
	ON c.customer_id = i.customer_id 
	GROUP BY 1,2,3,4
	ORDER BY 4,5 DESC
	),
	high_spending_customers AS(
	SELECT MAX(total_spend) as top_spenders, billing_country FROM country_wise_spending
	GROUP BY 2
	)
	SELECT cws.* FROM country_wise_spending cws
	JOIN high_spending_customers hsc
	ON cws.billing_country = hsc.billing_country
	WHERE cws.total_spend = hsc.top_spenders;
	
--- Using Row number

	WITH customer_spending AS(
	SELECT c.customer_id, first_name, last_name, billing_country, ROUND(SUM(total)) total_spending,
	ROW_NUMBER () OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC)
	FROM  customer c
	JOIN invoice i
	ON c.customer_id = i.customer_id
	GROUP BY 1,2,3,4
	)
	SELECT * FROM customer_spending
	WHERE row_number = 1;
		