


-- Q1 [Basic] Overall business summary
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders)    AS total_orders,
    (SELECT COUNT(*) FROM products)  AS total_products,
    (SELECT SUM(total_amount) FROM orders WHERE status = 'completed') AS total_revenue;


-- Q2 [Basic] Revenue by product category
SELECT
    c.name AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) * 100.0
          / (SELECT SUM(quantity * unit_price) FROM order_items), 1) AS revenue_pct
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY total_revenue DESC;


-- Q3 [Basic] Top 10 best-selling products
SELECT TOP 10
    p.name AS product,
    c.name AS category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.name, c.name
ORDER BY revenue DESC;


-- Q4 [Basic] Monthly revenue trend
SELECT
    FORMAT(order_date, 'yyyy-MM') AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS monthly_revenue,
    ROUND(AVG(total_amount), 0) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month;


-- Q5 [Basic] Revenue by payment mode
SELECT
    payment_mode,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue,
    ROUND(AVG(total_amount), 0) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY payment_mode
ORDER BY total_orders DESC;


-- Q6 [Intermediate] Top 5 customers by total spend
SELECT TOP 5
    c.name,
    c.city,
    c.state,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.name, c.city, c.state
ORDER BY total_spend DESC;


-- Q7 [Intermediate] Customers who never placed an order
SELECT
    c.customer_id,
    c.name,
    c.email,
    c.city,
    c.joined_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Q8 [Intermediate] State-wise revenue distribution
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.state
ORDER BY revenue DESC;


-- Q9 [Intermediate] Order status breakdown
SELECT
    status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 1) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- Q10 [Intermediate] Average order value by city
SELECT
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.total_amount), 0) AS avg_order_value,
    SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.city
HAVING COUNT(o.order_id) >= 2
ORDER BY avg_order_value DESC;


-- Q11 [Advanced] Low-stock products that are also high sellers
SELECT
    p.name,
    p.stock AS current_stock,
    COUNT(oi.item_id) AS times_ordered,
    SUM(oi.quantity) AS units_sold
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.stock
HAVING p.stock < 50 AND COUNT(oi.item_id) > 3
ORDER BY p.stock ASC;


-- Q12 [Advanced] Customers who spent above average (nested subquery)
SELECT
    c.name,
    c.city,
    SUM(o.total_amount) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.name, c.city
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT customer_id, SUM(total_amount) AS customer_total
        FROM orders
        WHERE status = 'completed'
        GROUP BY customer_id
    ) t
)
ORDER BY total_spend DESC;


-- Q13 [Advanced] Product rank within each category (window function)
SELECT
    c.name AS category,
    p.name AS product,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    RANK() OVER (
        PARTITION BY c.category_id
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    ) AS rank_in_category
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.name, p.product_id, p.name
ORDER BY c.name, rank_in_category;


-- Q14 [Advanced] Running total of monthly revenue (CTE + window function)
WITH monthly_revenue AS (
    SELECT
        FORMAT(order_date, 'yyyy-MM') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)
SELECT
    month,
    revenue AS monthly_revenue,
    SUM(revenue) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING) AS cumulative_revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 1) AS pct_of_annual
FROM monthly_revenue
ORDER BY month;


-- Q15 [Advanced] Full customer 360-degree report
SELECT
    c.customer_id,
    c.name,
    c.city,
    c.state,
    c.joined_date AS member_since,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN o.status = 'returned'  THEN 1 ELSE 0 END) AS returned,
    ROUND(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount ELSE 0 END), 0) AS total_spend,
    ROUND(AVG(CASE WHEN o.status = 'completed' THEN o.total_amount END), 0) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city, c.state, c.joined_date
ORDER BY total_spend DESC;
