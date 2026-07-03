USE customerdb;

-- =========== Sales & Revenue Analysis =========
-- 1. Company ka total revenue kitna generate hua?
SELECT	
	SUM(total_order_value) company_total_revenue
FROM order_items;

-- 2. Sabse zyada revenue kis product category se aaya?
SELECT 
    p.product_category_name, SUM(oi.total_order_value) revenue
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 1;

-- 3. Top 10 revenue-generating products kaun se hain?
SELECT 
    p.product_category_name, SUM(oi.total_order_value) revenue
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- 4. Top 10 sellers kaun se hain?
SELECT
	s.seller_id,
    SUM(oi.total_order_value) revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_id
ORDER BY revenue DESC
LIMIT 10;

-- 5. Monthly revenue trend kya hai?
SELECT
		MONTH(o.order_purchase_timestamp) AS month,
		SUM(oi.total_order_value) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY MONTH(o.order_purchase_timestamp)
ORDER BY month ASC;

-- 6. Quarter-wise sales growth kitni hui?
SELECT
	*,
	LAG(revenue) OVER(ORDER BY current_quarter_revenue) previouse_revenue,
    current_quarter_revenue-LAG(revenue) OVER(ORDER BY current_quarter_revenue) growth
FROM
(    
SELECT
		QUARTER(o.order_purchase_timestamp) AS current_quarter_revenue,
		SUM(oi.total_order_value) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY QUARTER(o.order_purchase_timestamp)
ORDER BY current_quarter_revenue ASC
)t;

-- 7. Average order value (AOV) kitni hai?
SELECT
	order_id,
	ROUND(SUM(order_value) / COUNT(order_id), 2) AS AOV
    FROM (
        SELECT
            o.order_id,
            SUM(oi.total_order_value) AS order_value
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY o.order_id
    ) t;
    
-- 8. Kis month me sabse zyada sales hui?
SELECT
		MONTH(o.order_purchase_timestamp) AS month,
		SUM(oi.total_order_value) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY MONTH(o.order_purchase_timestamp)
ORDER BY revenue DESC;

-- 9. Weekend vs Weekday sales me kya difference hai?
SELECT
    CASE
        WHEN DAYNAME(o.order_purchase_timestamp) IN ('Saturday', 'Sunday')
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.total_order_value), 2) AS total_revenue

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    CASE
        WHEN DAYNAME(o.order_purchase_timestamp) IN ('Saturday', 'Sunday')
            THEN 'Weekend'
        ELSE 'Weekday'
    END;

-- 10. Revenue contribution by state/city kya hai?
SELECT
    c.customer_state,
    ROUND(SUM(oi.total_order_value), 2) AS total_revenue,
    ROUND(
        SUM(oi.total_order_value) * 100 /
        SUM(SUM(oi.total_order_value)) OVER (),
        2
    ) AS revenue_contribution_percentage
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

SELECT
    c.customer_city,
    ROUND(SUM(oi.total_order_value), 2) AS total_revenue,
    ROUND(
        SUM(oi.total_order_value) * 100 /
        SUM(SUM(oi.total_order_value)) OVER (),
        2
    ) AS revenue_contribution_percentage
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_city
ORDER BY total_revenue DESC;

-- 11. Total unique customers kitne hain?
SELECT
	COUNT(DISTINCT(customer_id)) total_unique_customer
FROM customers;

-- 12. Repeat customers ka percentage kitna hai?
SELECT
    ROUND(
        COUNT(CASE WHEN total_orders > 1 THEN 1 END)
        * 100.0
        / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM
(
    SELECT DISTINCT
        customer_id,
        COUNT(*) OVER(PARTITION BY customer_id) total_orders
    FROM orders
) t;

-- 13. Top customers kaun hain based on number of orders?
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 1;

-- Top customers kaun hain based on revenue?
SELECT
	c.customer_id,
    SUM(oi.total_order_value) revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
LEFT JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY c.customer_id
ORDER BY revenue DESC;

-- Customer retention rate kya hai?


-- First-time vs repeat customers ka revenue comparison kya hai?
SELECT
    customer_type,
    SUM(order_revenue) AS revenue
FROM
(
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.price) AS order_revenue,
        CASE
            WHEN COUNT(*) OVER(PARTITION BY o.customer_id) = 1
            THEN 'first-time'
            ELSE 'repeat'
        END AS customer_type
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) t
GROUP BY customer_type;

