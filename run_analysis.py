"""
Retail Sales Enterprise Data Warehouse & Analytics Engine
Executes Star Schema relational queries and advanced industry analytics (RFM, Cohorts, Pareto, Elasticity).
"""

import os
import sqlite3
import pandas as pd

def load_data_warehouse(conn):
    """Loads all dimensional and fact tables into SQLite in-memory database."""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    dataset_dir = os.path.join(base_dir, "dataset")

    tables = {
        "dim_customers": "dim_customers.csv",
        "dim_products": "dim_products.csv",
        "dim_stores": "dim_stores.csv",
        "fact_orders": "fact_orders.csv",
        "fact_order_items": "fact_order_items.csv"
    }

    for table_name, file_name in tables.items():
        file_path = os.path.join(dataset_dir, file_name)
        if os.path.exists(file_path):
            df = pd.read_csv(file_path)
            df.to_sql(table_name, conn, index=False, if_exists="replace")
        else:
            print(f"[!] Warning: {file_name} not found at {file_path}")

    # Create Denormalized View in SQLite
    conn.execute("""
    CREATE VIEW IF NOT EXISTS view_retail_analytics AS
    SELECT 
        o.order_id,
        o.order_date,
        o.shipping_date,
        c.customer_id,
        (c.first_name || ' ' || c.last_name) AS customer_name,
        c.gender AS customer_gender,
        c.age AS customer_age,
        c.city AS customer_city,
        c.state AS customer_state,
        c.region AS customer_region,
        s.store_id,
        s.store_name,
        s.region AS store_region,
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        p.brand,
        oi.quantity,
        oi.unit_price,
        oi.discount_percent,
        oi.line_total AS sales_amount,
        oi.line_cost AS cost_amount,
        oi.line_profit AS profit_amount,
        o.payment_method,
        o.order_status
    FROM fact_orders o
    JOIN dim_customers c ON o.customer_id = c.customer_id
    JOIN dim_stores s ON o.store_id = s.store_id
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    JOIN dim_products p ON oi.product_id = p.product_id;
    """)

