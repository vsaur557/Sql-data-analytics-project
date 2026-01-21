--Q1 - Who is the senior most employee based on job title ?

select * from employee
order by levels Desc
 limit 1;

--Q2 - which countries have the most invoce ?

 Select count(*) as c , billing_country
 from invoice
 group by billing_country
 order by c Desc;

--Q3 - what are top 3 value of total invoice?
 select * from invoice
 order by total Desc
 limit 3 ;

--Q4 which city has the best customers? We would like to throw a promotinal Music festival in the city 
--made the msot money .write a query that returns one city that has the highest sum of invoce totlas Return
--bith only the city name & sum of all invoice totals?
 
  select sum(total) as Total_invoice, billing_country
  from invoice
  group by billing_country
  order by Total_invoice Desc
  limit 1;
  
 --Q5 who is the best country ? the costomer who has spent the most money will
 --be declared the best customer .Write a query that returns the person who has 
 --spent the most money.
   select customer.customer_id,
            customer.first_name,
            customer.last_name,
            Sum(invoice.total) as total
    from customer
    join invoice ON customer.customer_id = invoice.customer_id
    group by customer.customer_id
    order by total Desc
    limit 1 ;
       
--Q6 write query to rturn the email, frist name, lastname,& ganre of all Rock Music listeners. 
--Returne your list orderd alphabetically by email starting with A.
  SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice 
  ON customer.customer_id = invoice.customer_id
JOIN invoice_line 
  ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id
    FROM track
    JOIN genre 
      ON track.genre_id = genre.genre_id
    WHERE genre.name = 'Rock'
)
ORDER BY email;

--Q7 let's invite the aritsts who have written the most rock music in our dataset .
--write a qury that query that return the Arist name and total track count of the top
--10 rock bands.
Select artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
from track 
Join album On album.album_id = track.album_id
Join artist On artist.artist_id = album.artist_id
JOIN genre on genre.genre_id = track.genre_id
Where genre.name like 'Rock'
Group by artist.artist_id
Order by number_of_songs Desc
Limit 10;

--Q8 Return all the track names that have a song length . Return the name and millisconds 
--for each track oreder by the song length with the lingest songs listed frist.
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;

--Q9 Find how much amount spent by each customers on artist ? Write a Query to return customer name,
--artist name and total spent.
WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id,
           artist.name AS artist_name,
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track 
      ON track.track_id = invoice_line.track_id
    JOIN album 
      ON album.album_id = track.album_id
    JOIN artist 
      ON artist.artist_id = album.artist_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)

SELECT c.customer_id,
       c.first_name,
       c.last_name,
       bsa.artist_name,
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Q10 We want to find out the most popular music genre for each country we determine the most
--popular genre as the genre with the higtest amount of purchases. write query that returns each country along with 
--the top genre. for countries where the moxium number of purchase is shared return all Genres.

 WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchase,
        customer.country,
        genre.name,
        genre.genre_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer.country 
            ORDER BY COUNT(invoice_line.quantity) DESC
        ) AS RowNo
    FROM invoice_line
    JOIN invoice 
      ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer 
      ON customer.customer_id = invoice.customer_id
    JOIN track 
      ON track.track_id = invoice_line.track_id
    JOIN genre 
      ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC, 1 DESC
)

SELECT *
FROM popular_genre
WHERE RowNo <= 1;
