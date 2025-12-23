-- * - all
-- similar to pd.head() in pandas
-- Alternatively, you can just use the GUI
-- Jetbrains >> Microsoft nonsense
-- DQL
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
-- SELECT TOP n column_name1,... column_name_n FROM table_name
SELECT TOP 20 id, website
FROM accounts;

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

SELECT MAX(standard_amt_usd) as Tega, AVG(standard_qty) as Jinmi
FROM orders;

-- Tega > Jinmi
-- Flawless Victory

SELECT MAX(standard_amt_usd) as Tega /*Tega is MAX*/, SUM(standard_qty) / COUNT(standard_qty) as Jinmi -- derived columns!
FROM orders;

-- Find the unit price for poster paper
SELECT(poster_amt_usd / poster_qty) as poster_unit_price, poster_amt_usd
FROM orders
WHERE poster_qty > 0;

-- Mini Boss 1: GROUP BY
-- But before that, WHERE, micro boss 1 (like me fr)

SELECT TOP 500 (standard_amt_usd)
FROM orders
WHERE standard_amt_usd > 1000
ORDER BY standard_amt_usd DESC;

-- Walmart accounts
-- conjunction functions. sharp
SELECT *
FROM accounts
WHERE name BETWEEN 'Wal' AND 'Walmart';

-- orders that have between 500 and 1000 total quantities ordered
SELECT *
FROM orders
WHERE total BETWEEN 500 AND 1000;

-- SANDWICH
-- sa%ch
-- search

-- %WAL - bring any name that ends with wal, anything else can come before it
-- WAL% - any name that begins with WAL, anything else can come after it

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

-- Find region of each account and sales rep.
SELECT a.name AS account_name, s.name AS sales_rep, r.name AS region
FROM region as r
INNER JOIN sales_reps s
ON s.region_id = r.id
INNER JOIN accounts a
ON a.sales_rep_id = s.id
WHERE s.name = 'Samuel Racine'
ORDER BY a.name;

--SELECT a.name account, s.name sales_rep, r.name region
--FROM accounts a
--CROSS JOIN sales_reps s
--CROSS JOIN region r
--WHERE s.name = 'Samuel Racine'
--ORDER BY a.name;

-- Find the number of accounts associated with each sales_rep
SELECT s.name AS sales_rep,  COUNT(s.name) AS acc_count
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY acc_count DESC;

-- Sub-Queries
-- Very wonderful thing.

-- Sub-Queries for Derived Columns
-- 1. Find the number of events that occur for each day for each channel
-- and find the day and channel where the most events occurred

SELECT datetrunc(day, occurred_at) as truncated_date, channel, COUNT(channel) as count_channel
FROM web_events
GROUP BY channel, datetrunc(day, occurred_at)
ORDER BY count_channel DESC;

-- Days: Dec. 21st 2016, and 1st Jan 2017, with 21 direct events happening

-- 1b: Average number of events for each channel per day
SELECT AVG(count_channel * 1.0) as average_event, channel
FROM (
    SELECT datetrunc(day, occurred_at) as truncated_date, channel, COUNT(channel) as count_channel
    FROM web_events
    GROUP BY channel, datetrunc(day, occurred_at)
--     ORDER BY count_channel DESC
) as tdccc
GROUP BY channel;

-- Sub-Queries with *where*
-- 2a. Find the month where the first order happened.
SELECT datetrunc(month, MIN(occurred_at)) as earliest_month
FROM orders;

-- 2b. Use the result of the previous query to find only the orders that took place in the same month and year
-- as the first order and then put the average for each type of paper quantity in this month.
SELECT datetrunc(month, MIN(occurred_at)) as earliest_month, AVG(poster_qty * 1.0) as avg_poster, AVG(standard_qty * 1.0) as avg_standard, AVG(gloss_qty * 1.0) as avg_gloss
FROM orders
    WHERE datetrunc(month, occurred_at) = (
    SELECT datetrunc(month, MIN(occurred_at)) as earliest_month
    FROM orders
        );

