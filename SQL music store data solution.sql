--Who is the senior most employee based on jon title?

select *
from employee
order by levels desc
limit 1;


--which countries has most invoices

select billing_country, count(*) as total_invoices
from invoice
group by billing_country
order by total_invoices desc;


--what are top 3 values of total invoice

select * 
from invoice
order by total desc
limit 3;

--which city has best customer? we would like to throw a promotional music festival in the city we made the most money
--write a query that returns one city that has the highest sum of invoice totals.Return both city name and sum of all invoice total

select billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc;


--who is the best customer? The customer who has spent the most money will be declared the best customer.
--write a query that returns the person who has spent the most money.

select c.first_name as first_name, c.last_name as last_name, sum(i.total) total_spent  
from customer as c
join invoice as i
	on c.customer_id = i.customer_id
group by c.first_name, c.last_name
order by total_spent desc
limit 1;






--write a query to return the email, first name, last name & genre of all Rock Music Listeners.Return your list 
--ordered alphabetically by email starting with A

select distinct c.first_name , c.last_name, c.email, g.name
from customer as c
join invoice as i
	on c.customer_id = i.customer_id
join invoice_line as il
	on i.invoice_id = il.invoice_id
join track as t
	on il.track_id = t.track_id
join genre as g
	on t.genre_id = g.genre_id
where g.name = 'Rock' 
order by email
;


--let's invite the artist who have written the most rock music in our dataset. write a query that returns the Artist name
-- and total track count of the top 10 rock bands

select
	ar.artist_id,ar.name as artist_name, count(g.name) as total_rock_band 
from artist  as ar
join album as al
	on ar.artist_id = al.artist_id
join track as t
	on al.album_id = t.album_id 
join genre as g
	on t.genre_id = g.genre_id
where g.name = 'Rock'
group by ar.artist_id
order by total_rock_band desc
limit 10;



--Return all the track names that have a song length longer than the average song length. Return the name and millisecond 
--for each track. Order by the song length with the longest song listed first 	

select * from track;

 
select 
	name, milliseconds
from track
where milliseconds >(select
					 avg(milliseconds) as avg_length
					 from track)
order by milliseconds desc;












--Find how much amount spent by each customer on artist? write a query to return customer name,artist name and total spent


with cte as(
select ar.artist_id,ar.name , sum(il.unit_price * il.quantity) as total_spent
from invoice_line as il
join track as t	
		on il.track_id = t.track_id
join album as al
		on al.album_id = t.album_id
join artist as ar
		on ar.artist_id = al.artist_id
group by 1
order by total_spent desc
limit 1)

select	
	c.first_name, c.last_name , ar.name as artist_name, sum(il.unit_price * il.quantity) as total_spent 
from customer as c
join invoice as i
	on c.customer_id = i.customer_id
join invoice_line as il
	on i.invoice_id = il.invoice_id
join track as t
	on il.track_id = t.track_id
join album as al
	on t.album_id = al.album_id
join artist as ar
	on al.artist_id = ar.artist_id
join cte as c1
	on ar.artist_id = c1.artist_id
group by 1,2,3
order by total_spent desc;



--we want to find out the most popular music genre for each country we determine the most popular genre as the genre with the 
--highest amount of purchase. write a query that returns each country along with the top genre. For countries where maximum
--number of purchases is shared return all genres.

with cte as (
select
	c.country, count(il.quantity) as purchase, g.name, g.genre_id ,
	row_number()over(partition by c.country order by count(il.quantity) desc) as rnk
from customer as c
join invoice as i 
	on c.customer_id = i.customer_id
join invoice_line as il
	on i.invoice_id = il.invoice_id
join track as t
	on il.track_id = t.track_id 
join genre as g
	on t.genre_id = g.genre_id
group by 1,3,4)
select 
	country, purchase, name, genre_id
from cte
where rnk = 1;



--write a query that determines the customer that has spent the most on music for each country. Write a query that returns the 
-- country along with the top customer and how much they spent. For countries where the top amount 	spent is shared
--, provide all customers who spent this amount

with cte as (
select
	c.customer_id,c.first_name, c.last_name, i.billing_country, sum(i.total) as total_spent,
	row_number()over(partition by i.billing_country order by sum(i.total) desc) as rnk
from customer as c
join invoice as i
	on c.customer_id = i.customer_id
group by 1,2,3,4
order by 5 desc)
select customer_id, first_name, last_name, billing_country, total_spent
from cte
where rnk = 1
order by billing_country asc;







