-- ============================================
-- Retail Sales Analysis Queries
-- ============================================
-- This file contains SQL queries to answer
-- key business questions about retail sales
-- Compatible with MySQL and PostgreSQL
-- ============================================

-- ============================================
-- QUESTION 1: Total Revenue kitni hai?
-- ============================================
-- Using simple aggregation
SELECT 
    SUM(Sales) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    COUNT(*) AS TotalOrders
FROM retail_sales;

-- ============================================
-- QUESTION 2: Sabse zyada bikne wala Product kaun sa hai?
-- ============================================
-- Using GROUP BY and ORDER BY
SELECT 
    Product,
    Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Sales) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS RevenueRank
FROM retail_sales
GROUP BY Product, Category
ORDER BY TotalRevenue DESC
LIMIT 1;

-- Alternative: Top 5 best-selling products
SELECT 
    Product,
    Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Sales) AS TotalRevenue
FROM retail_sales
GROUP BY Product, Category
ORDER BY TotalRevenue DESC
LIMIT 5;

-- ============================================
-- QUESTION 3: Top 10 Customers kaun hain?
-- ============================================
-- Using GROUP BY, ORDER BY, and Window Functions
SELECT 
    Customer,
    COUNT(*) AS TotalOrders,
    SUM(Sales) AS TotalSpent,
    AVG(Sales) AS AverageOrderValue,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS CustomerRank
FROM retail_sales
GROUP BY Customer
ORDER BY TotalSpent DESC
LIMIT 10;

-- ============================================
-- QUESTION 4: Kis Region me sabse zyada Sales hui?
-- ============================================
-- Using GROUP BY and ORDER BY
SELECT 
    Region,
    COUNT(*) AS TotalOrders,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    ROUND(SUM(Sales) * 100.0 / (SELECT SUM(Sales) FROM retail_sales), 2) AS SalesPercentage
FROM retail_sales
GROUP BY Region
ORDER BY TotalSales DESC;

-- ============================================
-- QUESTION 5: Monthly Sales Trend kya hai?
-- ============================================
-- Using GROUP BY with date extraction and CTE
WITH MonthlySales AS (
    SELECT 
        EXTRACT(YEAR FROM Order_Date) AS Year,
        EXTRACT(MONTH FROM Order_Date) AS Month,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit,
        COUNT(*) AS TotalOrders
    FROM retail_sales
    GROUP BY EXTRACT(YEAR FROM Order_Date), EXTRACT(MONTH FROM Order_Date)
)
SELECT 
    Year,
    Month,
    TotalSales,
    TotalProfit,
    TotalOrders,
    LAG(TotalSales) OVER (ORDER BY Year, Month) AS PreviousMonthSales,
    ROUND(
        (TotalSales - LAG(TotalSales) OVER (ORDER BY Year, Month)) * 100.0 / 
        LAG(TotalSales) OVER (ORDER BY Year, Month), 
        2
    ) AS MonthOverMonthGrowth
FROM MonthlySales
ORDER BY Year, Month;

-- ============================================
-- QUESTION 6: Highest Profit Category kaunsi hai?
-- ============================================
-- Using GROUP BY and Window Functions
SELECT 
    Category,
    COUNT(*) AS TotalOrders,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    ROUND(AVG(Profit), 2) AS AverageProfitPerOrder,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS ProfitMarginPercentage,
    RANK() OVER (ORDER BY SUM(Profit) DESC) AS ProfitRank
FROM retail_sales
GROUP BY Category
ORDER BY TotalProfit DESC;

-- ============================================
-- QUESTION 7: Average Order Value kitni hai?
-- ============================================
-- Using aggregation functions
SELECT 
    ROUND(AVG(Sales), 2) AS AverageOrderValue,
    ROUND(MIN(Sales), 2) AS MinimumOrderValue,
    ROUND(MAX(Sales), 2) AS MaximumOrderValue,
    ROUND(SUM(Sales) / COUNT(*), 2) AS CalculatedAOV
FROM retail_sales;

-- Average Order Value by Category
SELECT 
    Category,
    ROUND(AVG(Sales), 2) AS AverageOrderValue,
    COUNT(*) AS TotalOrders
FROM retail_sales
GROUP BY Category
ORDER BY AverageOrderValue DESC;

-- ============================================
-- QUESTION 8: Top 5 Products by Revenue
-- ============================================
-- Using GROUP BY, ORDER BY with Window Functions
SELECT 
    Product,
    Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Sales) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS ProfitMargin,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS RevenueRank
FROM retail_sales
GROUP BY Product, Category
ORDER BY TotalRevenue DESC
LIMIT 5;

-- ============================================
-- QUESTION 9: Lowest Selling Products
-- ============================================
-- Products with lowest sales revenue
SELECT 
    Product,
    Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Sales) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    RANK() OVER (ORDER BY SUM(Sales) ASC) AS SalesRank
FROM retail_sales
GROUP BY Product, Category
ORDER BY TotalRevenue ASC
LIMIT 5;

-- Products with lowest quantity sold
SELECT 
    Product,
    Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Sales) AS TotalRevenue,
    COUNT(*) AS TimesOrdered