-- 2c: Find the total amount spent on all orders
SELECT datetrunc(month, MIN(occurred_at)) as earliest_month, AVG(poster_qty * 1.0) as avg_poster, AVG(standard_qty * 1.0) as avg_standard, AVG(gloss_qty * 1.0) as avg_gloss, SUM(total_amt_usd) as total_orders
FROM orders
    WHERE datetrunc(month, occurred_at) = (
    SELECT datetrunc(month, MIN(occurred_at)) as earliest_month
    FROM orders
        );

-- CTEs (Common Table Expressions), not the concussion kind:
-- Let's convert our most recent example to a CTE
WITH day_per_event AS (
    SELECT datetrunc(day, occurred_at) as truncated_date, channel, COUNT(channel) as count_channel
    FROM web_events
    GROUP BY channel, datetrunc(day, occurred_at)
)

SELECT AVG(count_channel) as average_event, channel
FROM day_per_event
GROUP BY channel;

SELECT a.name, SUM(o.total) as total_orders, AVG(o.poster_qty) as avg_poster_qty
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

-- Find the names of all accounts that have placed at least one order where the standard_qty was
-- greater than the average standard_qty of all orders.
-- (Hint: Use a subquery in the WHERE clause to calculate the overall average standard_qty.)

SELECT name
FROM (
    SELECT a.name, o.id as order_id, o.standard_qty
    FROM accounts a
    JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > (
         SELECT AVG(standard_qty)
         FROM orders
        )
    ) o
GROUP BY name;

-- For every order placed, list the order ID, the account name, the total_amt_usd for that order,
-- and the average total sales amount for the entire region where the order was placed.
-- (Hint: Use a correlated subquery in the SELECT statement to calculate the regional average for each row/order.)


(
    SELECT o.id, a.name, r.name, o.total_amt_usd
    FROM accounts a
    JOIN orders o
ON o.account_id = a.id
    JOIN sales_reps
)

SELECT
    o.id AS order_id,
    a.name AS account_name,
    o.total_amt_usd,
    (
        SELECT AVG(o2.total_amt_usd)
        FROM orders o2
        JOIN accounts a2
        ON o2.account_id = a2.id
        JOIN sales_reps sr2
        ON a2.sales_rep_id = sr2.id
        WHERE sr2.region_id = sr.region_id
    ) AS regional_avg_sales
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps sr
ON a.sales_rep_id = sr.id
JOIN region r ON sr.region_id = r.id;



SELECT o.id, a.name, o.total_amt_usd, (
    SELECT AVG(o.total_amt_usd)  as avg_amt_usd
    FROM region r
    JOIN sales_reps s
    ON s.region_id = r.id
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    WHERE r.id = re.id
--     GROUP BY r.name
) as avg_amount_per_region
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region re
ON s.region_id = re.id;

SELECT TOP 1 acc_name, MAX(total_sales) as highest_sale
FROM(
    SELECT r.name as acc_name, SUM(o.total_amt_usd) as total_sales
    FROM region r
    JOIN sales_reps s
    ON s.region_id = r.id
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY r.name
) too
GROUP BY acc_name
ORDER BY highest_sale DESC;

SELECT region_name, MAX(total_amt) total_amt
        FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
                FROM sales_reps s
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders o
                ON o.account_id = a.id
                JOIN region r
                ON r.id = s.region_id
                GROUP BY s.name, r.name) t1
        GROUP BY region_name;

SELECT w.channel, COUNT(w.channel) as _count
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.id = (
SELECT acc_id
FROM (
    SELECT TOP 1 a.id as acc_id, SUM(o.total_amt_usd) as total_amount_spent
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    JOIN web_events w
    ON w.account_id = a.id
    GROUP BY a.id, a.name
    ORDER BY total_amount_spent DESC
) o
)
GROUP BY w.channel;