-- Kis state se sabse zyada customers aate hain?
SELECT
	customer_state,
    COUNT(*) total_customers
FROM customers 
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Average orders per customer kitne hain?
SELECT
	c.customer_id,
	ROUND(
        COUNT(o.order_id) * 1.0 /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_orders_per_customer
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id
ORDER BY avg_orders_per_customer DESC;

-- Customer lifetime value estimate kya hai?
SELECT
	c.customer_id,
	SUM(oi.total_order_value) life_time_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
LEFT JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY c.customer_id
ORDER BY life_time_revenue DESC;

-- Kis city ke customers sabse zyada spend karte hain?
SELECT
	c.customer_city,
    SUM(oi.total_order_value) total_spend
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
LEFT JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY c.customer_city
ORDER BY total_spend DESC;


-- ============= Product Analysis ===========
-- 21. Sabse zyada bikne wale products kaun se hain?
SELECT
	p.product_category_name,
	SUM(oi.total_order_value) revenue
FROM products p
JOIN order_items oi 
ON p.product_id=oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

-- 22. Sabse kam bikne wale products kaun se hain?
SELECT
	p.product_category_name,
	SUM(oi.total_order_value) revenue
FROM products p
JOIN order_items oi 
ON p.product_id=oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue ASC;

-- 23. Product category-wise revenue kya hai?
SELECT
	p.product_category_name,
	SUM(oi.total_order_value) revenue
FROM products p
JOIN order_items oi 
ON p.product_id=oi.product_id
GROUP BY p.product_category_name;

-- 24. Product category-wise order count kya hai?
SELECT
	p.product_category_name,
    COUNT(o.order_id) order_count
FROM products p 
JOIN order_items oi
ON p.product_id=oi.product_id
LEFT JOIN orders o
ON oi.order_id=o.order_id
GROUP BY p.product_category_name
ORDER BY order_count DESC;

-- 25. High-priced products ka performance kaisa hai?
SELECT
    high_priced_performance,
    SUM(revenue) total_revenue
FROM
(
SELECT
    SUM(oi.total_order_value) revenue,
    CASE 
		WHEN SUM(oi.total_order_value)>100000 THEN 'high'
        ELSE 'low'
	END high_priced_performance
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY p.product_category_name
)t
GROUP BY high_priced_performance;

-- 26. Kis category me highest average order value hai?
SELECT
	p.product_category_name,
    ROUND(AVG(oi.total_order_value), 2) average_order_value
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY average_order_value DESC
LIMIT 1;

-- 27. Product photos aur sales ke beech koi relation hai?
SELECT
	p.product_photos_qty,
    SUM(oi.total_order_value) revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_photos_qty
ORDER BY revenue DESC;

-- 28. Product description length aur sales ke beech koi relation hai?
SELECT
	p.product_description_lenght,
    SUM(oi.total_order_value) revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_description_lenght
ORDER BY revenue DESC;

-- ============= Seller Analysis ===========
-- 29. Har seller ne kitna revenue generate kiya?
SELECT
	s.seller_id,
    SUM(oi.total_order_value) revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_id
ORDER BY revenue DESC;

-- 30. Top-performing sellers kaun hain?
SELECT
	s.seller_id,
    SUM(oi.total_order_value) revenue,
    ROW_NUMBER() OVER(ORDER BY SUM(oi.total_order_value) DESC) top_performer
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_id
ORDER BY top_performer ASC
LIMIT 10;

-- 31. Lowest-performing sellers kaun hain?
SELECT
	s.seller_id,
    SUM(oi.total_order_value) revenue,
    ROW_NUMBER() OVER(ORDER BY SUM(oi.total_order_value) ASC) top_performer
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_id
ORDER BY top_performer DESC
LIMIT 10;

-- 32. Seller-wise average order value kya hai?
SELECT
	s.seller_id,
    ROUND(AVG(oi.total_order_value), 2) average_order_value
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_id
ORDER BY average_order_value DESC;

-- Kis state ke sellers sabse zyada revenue la rahe hain?
SELECT
    s.seller_state,
    SUM(oi.total_order_value) revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;

-- 33. Seller concentration analysis (Top 10 sellers kitna revenue contribute karte hain?)
SELECT
    ROUND(SUM(revenue)/(SELECT SUM(total_order_value) FROM order_items)*100, 2) top_10_seller_contribution
FROM
(
SELECT
	s.seller_id,
    SUM(oi.total_order_value) revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_id
ORDER BY revenue DESC
LIMIT 10
)t;

-- Delivery & Logistics Analysis
-- 34. Average delivery time kitna hai?
SELECT
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 0) average_delivery_days
FROM orders;

