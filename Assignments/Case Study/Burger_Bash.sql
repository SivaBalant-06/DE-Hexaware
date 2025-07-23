CREATE DATABASE burger_bash;
USE burger_bash;

CREATE TABLE burger_names (
  burger_id INT PRIMARY KEY,
  burger_name VARCHAR(100)
);

INSERT INTO burger_names VALUES
(1, 'Beef Burger'),
(2, 'Vegetarian Burger'),
(3, 'Chicken Burger'),
(4, 'Meatlovers Burger');

CREATE TABLE burger_runner (
  runner_id INT PRIMARY KEY,
  registration_date DATE
);

INSERT INTO burger_runner VALUES
(1, '2022-01-01'),
(2, '2022-01-08'),
(3, '2022-01-15');
--DROP TABLE IF EXISTS runner_orders;
--DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  burger_id INT,
  exclusions VARCHAR(100),
  extras VARCHAR(100),
  order_time DATETIME
);

CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time DATETIME,
  distance VARCHAR(20),
  duration VARCHAR(20),
  cancellation VARCHAR(20)
);

INSERT INTO customer_orders (order_id, customer_id, burger_id, exclusions, extras, order_time) VALUES
(101, 1, 1, NULL, 'Cheese', '2022-01-05 12:00:00'),
(102, 1, 2, 'Onion', NULL, '2022-01-05 13:10:00'),
(103, 2, 2, NULL, NULL, '2022-01-06 14:05:00'),
(104, 3, 4, NULL, 'Bacon', '2022-01-07 12:05:00'),
(105, 2, 3, 'Lettuce', NULL, '2022-01-08 11:30:00'),
(106, 1, 4, NULL, NULL, '2022-01-08 14:23:00');

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
(101, 1, '2022-01-05 12:30:00', '5km', '30min', NULL),
(102, 2, '2022-01-05 13:40:00', '3km', '20min', NULL),
(103, 1, '2022-01-06 14:31:00', '6km', '33min', 'Cancelled'),
(104, 3, '2022-01-07 12:32:00', '4km', '25min', NULL),
(105, 2, NULL, NULL, NULL, 'Cancelled'),
(106, 2, '2022-01-08 14:56:00', '2km', '10min', NULL);

SELECT COUNT(*) AS total_burgers_ordered FROM customer_orders;

SELECT COUNT(DISTINCT order_id) AS unique_customer_orders FROM customer_orders;

SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

SELECT b.burger_name, COUNT(*) AS burgers_delivered
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
JOIN burger_names b ON c.burger_id = b.burger_id
WHERE r.cancellation IS NULL
GROUP BY b.burger_name;

SELECT customer_id,
  SUM(CASE WHEN burger_id = 2 THEN 1 ELSE 0 END) AS Vegetarian_Burger,
  SUM(CASE WHEN burger_id = 4 THEN 1 ELSE 0 END) AS Meatlovers_Burger
FROM customer_orders
GROUP BY customer_id;

-- 1. List all delivered burger orders along with burger names and runner IDs
SELECT co.order_id, b.burger_name, ro.runner_id, ro.pickup_time
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN burger_names b ON co.burger_id = b.burger_id
WHERE ro.cancellation IS NULL;

-- 2. Show each runner’s name (ID), total number of burgers delivered, and the burger types they've delivered
SELECT ro.runner_id, b.burger_name, COUNT(*) AS total_deliveries
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
JOIN burger_names b ON co.burger_id = b.burger_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id, b.burger_name
ORDER BY ro.runner_id;

-- 3. Find all customers who ordered a Meatlovers Burger and received it. Show customer ID, order ID, and runner.
SELECT co.customer_id, co.order_id, ro.runner_id
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
  AND co.burger_id = (
    SELECT burger_id FROM burger_names WHERE burger_name = 'Meatlovers Burger');

-- 4. Total number of burgers ordered by each customer
SELECT customer_id, COUNT(*) AS burgers_ordered
FROM customer_orders
GROUP BY customer_id
ORDER BY burgers_ordered DESC;

-- 5. Average distance runners traveled on successful deliveries
SELECT 
  ROUND(AVG(CAST(REPLACE(distance, 'km', '') AS DECIMAL(5,2))), 2) AS average_distance_km
FROM runner_orders
WHERE cancellation IS NULL AND distance IS NOT NULL;

-- 6.Customer ordered the most Vegetarian Burgers successfully delivered
SELECT co.customer_id, COUNT(*) AS veg_burger_count
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
  AND co.burger_id = (
    SELECT burger_id FROM burger_names WHERE burger_name = 'Vegetarian Burger')
GROUP BY co.customer_id
ORDER BY veg_burger_count DESC;











