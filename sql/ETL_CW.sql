CREATE DATABASE IF NOT EXISTS Supermarket_Warehouse_new5;
USE Supermarket_Warehouse_new5;


CREATE TABLE Dim_Customer (
    Customer_Key INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(100),
    Region VARCHAR(50),
    Market VARCHAR(50)
);

CREATE TABLE Dim_Product (
    Product_Key INT AUTO_INCREMENT PRIMARY KEY,
    Product_ID VARCHAR(50),
    Product_Name VARCHAR(150),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100)
);

CREATE TABLE Dim_Date (
    Date_Key INT AUTO_INCREMENT PRIMARY KEY,
    Full_Date DATE,
    Day INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter VARCHAR(5),
    Year INT,
    Day_of_Week VARCHAR(20),
    Is_Weekend BOOLEAN
);

CREATE TABLE Dim_Location (
    Location_Key INT AUTO_INCREMENT PRIMARY KEY,
    Country VARCHAR(50),
    City VARCHAR(100),
    Region VARCHAR(50),
    Market VARCHAR(50)
);

CREATE TABLE Dim_Shipping (
    Shipping_Key INT AUTO_INCREMENT PRIMARY KEY,
    Ship_Mode VARCHAR(50),
    Order_Priority VARCHAR(50)
);

CREATE TABLE Fact_Sales (
    Sales_Key INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID VARCHAR(50),
    Customer_Key INT,
    Product_Key INT,
    Date_Key INT,
    Location_Key INT,
    Shipping_Key INT,
    Quantity INT,
    Sales DECIMAL(12,2),
    Profit DECIMAL(12,2),
    Shipping_Cost DECIMAL(12,2),
    Discount DECIMAL(5,2),
    Order_Priority VARCHAR(50),
    Ship_Mode VARCHAR(50),

    FOREIGN KEY (Customer_Key) REFERENCES Dim_Customer(Customer_Key),
    FOREIGN KEY (Product_Key) REFERENCES Dim_Product(Product_Key),
    FOREIGN KEY (Date_Key) REFERENCES Dim_Date(Date_Key),
    FOREIGN KEY (Location_Key) REFERENCES Dim_Location(Location_Key),
    FOREIGN KEY (Shipping_Key) REFERENCES Dim_Shipping(Shipping_Key)
);

CREATE TABLE Fact_Returns (
    Return_Key INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID VARCHAR(50),
    Date_Key INT,
    Location_Key INT,
    Returned VARCHAR(10),

    FOREIGN KEY (Date_Key) REFERENCES Dim_Date(Date_Key),
    FOREIGN KEY (Location_Key) REFERENCES Dim_Location(Location_Key)
);



CREATE TABLE staging_customer (
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(100),
    Region VARCHAR(50),
    Market VARCHAR(50)
);

CREATE TABLE staging_product (
    Product_ID VARCHAR(50),
    Product_Name VARCHAR(150),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100)
);

CREATE TABLE  Staging_Sales_Transactions (
    Order_ID       VARCHAR(255),
    Order_Date     DATE,
    Ship_Date      DATE,
    Customer_ID    VARCHAR(255),
    Product_ID     VARCHAR(255),
    Sales          DECIMAL(12, 2),
    Quantity       BIGINT,
    Profit         DECIMAL(12, 2),
    Shipping_Cost  DOUBLE,
    Discount       DOUBLE,
    Order_Priority VARCHAR(255),
    Ship_Mode      VARCHAR(255)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_data.csv'
INTO TABLE Staging_Customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_ID, Customer_Name, Segment, Country, City, Region, Market);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_data.csv'
INTO TABLE Staging_Product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_ID, Product_Name, Category, Sub_Category);



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_transactions.csv'
INTO TABLE Staging_Sales_Transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Order_Date, Ship_Date, Customer_ID, Product_ID,
 Sales, Quantity, Profit, Shipping_Cost, Discount,
 Order_Priority, Ship_Mode);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_data.csv'
INTO TABLE Dim_Customer
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_ID, Customer_Name, Segment, Country, City, Region, Market);

INSERT INTO Dim_Product
    (Product_ID, Product_Name, Category, Sub_Category)
SELECT DISTINCT
    Product_ID, Product_Name, Category, Sub_Category