-- 35. Sabse slow deliveries kaun si hain?
SELECT
	order_id,
    order_purchase_timestamp,
    COALESCE(order_delivered_customer_date, 'N/A'),
    COALESCE(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date), 'N/A') delivery_day
FROM orders
ORDER BY delivery_day ASC;

-- 36. High-value orders me kaunsa payment method use hota hai?
SELECT 
    p.payment_type, COUNT(*) total_order
FROM
    order_payments p
        JOIN
    order_items oi ON p.order_id = oi.order_id
WHERE
    oi.total_order_value > (SELECT 
            AVG(total_order_value)
        FROM
            order_items)
GROUP BY p.payment_type
ORDER BY total_order DESC;

-- 37. Payment behavior aur review score ka relation kya hai?
SELECT 
    op.payment_type, AVG(orw.review_score)
FROM
    order_payments op
        JOIN
    orders o ON op.order_id = o.order_id
        LEFT JOIN
    order_review orw ON o.order_id = orw.order_id
GROUP BY op.payment_type;

-- =========== Review & Customer Satisfaction Analysis ==========
-- 38. Average review score kitna hai?
SELECT
	ROUND(AVG(review_score), 2) average_review_score
FROM order_review;

-- 39. Review score distribution kya hai?
SELECT 
    *,
    ROUND(number_of_reviews * 100.0 / (SELECT 
                    COUNT(*)
                FROM
                    order_review),
            2) AS review_percentagee
FROM
    (SELECT 
        review_score, COUNT(*) number_of_reviews
    FROM
        order_review
    GROUP BY review_score) t;

-- 40. Kin categories me sabse zyada 5-star reviews aaye?"
SELECT 
    p.product_category_name,
    ord.review_score,
    COUNT(*) review_count
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
        LEFT JOIN
    order_review ord ON oi.order_id = ord.order_id
WHERE
    ord.review_score = (SELECT 
            MAX(review_score)
        FROM
            order_review)
GROUP BY p.product_category_name;

-- 41. Kis category ko sabse achhe reviews milte hain?
SELECT 
    p.product_category_name, AVG(review_score) average_score
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
        LEFT JOIN
    order_review ord ON oi.order_id = ord.order_id
GROUP BY p.product_category_name
ORDER BY average_score DESC
LIMIT 1;

-- Kis category ko sabse bure reviews milte hain?
SELECT 
    p.product_category_name, AVG(review_score) average_score
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
        LEFT JOIN
    order_review ord ON oi.order_id = ord.order_id
GROUP BY p.product_category_name
ORDER BY average_score ASC
LIMIT 1;

-- 42. Delivery delay ka review score par kya impact hai?
SELECT 
    TIMESTAMPDIFF(DAY,
        o.order_estimated_delivery_date,
        o.order_delivered_customer_date) delivery_delay,
    ROUND(AVG(orw.review_score), 2) average_review_score
FROM
    orders o
        JOIN
    order_review orw ON o.order_id = orw.order_id
WHERE
    o.order_delivered_customer_date > o.order_estimated_delivery_date
        AND o.order_status = 'delivered'
