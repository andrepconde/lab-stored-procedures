# Lab - Stored procedures
USE sakila;

# Write queries, stored procedures to answer the following questions:

# In the previous lab we wrote a query to find first name, last name, 
# and emails of all the customers who rented Action movies. 
# Convert the query into a simple stored procedure. 



  select first_name, last_name, email
  from customer
  join rental on customer.customer_id = rental.customer_id
  join inventory on rental.inventory_id = inventory.inventory_id
  join film on film.film_id = inventory.film_id
  join film_category on film_category.film_id = film.film_id
  join category on category.category_id = film_category.category_id
  where category.name = "Action"
  group by first_name, last_name, email;
  
DELIMITER //
create procedure action_mov (out param1 int) 
begin
select first_name, last_name, email
  from customer
  join rental on customer.customer_id = rental.customer_id
  join inventory on rental.inventory_id = inventory.inventory_id
  join film on film.film_id = inventory.film_id
  join film_category on film_category.film_id = film.film_id
  join category on category.category_id = film_category.category_id
  where category.name = "Action"
  group by first_name, last_name, email;
end //
DELIMITER ;


# Now keep working on the previous stored procedure to make it more dynamic.
# Update the stored procedure in a such manner that it can take a string argument 
# for the category name and return the results for all customers that 
# rented movie of that category/genre. For eg.,  it could be action, animation, children, classics, etc.

DELIMITER //
CREATE PROCEDURE film_cat (IN category_name VARCHAR(255), OUT param1 INT)
BEGIN
    SET @query = CONCAT('SELECT first_name, last_name, email
                        FROM customer
                        JOIN rental ON customer.customer_id = rental.customer_id
                        JOIN inventory ON rental.inventory_id = inventory.inventory_id
                        JOIN film ON film.film_id = inventory.film_id
                        JOIN film_category ON film_category.film_id = film.film_id
                        JOIN category ON category.category_id = film_category.category_id
                        WHERE category.name = "', category_name, '"
                        GROUP BY first_name, last_name, email;');
                        
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

CALL film_cat('Animation', @param1);

CALL film_cat('Children', @param1);

SELECT *
FROM film as F
JOIN film_category as FC
ON F.film_id = FC.film_id
JOIN category as C
ON FC.category_id = C.category_id
WHERE C.name = "Action";

# Write a query to check the number of movies released in each movie category. 
# Convert the query in to a stored procedure to filter only those categories that 
# have movies released greater than a certain number. 
# Pass that number as an argument in the stored procedure.

SELECT C.name, COUNT(F.film_id) AS num_of_mov
FROM film as F
JOIN film_category as FC
ON F.film_id = FC.film_id
JOIN category as C
ON FC.category_id = C.category_id
GROUP BY C.name;

DELIMITER //
CREATE PROCEDURE filter_categories(IN min_movies INT)
BEGIN
    SELECT C.name, COUNT(F.film_id) AS num_of_mov
    FROM film AS F
    JOIN film_category AS FC ON F.film_id = FC.film_id
    JOIN category AS C ON FC.category_id = C.category_id
    GROUP BY C.name
    HAVING COUNT(F.film_id) > min_movies;
END //
DELIMITER ;


CALL filter_categories(70);
