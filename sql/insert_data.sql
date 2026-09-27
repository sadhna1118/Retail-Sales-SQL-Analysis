-- ============================================
-- Insert Data into Retail Sales Table
-- ============================================
-- This script inserts sample retail sales data
-- Run this after create_tables.sql
-- ============================================

INSERT INTO retail_sales (Order_ID, Order_Date, Customer, Product, Category, Region, Quantity, Price, Sales, Profit) VALUES
('ORD001', '2024-01-05', 'Rahul Sharma', 'Laptop', 'Electronics', 'West', 2, 45000.00, 90000.00, 15000.00),
('ORD002', '2024-01-08', 'Priya Singh', 'Smartphone', 'Electronics', 'East', 1, 25000.00, 25000.00, 5000.00),
('ORD003', '2024-01-12', 'Amit Patel', 'Desk Chair', 'Furniture', 'North', 3, 5000.00, 15000.00, 3000.00),
('ORD004', '2024-01-15', 'Neha Gupta', 'Running Shoes', 'Clothing', 'South', 2, 3500.00, 7000.00, 1500.00),
('ORD005', '2024-01-18', 'Vijay Kumar', 'Headphones', 'Electronics', 'West', 1, 4000.00, 4000.00, 800.00),
('ORD006', '2024-01-22', 'Sneha Reddy', 'Office Desk', 'Furniture', 'East', 1, 12000.00, 12000.00, 2500.00),
('ORD007', '2024-01-25', 'Rajesh Verma', 'T-Shirt', 'Clothing', 'North', 5, 800.00, 4000.00, 1000.00),
('ORD008', '2024-01-28', 'Anjali Mehta', 'Tablet', 'Electronics', 'South', 1, 18000.00, 18000.00, 3500.00),
('ORD009', '2024-02-02', 'Suresh Yadav', 'Bookshelf', 'Furniture', 'West', 1, 8000.00, 8000.00, 1800.00),
('ORD010', '2024-02-05', 'Kavita Nair', 'Jeans', 'Clothing', 'East', 3, 2000.00, 6000.00, 1200.00),
('ORD011', '2024-02-08', 'Deepak Joshi', 'Smart Watch', 'Electronics', 'North', 1, 12000.00, 12000.00, 2400.00),
('ORD012', '2024-02-12', 'Pooja Sharma', 'Sofa', 'Furniture', 'South', 1, 25000.00, 25000.00, 5000.00),
('ORD013', '2024-02-15', 'Arun Kumar', 'Blazer', 'Clothing', 'West', 2, 4500.00, 9000.00, 2000.00),
('ORD014', '2024-02-18', 'Meena Iyer', 'Laptop', 'Electronics', 'East', 1, 45000.00, 45000.00, 8000.00),
('ORD015', '2024-02-22', 'Ravi Teja', 'Printer', 'Electronics', 'North', 1, 8000.00, 8000.00, 1500.00),
('ORD016', '2024-02-25', 'Lakshmi Rao', 'Dining Table', 'Furniture', 'South', 1, 15000.00, 15000.00, 3000.00),
('ORD017', '2024-03-01', 'Karthik Reddy', 'Sneakers', 'Clothing', 'West', 2, 3000.00, 6000.00, 1200.00),
('ORD018', '2024-03-05', 'Divya Sharma', 'Monitor', 'Electronics', 'East', 1, 15000.00, 15000.00, 2800.00),
('ORD019', '2024-03-08', 'Sandeep Patil', 'Wardrobe', 'Furniture', 'North', 1, 20000.00, 20000.00, 4000.00),
('ORD020', '2024-03-12', 'Anita Deshmukh', 'Formal Shirt', 'Clothing', 'South', 4, 1500.00, 6000.00, 1500.00),
('ORD021', '2024-03-15', 'Vikram Singh', 'Keyboard', 'Electronics', 'West', 1, 2000.00, 2000.00, 400.00),
('ORD022', '2024-03-18', 'Swati Joshi', 'Study Table', 'Furniture', 'East', 1, 10000.00, 10000.00, 2000.00),
('ORD023', '2024-03-22', 'Mohan Kumar', 'Sports Shoes', 'Clothing', 'North', 2, 4000.00, 8000.00, 1800.00),
('ORD024', '2024-03-25', 'Kiran Bhat', 'Mouse', 'Electronics', 'South', 1, 800.00, 800.00, 150.00),
('ORD025', '2024-04-02', 'Rajendra Prasad', 'Coffee Table', 'Furniture', 'West', 1, 6000.00, 6000.00, 1200.00),
('ORD026', '2024-04-05', 'Sunita Kapoor', 'Handbag', 'Clothing', 'East', 1, 3000.00, 3000.00, 600.00),
('ORD027', '2024-04-08', 'Ajay Thakur', 'Webcam', 'Electronics', 'North', 1, 2500.00, 2500.00, 500.00),
('ORD028', '2024-04-12', 'Reena Malhotra', 'Bed', 'Furniture', 'South', 1, 18000.00, 18000.00, 3500.00),
('ORD029', '2024-04-15', 'Sunil Chauhan', 'Tracksuit', 'Clothing', 'West', 2, 2500.00, 5000.00, 1000.00),
('ORD030', '2024-04-18', 'Meera Saini', 'Speaker', 'Electronics', 'East', 1, 3500.00, 3500.00, 700.00),
('ORD031', '2024-04-22', 'Dinesh Kumar', 'Bookshelf', 'Furniture', 'North', 1, 8000.00, 8000.00, 1600.00),
('ORD032', '2024-05-02', 'Preeti Singh', 'Sunglasses', 'Clothing', 'South', 1, 2000.00, 2000.00, 400.00),
('ORD033', '2024-05-05', 'Naveen Reddy', 'External HDD', 'Electronics', 'West', 1, 4500.00, 4500.00, 900.00),
('ORD034', '2024-05-08', 'Kusum Sharma', 'Couch', 'Furniture', 'East', 1, 22000.00, 22000.00, 4400.00),
('ORD035', '2024-05-12', 'Rakesh Mehta', 'Casual Shoes', 'Clothing', 'North', 2, 2800.00, 5600.00, 1200.00),
('ORD036', '2024-05-15', 'Anjali Gupta', 'Router', 'Electronics', 'South', 1, 3000.00, 3000.00, 600.00),
('ORD037', '2024-05-18', 'Vikrant Joshi', 'Office Chair', 'Furniture', 'West', 2, 6000.00, 12000.00, 2400.00),
('ORD038', '2024-05-22', 'Shweta Patil', 'Kurta', 'Clothing', 'East', 3, 1200.00, 3600.00, 800.00),
('ORD039', '2024-06-02', 'Mahesh Verma', 'Power Bank', 'Electronics', 'North', 1, 1500.00, 1500.00, 300.00),
('ORD040', '2024-06-05', 'Rashmi Nair', 'Side Table', 'Furniture', 'South', 2, 3000.00, 6000.00, 1200.00),
('ORD041', '2024-06-08', 'Suresh Kumar', 'Wireless Earbuds', 'Electronics', 'West', 1, 3000.00, 3000.00, 600.00),
('ORD042', '2024-06-12', 'Deepa Reddy', 'Summer Dress', 'Clothing', 'East', 1, 3500.00, 3500.00, 700.00),
('ORD043', '2024-06-15', 'Ajay Sharma', 'TV Stand', 'Furniture', 'North', 1, 7000.00, 7000.00, 1400.00),
('ORD044', '2024-06-18', 'Kavita Joshi', 'Smartphone', 'Electronics', 'South', 1, 25000.00, 25000.00, 5000.00),
('ORD045', '2024-06-22', 'Rajeev Patel', 'Formal Pants', 'Clothing', 'West', 2, 1800.00, 3600.00, 800.00),
('ORD046', '2024-07-02', 'Sneha Kumar', 'Laptop Bag', 'Clothing', 'East', 1, 2500.00, 2500.00, 500.00),
('ORD047', '2024-07-05', 'Vikram Reddy', 'Gaming Monitor', 'Electronics', 'North', 1, 25000.00, 25000.00, 5000.00),
('ORD048', '2024-07-08', 'Meena Sharma', 'Cabinet', 'Furniture', 'South', 1, 12000.00, 12000.00, 2400.00),
('ORD049', '2024-07-12', 'Sunil Verma', 'Sports Watch', 'Clothing', 'West', 1, 4000.00, 4000.00, 800.00),
('ORD050', '2024-07-15', 'Anita Iyer', 'USB Hub', 'Electronics', 'East', 1, 1000.00, 1000.00, 200.00);

-- Verify data insertion
SELECT 
    'Data inserted successfully!' AS Status,
    COUNT(*) AS TotalRecords
FROM retail_sales;