def run_enterprise_analytics():
    print("=" * 80)
    print("      RETAIL SALES ENTERPRISE ANALYTICS - EXECUTIVE REPORT")
    print("=" * 80)

    conn = sqlite3.connect(":memory:")
    load_data_warehouse(conn)

    queries = [
        ("1. EXECUTIVE SUMMARY SCORECARD", """
            SELECT 
                COUNT(DISTINCT o.order_id) AS Total_Delivered_Orders,
                COUNT(DISTINCT o.customer_id) AS Active_Customers,
                SUM(oi.quantity) AS Total_Units_Sold,
                PRINTF('INR %.2f', SUM(oi.line_total)) AS Gross_Revenue,
                PRINTF('INR %.2f', SUM(oi.line_profit)) AS Net_Profit,
                ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Profit_Margin_Pct,
                ROUND(SUM(oi.line_total) / COUNT(DISTINCT o.order_id), 2) AS Average_Order_Value
            FROM fact_orders o
            JOIN fact_order_items oi ON o.order_id = oi.order_id
            WHERE o.order_status = 'Delivered';
        """),
        ("2. CATEGORY & SUBCATEGORY PROFITABILITY MATRIX", """
            SELECT 
                p.category AS Category,
                p.subcategory AS Subcategory,
                COUNT(DISTINCT o.order_id) AS Order_Count,
                SUM(oi.quantity) AS Units_Sold,
                ROUND(SUM(oi.line_total), 2) AS Total_Revenue,
                ROUND(SUM(oi.line_profit), 2) AS Total_Profit,
                ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Margin_Pct
            FROM fact_order_items oi
            JOIN fact_orders o ON oi.order_id = o.order_id
            JOIN dim_products p ON oi.product_id = p.product_id
            WHERE o.order_status = 'Delivered'
            GROUP BY p.category, p.subcategory
            ORDER BY Total_Revenue DESC
            LIMIT 8;
        """),
        ("3. REGIONAL REVENUE & STORE PERFORMANCE", """
            SELECT 
                s.region AS Region,
                COUNT(DISTINCT s.store_id) AS Stores_Count,
                COUNT(DISTINCT o.order_id) AS Orders_Count,
                ROUND(SUM(oi.line_total), 2) AS Regional_Sales,
                ROUND(SUM(oi.line_profit), 2) AS Regional_Profit,
                ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Margin_Pct,
                ROUND(SUM(oi.line_total) * 100.0 / (
                    SELECT SUM(oi2.line_total) 
                    FROM fact_order_items oi2 
                    JOIN fact_orders o2 ON oi2.order_id = o2.order_id 
                    WHERE o2.order_status = 'Delivered'
                ), 2) AS Market_Share_Pct
            FROM fact_orders o
            JOIN dim_stores s ON o.store_id = s.store_id
            JOIN fact_order_items oi ON o.order_id = oi.order_id
            WHERE o.order_status = 'Delivered'
            GROUP BY s.region
            ORDER BY Regional_Sales DESC;
        """),
        ("4. TOP 5 REVENUE GENERATING PRODUCTS", """
            SELECT 
                p.product_id,
                p.product_name AS Product_Name,
                p.category AS Category,
                SUM(oi.quantity) AS Units_Sold,
                ROUND(SUM(oi.line_total), 2) AS Total_Revenue,
                ROUND(SUM(oi.line_profit), 2) AS Net_Profit,
                ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Margin_Pct
            FROM fact_order_items oi
            JOIN fact_orders o ON oi.order_id = o.order_id
            JOIN dim_products p ON oi.product_id = p.product_id
            WHERE o.order_status = 'Delivered'
            GROUP BY p.product_id, p.product_name, p.category
            ORDER BY Total_Revenue DESC
            LIMIT 5;
        """),
        ("5. RFM CUSTOMER SEGMENTATION SUMMARY", """
            WITH Customer_RFM AS (
                SELECT 
                    c.customer_id,
                    JULIANDAY('2024-12-31') - JULIANDAY(MAX(o.order_date)) AS recency_days,
                    COUNT(DISTINCT o.order_id) AS frequency_orders,
                    SUM(oi.line_total) AS monetary_spend
                FROM dim_customers c
                JOIN fact_orders o ON c.customer_id = o.customer_id
                JOIN fact_order_items oi ON o.order_id = oi.order_id
                WHERE o.order_status = 'Delivered'
                GROUP BY c.customer_id
            ),
            RFM_Quartiles AS (
                SELECT 
                    customer_id,
                    recency_days,
                    frequency_orders,
                    monetary_spend,
                    NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
                    NTILE(4) OVER (ORDER BY frequency_orders ASC) AS f_score,
                    NTILE(4) OVER (ORDER BY monetary_spend ASC) AS m_score
                FROM Customer_RFM
            ),
            Segmentation AS (
                SELECT 
                    customer_id,
                    monetary_spend,
                    recency_days,
                    frequency_orders,
                    CASE 
                        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions (VIP)'
                        WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal Customers'
                        WHEN r_score >= 3 AND f_score = 1 THEN 'Recent New Customers'
                        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk (Need Retention)'
                        WHEN r_score = 1 AND f_score <= 2 THEN 'Hibernating / Lost'
                        ELSE 'Potential Loyalists'
                    END AS Segment
                FROM RFM_Quartiles
            )
            SELECT 
                Segment,
                COUNT(*) AS Customer_Count,
                ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Segmentation), 2) AS Customer_Share_Pct,
                ROUND(SUM(monetary_spend), 2) AS Segment_Revenue,
                ROUND(AVG(monetary_spend), 2) AS Avg_Customer_Spend,
                ROUND(AVG(recency_days), 1) AS Avg_Recency_Days,
                ROUND(AVG(frequency_orders), 1) AS Avg_Frequency
            FROM Segmentation
            GROUP BY Segment
            ORDER BY Segment_Revenue DESC;
        """),
        ("6. DISCOUNT TIER ELASTICITY & MARGIN CANNIBALIZATION", """
            SELECT 
                CASE 
                    WHEN oi.discount_percent = 0 THEN '0% (Full Price)'
                    WHEN oi.discount_percent <= 5 THEN '1% - 5% (Minor Promo)'
                    WHEN oi.discount_percent <= 10 THEN '6% - 10% (Standard Promo)'
                    WHEN oi.discount_percent <= 15 THEN '11% - 15% (High Promo)'
                    ELSE '16% - 20%+ (Deep Clearance)'
                END AS Discount_Tier,
                COUNT(DISTINCT o.order_id) AS Orders_Count,
                SUM(oi.quantity) AS Total_Units_Sold,
                ROUND(SUM(oi.line_total), 2) AS Gross_Sales,
                ROUND(SUM(oi.line_profit), 2) AS Net_Profit,
                ROUND(SUM(oi.line_profit) * 100.0 / SUM(oi.line_total), 2) AS Net_Margin_Pct
            FROM fact_order_items oi
            JOIN fact_orders o ON oi.order_id = o.order_id
            WHERE o.order_status = 'Delivered'
            GROUP BY 
                CASE 
                    WHEN oi.discount_percent = 0 THEN '0% (Full Price)'
                    WHEN oi.discount_percent <= 5 THEN '1% - 5% (Minor Promo)'
                    WHEN oi.discount_percent <= 10 THEN '6% - 10% (Standard Promo)'
                    WHEN oi.discount_percent <= 15 THEN '11% - 15% (High Promo)'
                    ELSE '16% - 20%+ (Deep Clearance)'
                END
            ORDER BY Net_Margin_Pct DESC;
        """),
        ("7. PAYMENT METHOD & RETURN / CANCELLATION RISK MATRIX", """
            SELECT 
                o.payment_method AS Payment_Method,
                COUNT(*) AS Total_Orders_Attempted,
                COUNT(CASE WHEN o.order_status = 'Delivered' THEN 1 END) AS Delivered_Orders,
                COUNT(CASE WHEN o.order_status = 'Returned' THEN 1 END) AS Returned_Orders,
                COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) AS Cancelled_Orders,
                ROUND(COUNT(CASE WHEN o.order_status = 'Returned' THEN 1 END) * 100.0 / COUNT(*), 2) AS Return_Rate_Pct,
                ROUND(COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*), 2) AS Cancel_Rate_Pct,
                ROUND(SUM(CASE WHEN o.order_status = 'Delivered' THEN o.total_amount ELSE 0 END), 2) AS Realized_Revenue
            FROM fact_orders o
            GROUP BY o.payment_method
            ORDER BY Return_Rate_Pct DESC;
        """)
    ]

    for title, sql in queries:
        print(f"\n==================== {title} ====================")
        res_df = pd.read_sql_query(sql, conn)
        print(res_df.to_string(index=False))

    print("\n" + "=" * 80)
    print("      ALL ENTERPRISE ANALYTICS QUERIES EXECUTED SUCCESSFULLY")
    print("=" * 80)

if __name__ == "__main__":
    run_enterprise_analytics()
