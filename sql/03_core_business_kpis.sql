-- ====================================================================
-- RETAIL SALES ENTERPRISE ANALYTICS - CORE BUSINESS KPIS (03)
-- Relational Queries with Multi-Table Joins & Aggregations
-- ====================================================================

-- --------------------------------------------------------------------
-- KPI 1: Executive Summary - Total Sales, Profit, Margin & Order Volume
-- --------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(DISTINCT o.customer_id) AS Active_Customers,
    SUM(oi.quantity) AS Total_Units_Sold,
    ROUND(SUM(oi.line_total), 2) AS Gross_Revenue,
    ROUND(SUM(oi.line_cost), 2) AS Total_COGS,
    ROUND(SUM(oi.line_profit), 2) AS Net_Profit,
    ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Profit_Margin_Percentage,
    ROUND(SUM(oi.line_total) / COUNT(DISTINCT o.order_id), 2) AS Average_Order_Value
FROM fact_orders o
JOIN fact_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';

-- --------------------------------------------------------------------
-- KPI 2: Category & Subcategory Profitability Breakdown
-- --------------------------------------------------------------------
SELECT 
    p.category AS Category,
    p.subcategory AS Subcategory,
    COUNT(DISTINCT o.order_id) AS Order_Count,
    SUM(oi.quantity) AS Units_Sold,
    ROUND(SUM(oi.line_total), 2) AS Revenue,
    ROUND(SUM(oi.line_profit), 2) AS Net_Profit,
    ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Margin_Pct,
    ROUND(SUM(oi.line_total) * 100.0 / (
        SELECT SUM(oi2.line_total) 
        FROM fact_order_items oi2 
        JOIN fact_orders o2 ON oi2.order_id = o2.order_id 
        WHERE o2.order_status = 'Delivered'
    ), 2) AS Revenue_Contribution_Pct
FROM fact_order_items oi
JOIN fact_orders o ON oi.order_id = o.order_id
JOIN dim_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category, p.subcategory
ORDER BY Revenue DESC;

-- --------------------------------------------------------------------
-- KPI 3: Regional Sales & Store Performance Scorecard
-- --------------------------------------------------------------------
SELECT 
    s.region AS Region,
    s.store_name AS Store_Name,
    s.store_type AS Store_Type,
    s.city AS City,
    COUNT(DISTINCT o.order_id) AS Orders_Processed,
    ROUND(SUM(oi.line_total), 2) AS Total_Sales,
    ROUND(SUM(oi.line_profit), 2) AS Total_Profit,
    ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Profit_Margin_Pct,
    RANK() OVER (PARTITION BY s.region ORDER BY SUM(oi.line_total) DESC) AS Regional_Store_Rank
FROM fact_orders o
JOIN dim_stores s ON o.store_id = s.store_id
JOIN fact_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY s.region, s.store_name, s.store_type, s.city
ORDER BY Region, Total_Sales DESC;

-- --------------------------------------------------------------------
-- KPI 4: Top 10 Best-Selling Products by Revenue & Margin
-- --------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name AS Product_Name,
    p.category AS Category,
    p.brand AS Brand,
    SUM(oi.quantity) AS Total_Units_Sold,
    ROUND(SUM(oi.line_total), 2) AS Total_Revenue,
    ROUND(SUM(oi.line_profit), 2) AS Total_Profit,
    ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Margin_Pct,
    DENSE_RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS Revenue_Rank
FROM fact_order_items oi
JOIN fact_orders o ON oi.order_id = o.order_id
JOIN dim_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY Total_Revenue DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- KPI 5: Top 10 High-Value VIP Customers
-- --------------------------------------------------------------------
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS Customer_Name,
    c.city AS City,
    c.region AS Region,
    COUNT(DISTINCT o.order_id) AS Total_Orders_Placed,
    SUM(oi.quantity) AS Total_Items_Bought,
    ROUND(SUM(oi.line_total), 2) AS Lifetime_Spend,
    ROUND(AVG(o.total_amount), 2) AS Avg_Order_Value,
    DENSE_RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS Customer_Spend_Rank
FROM fact_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
JOIN fact_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.region
ORDER BY Lifetime_Spend DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- KPI 6: Payment Method Share & Average Basket Value
-- --------------------------------------------------------------------
SELECT 
    o.payment_method AS Payment_Method,
    COUNT(DISTINCT o.order_id) AS Order_Count,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM fact_orders WHERE order_status = 'Delivered'), 2) AS Order_Share_Pct,
    ROUND(SUM(oi.line_total), 2) AS Total_Sales,
    ROUND(AVG(o.total_amount), 2) AS Avg_Transaction_Value
FROM fact_orders o
JOIN fact_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.payment_method
ORDER BY Total_Sales DESC;

-- --------------------------------------------------------------------
-- KPI 7: Customer Demographic Performance (Gender & Age Groups)
-- --------------------------------------------------------------------
SELECT 
    c.gender AS Gender,
    CASE 
        WHEN c.age < 25 THEN 'Under 25 (Gen Z)'
        WHEN c.age BETWEEN 25 AND 35 THEN '25-35 (Young Professionals)'
        WHEN c.age BETWEEN 36 AND 50 THEN '36-50 (Established Adults)'
        ELSE '50+ (Seniors)'
    END AS Age_Group,
    COUNT(DISTINCT c.customer_id) AS Customer_Count,
    COUNT(DISTINCT o.order_id) AS Orders_Placed,
    ROUND(SUM(oi.line_total), 2) AS Total_Revenue,
    ROUND(SUM(oi.line_profit), 2) AS Total_Profit
FROM fact_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
JOIN fact_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY 
    c.gender,
    CASE 
        WHEN c.age < 25 THEN 'Under 25 (Gen Z)'
        WHEN c.age BETWEEN 25 AND 35 THEN '25-35 (Young Professionals)'
        WHEN c.age BETWEEN 36 AND 50 THEN '36-50 (Established Adults)'
        ELSE '50+ (Seniors)'
    END
ORDER BY Total_Revenue DESC;
