SELECT *
FROM accounts

SELECT *
FROM orders

SELECT * 
FROM region

SELECT *
FROM sales_reps

SELECT *
FROM web_events



-- Question 1:
-- Using the web_events table, which contains the
-- columns occurred_at (timestamp of when an event
-- occurred) and channel (the source or marketing
-- channel through which the event occurred), write a
-- SQL query to determine the average number of daily
-- web events for each channel.
-- Your query should:
-- 1. First calculate the total number of events per
-- channel per day.
-- 2. Then compute the average of these daily
-- event counts for each channel.
-- 3. Finally, display the results ordered by the
-- average number of events in descending order.

WITH DailyEvents AS (
    SELECT channel,
        DATETRUNC(day, occurred_at) AS event_date,
        COUNT(*) AS daily_event_count
    FROM web_events
    GROUP BY channel, DATETRUNC(day, occurred_at)
)

SELECT channel,
    AVG(daily_event_count) AS avg_daily_events
FROM DailyEvents
GROUP BY channel
ORDER BY avg_daily_events DESC;


-- Question 2:
-- Using the orders table, which contains information such
-- as occurred_at (the date the order was placed),
-- standard_qty, gloss_qty, poster_qty, and total_amt_usd,
-- write SQL queries to analyze performance for the
-- earliest month on record.
-- Specifically:
-- 1. Write a query to find the average quantity
-- ordered for each product type (standard_qty, gloss_qty,
-- and poster_qty) during the first month in which orders
-- were placed.
-- 2. Write another query to find the total
-- revenue (in USD) generated during that same month.
-- The month to be analyzed should be determined
-- dynamically by finding the minimum order date
-- (MIN(occurred_at)) in the table, truncated to
-- the month level.

-- CTE to find the first month
WITH FirstMonth AS (
    SELECT 
        DATETRUNC(month, MIN(occurred_at)) AS first_month
    FROM 
        orders
)

-- Query 1
SELECT 
    AVG(standard_qty) AS avg_standard_qty,
    AVG(gloss_qty) AS avg_gloss_qty,
    AVG(poster_qty) AS avg_poster_qty
FROM orders, FirstMonth
WHERE DATETRUNC(month, occurred_at) = FirstMonth.first_month;

-- Query 2
SELECT 
    SUM(total_amt_usd) AS total_revenue_usd
FROM orders, FirstMonth
WHERE 
    DATETRUNC(month, occurred_at) = FirstMonth.first_month;


-- Question 3:
-- Using the following tables:
-- • sales_reps – contains information about each
-- sales representative, including their id, name, and
-- region_id.
-- • accounts – contains customer account
-- information, including the sales_rep_id assigned to
-- each account.
-- • orders – contains all order transactions,
-- including account_id and total_amt_usd (the total
-- amount of the order in USD).
-- • region – contains regional information such
-- as id and name.
-- Write a SQL query to determine the top-performing
-- sales representative in each region based on the total
-- sales amount (total_amt_usd) generated from their
-- accounts.
-- Your query should:
-- 1. First calculate the total sales amount per
-- sales representative and region.
-- 2. Then identify the maximum total sales
-- amount within each region.
-- 3. Finally, return the name of the sales
-- representative, their region, and their total sales
-- amount for the top performer(s) in each region.
-- The final result should display only the best-performing
-- rep(s) per region.

WITH RegionRepSales AS (
    SELECT s.name AS sales_rep_name,
        s.id AS sales_rep_id,
        r.name AS region_name,
        r.id AS region_id,
        SUM(o.total_amt_usd) AS total_sales_amount
    FROM sales_reps s   
    JOIN accounts AS a 
    ON s.id = a.sales_rep_id    
    JOIN orders AS o 
    ON a.id = o.account_id
    JOIN region AS r 
    ON s.region_id = r.id
    GROUP BY s.id, s.name, r.id, r.name
), 
MaxRegionSales AS (
    SELECT region_id,
        MAX(total_sales_amount) AS max_sales_amount
    FROM RegionRepSales
    GROUP BY region_id
)

SELECT r.sales_rep_name, r.region_name, r.total_sales_amount
FROM RegionRepSales AS r
JOIN MaxRegionSales AS m
ON r.region_id = m.region_id
AND r.total_sales_amount = m.max_sales_amount
ORDER BY r.total_sales_amount DESC;


-- Question 4:
-- Using the following tables:
-- • sales_reps – contains details about each sales
-- representative, including id, name, and region_id.
-- • accounts – contains customer account
-- information, including the sales_rep_id for each
-- account.
-- • orders – contains order details such as
-- account_id, total_amt_usd, and total (number of items
-- or order quantity).
-- • region – contains information about each
-- sales region with columns id and name.
-- Write a SQL query to determine which region
-- generated the highest total sales (in USD) and find the
-- total number of orders placed in that region.
-- Your query should:
-- 1. First calculate the total sales amount per
-- region.
-- 2. Identify the maximum total sales value across
-- all regions.
-- 3. Finally, return the region name and the total
-- number of orders (COUNT(o.total)) for the region
-- with that maximum total sales.
-- The result should show only the region (or regions)
-- that achieved the highest total sales amount.


WITH RegionSales AS (
    SELECT r.name AS region_name,
        r.id AS region_id,
        SUM(o.total_amt_usd) AS total_sales_amount
    FROM region r   
    JOIN sales_reps AS s 
    ON s.region_id = r.id
    JOIN accounts AS a 
    ON s.id = a.sales_rep_id    
    JOIN orders AS o 
    ON a.id = o.account_id
    GROUP BY r.id, r.name
),
MaxRegionSales AS (
    SELECT r.region_id,
        r.region_name,
        MAX(r.total_sales_amount) AS max_sales_value
    FROM RegionSales r   
    GROUP BY r.region_id, r.region_name
)

SELECT TOP 1 region_name, COUNT(o.id)
FROM MaxRegionSales AS m
JOIN sales_reps AS s
ON s.region_id = m.region_id
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN orders AS o
ON o.account_id = a.id
GROUP BY region_name, m.max_sales_value
ORDER BY m.max_sales_value DESC;

-- Question 5:
-- Using the following tables:
-- • accounts – contains information about
-- customer accounts, including id and name.
-- • orders – contains order-related details such
-- as account_id, standard_qty (quantity of standard
-- paper ordered), and total (total quantity of all paper
-- types ordered).
-- Write a SQL query to determine how many accounts
-- have a higher total order quantity than the account
-- that has the highest total standard paper quantity.
-- Your query should:
-- 1. Identify the account with the highest total
-- standard paper quantity (standard_qty) and also find its
-- total order quantity (total).
-- 2. Find all other accounts whose total order
-- quantity is greater than that of the top standard paper
-- account.
-- 3. Return the count of such accounts.

WITH MaxStandardAccount AS (
    SELECT account_id,
        MAX(total_standard_qty) AS max_standard_qty,
        
    FROM TopStandardAccount
    GROUP BY account_id, 
),

