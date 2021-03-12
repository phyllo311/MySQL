use mavenmovies;

SELECT
	customer_id,
	rental_date
FROM rental;

SELECT
	first_name,
    last_name,
    email
FROM customer;

SELECT *
	FROM film;

SELECT
	rating
FROM film;

SELECT distinct
	rating
FROM film;

-- ASSIGNMT 2
SELECT *
FROM film;

SELECT distinct
	rental_duration
FROM film;

SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE payment_date > '2006-01-01';

-- ex 3

SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id <= 100;
-- WHERE customer_id BETWEEN 1 AND 100;
-- WHERE customer_id < 101;

SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE amount = 0.99
	AND payment_date > '2006-01-01';
    
-- ex 4
SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE amount > 5
	AND customer_id <= 100
	AND payment_date > '2006-01-01';
    
-- WHERE & OR
SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id = 5
	OR customer_id = 11
    OR customer_id = 29;
    
-- ex 5
SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE amount > 5
	or customer_id = 42
	OR customer_id = 53
    OR customer_id = 60
    OR customer_id = 73;
    
-- WHERE & IN
SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE amount > 5
	or customer_id IN (42,53,60,73);
    
SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id IN (5,11,29);

-- WHERE & LIKE
SELECT
	title,
    description
FROM film
WHERE title NOT LIKE '_LADDIN CALENDA_';

SELECT
	title,
    description
FROM film
WHERE description LIKE '%Epic%';

SELECT
	title,
    description
FROM film
WHERE description LIKE '_Epic_';

-- ex 6
SELECT
	title,
    special_features
FROM film
WHERE special_features LIKE '%Behind the Scenes%';

-- GROUP BY

SELECT
	rating,
    COUNT(film_id)
FROM film
GROUP BY
	rating; -- metrics / dim aggreation as pivot
    
-- THIS is a comment
/* this is also a comment */

SELECT
	rating,
    -- COUNT(film_id),
    COUNT(film_id) AS films_with_this_rating -- create new col w name changed
FROM film
GROUP BY
	rating; -- same results

-- ex 7
SELECT
	title,
	rental_duration,
    COUNT(film_id) AS films_with_this_rental_duration
FROM film
GROUP BY
	rental_duration;
    
-- GROUP BY multiple dim
SELECT
	rating,
    rental_duration,
    replacement_cost,
    COUNT(film_id) AS count_of_films
FROM film
GROUP BY
	rating,
    rental_duration,
    replacement_cost;
    
-- GROUP BY W AGG FUNCN
SELECT
	rating,
    COUNT(film_id) AS count_of_films,
    min(length) AS shortest_film,
    max(length) AS longest_film,
    AVG(length) AS average_length_film,
    SUM(length) AS total_minutes,
    avg(rental_duration) AS avg_rental_duration
FROM film
GROUP BY
	rating;
    
-- EX 8
SELECT
	replacement_cost,
    COUNT(film_id) AS number_of_film,
    MIN(rental_rate) AS cheapest_rental,
    max(rental_rate) AS most_exps_rental,
    avg(rental_rate)
FROM film
GROUP BY
	replacement_cost;
    
-- HAVING
SELECT
	customer_id,
    COUNT(*) AS total_rental
FROM rental
GROUP BY
	customer_id
HAVING COUNT(*) >= 30;
 
 -- ex 9
 SELECT
	customer_id,
    COUNT(rental_id) AS total_rental
FROM rental
GROUP BY
	customer_id
HAVING COUNT(rental_id) < 15;

-- ORDER
SELECT
	customer_id,
    SUM(amount) AS tol_pmt_amt
FROM payment
GROUP BY
	customer_id
ORDER BY
	sum(amount) desc;
    
-- ex 10
SELECT
	title,
    rental_rate,
    length
FROM film
GROUP BY
	title
ORDER BY length desc;

-- CASE STATEMENT
SELECT distinct
	length,
    CASE
		WHEN length < 60 THEN 'under 1 hr'
        WHEN length BETWEEN 60 and 90 THEN '1-1.5 hrs'
        WHEN length > 90 THEN 'over 1.5 hrs'
        ELSE 'check logic'
	END As length_bucket
FROM film;

SELECT distinct
	title,
CASE -- classificaN.
	WHEN rental_duration <= 4 THEN "rental_too_short"
    WHEN rental_rate >= 3.99 THEN "too_expensive"
    WHEN rating IN ('NC-17', 'R') THEN "too_adult"
    WHEN length NOT BETWEEN 60 AND 90 THEN "too_short_or_too_long"
    WHEN description LIKE "%Shark%" THEN "nope_has_sharks"
    ELSE "great_reco_for_my_niece"
    END AS fit_for_rec,
CASE -- classificaN.
	WHEN description LIKE "%Shark%" THEN "nope_has_shark"
    WHEN length NOT BETWEEN 60 AND 90 THEN "too_short_or_too_long"
    WHEN rating IN ('NC-17', 'R') THEN "too_adult"
    WHEN rental_duration <= 4 THEN "rental_too_short"
    WHEN rental_rate >= 3.99 THEN "too_expensive"
    ELSE "great_reco_for_my_niece"
END AS reordered_reco
FROM film;

-- ex 11
SELECT
	customer_id,
    first_name,
    last_name,
