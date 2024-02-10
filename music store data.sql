use music_data_store;

-- Who is the senior most employee based on job title?
select *from employee
order by levels limit 1;

-- Which countries have the most Invoices?
select billing_country, Count(total) as most_invoices from invoice
group by billing_country
order by most_invoices desc;

-- What are top 3 values of total invoice?
select total from invoice
order by total desc limit 3;

/* Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals */ 
select billing_city, Sum(total) as All_invoice from invoice 
group by billing_city 
order by All_invoice desc limit 1;

/*Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money
*/
select customer.customer_id, Sum(invoice.total) as top_customer from customer inner join invoice 
on customer.customer_id = invoice.customer_id
group by invoice.customer_id
order by top_customer desc limit 1;

-- MEDIUM
/*Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A
*/
select distinct c.email, c.first_name, c.last_name from customer c
inner join invoice i on c.customer_id = i.customer_id
inner join invoice_line i_l on i.invoice_id = i_l.invoice_id
where track_id in (
	select track_id from track inner join genre 
    On genre.genre_id = track.genre_id and genre.name like "Rock"
	)
order by c.email asc;
-- OR
select distinct c.email, c.first_name, c.last_name, g.name from customer c, invoice i, invoice_line il, track t, genre g
where c.customer_id = i.customer_id and i.invoice_id=il.invoice_id 
and g.genre_id=t.genre_id and t.track_id = il.track_id and g.name like "Rock"
order by c.email; 

/*Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/
select artist.name, count(t.track_id) as total from track t 
inner join album on t.album_id = album.album_id
inner join artist on album.artist_id = artist.artist_id
join genre on t.genre_id = genre.genre_id where genre.name  like "Rock"
group by artist.name
order by total desc; 

select artist.artist_id, artist.name, count(artist.artist_id) as total from track t 
inner join album on t.album_id = album.album_id
inner join artist on album.artist_id = artist.artist_id
join genre on t.genre_id = genre.genre_id where genre.name  like "Rock"
group by artist.name, artist.artist_id
order by total desc; 

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

/*Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first*/
select name , milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- Advanced
/*Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/
select *from invoice_line;
with best_selling_artist as(
	select artist.artist_id as artist_id, artist.name artist_name, sum(il.unit_price*il.quantity) as sales 
    from invoice_line il
    inner join track on  track.track_id = il.track_id
    inner join album on album.album_id = track.album_id
    inner join artist on artist.artist_id = album.artist_id
    group by 1,2
    order by 3 desc limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/*We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres*/
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	Rank() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/*Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount*/
with top_countries as (
	select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country,
    sum(total) as total_spending,
	rank() over (partition by invoice.billing_country order by sum(total) desc) as rank_no
	from invoice
	JOIN customer on invoice.customer_id = customer.customer_id
	group by 1,2,3,4
	order by 4 asc
    )
select * from top_countries where rank_no<=1;

