WITH inner_inner AS (
    SELECT TOP 1 a.id as acc_id, SUM(o.total_amt_usd) as total_amount_spent
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    JOIN web_events w
    ON w.account_id = a.id
    GROUP BY a.id, a.name
    ORDER BY total_amount_spent DESC
)

SELECT w.channel, COUNT(w.channel) as _count
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.id = (
SELECT acc_id
FROM inner_inner
)
GROUP BY w.channel;

SELECT account_name, COUNT(w.id)
FROM (
SELECT TOP 10 a.id as acc_id, a.name as account_name
 FROM accounts a
          JOIN orders o
               ON o.account_id = a.id
          JOIN web_events w
               ON w.account_id = a.id
 ORDER BY SUM(total_amt_usd) DESC
) o
JOIN web_events w
ON w.account_id = acc_id
GROUP BY account_name;

SELECT
    a.name AS account_name,
    COUNT(we.id) AS num_web_events
FROM accounts a
JOIN web_events we ON a.id = we.account_id
WHERE a.id IN (
    SELECT TOP 10 a2.id
    FROM accounts a2
    JOIN orders o2 ON a2.id = o2.account_id
    GROUP BY a2.id
    ORDER BY SUM(o2.total_amt_usd) DESC
)
GROUP BY a.name
ORDER BY num_web_events DESC;

WITH CountNumbers AS (
  SELECT 1 AS Number
  UNION ALL
  SELECT Number + 1 FROM CountNumbers WHERE Number < 5
)
SELECT * FROM CountNumbers;

WITH factorial AS (
    SELECT 3 as fac
    UNION ALL
    SELECT fac * (fac - 1) FROM factorial WHERE fac > 0
)
SELECT * FROM factorial; -- suspended

-- Find the number of orders placed by each account (account_id) and display the account_id alongside the order count.
SELECT account_id , COUNT(id) AS order_count
FROM orders
GROUP BY account_id


-- ADVANCED SQL!!
-- You're about to become big boys and girl

-- Window Functions (not macOS, or Linux)
-- I'm hilarious.
-- OVER() clause - creates a window or set of rows to perform calculations across
-- PARTITION BY - divides the result set into partitions to perform calculations on each partition
-- ORDER BY - defines the order of rows in each partition
-- ROWS BETWEEN - defines a subset of rows within the partition
-- Common Window Functions: ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE(), LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE(), SUM(), AVG(), COUNT(), MIN(),

SELECT SUM(total_amt_usd)
FROM orders;

SELECT account_id, 
    total_amt_usd, 
    SUM(total_amt_usd) OVER() AS sum_total_usd
FROM orders

-- Basic of basics
SELECT id AS order_id, 
    total_amt_usd, 
    SUM(total_amt_usd) OVER(ORDER BY id) AS running_total
FROM orders

SELECT id AS order_id, 
    total_amt_usd, 
    SUM(total_amt_usd) OVER(PARTITION BY id) AS running_total
FROM orders

ITEM    Price |PARTITION BY..| ORDER BY...| 
water    30     100            30            
egg      20     75             50            
flour    10     10             60            
water    70     100            130           
egg      55     75             185           

-- Now, add a column that ranks the accounts based on the number of orders they have placed, with the account having the highest number of orders ranked 1.
-- If two accounts have the same number of orders, they should receive the same rank, and the next rank(s) should be skipped accordingly.
SELECT a.id AS account_id, COUNT(o.id) AS order_count,
       ROW_NUMBER() OVER (ORDER BY COUNT(o.id) DESC) AS order_rank,
       RANK() OVER (ORDER BY COUNT(o.id) DESC) AS acc_order_rank
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY a.id
ORDER BY order_rank;

