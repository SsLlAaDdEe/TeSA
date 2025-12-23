
-- Task 1
SELECT a.primary_poc, w.occurred_at, w.channel, a.name AS account_name
FROM web_events AS w
JOIN accounts AS a 
ON w.account_id = a.id
WHERE a.name = 'Walmart' -- Optional

-- Task 2
SELECT r.name AS region_name, s.name AS sales_rep_name, a.name AS account_name
FROM accounts AS a
JOIN sales_reps AS s 
ON s.id = a.sales_rep_id 
JOIN region AS r 
ON r.id = s.region_id
ORDER BY account_name

-- Task 3
SELECT r.name AS region_name, a.name AS account_name, (o.total_amt_usd/(o.total+0.01)) AS unit_price
FROM orders AS o
JOIN accounts AS a 
ON a.id = o.account_id 
JOIN sales_reps AS s 
ON s.id = a.sales_rep_id 
JOIN region AS r 
ON r.id = s.region_id


SELECT *
FROM orders

SELECT *
FROM accounts

SELECT *
FROM region

SELECT *
FROM sales_reps

SELECT *
FROM web_events