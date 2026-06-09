USE practice_db;

SELECT * FROM projects.sales;

-- Data Cleaning --

-- 1.Change the purchase_date to date format --
SET sql_safe_updates = 0;                                      -- ensure safe updates to the table --

UPDATE projects.sales                                         
SET purchase_date = str_to_date(purchase_date, '%d/%m/%Y');     -- Set new date format --

ALTER TABLE projects.sales -- change text type to date --
MODIFY purchase_date DATE;                                     -- Modify the column to change the data type as date --

DESCRIBE projects.sales;                                              -- verify our change --


-- 2.Change time_of_purchase format to Time --

UPDATE projects.sales  -- time format changed --
SET time_of_purchase = str_to_date(time_of_purchase, '%H:%i:%s');        -- Set time_of_purchase in time format --

ALTER TABLE projects.sales  -- change text type to Time --
MODIFY time_of_purchase TIME;                                          -- Modify the column to change data type as time --



-- Data Analysis --

-- 1.What are the top 5 most selling products by quantity? --
SELECT 
	product_name,                             -- Show the name of products --
    SUM(quantity) AS total_quantity_sold      -- Total the quantities for each product into another column --
FROM projects.sales
WHERE status = 'delivered'                    -- Filter by the status of delievery as 'delievere' --
GROUP BY product_name                         -- Combine like products into one cell --
ORDER BY total_quantity_sold                  -- Sort by total_quantity --
LIMIT 5;                                      -- Limit results to only the top 5 --


-- 2.Which products are most frequently cancelled? --
SELECT
	product_name,                         -- Show product names --
    COUNT(*) AS total_cancelled           -- Count all product names into another column --
FROM projects.sales
WHERE status = 'cancelled'                -- Filter by status of delivery 'cancelled' --
GROUP BY product_name                     -- Combine like products --
ORDER BY total_cancelled DESC             -- Sort by total_cancelled in descending order --
LIMIT 5;                                  -- Limit to only top 5 --

-- 3.What times of the day has the highest number of purchases? --

SELECT 
	CASE                                                                 -- Group time of purchase using CASE statements into another column --
		WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'morning'
		WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'afternoon'
        WHEN HOUR(time_of_purchase) BETWEEN 18 AND 23 THEN 'evening'
        ELSE 'night'
		END AS time_of_day,
	COUNT(*) AS total_order                                              -- Aggregate toproducts as total_order --
FROM projects.sales
GROUP BY time_of_day                                                     -- Combine like product by time_of_day --
ORDER BY total_order DESC;                                               -- Sort by total_order in descending order --


-- 4.Who are the top 5 highest spending customers? --
SELECT 
	customer_id,                                                        -- Show customer ID --
    customer_name,                                                      -- Show customer name --
    SUM(quantity*price) AS total_spend_of_the_customer                  -- Multiply quantity by price and add in each as new column --
FROM projects.sales
WHERE status = 'delivered'                                              -- Filter by status 'delivered' --
GROUP BY customer_id, customer_name                                     -- Combine like products based on customer_id and customer_name --
ORDER BY total_spend_of_the_customer DESC                               -- Sort by total_spend_of_the_customer in descending order --
LIMIT 5;                                                                -- Limit results to top 5 --


-- 5.Which product categories generate the highest revenue? --
SELECT 
	product_category,                                                   -- Show product_category --
    SUM(quantity*price) AS revenue                                      -- Multiply each quantity by price and add in each as revenue --
FROM projects.sales
WHERE status = 'delivered'                                               -- Filter by status 'delivered' --
GROUP BY product_category                                                -- Combine like products based on product_cateogory --
ORDER BY revenue DESC;                                                   -- Sort by revenue in descending order --




-- 6.What is the return/cancellation rate per product category? --
SELECT
	product_category,                                                     -- Show product_category --
    COUNT(*) AS total_orders,                                             -- Count each product category into a new column as total_orders --
    SUM(status = 'returned') AS returned_orders,                          -- Sum up all returned orders into another column as returned_orders --
    SUM(status = 'cancelled') AS cancelled_order,                          -- Sum up all cancelled orders into another column as cancelled_orders --
	ROUND(SUM(status = 'returned')/COUNT(*) * 100, 0) AS returned_rate,    -- Find the percentage of returned_oders to 2 decimal places --
    ROUND(SUM(status = 'cancelled')/COUNT(*) * 100, 0) AS cancelled_rate    -- Find the percentage of cancelled_oders to 2 decimal places --
FROM projects.sales
GROUP BY product_category;                                                  -- Combine all product_categories --


-- 7.What is the preferred payment mode? --
SELECT 
	payment_mode,                                                        -- Show payment_mode --
    COUNT(*) AS total_count                                              -- Count all payment modes --
FROM projects.sales
GROUP BY payment_mode                                                   -- Combine each payment role --
ORDER BY total_count DESC                                               -- Sort by total_count in descending order --
LIMIT 1;                                                                -- Show only the topmost result --

-- 8.How does age group affect purchasing behavior? --
SELECT 
	CASE                                                               -- grouping the ages --
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
        END AS age_group,
        SUM(quantity*price) AS total_purchase_by_age_group            -- Calculate revenue --
FROM projects.sales
GROUP BY age_group                                                    -- Combine by age groups --
ORDER BY total_purchase_by_age_group DESC;                            -- Sort by the total_purchase_by_age_group --


-- 9.What is the monthly sales trend? --
SELECT 
	date_format(purchase_date, '%Y-%m') AS monthly_purchase,          -- Show and chnage purchase_date format in new column --
    SUM(quantity*price) AS total_sales,                               -- Calculate revenue --
    SUM(quantity)                                                     -- Sum the quantities -- 
FROM projects.sales
GROUP BY monthly_purchase                                             -- Combine as monthly_purchase --
ORDER BY monthly_purchase;                                            -- Sort by monthly purchase --

-- 10.Are certain genders buying more specific product categories? --
SELECT
	gender,                                                           -- Show gender --
    product_category,                                                 -- Show product_category --
    COUNT(product_category) AS total_purchase                         -- Count product_category into new column --
FROM projects.sales
GROUP BY  product_category, gender                                     -- Combine as product_category, gender --
ORDER BY total_purchase DESC;                                         -- Sort by total_purchase in descending order --
