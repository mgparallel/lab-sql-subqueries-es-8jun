USE sakila;
-- 1. ¿Cuántas copias de la película El Jorobado Imposible existen en el sistema de inventario?
SELECT 
	copy.title,
    copy.copy_num
FROM (
	SELECT
		f.title,
        COUNT(iv.inventory_id) AS copy_num
	FROM film f
    LEFT JOIN inventory iv ON (f.film_id = iv.film_id)
    WHERE f.title = 'HUNCHBACK IMPOSSIBLE'
    GROUP BY f.title
) AS copy
;

-- 2. Lista todas las películas cuya duración sea mayor que el promedio de todas las películas.
SELECT 
		title,
        length
FROM film
WHERE 
	length > (SELECT AVG(length) FROM film)
;

-- 3. Usa subconsultas para mostrar todos los actores que aparecen en la película Viaje Solo.
SELECT *
FROM (
	SELECT 
		ac.first_name,
        ac.last_name
	FROM film f
    JOIN film_actor fc USING (film_id)
    JOIN actor ac USING (actor_id)
    WHERE f.title = 'ALONE TRIP'
) AS actor_lt
;

-- 4. Las ventas han estado disminuyendo entre las familias jóvenes, y deseas dirigir todas las películas familiares a una promoción.
-- Identifica todas las películas categorizadas como películas familiares.
SELECT * 
FROM (
	SELECT 
		f.title
	FROM film f
    JOIN film_category fc USING (film_id)
    JOIN category ca USING (category_id)
    WHERE ca.name = 'Family'
) AS category_table
;

-- 5. Obtén el nombre y correo electrónico de los clientes de Canadá usando subconsultas. Haz lo mismo con uniones. 
-- Ten en cuenta que para crear una unión, tendrás que identificar las tablas correctas con sus claves primarias y claves foráneas, que te ayudarán a obtener la información relevante.
-- 5.1
SELECT *
FROM (
	SELECT
		cs.first_name,
        cs.last_name,
        cs.email
	FROM customer cs
    JOIN address a USING (address_id)
    JOIN city ci USING (city_id)
    JOIN country co USING (country_id)
    WHERE co.country = 'Canada'
) AS country_table
;

-- 5.2 USING UNION
SELECT
    cs.first_name,
    cs.last_name,
    cs.email
FROM customer cs
JOIN address a ON cs.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada'

UNION

SELECT
    cs.first_name,
    cs.last_name,
    cs.email
FROM customer cs
JOIN address a ON cs.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada'

UNION

SELECT
    cs.first_name,
    cs.last_name,
    cs.email
FROM customer cs
JOIN address a ON cs.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada'
;

-- 6. ¿Cuáles son las películas protagonizadas por el actor más prolífico? El actor más prolífico se define como el actor que ha actuado en el mayor número de películas. 
-- Primero tendrás que encontrar al actor más prolífico y luego usar ese actor_id para encontrar las diferentes películas en las que ha protagonizado.
SELECT
	f.title,
	ac.first_name,
	ac.last_name
FROM film f
JOIN film_actor fa USING (film_id)
JOIN actor ac USING (actor_id)
WHERE ac.actor_id IN (
	SELECT 
		actor_id
    FROM (
		SELECT
			fa.actor_id,
            COUNT(fa.actor_id) AS f_count
		FROM film_actor fa
        GROUP BY fa.actor_id
        ORDER BY COUNT(fa.actor_id) DESC
        LIMIT 1
	) AS new_t
)
;

-- 7. Películas alquiladas por el cliente más rentable. Puedes usar la tabla de clientes y la tabla de pagos para encontrar al cliente más rentable, es decir, el cliente que ha realizado la mayor suma de pagos.
SELECT 
	DISTINCT f.title,
    cs.first_name,
    cs.last_name
FROM customer cs
JOIN payment p USING (customer_id)
JOIN rental r USING (customer_id)
JOIN inventory iv USING (inventory_id)
JOIN film f USING (film_id)
WHERE cs.customer_id IN (
	SELECT
		customer_id
	FROM (
		SELECT
			p.customer_id,
            MAX(p.amount) AS most_amount
		FROM payment p
        GROUP BY p.customer_id
        LIMIT 1
	) AS new_t
);
        
-- 8. Obtén el client_id y el total_amount_spent de esos clientes que gastaron más que el promedio del total_amount gastado por cada cliente.
SELECT
	cs.customer_id,
    SUM(p.amount) AS total_amount_spent
FROM customer cs
JOIN payment p USING (customer_id)
GROUP BY cs.customer_id
HAVING SUM(p.amount) > (
	SELECT 
        AVG(amount)
	FROM payment 
)
;