GROUP BY TIMESTAMPDIFF(DAY,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date)
ORDER BY delivery_delay ASC;

-- 43. Top-rated sellers kaun hain?
SELECT 
    s.seller_id, ROUND(AVG(orw.review_score), 2) rate
FROM
    sellers s
        JOIN
    order_items oi ON s.seller_id = oi.seller_id
        JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    order_review orw ON o.order_id = orw.order_id
GROUP BY s.seller_id
ORDER BY rate DESC;

-- 44. Lowest-rated sellers kaun hain?
SELECT 
    s.seller_id, ROUND(AVG(orw.review_score), 2) rate
FROM
    sellers s
        JOIN
    order_items oi ON s.seller_id = oi.seller_id
        JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    order_review orw ON o.order_id = orw.order_id
GROUP BY s.seller_id
ORDER BY rate ASC;

-- 45. Revenue aur ratings ke beech koi relation hai?
SELECT
	*,
    NTILE(10) OVER(ORDER BY revenue) AS revenue_buckets
FROM
(
SELECT 
    o.order_id,
    AVG(orw.review_score) average_review_score,
    SUM(oi.total_order_value) revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
        LEFT JOIN
    order_review orw ON oi.order_id = orw.order_id
GROUP BY order_id
)t
ORDER BY revenue_buckets;

-- ========== Advanced Business Questions ===========
-- 46. Monthly growth rate kya hai?
SELECT
	*,
    ROUND((curret_revenue-previouse_revenue)/previouse_revenue*100, 2) growth_rate
FROM
(
	SELECT
		MONTHNAME(o.order_purchase_timestamp) AS month,
		SUM(oi.total_order_value) AS curret_revenue,
		LAG(SUM(oi.total_order_value)) OVER(ORDER BY MONTH(o.order_purchase_timestamp)) AS previouse_revenue
	FROM orders o
	JOIN order_items oi
	ON o.order_id=oi.order_id
	GROUP BY MONTHNAME(o.order_purchase_timestamp)
)t;

-- 47. Revenue forecasting ke liye historical trend kya dikhata hai?
SELECT
    month,
    current_revenue,
    ROUND(
        (current_revenue - previous_revenue) / previous_revenue * 100,
        2
    ) AS growth_rate
FROM
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.total_order_value) AS current_revenue,
        LAG(SUM(oi.total_order_value))
            OVER (ORDER BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) AS previous_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
) t;

-- 48. Pareto Analysis: 80% revenue kin products/sellers se aata hai?
SELECT
	*,
	cumulative_revenue/over_all_revenue*100 cumulative_percentage
FROM
(
	SELECT
		*,
		SUM(revenue) OVER(ORDER BY revenue DESC) cumulative_revenue,
		SUM(revenue) OVER() over_all_revenue
	FROM
	(
		SELECT
			p.product_category_name,
			SUM(oi.total_order_value) AS revenue
		FROM products p
		JOIN order_items oi
		ON p.product_id=oi.product_id
		GROUP BY p.product_category_name
	)t
)t2
WHERE cumulative_revenue/over_all_revenue*100<=80
ORDER BY revenue DESC;

-- 49. RFM Analysis (Recency, Frequency, Monetary) ke hisab se customer segmentation karo.
CREATE VIEW vw_rfm AS(

WITH recency AS(
	SELECT 
		customer_id,
		MAX(order_purchase_timestamp) last_order,
		TIMESTAMPDIFF(DAY, MAX(order_purchase_timestamp), CURDATE()) gap
	FROM orders
	GROUP BY customer_id
),

frequency AS(
	SELECT
		customer_id,
		COUNT(order_id) total_orders
	FROM orders 
	GROUP BY customer_id
),
monerary AS(
	SELECT
		c.customer_id,
		SUM(oi.total_order_value) total_spend
	FROM customers c
	JOIN orders o
	ON c.customer_id=o.customer_id
	JOIN order_items oi
	ON o.order_id=oi.order_id
	GROUP BY c.customer_id
)

SELECT
	r.customer_id,
	r.gap,
	f.total_orders,
	m.total_spend
FROM recency r
JOIN frequency f
ON r.customer_id=f.customer_id
JOIN monerary m
ON f.customer_id=m.customer_id
);