-- For each region, calculate the running average of total_amt_usd over time.
SELECT r.name,
       o.occurred_at,
       o.total_amt_usd,
       SUM(o.total_amt_usd) OVER (PARTITION BY r.name ORDER BY r.name) AS mov_sum,
       RANK() OVER (PARTITION BY r.name ORDER BY datetrunc(month, o.occurred_at)) AS rank_,
       RANK() OVER (PARTITION BY datetrunc(month, o.occurred_at) ORDER BY o.account_id) AS alt_rank
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id

 -- create a running total of standard_amt_usd (in the orders table)
 -- over order time with no date truncation. Your final table should have two columns:
 -- one with the amount being added for each new row, and a second with the running total.

SELECT standard_amt_usd,
       occurred_at,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) as running_total
FROM orders

-- Find the running total of each account (id) per month and their row number
SELECT a.id,
       datetrunc(month, o.occurred_at) as monthly_occurence,
       RANK() over win_function as rank,
       DENSE_RANK() over win_function as dense_rank,
       o.total_amt_usd,
       SUM(o.total_amt_usd) OVER win_function as running_total,
       LEAD(o.total_amt_usd) OVER win_function as lead_,
       LAG(o.total_amt_usd) OVER win_function as lag_,
       FIRST_VALUE(o.total_amt_usd) OVER win_function as first_value_,
       LAST_VALUE(o.total_amt_usd) OVER win_function as last_value_
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WINDOW win_function AS (PARTITION BY a.id ORDER BY datetrunc(month, o.occurred_at))


-- Top 10 Accounts and their Events:
-- Determine the name of the account and the number of web events for the top 10 spending accounts 
-- (based on total total_amt_usd). (Hint: Use a subquery in the FROM clause to 
-- select the IDs of the top 10 accounts first, then join that derived table 
-- to accounts and web_events.)

WITH top_accounts AS (
    SELECT TOP 10 account_id
    FROM orders
    GROUP BY account_id
    ORDER BY SUM(total_amt_usd) DESC
)

SELECT a.name AS account_name, COUNT(w.id) AS event_count
FROM top_accounts
JOIN accounts AS a 
ON top_accounts.account_id = a.id
JOIN web_events AS w
ON a.id = w.account_id
GROUP BY a.name;


-- Question 1: Top 5 High-Value Accounts per Sales Rep (Multi-Step Filtering)
WITH top_account AS (
    SELECT s.id AS sales_id, s.name AS sales_rep, a.id AS acc_id, SUM(o.total_amt_usd) AS total_sales
    FROM orders AS o
    JOIN accounts AS a
    ON o.account_id = a.id
    JOIN sales_reps AS s
    ON a.sales_rep_id = s.id
    GROUP BY s.id, s.name, a.id),
    rank_account AS (
        SELECT *, 
        RANK() OVER(PARTITION BY sales_id ORDER BY total_sales DESC) AS sales_rank
        FROM top_account 
    )

-- SELECT * FROM rank_account;

SELECT r.sales_rep AS sales_rep, a.name AS account_name, r.total_sales AS sales
FROM rank_account AS r
JOIN accounts AS a
ON r.acc_id = a.id
WHERE r.sales_rank <= 5
ORDER BY r.sales_rep, r.sales_rank;




WITH rep_account_revenue AS (
    -- Calculate total revenue and order count for each account/rep combination
    SELECT
        a.sales_rep_id,
        o.account_id,
        SUM(o.total_amt_usd) AS total_revenue,
        COUNT(o.id) AS total_orders
    FROM orders AS o
    JOIN accounts AS a ON o.account_id = a.id
    GROUP BY a.sales_rep_id, o.account_id
),
ranked_accounts AS (
    -- Rank accounts within each sales rep group based on total revenue
    SELECT
        *,
        RANK() OVER (
            PARTITION BY sales_rep_id
            ORDER BY total_revenue DESC
        ) AS rank_by_revenue
    FROM rep_account_revenue
)
-- Final result
SELECT
    sr.name AS sales_rep_name,
    a.name AS account_name,
    ra.total_revenue,
    ra.total_orders
