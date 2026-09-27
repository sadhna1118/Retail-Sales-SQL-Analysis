-- ====================================================================
-- RETAIL SALES ENTERPRISE DATA WAREHOUSE - STAR SCHEMA DEFINITION
-- Dialect Compatibility: MySQL 8.0+ / PostgreSQL 12+ / SQLite 3
-- ====================================================================

-- Drop existing views and tables if recreating
DROP VIEW IF EXISTS view_retail_analytics;
DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_stores;
DROP TABLE IF EXISTS dim_customers;

-- ====================================================================
-- 1. DIMENSION TABLE: CUSTOMERS (dim_customers)
-- ====================================================================
CREATE TABLE dim_customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    age INT CHECK (age BETWEEN 18 AND 100),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    region VARCHAR(20) NOT NULL CHECK (region IN ('North', 'South', 'East', 'West')),
    signup_date DATE NOT NULL
);

-- ====================================================================
-- 2. DIMENSION TABLE: PRODUCTS (dim_products)
-- ====================================================================
CREATE TABLE dim_products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL CHECK (unit_cost > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    brand VARCHAR(50) NOT NULL
);

-- ====================================================================
-- 3. DIMENSION TABLE: STORES / OUTLETS (dim_stores)
-- ====================================================================
CREATE TABLE dim_stores (
    store_id VARCHAR(20) PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    region VARCHAR(20) NOT NULL CHECK (region IN ('North', 'South', 'East', 'West')),
    store_type VARCHAR(50) NOT NULL,
    manager VARCHAR(100) NOT NULL
);

-- ====================================================================
-- 4. FACT TABLE: ORDERS (fact_orders)
-- ====================================================================
CREATE TABLE fact_orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    store_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    shipping_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Cash on Delivery (COD)')),
    order_status VARCHAR(30) NOT NULL CHECK (order_status IN ('Delivered', 'Returned', 'Cancelled', 'Shipped')),
    shipping_cost DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    total_profit DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES dim_stores(store_id)
);

-- ====================================================================
-- 5. FACT TABLE: ORDER LINE ITEMS (fact_order_items)
-- ====================================================================
CREATE TABLE fact_order_items (
    order_item_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    discount_percent DECIMAL(5, 2) DEFAULT 0.00 CHECK (discount_percent BETWEEN 0 AND 100),
    line_total DECIMAL(12, 2) NOT NULL,
    line_cost DECIMAL(12, 2) NOT NULL,
    line_profit DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES fact_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id)
);

-- ====================================================================
-- 6. PERFORMANCE INDEXES
-- ====================================================================
CREATE INDEX idx_orders_date ON fact_orders(order_date);
CREATE INDEX idx_orders_customer ON fact_orders(customer_id);
CREATE INDEX idx_orders_store ON fact_orders(store_id);
CREATE INDEX idx_orders_status ON fact_orders(order_status);
CREATE INDEX idx_items_product ON fact_order_items(product_id);
CREATE INDEX idx_items_order ON fact_order_items(order_id);
CREATE INDEX idx_customers_region ON dim_customers(region);
CREATE INDEX idx_products_category ON dim_products(category);

-- ====================================================================
-- 7. DENORMALIZED ANALYTICAL VIEW (FOR BI & REPORTING TOOLS)
-- ====================================================================
CREATE VIEW view_retail_analytics AS
SELECT 
    o.order_id,
    o.order_date,
    o.shipping_date,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
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
