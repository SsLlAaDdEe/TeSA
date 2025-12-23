-- QUESTION 1

SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';

-- QUESTION 2
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;

-- QUESTION 3
SELECT r.name region, a.name account, 
           o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

-- QUESTION 4.

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

-- QUESTION 5.
SELECT a.name, w.channel, COUNT(*) count_
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                        FROM (SELECT TOP 1 a.id, a.name, SUM(o.total_amt_usd) tot_spent
                              FROM orders o
                              JOIN accounts a
                              ON a.id = o.account_id
                              GROUP BY a.id, a.name
                              ORDER BY tot_spent DESC
                              ) inner_table)
GROUP BY a.name, w.channel
ORDER BY count_ DESC;