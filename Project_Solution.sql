# Question -> List all employees who are managers.
USE companydata;
SELECT * FROM employees;
SELECT * FROM departments;
SELECT e.*
FROM Employees e
JOIN Departments d ON e.employee_id = d.manager_id;

# Question -> Find the total salary expenditure per department.
USE companydata;
SELECT * FROM employees;
SELECT * FROM departments;
SELECT d.department_name, SUM(e.salary) AS total_salary_expenditure
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

# Question -> List the employees working on more than one project.
# Getting data from tables
USE companydata;
SELECT * FROM employees;
SELECT * FROM employeesprojects;
SELECT ep.employee_id, COUNT(ep.project_id) AS project_count
FROM EmployeesProjects ep
GROUP BY ep.employee_id
HAVING COUNT(ep.project_id) > 1;

# Question -> Find the projects that have not ended yet.
SELECT * FROM projects;
SELECT * FROM projects
WHERE end_date > CURDATE();

# Question -> Identify the highest and lowest salaries for each job role.
SELECT * FROM employees; # Has salary column in it
SELECT * FROM jobs; # Has salary for each job title
SELECT j.job_title, MAX(e.salary) AS highest_salary, MIN(e.salary) AS lowest_salary
FROM Employees e
JOIN Jobs j ON e.job_id = j.job_id
GROUP BY j.job_title;

# Question -> List all employees whose email address contains ‘company’.
SELECT * FROM employees;
SELECT *
FROM Employees
WHERE email LIKE '%company%';

# Question -> Find the total number of employees in each department.
SELECT * FROM employees;
SELECT * FROM departments;
SELECT d.department_name, COUNT(e.employee_id) AS total_employees
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

# Question -> Calculate the average salary for each department.
SELECT * FROM employees;
SELECT * FROM departments;
SELECT d.department_name, AVG(e.salary) AS average_salary
FROM Employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

# Question -> List the employees who joined the company before 2020.
# Getting data from table
SELECT * FROM employees;
SELECT * FROM employees
WHERE hire_date < '2020-01-01';

# Question -> Display the details of projects handled by IT department employees.
# Getting the data from tables
SELECT * FROM employeesprojects;
SELECT * FROM projects;
SELECT * FROM employees;
SELECT * FROM departments; -- IT department has 3 department_id
SELECT p.*
FROM projects p
JOIN employeesprojects ep ON p.project_id = ep.project_id
JOIN employees e ON ep.employee_id = e.employee_id
WHERE e.department_id = 3;

# Calculate the Top 3 Products by Revenue for Each Customer
# Question: -> Write a query to find the top 3 products that generated the most revenue for each customer. 
# Return the customer_id, product_id, and the total_revenue for these top 3 products. 
# If a customer has fewer than 3 products, return all of them.

# Getting the database
USE storedatabase;
# Getting the data
SELECT * FROM customers;
SELECT * FROM order_details;
SELECT * FROM orders_0;
SELECT * FROM products;

WITH ProductRevenue AS (
    SELECT o.customer_id, od.product_id, SUM(od.quantity * p.price) AS total_revenue
    FROM orders_0 o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY o.customer_id, od.product_id
),
RankedProducts AS ( 
    SELECT customer_id, product_id, total_revenue,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_revenue DESC) AS rank_
    FROM ProductRevenue
)
SELECT customer_id, product_id, total_revenue
FROM RankedProducts
WHERE rank_ <= 3
ORDER BY customer_id, total_revenue DESC;

# Identify Customers with No Orders in the Last 6 Months
# Question:-> Write a query to find the customer_id and customer_name of customers 
# who have not placed any orders in the last 6 months from the current date
# Getting the data
SELECT * FROM customers;
SELECT * FROM orders_0;
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders_0 o ON c.customer_id = o.customer_id 
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
WHERE o.order_id IS NULL;

