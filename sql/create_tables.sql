-- ============================================
-- Retail Sales Database Schema Creation
-- ============================================
-- This script creates the retail_sales table
-- Compatible with MySQL and PostgreSQL
-- ============================================

-- Drop table if exists (for clean re-creation)
DROP TABLE IF EXISTS retail_sales;

-- Create retail_sales table
CREATE TABLE retail_sales (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Customer VARCHAR(100) NOT NULL,
    Product VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0),
    Sales DECIMAL(10, 2) NOT NULL CHECK (Sales > 0),
    Profit DECIMAL(10, 2) NOT NULL
);

-- Add indexes for better query performance
CREATE INDEX idx_order_date ON retail_sales(Order_Date);
CREATE INDEX idx_category ON retail_sales(Category);
CREATE INDEX idx_region ON retail_sales(Region);
CREATE INDEX idx_customer ON retail_sales(Customer);
CREATE INDEX idx_product ON retail_sales(Product);

-- Verify table creation
SELECT 
    'Table retail_sales created successfully!' AS Status,
    COUNT(*) AS ColumnCount
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'retail_sales';
