-- ====================================================================
-- RETAIL SALES ENTERPRISE ANALYTICS - ADVANCED INDUSTRY SQL (04)
-- Advanced Business Intelligence: RFM, Cohorts, Pareto, Elasticity, YoY
-- Dialect: ANSI SQL (MySQL 8.0+ / PostgreSQL 12+ / Modern SQL Engines)
-- ====================================================================

-- ====================================================================
-- 1. RFM CUSTOMER SEGMENTATION (Recency, Frequency, Monetary Value)
-- ====================================================================
-- Calculates R, F, M metrics for each customer, divides them into 4 quartiles (NTILE),
-- and classifies them into actionable business segments (Champions, Loyal, At-Risk, Lost).

WITH Customer_RFM_Raw AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        c.city,
        c.region,
        -- Recency: Days between reference date ('2024-12-31') and customer's latest order
        DATEDIFF('2024-12-31', MAX(o.order_date)) AS recency_days,
        -- Frequency: Total delivered orders
        COUNT(DISTINCT o.order_id) AS frequency_orders,
        -- Monetary: Total spend
        SUM(oi.line_total) AS monetary_spend
    FROM dim_customers c
    JOIN fact_orders o ON c.customer_id = o.customer_id
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city, c.region
),
RFM_Scores AS (
    SELECT 
        customer_id,
        customer_name,
        city,
        region,
        recency_days,
        frequency_orders,
        monetary_spend,
        -- Lower recency = better score (4 is best, 1 is worst)
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        -- Higher frequency = better score (4 is best)
        NTILE(4) OVER (ORDER BY frequency_orders ASC) AS f_score,
        -- Higher monetary = better score (4 is best)
        NTILE(4) OVER (ORDER BY monetary_spend ASC) AS m_score
    FROM Customer_RFM_Raw
),
RFM_Segmentation AS (
    SELECT 
        customer_id,
        customer_name,
        city,
        region,
        recency_days,
        frequency_orders,
        monetary_spend,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score) AS rfm_composite_score,
        CASE 
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions (VIP)'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal Customers'
            WHEN r_score >= 3 AND f_score = 1 THEN 'Recent New Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk (Need Retention)'
            WHEN r_score = 1 AND f_score <= 2 THEN 'Hibernating / Lost'
            ELSE 'Potential Loyalists'
        END AS Customer_Segment
    FROM RFM_Scores
)
SELECT 
    Customer_Segment,
    COUNT(*) AS Total_Customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM RFM_Segmentation), 2) AS Customer_Share_Pct,
    ROUND(SUM(monetary_spend), 2) AS Total_Segment_Revenue,
    ROUND(AVG(monetary_spend), 2) AS Avg_Revenue_Per_Customer,
    ROUND(AVG(recency_days), 1) AS Avg_Recency_Days,
    ROUND(AVG(frequency_orders), 1) AS Avg_Order_Frequency
FROM RFM_Segmentation
GROUP BY Customer_Segment
ORDER BY Total_Segment_Revenue DESC;


-- ====================================================================
-- 2. MONTH-OVER-MONTH (MoM) & YEAR-OVER-YEAR (YoY) GROWTH TRENDS
-- ====================================================================
-- Uses CTE and Window Function LAG() to calculate monthly growth velocity.

WITH Monthly_Aggregates AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.line_total), 2) AS monthly_revenue,
        ROUND(SUM(oi.line_profit), 2) AS monthly_profit,
        ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS profit_margin_pct
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
)
SELECT 
    order_year,
    order_month,
    total_orders,
    monthly_revenue,
    monthly_profit,
    profit_margin_pct,
    -- Previous month revenue
    LAG(monthly_revenue, 1) OVER (ORDER BY order_year, order_month) AS prev_month_revenue,
    -- MoM Growth %
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY order_year, order_month)) * 100.0 / 
        NULLIF(LAG(monthly_revenue, 1) OVER (ORDER BY order_year, order_month), 0),
        2
    ) AS MoM_Revenue_Growth_Pct,
    -- YoY Growth % (Comparing with same month in previous year, lag 12)
    LAG(monthly_revenue, 12) OVER (ORDER BY order_year, order_month) AS same_month_last_year_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 12) OVER (ORDER BY order_year, order_month)) * 100.0 / 
        NULLIF(LAG(monthly_revenue, 12) OVER (ORDER BY order_year, order_month), 0),
        2
    ) AS YoY_Revenue_Growth_Pct
