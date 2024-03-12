-- 1. Result set to identify users who initiated a checkout process
WITH total_carts_created AS 
(
     SELECT 
	     *
     FROM 
	     checkout_carts
),

-- 2. Result set to identify users who create purchase cart and attempt to finalize a purchase.
total_checkout_attempts AS
(
SELECT tc.user_id, a.action_date, a.action_name
FROM total_carts_created AS tc
LEFT JOIN
checkout_actions AS a ON a.user_id = tc.user_id
WHERE
a.action_name LIKE '%completepayment.click%'
AND
a.action_date BETWEEN '2022-07-01' AND '2023-01-31'
),

-- 3. Result set that capture only successful checkout attempts
total_successful_attempts AS 
(
SELECT a.user_id, a.action_date, a.action_name
FROM total_checkout_attempts AS a
WHERE a.action_name LIKE '%success%'
GROUP BY a.user_id
),

-- 4. Total number of carts containing all purchased carts daily
count_total_carts AS
(
SELECT action_date, count(*) AS count_total_carts
FROM total_carts_created
GROUP BY action_date
),

-- 5. Total number of daily checkout attempts 
count_total_checkout_attempts AS
(
SELECT action_date, count(*) AS count_total_checkout_attempts
FROM total_checkout_attempts
GROUP BY action_date
),

--  6. Total number of only successful daily attempts
count_successful_checkout_attempts AS
(
SELECT action_date, count(*) AS count_successful_checkout_attempts
FROM total_successful_attempts
GROUP BY action_date
)

-- 7. Compile day-wise aggregated data
SELECT 
c.action_date, c.count_total_carts, 
IFNULL(tc.count_total_checkout_attempts, 0) AS count_total_checkout_attempts,
IFNULL(sc.count_successful_checkout_attempts, 0) AS count_successful_checkout_attempts
FROM count_total_carts AS c
LEFT JOIN 
count_total_checkout_attempts AS tc on c.action_date = tc.action_date
LEFT JOIN
count_successful_checkout_attempts AS sc on c.action_date = sc.action_date
WHERE
c.action_date BETWEEN '2022-07-01' AND '2023-01-31'
ORDER BY c.action_date;



-- 8. Select pertinent columns containing error detail and device utilized during the process
SELECT user_id, action_date, action_name, error_message, device
FROM checkout_actions
WHERE action_name LIKE '%checkout%' AND action_date BETWEEN '2022-07-01' and '2023-01-31'
GROUP BY user_id
ORDER BY action_date