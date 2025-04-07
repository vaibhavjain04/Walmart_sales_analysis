select * from walmart;
select count(*) from walmart;
select 
	payment_method,
    count(*)
    from walmart
    group by payment_method;
    
select count(distinct Branch)
from walmart;

-- Business problems
-- Q.1 Find different payment methods and number of transactions, number of qty sold

select 
	payment_method,
    count(*) as no_payments,
    sum(quantity) as no_qty_sold
    from walmart
    group by payment_method;

-- Q2 Identify the highest rated category in each branch, displaying the branch, category, avg rating

SELECT *
FROM (
    SELECT
        Branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS ranking
    FROM walmart
    GROUP BY Branch, category
) AS ranked_data
WHERE ranking = 1;

-- Q3 Identify the busiest day for each branch based on the number of transactions
select *
from
	(SELECT
    Branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
    count(*) as no_transactions,
	RANK() OVER(PARTITION BY Branch ORDER BY count(*) DESC) AS ranking
    FROM walmart
    GROUP BY Branch, day_name
    ) as ranked_data
where ranking = 1;

-- Q4 calculate the total qty of items sold per payment method. List paymwnt_methid and total_quantity.
select 
	payment_method,
    sum(quantity) as no_qty_sold
    from walmart
    group by payment_method;
    
-- Q5 determine the avg, min and max rating of category for each city. List the city, average_rating, min_rating and max_rating.

select
	City,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by City, category;

-- Q6 Calculate the total profit for each category by considering total_profit as (unit_price* quantity * profit_margin).List category and total_profit, ordered from highest to lowest profit.

SELECT
category,
SUM(total) as total_revenue,
SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1;

-- Q7 Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method.
WITH cte AS (
    SELECT
        Branch,
        "payment method",
        COUNT(*) AS total_trans,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY Branch, "payment method"
)
SELECT *
FROM cte
WHERE ranking = 1;



-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices

SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM "time") < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM "time") BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY branch,
         CASE
             WHEN EXTRACT(HOUR FROM "time") < 12 THEN 'Morning'
             WHEN EXTRACT(HOUR FROM "time") BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
         END
ORDER BY branch, total_transactions DESC;


-- #9 Identify 5 branch with highest decrese ratio in
-- revevenue compare to last year (current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;




