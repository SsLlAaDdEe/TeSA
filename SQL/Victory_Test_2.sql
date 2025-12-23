

-- Task 1
-- In each  region what is largest amount of  sales, and what is the highest value across all regions?
SELECT TOP 1 t.region_name AS highest_region, t.sales_amount AS highest_value
FROM 
(SELECT r.name AS region_name, SUM(o.total_amt_usd) AS sales_amount
FROM orders AS o
JOIN accounts AS a 
ON a.id = o.account_id 
JOIN sales_reps AS s 
ON s.id = a.sales_rep_id 
JOIN region AS r 
ON r.id = s.region_id
GROUP BY r.name) AS t
ORDER BY t.sales_amount DESC;






-- Task 2
-- For the customer that spent the most (in total over their lifetime as a customer)  ,, how many web_events did they have for each channel?

SELECT COUNT(*) AS count_web_events, w.channel AS channel
FROM
(SELECT TOP 1 b.account_id AS highest_account, MAX(b.h) AS highest_amount
FROM
(SELECT account_id, SUM(total_amt_usd) AS h
FROM orders
GROUP BY account_id) AS b
GROUP BY b.account_id
ORDER BY highest_amount DESC) AS bb
JOIN web_events AS w
ON bb.highest_account=w.account_id
GROUP BY w.channel


-- Second version
SELECT t.account_id AS account_id, a.name AS account_name, w.channel AS channel, COUNT(w.channel) AS channel_count
FROM accounts AS a
JOIN
(SELECT TOP 1 account_id, SUM(total_amt_usd) AS total_spent
FROM orders
GROUP BY account_id
ORDER BY total_spent DESC) AS t
ON t.account_id=a.id
JOIN web_events AS w
ON t.account_id=w.account_id
GROUP BY t.account_id, a.name, w.channel;


-- Using CTE
WITH t AS (SELECT TOP 1 account_id, SUM(total_amt_usd) AS total_spent
FROM orders
GROUP BY account_id
ORDER BY total_spent DESC)

SELECT t.account_id AS account_id, a.name AS account_name, w.channel AS channel, COUNT(w.channel) AS channel_count
FROM accounts AS a
JOIN
t
ON t.account_id=a.id
JOIN web_events AS w
ON t.account_id=w.account_id
GROUP BY t.account_id, a.name, w.channel;


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


-- Demi's version
SELECT a.name [Account Name], a.id [Account ID], w.channel Channel, COUNT(w.channel) [No. of Events]
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN

(SELECT TOP 1 account_id
FROM orders o
GROUP BY account_id
ORDER BY SUM(total_amt_usd) DESC) t -- Top Spender
ON t.account_id = a.id

GROUP BY a.name, a.id, w.channel
ORDER BY [Account ID], [No. of Events] DESC;