FROM Monthly_Aggregates
ORDER BY order_year, order_month;


-- ====================================================================
-- 3. COHORT RETENTION ANALYSIS
-- ====================================================================
-- Tracks retention: Customers who made first purchase in Month 0,
-- returning in Month +1, +2, +3, etc.

WITH Customer_First_Purchase AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
Customer_Activities AS (
    SELECT 
        o.customer_id,
        cfp.cohort_month,
        DATE_TRUNC('month', o.order_date) AS activity_month,
        -- Difference in months between activity and cohort
        (EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM cfp.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM cfp.cohort_month)) AS month_index
    FROM fact_orders o
    JOIN Customer_First_Purchase cfp ON o.customer_id = cfp.customer_id
    WHERE o.order_status = 'Delivered'
)
SELECT 
    cohort_month,
    COUNT(DISTINCT CASE WHEN month_index = 0 THEN customer_id END) AS Cohort_Size_M0,
    COUNT(DISTINCT CASE WHEN month_index = 1 THEN customer_id END) AS Retained_M1,
    COUNT(DISTINCT CASE WHEN month_index = 2 THEN customer_id END) AS Retained_M2,
    COUNT(DISTINCT CASE WHEN month_index = 3 THEN customer_id END) AS Retained_M3,
    COUNT(DISTINCT CASE WHEN month_index = 4 THEN customer_id END) AS Retained_M4,
    COUNT(DISTINCT CASE WHEN month_index = 5 THEN customer_id END) AS Retained_M5,
    -- Retention Percentages
    ROUND(COUNT(DISTINCT CASE WHEN month_index = 1 THEN customer_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN customer_id END), 0), 1) AS M1_Retention_Pct,
    ROUND(COUNT(DISTINCT CASE WHEN month_index = 2 THEN customer_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN customer_id END), 0), 1) AS M2_Retention_Pct
FROM Customer_Activities
GROUP BY cohort_month
ORDER BY cohort_month;


-- ====================================================================
-- 4. PARETO PRINCIPLE (80/20 RULE) PRODUCT ANALYSIS
-- ====================================================================
-- Tests if top 20% of products generate 80% of total company revenue.

WITH Product_Revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.line_total) AS product_revenue,
        SUM(oi.quantity) AS product_units
    FROM dim_products p
    JOIN fact_order_items oi ON p.product_id = oi.product_id
    JOIN fact_orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
),
Product_Cumulative AS (
    SELECT 
        product_id,
        product_name,
        category,
        product_revenue,
        product_units,
        -- Running cumulative revenue
        SUM(product_revenue) OVER (ORDER BY product_revenue DESC) AS cumulative_revenue,
        -- Total company revenue
        SUM(product_revenue) OVER () AS total_company_revenue,
        -- Product index ranking
        ROW_NUMBER() OVER (ORDER BY product_revenue DESC) AS product_rank,
        COUNT(*) OVER () AS total_products
    FROM Product_Revenue
)
SELECT 
    product_rank,
    product_name,
    category,
    ROUND(product_revenue, 2) AS Product_Revenue,
    ROUND(cumulative_revenue, 2) AS Cumulative_Revenue,
    ROUND(cumulative_revenue * 100.0 / total_company_revenue, 2) AS Cumulative_Revenue_Pct,
    ROUND(product_rank * 100.0 / total_products, 2) AS Cumulative_Product_Pct,
    CASE 
        WHEN (cumulative_revenue * 100.0 / total_company_revenue) <= 80.0 THEN 'Core 80% Driver (Top Tier)'
        ELSE 'Long Tail Product'
    END AS Pareto_Classification