FROM retail_sales
GROUP BY Product, Category
ORDER BY TotalQuantitySold ASC, TimesOrdered ASC
LIMIT 5;

-- ============================================
-- QUESTION 10: Customer-wise Revenue
-- ============================================
-- Using GROUP BY and Window Functions
SELECT 
    Customer,
    COUNT(*) AS TotalOrders,
    SUM(Sales) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    ROUND(AVG(Sales), 2) AS AverageOrderValue,
    MIN(Order_Date) AS FirstPurchaseDate,
    MAX(Order_Date) AS LastPurchaseDate,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS RevenueRank
FROM retail_sales
GROUP BY Customer
ORDER BY TotalRevenue DESC;

-- ============================================
-- ADDITIONAL ANALYSIS QUERIES
-- ============================================

-- Regional Performance by Category
SELECT 
    Region,
    Category,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    COUNT(*) AS TotalOrders,
    ROUND(SUM(Sales) * 100.0 / (SELECT SUM(Sales) FROM retail_sales), 2) AS SalesContribution
FROM retail_sales
GROUP BY Region, Category
ORDER BY Region, TotalSales DESC;

-- Sales Distribution by Price Range
SELECT 
    CASE 
        WHEN Price < 1000 THEN 'Low (< 1000)'
        WHEN Price BETWEEN 1000 AND 10000 THEN 'Medium (1000-10000)'
        WHEN Price > 10000 THEN 'High (> 10000)'
    END AS PriceRange,
    COUNT(*) AS TotalOrders,
    SUM(Sales) AS TotalSales,
    ROUND(SUM(Sales) * 100.0 / (SELECT SUM(Sales) FROM retail_sales), 2) AS SalesPercentage
FROM retail_sales
GROUP BY 
    CASE 
        WHEN Price < 1000 THEN 'Low (< 1000)'
        WHEN Price BETWEEN 1000 AND 10000 THEN 'Medium (1000-10000)'
        WHEN Price > 10000 THEN 'High (> 10000)'
    END
ORDER BY 
    CASE 
        WHEN Price < 1000 THEN 1
        WHEN Price BETWEEN 1000 AND 10000 THEN 2
        WHEN Price > 10000 THEN 3
    END;

-- Quarterly Sales Analysis
SELECT 
    EXTRACT(YEAR FROM Order_Date) AS Year,
    CASE 
        WHEN EXTRACT(MONTH FROM Order_Date) IN (1,2,3) THEN 'Q1'
        WHEN EXTRACT(MONTH FROM Order_Date) IN (4,5,6) THEN 'Q2'
        WHEN EXTRACT(MONTH FROM Order_Date) IN (7,8,9) THEN 'Q3'
        WHEN EXTRACT(MONTH FROM Order_Date) IN (10,11,12) THEN 'Q4'
    END AS Quarter,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    COUNT(*) AS TotalOrders
FROM retail_sales
GROUP BY 
    EXTRACT(YEAR FROM Order_Date),
    CASE 
        WHEN EXTRACT(MONTH FROM Order_Date) IN (1,2,3) THEN 'Q1'
        WHEN EXTRACT(MONTH FROM Order_Date) IN (4,5,6) THEN 'Q2'
        WHEN EXTRACT(MONTH FROM Order_Date) IN (7,8,9) THEN 'Q3'
        WHEN EXTRACT(MONTH FROM Order_Date) IN (10,11,12) THEN 'Q4'
    END
ORDER BY Year, Quarter;

-- Top Performing Products with Customer Information
WITH TopProducts AS (
    SELECT 
        Product,
        SUM(Sales) AS ProductRevenue,
        RANK() OVER (ORDER BY SUM(Sales) DESC) AS ProductRank
    FROM retail_sales
    GROUP BY Product
    LIMIT 5
)
SELECT 
    r.Product,
    r.Category,
    r.Customer,
    r.Order_Date,
    r.Quantity,
    r.Sales,
    r.Profit,
    tp.ProductRank
FROM retail_sales r
JOIN TopProducts tp ON r.Product = tp.Product
ORDER BY tp.ProductRank, r.Order_Date;

-- Customer Segmentation based on spending
SELECT 
    Customer,
    COUNT(*) AS TotalOrders,
    SUM(Sales) AS TotalRevenue,
    CASE 
        WHEN SUM(Sales) < 10000 THEN 'Bronze'
        WHEN SUM(Sales) BETWEEN 10000 AND 30000 THEN 'Silver'
        WHEN SUM(Sales) > 30000 THEN 'Gold'
    END AS CustomerSegment,
    ROUND(AVG(Sales), 2) AS AverageOrderValue
FROM retail_sales
GROUP BY Customer
ORDER BY TotalRevenue DESC;

-- Profit Analysis by Region and Category
SELECT 
    Region,
    Category,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS ProfitMargin,
    ROUND(AVG(Profit), 2) AS AverageProfitPerOrder
FROM retail_sales
GROUP BY Region, Category
ORDER BY Region, ProfitMargin DESC;