-- 50. Churned customers kaun hain?
SELECT
	*,
    CASE
		WHEN gap>90 THEN 'Churned'
        WHEN gap>30 THEN 'At risk'
		ELSE 'Active'
	END status
FROM
(
	SELECT
		c.customer_id,
		MAX(o.order_purchase_timestamp) last_order,
		TIMESTAMPDIFF(DAY, MAX(o.order_purchase_timestamp), CURDATE()) gap
	FROM customers c
	JOIN orders o
	ON c.customer_id=o.customer_id
	GROUP BY c.customer_id
)t;

-- 51. High-value customers kaun hain?
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        SUM(oi.total_order_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
)

SELECT *
FROM (
    SELECT
        *,
        PERCENT_RANK() OVER (ORDER BY revenue DESC) AS percent_rnk
    FROM customer_revenue
) t
WHERE percent_rnk <= 0.10
ORDER BY revenue DESC;

-- 52. Seasonal demand patterns kya hain?
SELECT
		MONTH(o.order_purchase_timestamp) AS month,
		SUM(oi.total_order_value) AS curret_revenue
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY MONTH(o.order_purchase_timestamp)
ORDER BY month ASC;

-- 53. Customer acquisition trend kya hai?
SELECT 
    YEAR(first_order_date) order_year,
    MONTH(first_order_date) order_month,
    COUNT(customer_id) new_customers
FROM
    (SELECT 
        customer_id, MIN(order_purchase_timestamp) first_order_date
    FROM
        orders
    GROUP BY customer_id) t
GROUP BY YEAR(first_order_date) , MONTH(first_order_date) , MONTHNAME(first_order_date)
ORDER BY order_year , order_month;

-- 54. Business expansion ke liye sabse promising states kaun si hain?
WITH state_wise_revenue AS(
	SELECT
		c.customer_state,
		SUM(oi.total_order_value) revenue
	FROM customers c
    JOIN orders o
    ON c.customer_id=o.customer_id
    JOIN order_items oi
    ON o.order_id=oi.order_id
    GROUP BY c.customer_state
),
state_wise_orders AS (
    SELECT
        c.customer_state,
        COUNT(o.order_id) AS count_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_state
),
state_wise_customers AS (
	SELECT
		customer_state,
        COUNT(*) AS count_customers
	FROM customers 
    GROUP BY customer_state
),
average_order_value AS (
    SELECT
        customer_state,
        SUM(order_value) / COUNT(order_id) AS AOV
    FROM (
        SELECT
            c.customer_state,
            o.order_id,
            SUM(oi.total_order_value) AS order_value
        FROM customers c
        JOIN orders o
            ON c.customer_id = o.customer_id
        JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY c.customer_state, o.order_id
    ) t
    GROUP BY customer_state
)

SELECT
	swr.customer_state,
    swr.revenue,
    swo.count_orders,
    swc.count_customers,
    aov.AOV
FROM state_wise_revenue swr
JOIN state_wise_orders swo
ON swr.customer_state=swo.customer_state
JOIN state_wise_customers swc
ON swo.customer_state=swc.customer_state
JOIN average_order_value aov
ON swc.customer_state=aov.customer_state;

-- 55. Un customers ko nikaalo jinka total order value (orders + order_items join karke) average order value se zyada hai.
SELECT 
    c.customer_id, oi.total_order_value
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    oi.total_order_value > (SELECT 
            AVG(total_order_value)
        FROM
            order_items);

-- 56. Har product category ka woh product nikaalo jiska price us category ke average price se sabse zyada deviate karta hai (scalar subquery + ABS).
SELECT
    p.product_category_name,
    p.product_id,
    oi.total_order_value AS price
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE ABS(
        oi.total_order_value -
        (
            SELECT AVG(oi2.total_order_value)
            FROM order_items oi2
            JOIN products p2
                ON oi2.product_id = p2.product_id
            WHERE p2.product_category_name = p.product_category_name
        )
      ) =
