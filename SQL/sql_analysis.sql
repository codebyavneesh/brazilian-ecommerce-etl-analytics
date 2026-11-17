-- ==============
-- Use Database
-- ==============
USE olist_db;

-- ===============================
-- Count Rows to Varify our data
-- ===============================
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM product_category_translation;
SELECT COUNT(*) FROM order_items;

-- =============
-- check joins
-- =============
SELECT
    COUNT(*)
FROM products p 
JOIN order_items oi 
    ON p.product_id = oi.product_id;

SELECT
    COUNT(*)
FROM products p 
LEFT JOIN product_category_translation pct 
    ON p.product_category_name = pct.product_category_name;

-- ==============
-- Varify Nulls
-- ==============
SELECT
    p.product_category_name,
    COUNT(*) AS product_count
FROM products p
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
WHERE pct.product_category_name_english IS NULL
GROUP BY p.product_category_name
ORDER BY product_count DESC;

-- ============================================================
-- Q1. Which Category contributes highest in overall business?
-- ============================================================
-- =======================
-- Category wise Revenue 
-- =======================
SELECT
    p.product_category_name,
    
    SUM(oi.price) AS total_revenue
FROM products p 
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

-- ================================
-- Category wise Delivered Orders
-- ================================
SELECT
    p.product_category_name,

    COUNT(DISTINCT o.order_id) AS total_orders
FROM products p 
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_orders DESC;

-- ================================
-- Category wise Unique Customers
-- ================================
SELECT
    p.product_category_name,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers
FROM products p 
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON o.order_id = oi.order_id
JOIN customers c 
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_customers DESC;

-- ====================================
-- Category wise Revenue contribution
-- ====================================
WITH category_wise_revenue AS (
    SELECT
        p.product_category_name,
        
        SUM(oi.price) AS total_revenue
    FROM products p 
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    JOIN orders o 
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.product_category_name
)

SELECT 
    product_category_name,
    total_revenue,

    SUM(total_revenue) OVER() AS overall_revenue,

    ROUND(
        (total_revenue * 100.0) / SUM(total_revenue) OVER(),
        2
    ) AS contribution_percentage
FROM category_wise_revenue
ORDER BY total_revenue DESC;

-- ===================================
-- Q2. Repeat Customer Purchase Rate
-- ===================================
-- ===============================================================
-- Write the query which calculate repeat customer wise revenue.
-- ===============================================================
SELECT
    c.customer_unique_id,

    SUM(oi.price) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c 
JOIN orders o 
    ON c.customer_id = o.customer_id
    AND o.order_status = 'delivered'
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
HAVING total_orders>1;

-- ===================================
-- Repeat customers Rate Calculation
-- ===================================
WITH customer_wise_revenue AS (
    SELECT
        c.customer_unique_id,

        SUM(oi.price) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c 
    JOIN orders o 
        ON c.customer_id = o.customer_id
        AND o.order_status = 'delivered'
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
overall_business_revenue AS (
    SELECT
        customer_unique_id,
        total_revenue,
        total_orders,

        SUM(total_revenue) OVER() AS overall_business_rev
    FROM customer_wise_revenue
),
repeat_customer_revenue AS (
    SELECT
        customer_unique_id,
        total_revenue,
        total_orders,
        overall_business_rev
    FROM overall_business_revenue
    WHERE total_orders>1
)
SELECT
    ROUND(
        (SUM(total_revenue) * 100.0) / overall_business_rev,
        2
    ) AS repeat_customers_contribution_per
FROM repeat_customer_revenue;

-- =======================
-- Repeat Customers Rate
-- ======================
WITH customer_wise_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c 
    JOIN orders o 
        ON c.customer_id = o.customer_id
        AND o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING total_orders>1
)
SELECT
    ROUND(
        COUNT(customer_unique_id) * 100.0 / (SELECT COUNT(DISTINCT c.customer_unique_id) FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_status = 'delivered'),
        2
    ) AS repeat_customer_rate
FROM customer_wise_orders;

SELECT
    COUNT(customer_unique_id)
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c 
    JOIN orders o 
        ON c.customer_id = o.customer_id
        AND o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING total_orders>=1
) AS t;


-- ===========================================================================================
-- Q3. How does each category compare with the other categories and with the overall average?
-- ===========================================================================================
WITH category_info AS (
    -- Level 1: one row = one customer in one category
    SELECT
        p.product_category_name,
        c.customer_unique_id,
        SUM(oi.price)              AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON o.order_id = oi.order_id
        AND o.order_status = 'delivered'
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY p.product_category_name, c.customer_unique_id
),
category_summary AS (
    -- Level 2: one row = one category
    SELECT
        product_category_name,
        SUM(total_revenue) AS category_revenue,
        COUNT(*)           AS total_customers,
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers
    FROM category_info
    GROUP BY product_category_name
)
SELECT
    product_category_name,
    category_revenue,
    ROUND(category_revenue * 100.0 / SUM(category_revenue) OVER(), 2) AS revenue_contribution_pct,
    total_customers,
    repeat_customers,
    ROUND(repeat_customers * 100.0 / total_customers, 2) AS repeat_rate_pct,
    ROUND(SUM(repeat_customers) OVER() * 100.0
          / SUM(total_customers) OVER(), 2) AS overall_repeat_rate_pct
FROM category_summary
ORDER BY category_revenue DESC;
SELECT
    COUNT(DISTINCT c.customer_unique_id)
FROM customers c 
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'