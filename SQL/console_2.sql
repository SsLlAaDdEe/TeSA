-- * - all
-- similar to pd.head() in pandas
-- Alternatively, you can just use the GUI
-- Jetbrains >> Microsoft nonsense ... CAP
SELECT * from accounts;

-- Selecting Certain Columns in a table
-- Syntax
-- SELECT `column_name1`, `column_name2`, ... `column_name_n` FROM `table_name`;

SELECT id, name, website FROM accounts;

-- SQL Best Practice: Writing FROM in a new line is better.

SELECT id, name, website, lat, long
FROM accounts;
-- See? cleaner

-- Temporary renaming of columns

SELECT id Tega, name, website, lat, long
FROM accounts;

-- Alternatively, for better readability, you can use `AS`
-- Exhibit A:
SELECT id Tega, name, website AS Samuel, lat, long
FROM accounts;

-- TOP command, an efficient way of returning a limited row number
-- Again, very similar to pd.head(n) in pandas
-- Syntax:
-- SELECT TOP n (column_name1,... column_name_n) FROM table_name
SELECT TOP 20 id, website FROM accounts;

-- You can also use * instead of individually selecting columns
SELECT TOP 20 * FROM accounts;

-- ORDER BY
-- You can use this to sort by a column in ascending (ASC) or descending order (DESC)
-- Syntax:
-- SELECT * from table_name ORDER BY column_name DESC;
SELECT TOP 20 * FROM accounts ORDER BY id DESC;

SELECT COUNT(id) as count_id
FROM orders;

SELECT SUM(standard_amt_usd) as Amount
FROM orders;

-- 9 milly!

-- Find the sum of standard_qty, standard_amt_usd
SELECT MAX(standard_amt_usd) as Tega, MIN(standard_qty) as Jinmi
FROM orders;

-- Tega > Jinmi
-- Flawless Victory

SELECT MAX(standard_amt_usd) as Tega, SUM(standard_qty) / COUNT(standard_qty) as Jinmi
FROM orders;

-- Mini Boss 1: GROUP BY
-- But before that, WHERE, micro boss 1 (like me fr)

SELECT TOP 500 (standard_amt_usd)
FROM orders
WHERE standard_amt_usd > 1000
ORDER BY standard_amt_usd DESC;

-- Walmart accounts
SELECT *
FROM accounts
WHERE name BETWEEN 'Wal' AND 'Walmart';

-- SANDWICH
-- sa%ch
-- search

SELECT *
FROM accounts
WHERE name LIKE 'Wa%l%'; -- Wal starts the string, looking for entries that have "Wal" at the start

-- Display a table for the top 15 rows of occurred_at, account_id, and channel from web_events table
SELECT TOP 15 occurred_at, account_id, channel
FROM web_events;

-- Write query to return lowest 20 orders in terms of smallest total_amt_usd (id, account_id, total_amt_usd)
-- who wants to step up?
SELECT TOP 20 id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;

-- Pulling 10 rows and all columns from orders table that have a total_amount_sad < 500
SELECT TOP 10 *
FROM orders
WHERE total_amt_usd < 500;

-- FILTER and return name, website, primary_poc for just exxon mobil in accounts table
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'EXXON MOBIL';

-- Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order. Limit the results to the first 10 orders, and include the id and account_id fields.
SELECT TOP 10 standard_amt_usd / standard_qty as Unit_price_std, id, account_id
FROM orders;

-- GROUP BY
-- Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
SELECT channel, COUNT(*)
FROM web_events
GROUP BY channel;

-- Show the sales_channel
SELECT DISTINCT(Sales_Channel) 
FROM [Amazon Sale Report];

-- Show the different categories 
SELECT DISTINCT(Category) 
FROM [Amazon Sale Report];

-- Find the average amount spent on each category of sales
SELECT Category, AVG(Amount) AS Avg_amount
FROM [Amazon Sale Report]
GROUP BY Category;

-- Find the total items each category has
SELECT Category, SUM(Qty) AS Total_qty
FROM [Amazon Sale Report]
GROUP BY Category;

-- HAVING: Used to filter in-line aggregations on numeric columns... duhhh
SELECT account_id, SUM(total_amt_usd) AS sum_total_usd
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd) >= 250000;



WITH regional_avg AS (SELECT AVG(total_amt_usd)
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS r
ON s.region_id = r.id
WHERE r.id = re.id
GROUP BY r.name) 

SELECT o.id AS order_id, a.name AS account_name, o.total_amt_usd AS total_amt, regional_avg
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS re
ON s.region_id = re.id;



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


-- WINDOW FUNCTIONS
-- Find the total sales amount for each region, ordered by the sales amount assigning a rank in descending order
SELECT r.name AS region_name, COUNT(o.id) AS order_count, SUM(o.total_amt_usd) AS sales_amount,
       RANK() OVER (ORDER BY SUM(o.total_amt_usd) DESC) AS sales_rank
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS r
ON s.region_id = r.id
GROUP BY r.name