(
    SELECT MAX(
            ABS(
                oi3.total_order_value -
                (
                    SELECT AVG(oi4.total_order_value)
                    FROM order_items oi4
                    JOIN products p4
                        ON oi4.product_id = p4.product_id
                    WHERE p4.product_category_name = p.product_category_name
                )
            )
        )
    FROM order_items oi3
    JOIN products p3
        ON oi3.product_id = p3.product_id
    WHERE p3.product_category_name = p.product_category_name
);

-- 57. NOT EXISTS use karke woh sellers nikaalo jinka ek bhi order kabhi "delivered" status pe nahi gaya.
SELECT
	s.seller_id
FROM sellers s
WHERE NOT EXISTS (
				  SELECT
						1
				  FROM order_items oi
                  JOIN orders o
                  ON oi.order_id = o.order_id
                  WHERE oi.seller_id = s.seller_id AND o.order_status='canceled'
				);

-- 58. IN vs correlated subquery dono se same result nikaalo: woh customers jinhone kam se kam 1 order multiple states me deliver karaya ho.
SELECT 
    c.customer_id
FROM
    customers c
WHERE
    c.customer_id IN (SELECT 
            o.customer_id
        FROM
            orders o
                JOIN
            order_items oi ON o.order_id = oi.order_id
        GROUP BY o.customer_id
        HAVING COUNT(DISTINCT oi.seller_state) > 1);

-- 59. Single CTE: monthly revenue trend nikaalo (order_purchase_timestamp se month extract karke SUM revenue).
WITH monthly_revenue_trend AS(
	SELECT
		MONTH(o.order_purchase_timestamp) AS order_month,
		SUM(oi.total_order_value) AS revenue
	FROM orders o
	JOIN order_items oi
	ON o.order_id=oi.order_id
	GROUP BY MONTH(o.order_purchase_timestamp)
	ORDER BY order_month
)

SELECT * FROM monthly_revenue_trend;

-- 60. Multiple CTEs chain karo: pehle CTE me customer-wise total spend, doosre CTE me usi se top 10% spenders, phir unka order frequency nikaalo.
WITH customer_wise_total_spend AS (
	SELECT
		c.customer_id,
        SUM(oi.total_order_value) AS revenue
	FROM customers c
    JOIN orders o
    ON c.customer_id=o.customer_id
    JOIN order_items oi
    ON o.order_id=oi.order_id
    GROUP BY c.customer_id
),
top_rnk_percent_customers AS (
	SELECT
		customer_id,
        revenue,
		PERCENT_RANK() OVER(ORDER BY revenue DESC) AS top_rnk
	FROM customer_wise_total_spend
),
top_10_percent_customers AS (
	SELECT 
		customer_id,
        revenue,
        top_rnk
	FROM top_rnk_percent_customers
    WHERE top_rnk<=0.10
)

SELECT
	t.customer_id,
    COUNT(o.order_id) AS order_frequency
FROM top_10_percent_customers t
JOIN orders o
ON t.customer_id=o.customer_id
GROUP BY t.customer_id;

-- 61. CTE + window function combine karo: har customer ka order rank by date, aur unka running total spend (cumulative SUM).
WITH custome_rnk AS (
	SELECT
		c.customer_id,
        o.order_id,
        o.order_purchase_timestamp,
        RANK() OVER(PARTITION BY c.customer_id ORDER BY o.order_purchase_timestamp) customer_rn
	FROM customers c 
    JOIN orders o 
    ON c.customer_id=o.customer_id
),
cust_running_total AS (
	SELECT
		cr.customer_id,
        customer_rn,
        SUM(oi.total_order_value) OVER(PARTITION BY cr.customer_id ORDER BY cr.order_purchase_timestamp) AS running_total_spend
	FROM custome_rnk cr
    JOIN order_items oi
    ON cr.order_id = o.order_id
)

SELECT
	customer_id,
    customer_rn,
    running_total_spend
FROM cust_running_total
ORDER BY customer_rn;

