 -- Understading the dataset.

-- Keep Raw dataset always seperate.

create table raw_data as
select * from retail_sales;

--- Data Cleaning:

-- Step 1: Check for Duplicates

-- Why: Duplicate invoices can skew revenue, profit, and ratings.

-- Check duplicate invoice IDs
SELECT invoice_id, COUNT(*) 
FROM retail_sales
GROUP BY invoice_id
HAVING COUNT(*) > 1;

-- Removing the Duplicates

DELETE FROM retail_sales
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM retail_sales
    GROUP BY invoice_id
);

-- Step 2: Handle Missing Values.

-- Count nulls per column
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
FROM sales;

-- Step 3: Validate Data Types & Ranges

-- Why: To avoid logical errors in analysis.


-- Check for negative prices or quantities
SELECT * 
FROM sales
WHERE unit_price < 0 OR quantity < 0;

-- Check rating range
SELECT * 
FROM sales
WHERE rating < 0 OR rating > 5;

-- Check profit margin range
SELECT * 
FROM sales
WHERE profit_margin < -1 OR profit_margin > 1;  -- assuming profit_margin is percentage

-- Step 4: Standardize Text Fields

-- Why: Inconsistent text (NY, New York, ny) breaks grouping.

-- Standardize branch names
UPDATE sales
SET branch = INITCAP(branch);

-- Standardize city names
UPDATE sales
SET city = INITCAP(city);

-- Standardize payment methods
UPDATE walmart_cleaned
SET payment_method = LOWER(payment_method);

-- Add Columns

ALTER TABLE walmart_cleaned
ADD COLUMN year INT


-- Populate Columns
UPDATE walmart_cleaned
SET 
    year = EXTRACT(YEAR FROM date)

ALTER TABLE walmart_cleaned
ADD COLUMN month_name TEXT;

UPDATE walmart_cleaned
SET month_name = TO_CHAR(date, 'Month');


-- Step 5: Handle Date & Time Issues

-- Why: Time-based analysis is critical.

-- Check date range
SELECT MIN(date) AS min_date, MAX(date) AS max_date FROM sales;

-- Check time anomalies
SELECT * FROM sales WHERE time < '00:00' OR time > '23:59';

-- Step 6: Create a Cleaned Dataset

-- Why: Always keep original intact; create a cleaned table:
CREATE TABLE walmart_cleaned AS
SELECT *
FROM sales
WHERE unit_price > 0 
  AND quantity > 0 
  AND rating BETWEEN 1 AND 5;

select * from walmart_cleaned;

SELECT month, round(SUM(unit_price * quantity)::numeric,2) AS total_revenue
FROM walmart_cleaned
GROUP BY month
ORDER BY month

SELECT year, round(SUM(unit_price * quantity)::numeric,2) AS total_revenue
FROM walmart_cleaned
GROUP BY year
ORDER BY year