FROM Product_Cumulative
ORDER BY product_rank;


-- ====================================================================
-- 5. 30-DAY ROLLING MOVING AVERAGE & DAILY REVENUE RUNNING TOTALS
-- ====================================================================
-- Smooths out daily volatility using window frames (ROWS BETWEEN 29 PRECEDING).

WITH Daily_Sales AS (
    SELECT 
        o.order_date,
        COUNT(DISTINCT o.order_id) AS daily_orders,
        SUM(oi.line_total) AS daily_revenue,
        SUM(oi.line_profit) AS daily_profit
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.order_date
)
SELECT 
    order_date,
    daily_orders,
    ROUND(daily_revenue, 2) AS Daily_Revenue,
    ROUND(
        AVG(daily_revenue) OVER (
            ORDER BY order_date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2
    ) AS Moving_Avg_30_Day_Revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS Cumulative_Year_To_Date_Revenue
FROM Daily_Sales
ORDER BY order_date;


-- ====================================================================
-- 6. DISCOUNT ELASTICITY & PROFIT MARGIN CANNIBALIZATION ANALYSIS
-- ====================================================================
-- Evaluates whether higher promotional discounts drive healthy volume or destroy net margins.

SELECT 
    CASE 
        WHEN oi.discount_percent = 0 THEN '0% (Full Price)'
        WHEN oi.discount_percent <= 5 THEN '1% - 5% (Minor Promo)'
        WHEN oi.discount_percent <= 10 THEN '6% - 10% (Standard Discount)'
        WHEN oi.discount_percent <= 15 THEN '11% - 15% (High Promo)'
        ELSE '16% - 20%+ (Deep Clearance)'
    END AS Discount_Tier,
    COUNT(DISTINCT o.order_id) AS Orders_Count,
    SUM(oi.quantity) AS Total_Units_Sold,
    ROUND(SUM(oi.line_total), 2) AS Gross_Sales,
    ROUND(SUM(oi.line_profit), 2) AS Net_Profit,
    ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Net_Profit_Margin_Pct,
    ROUND(AVG(oi.line_total), 2) AS Avg_Item_Transaction_Value
FROM fact_order_items oi
JOIN fact_orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY 
    CASE 
        WHEN oi.discount_percent = 0 THEN '0% (Full Price)'
        WHEN oi.discount_percent <= 5 THEN '1% - 5% (Minor Promo)'
        WHEN oi.discount_percent <= 10 THEN '6% - 10% (Standard Discount)'
        WHEN oi.discount_percent <= 15 THEN '11% - 15% (High Promo)'
        ELSE '16% - 20%+ (Deep Clearance)'
    END
ORDER BY Net_Profit_Margin_Pct DESC;


-- ====================================================================
-- 7. RETURN & CANCELLATION RISK MATRIX BY PAYMENT METHOD
-- ====================================================================
-- Critical supply chain query: Identifies payment methods causing high Return-to-Origin (RTO).

SELECT 
    o.payment_method AS Payment_Method,
    COUNT(*) AS Total_Orders_Attempted,
    COUNT(CASE WHEN o.order_status = 'Delivered' THEN 1 END) AS Delivered_Orders,
    COUNT(CASE WHEN o.order_status = 'Returned' THEN 1 END) AS Returned_Orders,
    COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) AS Cancelled_Orders,
    ROUND(COUNT(CASE WHEN o.order_status = 'Returned' THEN 1 END) * 100.0 / COUNT(*), 2) AS Return_Rate_Pct,
    ROUND(COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct,
    ROUND(SUM(CASE WHEN o.order_status = 'Delivered' THEN o.total_amount ELSE 0 END), 2) AS Realized_Revenue,
    ROUND(SUM(CASE WHEN o.order_status IN ('Returned', 'Cancelled') THEN o.total_amount ELSE 0 END), 2) AS Lost_Gross_Merchandise_Value
FROM fact_orders o
GROUP BY o.payment_method
ORDER BY Return_Rate_Pct DESC;