-- 62. Ek view banao vw_customer_summary jisme har customer ka total orders, total spend, last order date ho — phir us view pe simple SELECT chalao jaise woh ek normal table ho.
CREATE VIEW vw_customer_summary AS 
(
	SELECT 
		o.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM(oi.total_order_value) AS total_spend
	FROM orders o
	JOIN order_items oi
    ON o.order_id=oi.order_id
    GROUP BY o.customer_id
);

-- 63. Customer Purchase Gap Analysis
WITH order_gap AS
(
    SELECT
        customer_id,
        order_purchase_timestamp,
        LAG(order_purchase_timestamp) OVER
        (
            PARTITION BY customer_id
            ORDER BY order_purchase_timestamp
        ) AS previous_order
    FROM orders
)

SELECT
    customer_id,
    ROUND(
        AVG(
            DATEDIFF(order_purchase_timestamp, previous_order)
        ),
        2
    ) AS avg_gap_days
FROM order_gap
WHERE previous_order IS NOT NULL
GROUP BY customer_id
ORDER BY avg_gap_days;

-- 64. Har month acquire hue customers ka next months me retention percentage nikalo.
WITH customer_acquisition_month AS
(
    SELECT
        customer_id,
        DATE_FORMAT(MIN(order_purchase_timestamp), '%Y-%m') AS first_order_month
    FROM orders
    GROUP BY customer_id
),

customer_order_month AS
(
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month
    FROM orders
),

cohort_data AS
(
    SELECT
        cam.customer_id,
        cam.first_order_month,
        com.order_month
    FROM customer_acquisition_month cam
    JOIN customer_order_month com
        ON cam.customer_id = com.customer_id
),

cohort_size AS
(
    SELECT
        first_order_month,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_data
    GROUP BY first_order_month
),

retained_customers AS
(
    SELECT
        first_order_month,
        order_month,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM cohort_data
    GROUP BY
        first_order_month,
        order_month
)

SELECT
    rc.first_order_month AS acquisition_month,
    rc.order_month,
    cs.total_customers,
    rc.retained_customers,
    ROUND(
        (rc.retained_customers * 100.0) / cs.total_customers,
        2
    ) AS retention_percentage
FROM retained_customers rc
JOIN cohort_size cs
    ON rc.first_order_month = cs.first_order_month
ORDER BY
    acquisition_month,
    order_month;
    
-- 65. Customer Loyalty Score
WITH monetary AS (
	SELECT
		c.customer_id,
        SUM(oi.total_order_value) AS revenue
	FROM customers c 
    JOIN orders o 
    ON c.customer_id=o.customer_id
    LEFT JOIN order_items oi
	ON o.order_id=oi.order_id
    GROUP BY c.customer_id
),
frequency AS (
	SELECT
		c.customer_id,
        COUNT(DISTINCT o.order_id) AS orders
	FROM customers c
    LEFT JOIN orders o 
    ON c.customer_id=o.customer_id
    GROUP BY c.customer_id
),
recency AS (
	SELECT
		customer_id,
        DATEDIFF(CURDATE(), last_order_date) AS recency
	FROM 
    (
		SELECT
			c.customer_id,
			MAX(o.order_purchase_timestamp) AS last_order_date
		FROM customers c
		LEFT JOIN orders o 
		ON c.customer_id=o.customer_id
		GROUP BY c.customer_id
	)t
),
rfm AS (
	SELECT
		m.customer_id,
		m.revenue,
		f.orders,
		r.recency
	FROM monetary m
	JOIN frequency f
	ON m.customer_id=f.customer_id
	JOIN recency r
	ON f.customer_id=r.customer_id
),
rfm_score AS (
	SELECT
		*,
        NTILE(5) OVER(ORDER BY revenue) AS monetary_score,
        NTILE(5) OVER(ORDER BY orders) AS frequency_score,
        NTILE(5) OVER(ORDER BY recency) AS recency_score
	FROM rfm
)

SELECT
	customer_id,
	revenue,
	orders,
	recency,
	monetary_score,
	frequency_score,
	recency_score,
	(monetary_score + frequency_score + recency_score) AS loyalty_score
FROM rfm_score
ORDER BY loyalty_score DESC;