FROM Staging_Product
WHERE Product_ID NOT IN (SELECT Product_ID FROM Dim_Product);

INSERT INTO Dim_Date
    (Full_Date, Day, Month, Month_Name, Quarter, Year, Day_of_Week, Is_Weekend)
SELECT DISTINCT
    d.Full_Date,
    DAY(d.Full_Date)                             AS Day,
    MONTH(d.Full_Date)                           AS Month,
    DATE_FORMAT(d.Full_Date, '%M')               AS Month_Name,
    CONCAT('Q', QUARTER(d.Full_Date))            AS Quarter,
    YEAR(d.Full_Date)                            AS Year,
    DAYNAME(d.Full_Date)                         AS Day_of_Week,
    CASE WHEN DAYOFWEEK(d.Full_Date) IN (1, 7)
         THEN 1 ELSE 0 END                       AS Is_Weekend
FROM (
    SELECT Order_Date AS Full_Date FROM Staging_Sales_Transactions
    UNION
    SELECT Ship_Date  AS Full_Date FROM Staging_Sales_Transactions
) d
WHERE d.Full_Date IS NOT NULL
  AND d.Full_Date NOT IN (SELECT Full_Date FROM Dim_Date);

INSERT INTO Dim_Location
    (Country, City, Region, Market)
SELECT DISTINCT
    c.Country, c.City, c.Region, c.Market
FROM Staging_Customer c
WHERE NOT EXISTS (
    SELECT 1 FROM Dim_Location dl
    WHERE dl.Country = c.Country
      AND dl.City    = c.City
      AND dl.Region  = c.Region
      AND dl.Market  = c.Market
);

INSERT INTO Dim_Shipping
    (Ship_Mode, Order_Priority)
SELECT DISTINCT
    s.Ship_Mode, s.Order_Priority
FROM Staging_Sales_Transactions s
WHERE NOT EXISTS (
    SELECT 1 FROM Dim_Shipping ds
    WHERE ds.Ship_Mode      = s.Ship_Mode
      AND ds.Order_Priority = s.Order_Priority
);



SET @batch_size = 1000;
SET @offset = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_transactions.csv'
INTO TABLE Staging_Sales_Transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID,Order_Date,Ship_Date,Customer_ID,Product_ID,Sales,Quantity,Profit,Shipping_Cost,Discount,Order_Priority,Ship_Mode);

INSERT INTO Fact_Sales
(
    Order_ID,
    Customer_Key,
    Product_Key,
    Date_Key,
    Location_Key,
    Shipping_Key,
    Quantity,
    Sales,
    Profit,
    Shipping_Cost,
    Discount,
    Order_Priority,
    Ship_Mode
)

SELECT
    s.Order_ID,
    c.Customer_Key,
    p.Product_Key,
    d.Date_Key,
    l.Location_Key,
    sh.Shipping_Key,
    s.Quantity,
    s.Sales,
    s.Profit,
    s.Shipping_Cost,
    s.Discount,
    s.Order_Priority,
    s.Ship_Mode

FROM Staging_Sales_Transactions s

JOIN Dim_Customer c
ON s.Customer_ID = c.Customer_ID

JOIN Dim_Product p
ON s.Product_ID = p.Product_ID

JOIN Dim_Date d
ON s.Order_Date = d.Full_Date

JOIN Dim_Location l
ON c.City = l.City
AND c.Country = l.Country

JOIN Dim_Shipping sh
ON s.Ship_Mode = sh.Ship_Mode
AND s.Order_Priority = sh.Order_Priority;

USE Supermarket_Warehouse_new5;
CREATE TABLE Staging_Returns (
    Order_ID VARCHAR(50),
    Return_Date DATE,
    Country VARCHAR(50),
    City VARCHAR(100),
    Returned VARCHAR(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/returns_data.csv'
INTO TABLE Staging_Returns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Return_Date, Country, City, Returned);

INSERT INTO Fact_Returns
(Order_ID, Date_Key, Location_Key, Returned)

SELECT
    r.Order_ID,
    d.Date_Key,
    l.Location_Key,
    r.Returned

FROM Staging_Returns r

JOIN Dim_Date d
ON r.Return_Date = d.Full_Date

JOIN Dim_Location l
ON r.Country = l.Country
AND r.City = l.City;


