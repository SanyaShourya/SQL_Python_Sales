CREATE DATABASE SQL_Project;
USE SQL_Project;
SELECT * FROM orders_table;
DESCRIBE orders_table;

-- changing the datatype of each column
ALTER TABLE orders_table
MODIFY COLUMN order_id INT PRIMARY KEY,
MODIFY COLUMN order_date DATETIME,
MODIFY COLUMN ship_mode VARCHAR(20),
MODIFY COLUMN segment VARCHAR(20),
MODIFY COLUMN country VARCHAR(20),
MODIFY COLUMN city VARCHAR(20),
MODIFY COLUMN state VARCHAR(20),
MODIFY COLUMN postal_code VARCHAR(20),
MODIFY COLUMN region VARCHAR(20),
MODIFY COLUMN category VARCHAR(20),
MODIFY COLUMN sub_category VARCHAR(20),
MODIFY COLUMN product_id VARCHAR(50),
MODIFY COLUMN quantity INT,
MODIFY COLUMN discount DECIMAL(7,2),
MODIFY COLUMN sale_price DECIMAL(7,2),
MODIFY COLUMN profit DECIMAL(7,2);

-- Finding top 10 highest revenue generating products
SELECT product_id, SUM(sale_price) AS revenue FROM orders_table
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;

-- Finding top 5 highest selling products in each region
WITH cte AS(
SELECT region,product_id,SUM(sale_price) AS sales
FROM orders_table
GROUP BY region,product_id)
SELECT * FROM(
SELECT *,
row_number() over(partition by region ORDER BY sales DESC) as rank_no
FROM cte) A
WHERE rank_no <= 5

-- Finding month over month growth comparison for 2022 and 2023 sales
WITH cte AS(
SELECT year(order_date) AS order_year,month(order_date) AS order_month,
SUM(sale_price) AS sales
FROM orders_table
GROUP BY year(order_date), month(order_date)
ORDER BY year(order_date),month(order_date)
)
SELECT order_month,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month
;

-- For each category which month had highest sale
WITH cte AS (
  SELECT 
    category, 
    DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
    SUM(sale_price) AS sales
  FROM orders_table
  GROUP BY category, DATE_FORMAT(order_date, '%Y%m')
)
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
  FROM cte
) AS ranked_sales
WHERE rn = 1;