-- 66. Top 5% customers company ke kitne percent revenue ke liye responsible hain?
SELECT
	ROUND( 
		SUM(revenue)/(
					SELECT SUM(total_order_value) FROM order_items
                    ),
		2) AS percent_rnk
FROM
(
	SELECT
		customer_id,
        revenue,
		PERCENT_RANK() OVER(ORDER BY revenue DESC) AS rnk
	FROM
	(
		SELECT
			c.customer_id,
			sum(oi.total_order_value) AS revenue
		FROM customers c
		JOIN orders o 
		ON c.customer_id=o.customer_id
		LEFT JOIN order_items oi 
		ON o.order_id=oi.order_id
		GROUP BY c.customer_id
	)t
)x
WHERE rnk<=0.05;

-- 67. Executive KPI Dashboard Query
-- Ek hi query me ye KPIs nikalo:
-- Total Revenue, Total Orders, Total Customers, AOV, Repeat Customer %, Average Rating, Average Delivery Days
WITH total_revenue AS(
	SELECT
		SUM(total_order_value) AS total_revenue
	FROM order_items
),
total_orders AS(
	SELECT
		COUNT(DISTINCT order_id) AS total_orders
	FROM orders
),
total_customers AS(
	SELECT
		COUNT(DISTINCT customer_id) AS total_customers
	FROM customers 
),
avg_order_value AS(
	SELECT 
    ROUND(SUM(total_order_value) / (SELECT 
                    COUNT(DISTINCT order_id)
                FROM
                    orders),
            2) AS AOV
FROM
    order_items
),
repeat_customer_percentage AS(
	WITH customer_orders AS
(
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)

SELECT
    COUNT(
        CASE
            WHEN total_orders > 1 THEN 1
        END
    ) AS repeat_customers,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(
            CASE
                WHEN total_orders > 1 THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;

-- 68. Customer Revenue Decile Analysis
WITH customer_revenue_analysis AS (
	SELECT
		customer_id,
        revenue,
        NTILE(10) OVER(ORDER BY revenue DESC) AS customer_buckets
	FROM
    (
		SELECT
			c.customer_id,
			SUM(oi.total_order_value) AS revenue
		FROM customers c
		JOIN orders o 
		ON c.customer_id=o.customer_id
		LEFT JOIN order_items oi
		ON o.order_id=oi.order_id
		GROUP BY c.customer_id
	)t
),
all_analysis AS(
	SELECT
		customer_buckets,
        customer_count,
        total_revenue,
        ROUND(total_revenue/SUM(total_revenue) OVER()*100, 2) AS revenue_contribution
	FROM	
    (
		SELECT 	
			customer_buckets,
			COUNT(customer_id) AS customer_count,
			SUM(revenue) AS total_revenue
		FROM customer_revenue_analysis
		GROUP BY customer_buckets
	)x
) 

SELECT
	customer_buckets,
	customer_count,
    total_revenue,
    revenue_contribution
FROM all_analysis;

-- 69. Rolling 3-Month Revenue Trend
SELECT
	order_month,
    current_month_revenue,
    LAG(current_month_revenue, 3) OVER(ORDER BY order_month) AS previouse_3_month_revenue
FROM
(
	SELECT
		DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
		AVG(oi.total_order_value) AS current_month_revenue
	FROM orders o
	LEFT JOIN order_items oi
	ON o.order_id=oi.order_id
	GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)t
ORDER BY order_month;

-- 70. Customer Purchase Sequence Analysis
WITH purchase_sequence AS(
	SELECT
		c.customer_id,
        o.order_id,
        oi.total_order_value,
        ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY o.order_purchase_timestamp) AS purchase_no
	FROM customers c
    JOIN orders o 
    ON c.customer_id=o.customer_id
    JOIN order_items oi 
    ON o.order_id=oi.order_id
)
SELECT
    purchase_no,
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(total_order_value) AS total_revenue,
    AVG(total_order_value) AS avg_revenue
FROM purchase_sequence
-- WHERE purchase_no <= 3
GROUP BY purchase_no
ORDER BY purchase_no;