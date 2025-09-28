-- Row count
SELECT COUNT(*) AS total_records FROM sales_cleaned;

-- Unique invoices
SELECT COUNT(DISTINCT invoice_id) AS unique_invoices FROM sales_cleaned;

-- Column completeness check
SELECT 
    COUNT(*) FILTER (WHERE branch IS NULL) AS missing_branch,
    COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE date IS NULL) AS missing_date,
    COUNT(*) FILTER (WHERE time IS NULL) AS missing_time,
    COUNT(*) FILTER (WHERE payment_method IS NULL) AS missing_payment_method,
    COUNT(*) FILTER (WHERE rating IS NULL) AS missing_rating,
    COUNT(*) FILTER (WHERE profit_margin IS NULL) AS missing_profit_margin
FROM sales_cleaned;

-- ===========================================================
-- STEP 2: UNIVARIATE ANALYSIS
-- ===========================================================

-- Quantity distribution
SELECT 
    MIN(quantity) AS min_qty,
    MAX(quantity) AS max_qty,
    AVG(quantity) AS avg_qty,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY quantity) AS median_qty
FROM sales_cleaned;

-- Rating distribution
SELECT rating, COUNT(*) AS count
FROM sales_cleaned
GROUP BY rating
ORDER BY rating;

-- Profit margin summary
SELECT 
    MIN(profit_margin) AS min_margin,
    MAX(profit_margin) AS max_margin,
    AVG(profit_margin) AS avg_margin
FROM sales_cleaned;

-- ===========================================================
-- STEP 3: BIVARIATE ANALYSIS
-- ===========================================================

-- Revenue by payment method
SELECT payment_method, round(SUM(unit_price * quantity)::numeric,2) AS total_revenue
FROM walmart_cleaned
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Avg profit margin by branch
SELECT branch, AVG(profit_margin) AS avg_margin
FROM walmart_cleaned
GROUP BY branch
ORDER BY avg_margin DESC;

-- Revenue by product category
SELECT category, round(SUM(unit_price * quantity)::numeric,2) AS total_revenue
FROM walmart_cleaned
GROUP BY category
ORDER BY total_revenue DESC;

-- ===========================================================
-- STEP 4: TIME SERIES ANALYSIS
-- ===========================================================

-- Revenue trend by month
SELECT DATE_TRUNC('month', date) AS monthly, round(SUM(unit_price * quantity)::numeric,2) AS total_revenue
FROM Walmart_cleaned
GROUP BY monthly
ORDER BY monthly;

-- Peak sales hours
SELECT EXTRACT(HOUR FROM time) AS hour, SUM(unit_price * quantity) AS total_revenue
FROM walmart_cleaned
GROUP BY hour
ORDER BY total_revenue DESC;

-- ===========================================================
-- STEP 5: CUSTOMER BEHAVIOR
-- ===========================================================

-- Customer buying behaviour analysis.

select 
case 
when Extract(hour from time) between 7 and 12 then 'Morning'
when Extract(hour from time) between 12 and 15 then 'AfterNoon'
when Extract(hour from time) between 15 and 18 then 'Evening'
Else 'Night'
End as shifts,
round(SUM(unit_price * quantity)::numeric,2) AS total_revenue
from walmart_cleaned
group by shifts
order by total_revenue;



-- Average spend per invoice
SELECT AVG(unit_price * quantity) AS avg_invoice_value
FROM sales_cleaned;

-- Ratings vs payment method
SELECT payment_method, AVG(rating) AS avg_rating
FROM sales_cleaned
GROUP BY payment_method
ORDER BY avg_rating DESC;

-- ===========================================================
-- STEP 6: OUTLIER DETECTION
-- ===========================================================

-- Top 5 invoices by revenue
SELECT invoice_id, SUM(unit_price * quantity) AS revenue
FROM sales_cleaned
GROUP BY invoice_id
ORDER BY revenue DESC
LIMIT 5;

-- High spenders giving low ratings
SELECT invoice_id, rating, SUM(unit_price * quantity) AS revenue
FROM sales_cleaned
GROUP BY invoice_id, rating
HAVING SUM(unit_price * quantity) > 1000 AND rating < 2
ORDER BY revenue DESC;

-- ===========================================================
-- STEP 7: KPI SUMMARY (Executive Dashboard)
-- ===========================================================

SELECT 
    COUNT(DISTINCT invoice_id) AS total_invoices,
    round(SUM(unit_price * quantity)::numeric,2) AS total_revenue,
    round(AVG(rating)::numeric,2) AS avg_rating,
    round(AVG(profit_margin)::numeric,2) AS avg_profit_margin,
    COUNT(DISTINCT branch) AS total_branches,
    COUNT(DISTINCT city) AS total_cities,
    COUNT(DISTINCT category) AS total_categories
FROM walmart_cleaned;

select * from walmart_cleaned;