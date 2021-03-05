-- Lab | SQL Subqueries
USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM film;
SELECT count(i.inventory_id) FROM inventory i
JOIN film f 
ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average of all the films.
SELECT title, length FROM film
WHERE length > 
	(SELECT avg(length) FROM film)
ORDER BY length ASC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.first_name, a.last_name FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f on fa.film_id = f.film_id
WHERE f.title = 'Alone Trip';

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, cat.name FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Family'
;

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary 
-- keys and foreign keys, that will help you get the relevant information.

SELECT cust.first_name, cust.last_name, cust.email, cust.address_id, co.country FROM customer cust
JOIN address a ON cust.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.city_id = co.country_id
WHERE co.country = 'Canada';

SELECT * FROM (
SELECT first_name, last_name, email, cust.address_id, co.country_id , country FROM customer cust
JOIN address a ON cust.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.city_id = co.country_id
) sub1
WHERE country = 'Canada'
GROUP BY country;

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the 
-- actor that has acted in the most number of films. First you will have to find the most prolific
-- actor and then use that actor_id to find the different films that he/she starred.
SELECT fa.actor_id, a.first_name, a.last_name, count(fa.film_id) FROM film_actor fa
JOIN actor a ON a.actor_id = fa.actor_id
GROUP BY fa.actor_id
ORDER BY count(fa.film_id) DESC 
LIMIT 1; -- most prolific actor with count(fa.film_id) = 42

SELECT fa.actor_id FROM film_actor fa
JOIN actor a ON a.actor_id = fa.actor_id
GROUP BY fa.actor_id
ORDER BY count(fa.film_id) DESC 
LIMIT 1; -- most prolific actor (only actor_id)

SELECT f.film_id, f.title FROM film f 
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE actor_id = 107; -- hard coding (bingo: 42 rows returned)

SELECT f.film_id, f.title FROM film f 
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE actor_id = (
	SELECT fa.actor_id FROM film_actor fa
	JOIN actor a ON a.actor_id = fa.actor_id
	GROUP BY fa.actor_id
	ORDER BY count(fa.film_id) DESC 
	LIMIT 1) ;


-- 7. Films rented by most profitable customer. You can use the customer table and payment table
-- to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT pay.customer_id -- , sum(pay.amount) 
FROM payment pay
GROUP BY pay.customer_id
ORDER BY sum(pay.amount) DESC
LIMIT 1; -- (most profitable customer)

SELECT * FROM rental r
WHERE r.customer_id = 526; -- hard coding to know the answer and check it later

SELECT r.rental_id, f.title FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id 
WHERE r.customer_id = 526; -- film titles borrowed by most profitable customer (same result as the query above)

SELECT r.rental_id, f.title FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id 
WHERE r.customer_id = (    -- here we insert the first query of the question to replace customer_id 526
	SELECT pay.customer_id FROM payment pay
	GROUP BY pay.customer_id
	ORDER BY sum(pay.amount) DESC
	LIMIT 1);


-- 8. Customers who spent more than the average payments.
use sakila;
select * from payment;
SELECT pay.customer_id, sum(pay.amount) as payment_total FROM payment pay
GROUP BY pay.customer_id; -- amount paid by customer

SELECT pay.customer_id, sum(pay.amount) as payment_total FROM payment pay
WHERE pay.customer_id = 1
GROUP BY pay.customer_id;