CASE
	WHEN store_id = 1 AND active = 1 THEN "store 1 active"
    WHEN store_id = 1 AND active = 0 THEN "store 1 inactive"
    WHEN store_id = 2 AND active = 1 THEN "store 2 active"
    ELSE "store 2 inactive"
END AS store_and_status
FROM customer;

-- PIVOTING W COUNT & CASE (count n0. items in location)
SELECT
	inventory_id,
    COUNT(CASE WHEN store_id = 1 THEN inventory_id ELSE NULL END) AS count_of_store_1_inv,
    COUNT(CASE WHEN store_id = 2 THEN inventory_id ELSE NULL END) AS count_of_store_2_inv
FROM inventory
GROUP BY
	inventory_id
ORDER BY
	inventory_id;
    
SELECT
	film_id,
    COUNT(CASE WHEN store_id = 1 THEN inventory_id ELSE NULL END) AS count_of_store_1_inv,
    COUNT(CASE WHEN store_id = 2 THEN inventory_id ELSE NULL END) AS count_of_store_2_inv
FROM inventory
GROUP BY
	film_id
ORDER BY
	film_id;
    
-- ex 12
SELECT
store_id,
count(CASE WHEN active = 1 THEN customer_id ELSE NULL END) AS active,
count(CASE WHEN active = 0 THEN customer_id ELSE NULL END) AS inactive
FROM customer
GROUP BY
	store_id;

-- JOIN
SELECT distinct
	inventory.inventory_id
FROM inventory
	INNER JOIN rental
    ON inventory.inventory_id = rental.inventory_id
LIMIT 5000;

-- ex 13
SELECT
	film.title,
    film.film_id,
    film.description,
    inventory.store_id -- call diff. table cols
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id;

-- solution
SELECT
	inventory_id,
    store_id,
    film.title,
    film.description
FROM inventory
	INNER JOIN film
    ON film.film_id = inventory.film_id;

-- LEFT JOIN
SELECT
	actor.first_name,
    actor.last_name,
    COUNT(film_actor.film_id) AS number_of_films
FROM actor
	LEFT JOIN film_actor
		ON actor.actor_id = film_actor.actor_id
GROUP BY
	actor.first_name,
    actor.last_name;

-- ex 14
SELECT
	film.film_id,
    film.title,
    COUNT(film_actor.actor_id) AS actors_in_film
FROM film
	LEFT JOIN film_actor
    ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- LEFT vs INNER vs RIGHT JOIN
SELECT
	actor.actor_id,
    actor.first_name AS actor_first,
    actor.last_name AS actor_last,
    actor_award.first_name AS award_first,
    actor_award.last_name AS award_last,
    actor_award.awards
FROM actor
	LEFT JOIN actor_award
    ON actor.actor_id = actor_award.actor_id
    ORDER BY actor_id;
    
SELECT
	actor.actor_id,
    actor.first_name AS actor_first,
    actor.last_name AS actor_last,
    actor_award.first_name AS award_first,
    actor_award.last_name AS award_last,
    actor_award.awards
FROM actor
	INNER JOIN actor_award
    ON actor.actor_id = actor_award.actor_id
    ORDER BY actor_id;
    
SELECT
	actor.actor_id,
    actor.first_name AS actor_first,
    actor.last_name AS actor_last,
    actor_award.first_name AS award_first,
    actor_award.last_name AS award_last,
    actor_award.awards
FROM actor
	RIGHT JOIN actor_award
    ON actor.actor_id = actor_award.actor_id
    ORDER BY actor_id;

-- FULL OUTER JOIN
-- snowflake schema, join 2 tables without common col
-- 3rd table serves as bridge
SELECT
	film.film_id,
    film.title,
    category.name AS category
FROM film
	INNER JOIN film_category
    ON film.film_id = film_category.film_id
    INNER JOIN category
    ON film_category.category_id = category.category_id;

-- ex 15
SELECT
	actor.first_name,
    actor.last_name,
    film.title
FROM actor
INNER JOIN film_actor
ON film_actor.actor_id = actor.actor_id
INNER JOIN film
ON film_actor.film_id = film.film_id;

-- Multicondition joins
SELECT
	film.film_id,
    film.title,
    film.rating,
    category.name
    
FROM film
	INNER JOIN film_category
    ON film.film_id = film_category.film_id
    INNER JOIN category
    ON film_category.category_id = category.category_id
WHERE category.name = "horror"
ORDER BY film_id;

-- alternative
SELECT
	film.film_id, film.title, film.rating,
    category.name
FROM film
	INNER JOIN film_category
		ON film.film_id = film_category.film_id
	INNER JOIN category
		ON film_category.category_id = category.category_id
        AND category.name = "horror"
ORDER BY film_id;

-- ex 15
SELECT distinct
	film.title,
	film.description,
    inventory.store_id
FROM film
INNER JOIN inventory
ON inventory.film_id = film.film_id
AND inventory.store_id = 2;

-- UNION
SELECT
	'advisor' AS type,
    first_name,
    last_name
FROM advisor
UNION
SELECT
	'investor' AS type,
    first_name,
    last_name
FROM investor;

-- ex 16
SELECT
	'advisor' AS type,
    first_name,
    last_name
FROM advisor
UNION
SELECT
	'staff' AS type,
    first_name,
    last_name
FROM staff;