FROM ranked_accounts AS ra
JOIN sales_reps AS sr ON ra.sales_rep_id = sr.id
JOIN accounts AS a ON ra.account_id = a.id
WHERE ra.rank_by_revenue <= 5
ORDER BY sr.name, ra.rank_by_revenue;

-- Moving Averages and Time Series Analysis
SELECT datetrunc(month, occurred_at) as month, 
       total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY datetrunc(month, occurred_at) ORDER BY AVG(total_amt_usd) DESC) as mov_avg
FROM orders
GROUP BY datetrunc(month, occurred_at), total_amt_usd
ORDER BY month;


SELECT
    DATETRUNC(month, occurred_at) AS sales_month,
    SUM(total_amt_usd) AS monthly_revenue,
    -- Calculate 3-month rolling average revenue
    AVG(SUM(total_amt_usd)) OVER (
        ORDER BY DATETRUNC(month, occurred_at)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_rolling_avg,
    -- Get last month's revenue using LAG
    LAG(SUM(total_amt_usd)) OVER (
        ORDER BY DATETRUNC(month, occurred_at)
    ) AS previous_month_revenue,
    -- Calculate Month-over-Month Percent Change
    (SUM(total_amt_usd) - LAG(SUM(total_amt_usd), 1) OVER (ORDER BY DATETRUNC(month, occurred_at))) 
    / LAG(SUM(total_amt_usd), 1) OVER (ORDER BY DATETRUNC(month, occurred_at)) * 100 AS mom_percent_change
FROM orders
GROUP BY DATETRUNC(month, occurred_at)
ORDER BY sales_month;\


-- Question 3: Account-Level Web Activity Ranking
-- Goal: Find the rank of each account based on its total number of web events within its assigned region.

-- Step 1: Count the number of web_events for each account_id.

-- Step 2: Use the DENSE_RANK() window function, partitioning by region.id (via the joins) and ordering by the web event count.

SELECT a.name AS account_name,
    r.name AS region,
    COUNT(w.id) as web_events,
    DENSE_RANK() OVER(PARTITION BY r.name ORDER BY COUNT(w.id) DESC) AS rank
FROM web_events AS w
JOIN accounts AS a
ON w.account_id = a.id
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS r
ON s.region_id = r.id
GROUP BY a.name, r.name


-- Question 4: Creating a View for Account Profitability Metrics
-- Goal: Create a reusable view that combines sales data with account information and flags accounts based on their product mix.

-- Flag Logic: Use CASE statements to categorize accounts based on whether they prioritize physical posters (poster_qty) or digital/standard goods (standard_qty).

-- View Creation: Define a view named account_profit_summary containing the account name, region, total revenue, total quantity, and the calculated product mix flag.

-- Create the View
CREATE VIEW account_profit_summary AS
SELECT
    a.name AS account_name,
    r.name AS region_name,
    SUM(o.total_amt_usd) AS lifetime_revenue,
    SUM(o.total) AS total_quantity_sold,
    -- Flag accounts based on product mix
    CASE
        WHEN SUM(o.poster_qty) * 2 > SUM(o.standard_qty + o.gloss_qty) THEN 'Poster Heavy'
        WHEN SUM(o.standard_qty + o.gloss_qty) * 2 > SUM(o.poster_qty) THEN 'Standard/Glossy Heavy'
        ELSE 'Balanced Mix'
    END AS product_mix_flag
FROM orders AS o
JOIN accounts AS a ON o.account_id = a.id
JOIN sales_reps AS sr ON a.sales_rep_id = sr.id
JOIN region AS r ON sr.region_id = r.id
GROUP BY a.name, r.name;
GO

-- Test the View (Example Query after creation)
SELECT
    region_name,
    product_mix_flag,
    COUNT(account_name) AS num_accounts,
    AVG(lifetime_revenue) AS avg_account_revenue
FROM account_profit_summary
GROUP BY region_name, product_mix_flag
ORDER BY region_name, num_accounts DESC;