# Calculate the Average Order Value by Customer Segment
# Question:-> Write a query to calculate the average order value for each customer segment
# Return the segment_name and the average_order_value
# Getting the data
SELECT * FROM customers;
SELECT * FROM order_details;
SELECT * FROM orders_0;
WITH CustomerOrderValues AS (
    SELECT c.customer_id, SUM(o.total_amount) AS total_spending
    FROM customers c
    JOIN orders_0 o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
SegmentedCustomers AS (
    SELECT customer_id, total_spending,
        CASE 
            WHEN total_spending < 5000 THEN 'Low Value'
            WHEN total_spending BETWEEN 5000 AND 20000 THEN 'Medium Value'
            ELSE 'High Value'
        END AS segment_name
    FROM CustomerOrderValues
)
SELECT segment_name, AVG(total_spending) AS average_order_value
FROM SegmentedCustomers
GROUP BY segment_name;

# Identify Top Customers by Order Value
# Question: -> Write a query to find the top 3 customers who have spent the most money across all their orders. 
# Consider the total order_value for each customer and order the result by total spend in descending order.
# Getting the data
SELECT * FROM customers;
SELECT * FROM orders_0;
SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_order_value
FROM customers c
JOIN orders_0 o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_order_value DESC
LIMIT 3;

# Analyzing Customer Behavior Over Time
# Question:-> Identify customers who have made purchases in at least 3 different years. 
# Return the customer ID and the number of distinct years in which they made purchases.
# Getting the data
SELECT * FROM customers;
SELECT * FROM orders_0;
SELECT o.customer_id, COUNT(DISTINCT YEAR(o.order_date)) AS distinct_years
FROM orders_0 o
GROUP BY o.customer_id
HAVING COUNT(DISTINCT YEAR(o.order_date)) >= 3;

# Correlate Product Categories with Order Volume
# Question:-> Write a query to find the product category that has the highest average order volume (quantity). 
# Return the category name and the average quantity ordered.
# Getting that data
SELECT * FROM products;
SELECT * FROM order_details;
SELECT p.product_id, p.name, AVG(od.quantity) AS average_quantity_ordered
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.name
ORDER BY average_quantity_ordered DESC
LIMIT 1;

# Finding Frequent Customers and Their Orders
# Question:-> Identify customers who have placed more than 5 orders in any single month. 
# Return the customer ID, the month, and the number of orders they placed in that month.
SELECT o.customer_id,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(o.order_id) AS order_count
FROM orders_0 o
GROUP BY o.customer_id, order_month
HAVING COUNT(o.order_id) > 5;

# Track Customer Retention Rates
# Question:-> Calculate the retention rate of customers by identifying how many customers who made a purchase in the first quarter of any year 
# also made a purchase in the second quarter of the same year. 
# Return the year, the number of customers in Q1, the number of retained customers in Q2, and the retention rate.

WITH Q1_Customers AS (
    SELECT DISTINCT YEAR(order_date) AS year, customer_id
    FROM orders_0
    WHERE MONTH(order_date) IN (1, 2, 3)  -- Q1 months
),
Q2_Customers AS ( 
	SELECT DISTINCT YEAR(order_date) AS year, customer_id
    FROM orders_0
    WHERE MONTH(order_date) IN (4, 5, 6)  -- Q2 months
)
SELECT 
    q1.year,
    COUNT(DISTINCT q1.customer_id) AS num_customers_Q1,
    COUNT(DISTINCT q2.customer_id) AS num_retained_customers_Q2,
    COALESCE(COUNT(DISTINCT q2.customer_id) * 100.0 / NULLIF(COUNT(DISTINCT q1.customer_id), 0), 0) AS retention_rate
FROM Q1_Customers q1
LEFT JOIN Q2_Customers q2 ON q1.year = q2.year AND q1.customer_id = q2.customer_id
GROUP BY q1.year
ORDER BY q1.year;

# Identify Unusual Customer Behavior
# Question: Identify customers who have had a month with a number of orders that is more than double the average number of orders they typically place in a month. 
# Return the customer ID, the month in which this anomaly occurred, and the number of orders placed in that month.

WITH MonthlyOrderCounts AS (
    SELECT customer_id, DATE_FORMAT(order_date, '%Y-%m') AS order_month, COUNT(order_id) AS monthly_order_count
    FROM orders_0
    GROUP BY customer_id, order_month
),
AverageOrderCounts AS (
    SELECT customer_id, AVG(monthly_order_count) AS average_monthly_orders
    FROM MonthlyOrderCounts
    GROUP BY customer_id
)
SELECT m.customer_id, m.order_month, m.monthly_order_count
FROM MonthlyOrderCounts m
JOIN AverageOrderCounts a ON m.customer_id = a.customer_id
WHERE m.monthly_order_count > 2 * a.average_monthly_orders
ORDER BY m.customer_id, m.order_month;

# Product Cross-Sell Analysis
# Question:-> Identify pairs of products that are frequently bought together in the same order. 
# For each pair, return the two product IDs and the number of orders in which both products were bought together. 
# Only return pairs that appear in at least 3 different orders.
SELECT od1.product_id AS product_id_1, od2.product_id AS product_id_2,
    COUNT(DISTINCT o.order_id) AS order_count
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id 
    AND od1.product_id < od2.product_id  -- Ensure each pair is unique
JOIN orders_0 o ON od1.order_id = o.order_id
GROUP BY od1.product_id, od2.product_id
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY order_count DESC;

# Inventory Turnover Rate
# Question:-> Calculate the inventory turnover rate for each product. 
# The inventory turnover rate is defined as the total quantity sold divided by the average quantity available in inventory during the period. 
# Assume you have a table Inventory with product_id, quantity_available, and inventory_date. 
# Return the product ID and the turnover rate, sorted by the highest turnover rate.
SELECT * FROM order_details;
SELECT * FROM products;
# -- THERE IS NO INVENTORY TABLE. HENCE, WRITING THIS QUERY BY ASSUMPTIONS --

WITH TotalSold AS (
    SELECT od.product_id,
        SUM(od.quantity) AS total_quantity_sold
    FROM order_details od
    GROUP BY od.product_id
),
AverageInventory AS (
    SELECT i.product_id,
        AVG(i.quantity_available) AS average_quantity_available
    FROM Inventory i
    GROUP BY i.product_id
)
SELECT 
    COALESCE(ts.product_id, ai.product_id) AS product_id,
    COALESCE(total_quantity_sold, 0) AS total_quantity_sold,
    COALESCE(average_quantity_available, 0) AS average_quantity_available,
    CASE 
        WHEN COALESCE(average_quantity_available, 0) = 0 THEN 0
        ELSE COALESCE(total_quantity_sold, 0) / COALESCE(average_quantity_available, 1) 
    END AS inventory_turnover_rate
FROM TotalSold ts
JOIN AverageInventory ai ON ts.product_id = ai.product_id
ORDER BY inventory_turnover_rate DESC;

# Identify Most Consistent Products
# Question: Identify products that have the most consistent monthly sales volume, measured by the standard deviation of the number of orders across months. 
# Return the product ID and the standard deviation of the number of orders, sorted by the lowest standard deviation.
# Getting the data
SELECT * FROM order_details;
SELECT * FROM orders_0;
SELECT * FROM products;
WITH MonthlySales AS (
    SELECT od.product_id,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        COUNT(od.order_id) AS monthly_order_count
    FROM order_details od
    JOIN orders_0 o ON od.order_id = o.order_id
    GROUP BY od.product_id, order_month
),
ProductSales AS (
    SELECT product_id,
        STDDEV(monthly_order_count) AS std_dev_orders
    FROM MonthlySales
    GROUP BY product_id
)
SELECT product_id, std_dev_orders
FROM ProductSales
ORDER BY std_dev_orders ASC;





