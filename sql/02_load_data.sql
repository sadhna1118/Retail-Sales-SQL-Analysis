-- ====================================================================
-- RETAIL SALES DATA LOADING SCRIPT (MySQL & PostgreSQL)
-- ====================================================================
-- Instructions: Run 01_schema_definition.sql first before loading.
-- ====================================================================

-- --------------------------------------------------------------------
-- A. MYSQL BULK IMPORT COMMANDS (LOCAL INFILE)
-- --------------------------------------------------------------------
-- Note: Replace '/path/to/dataset/' with your actual dataset directory path.

/*
LOAD DATA LOCAL INFILE 'dataset/dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'dataset/dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'dataset/dim_stores.csv'
INTO TABLE dim_stores
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'dataset/fact_orders.csv'
INTO TABLE fact_orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'dataset/fact_order_items.csv'
INTO TABLE fact_order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

-- --------------------------------------------------------------------
-- B. POSTGRESQL BULK IMPORT COMMANDS (\copy)
-- --------------------------------------------------------------------
/*
\copy dim_customers FROM 'dataset/dim_customers.csv' WITH (FORMAT csv, HEADER true);
\copy dim_products FROM 'dataset/dim_products.csv' WITH (FORMAT csv, HEADER true);
\copy dim_stores FROM 'dataset/dim_stores.csv' WITH (FORMAT csv, HEADER true);
\copy fact_orders FROM 'dataset/fact_orders.csv' WITH (FORMAT csv, HEADER true);
\copy fact_order_items FROM 'dataset/fact_order_items.csv' WITH (FORMAT csv, HEADER true);
*/

-- --------------------------------------------------------------------
-- C. DATA VERIFICATION QUERIES
-- --------------------------------------------------------------------
SELECT 'dim_customers' AS Table_Name, COUNT(*) AS Total_Records FROM dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL
SELECT 'dim_stores', COUNT(*) FROM dim_stores
UNION ALL
SELECT 'fact_orders', COUNT(*) FROM fact_orders
UNION ALL
SELECT 'fact_order_items', COUNT(*) FROM fact_order_items;
