CREATE DATABASE project;
USE project;

CREATE TABLE orders(
  order_id INT NOT NULL,
  order_date DATE ,
  order_time TIME
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT,
    quantity INT
);

-- Retrieve the total number of orders placed.

SELECT * FROM orders; 
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(quantity*price),2) AS total_revenue
FROM pizzas AS a
JOIN order_details AS b
ON a.pizza_id=b.pizza_id; 

-- Identify the highest-priced pizza.

SELECT name, price
FROM pizza_types AS a
JOIN pizzas AS b
ON a.pizza_type_id=b.pizza_type_id
ORDER BY price DESC 
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    size, SUM(quantity)
FROM
    pizzas AS a
        JOIN
    order_details AS b ON a.pizza_id = b.pizza_id
GROUP BY size
ORDER BY SUM(quantity) DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, SUM(quantity) AS order_quantity
FROM
    pizza_types AS a
        JOIN
    pizzas AS b ON a.pizza_type_id = b.pizza_type_id
        JOIN
    order_details AS c ON c.pizza_id = b.pizza_id
GROUP BY name
ORDER BY SUM(quantity) DESC
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity)
FROM
    pizza_types AS a
        JOIN
    pizzas AS b ON a.pizza_type_id = b.pizza_type_id
        JOIN
    order_details AS c ON c.pizza_id = b.pizza_id
GROUP BY category
ORDER BY SUM(quantity) ASC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour_of_day, COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time) ASC;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(total_order)
FROM
    (SELECT 
        DATE(order_date), SUM(quantity) AS total_order
    FROM
        orders AS a
    JOIN order_details AS b ON a.order_id = b.order_id
    GROUP BY DATE(order_date)) AS avg_order;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    name AS pizza_name, SUM(price * quantity) AS revenue
FROM
    pizza_types AS a
        JOIN
    pizzas AS b ON a.pizza_type_id = b.pizza_type_id
        JOIN
    order_details AS c ON b.pizza_id = c.pizza_id
GROUP BY pizza_name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category AS pizza_type,
    ROUND(SUM(price * quantity), 0),
    ROUND((SUM(price * quantity) / (SELECT 
                    SUM(quantity * price) AS total_revenue
                FROM
                    pizzas AS a
                        JOIN
                    order_details AS b ON a.pizza_id = b.pizza_id) * 100),
            0) AS revenue_percent
FROM
    pizza_types AS a
        JOIN
    pizzas AS b ON a.pizza_type_id = b.pizza_type_id
        JOIN
    order_details AS c ON b.pizza_id = c.pizza_id
GROUP BY pizza_type;



-- Analyze the cumulative revenue generated over time.

SELECT order_date,SUM(revenue) OVER (ORDER BY order_date) AS cumulative_rev
FROM
(SELECT order_date,SUM(price*quantity) AS revenue
FROM orders AS a
JOIN order_details AS b
ON a.order_id=b.order_id
JOIN pizzas AS c
 ON b.pizza_id = c.pizza_id
 GROUP BY order_date) AS sales;
  
  
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,pizza_name,revenue,
RANK() OVER (PARTITION BY category ORDER BY revenue) As r
FROM
(SELECT 
    category ,name AS pizza_name, SUM(price * quantity) AS revenue
FROM
    pizza_types AS a
        JOIN
    pizzas AS b ON a.pizza_type_id = b.pizza_type_id
        JOIN
    order_details AS c ON b.pizza_id = c.pizza_id
    GROUP BY category,name) AS rev;
