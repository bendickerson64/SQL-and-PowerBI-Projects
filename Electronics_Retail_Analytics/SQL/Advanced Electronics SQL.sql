

#1. Find the store with the earliest opening sales on each state.
SELECT state, store_name, first_sale_date
FROM (


SELECT s.state, s.store_name, MIN(o.order_date) AS first_sale_date,
ROW_NUMBER() OVER(partition by s.state ORDER BY MIN(o.order_date)) as r
FROM stores s
JOIN orders o ON s.store_id = o.store_id
GROUP BY s.state, s.store_name

) t
WHERE r=1;

#2. Count how many customers per state have never placed an order.
SELECT  s.state, COUNT(c.customer_id) as customers_without_orders
FROM customers c
JOIN stores s ON o.store_id = s.store_id
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
GROUP BY s.state
ORDER BY customers_without_orders DESC;


#3. Which product categories generate the highest repeat purchases?
SELECT sub.category_name, COUNT(DISTINCT sub.customer_id) AS repeat_customers
FROM (
    SELECT c.customer_id, cat.category_name, COUNT(DISTINCT o.order_id) AS times_purchased
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories cat ON p.category_id = cat.category_id
    GROUP BY c.customer_id, cat.category_name
) AS sub
WHERE sub.times_purchased >= 2
GROUP BY sub.category_name
ORDER BY repeat_customers DESC;

  
### 4. Find the **oldest product line (by first sale date)** in each brand.
SELECT 
    b.brand_name,
    c.category_name,
    MIN(o.order_date) AS first_sold_date
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY b.brand_name, c.category_name
ORDER BY first_sold_date;


#5. Which states rely most heavily on discounts? Calculate the percentage of revenue that came from discounted items in each state.
WITH state_revenue AS (
    SELECT  
        s.state,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        SUM(CASE WHEN oi.discount > 0 
                 THEN oi.quantity * oi.list_price * (1 - oi.discount) 
                 ELSE 0 END) AS discounted_revenue
    FROM stores s
    JOIN orders o 
        ON s.store_id = o.store_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY s.state
)
SELECT 
    state,
    ROUND((discounted_revenue / total_revenue) * 100, 2) AS discounted_revenue_pct
FROM state_revenue
ORDER BY discounted_revenue_pct DESC;



#6. Which product categories drive the highest lifetime revenue per customer?
WITH category_revenue AS (
    SELECT 
        cat.category_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        COUNT(DISTINCT o.customer_id) AS distinct_customers
    FROM categories cat
    JOIN products p 
        ON cat.category_id = p.category_id
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    JOIN orders o 
        ON oi.order_id = o.order_id
    GROUP BY cat.category_name
)
SELECT 
    category_name,
    ROUND(total_revenue / NULLIF(distinct_customers, 0), 2) 
        AS avg_customer_lifetime_value
FROM category_revenue
ORDER BY avg_customer_lifetime_value DESC;


