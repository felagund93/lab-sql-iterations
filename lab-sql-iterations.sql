# Lab | SQL Iterations

-- In this lab, we will continue working on the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals. 

### Instructions

-- Write queries to answer the following questions:

-- Write a query to find what is the total business done by each store.
SELECT st.store_id, SUM(pay.amount) AS sales_USD FROM sakila.store AS st
JOIN sakila.staff ON st.store_id= staff.store_id
JOIN sakila.rental AS r ON staff.staff_id=r.staff_id
JOIN sakila.payment AS pay ON r.rental_id = pay.rental_id
GROUP BY st.store_id;

-- Convert the previous query into a stored procedure.
DROP PROCEDURE IF EXISTS total_sales_by_store;
DELIMITER //
CREATE PROCEDURE total_sales_by_store()
BEGIN
	SELECT st.store_id, SUM(pay.amount) AS sales_USD FROM sakila.store AS st
	JOIN sakila.staff ON st.store_id= staff.store_id
	JOIN sakila.rental AS r ON staff.staff_id=r.staff_id
	JOIN sakila.payment AS pay ON r.rental_id = pay.rental_id
	GROUP BY st.store_id;
END //
DELIMITER ;

-- Convert the previous query into a stored procedure that takes the input for `store_id` and displays the *total sales for that store*.
DROP PROCEDURE IF EXISTS total_sales_by_store_2;
DELIMITER //
CREATE PROCEDURE total_sales_by_store_2(IN store INT)
BEGIN
	SELECT st.store_id, SUM(pay.amount) AS sales_USD FROM sakila.store AS st
	JOIN sakila.staff ON st.store_id= staff.store_id
	JOIN sakila.rental AS r ON staff.staff_id=r.staff_id
	JOIN sakila.payment AS pay ON r.rental_id = pay.rental_id
	GROUP BY st.store_id
    HAVING st.store_id = store;
END //
DELIMITER ;

CALL total_sales_by_store_2(1);

-- Update the previous query. Declare a variable `total_sales_value` of float type, that will store the returned result (of the total sales amount for the store).
DROP PROCEDURE IF EXISTS total_sales_by_store_3;
DELIMITER //
CREATE PROCEDURE total_sales_by_store_3(IN store INT, OUT param1 FLOAT)
BEGIN
	SELECT sales_USD INTO param1 FROM (
    SELECT st.store_id, SUM(pay.amount) AS sales_USD FROM sakila.store AS st
	JOIN sakila.staff ON st.store_id= staff.store_id
	JOIN sakila.rental AS r ON staff.staff_id=r.staff_id
	JOIN sakila.payment AS pay ON r.rental_id = pay.rental_id
	GROUP BY st.store_id
    HAVING st.store_id = store
    ) sub1 ;
END //
DELIMITER ;

-- Call the stored procedure and print the results.
CALL total_sales_by_store_3(1,@total_sales_value);
SELECT ROUND(@total_sales_value,2);

-- In the previous query, add another variable `flag`. If the total sales value for the store is over 30.000, then label it as `green_flag`, otherwise label is as `red_flag`.
DROP PROCEDURE IF EXISTS total_sales_by_store_4;
DELIMITER //
CREATE PROCEDURE total_sales_by_store_4(IN store INT, OUT param1 FLOAT, OUT param2 VARCHAR(20))
BEGIN
	DECLARE flag VARCHAR(20) DEFAULT "";
    SELECT sales_USD INTO param1 FROM (
    SELECT st.store_id, SUM(pay.amount) AS sales_USD FROM sakila.store AS st
	JOIN sakila.staff ON st.store_id= staff.store_id
	JOIN sakila.rental AS r ON staff.staff_id=r.staff_id
	JOIN sakila.payment AS pay ON r.rental_id = pay.rental_id
	GROUP BY st.store_id
    HAVING st.store_id = store
    ) sub1 ;
    
    CASE 
		WHEN param1 > 30000 THEN 
			SET flag = "green_flag";
        ELSE 
			SET flag = "red_flag";
        END CASE;
	SELECT flag INTO param2;
END //
DELIMITER ;
 
-- Update the stored procedure that takes an input as the `store_id` and returns total sales value for that store and flag value.
CALL total_sales_by_store_4(1,@total_sales_value, @flag_value);
SELECT ROUND(@total_sales_value,2), @flag_value;
