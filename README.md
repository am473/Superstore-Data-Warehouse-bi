# 📊 SuperStore Data Warehouse & Business Intelligence Solution

## Overview

This project presents the design and implementation of a complete Data Warehouse and Business Intelligence solution for a retail supermarket environment. The system integrates data from multiple operational sources, transforms it through an ETL process, stores it in a centralized Data Warehouse using a Galaxy Schema, and delivers actionable business insights through Power BI dashboards.

The solution enables efficient reporting, trend analysis, customer segmentation, profitability assessment, and strategic decision-making.

---

## Objectives

* Integrate data from multiple heterogeneous sources
* Design a scalable Data Warehouse using a Galaxy Schema
* Implement an ETL pipeline for data extraction, transformation, and loading
* Create analytical models for business reporting
* Develop interactive Power BI dashboards
* Generate business insights to support data-driven decisions

---

## Technologies Used

* MySQL
* SQL
* Power BI
* ETL Process
* Data Warehousing
* Galaxy Schema Modeling
* CSV Data Sources
* Excel Data Sources

---

## Data Sources

### Customer Data

* Source Type: CSV File
* Customer profiles and segmentation information

### Sales Transactions

* Source Type: MySQL Database
* Sales orders, revenue, profit, discounts, and shipping details

### Product Data

* Source Type: Excel Spreadsheet
* Product categories and subcategories

---

## Data Warehouse Design

### Fact Tables

* Fact_Sales
* Fact_Returns

### Dimension Tables

* Dim_Customer
* Dim_Product
* Dim_Date
* Dim_Location
* Dim_Shipping

### Schema Type

Galaxy Schema

The Galaxy Schema was selected to support multiple business processes while sharing common dimensions, enabling efficient multidimensional analysis.

---

## ETL Process

### Extract

Data collected from:

* CSV files
* Excel spreadsheets
* MySQL transactional database

### Transform

* Data cleaning
* Duplicate removal
* Data validation
* Data standardization

### Load

Data loaded into:

* Dimension tables
* Fact tables

---

## Power BI Dashboard Features

### Sales Analysis

* Sales by Year and Category
* Regional Sales Performance
* Total Sales, Profit, and Quantity KPIs

### Product Analysis

* Category Performance
* Product Profitability
* Category Ranking

### Customer Analysis

* Customer Segmentation
* Top Customers by Revenue

### Shipping Analysis

* Shipping Cost vs Sales
* Order Priority Distribution

### Profit Analysis

* Year-over-Year Profit Trends
* Profit Contribution by Product Category

---

## Key Business Insights

* Identified high-performing product categories
* Analyzed customer purchasing behavior
* Evaluated regional sales performance
* Measured shipping cost impact on profitability
* Supported strategic business decision-making through data-driven insights

---

## Project Structure

SuperStore-Data-Warehouse-BI/

├── dashboard/

├── reports/

├── sources/

├── sql/

├── Galaxy_Schema.png

├──LICENSE

├── README.md


---

## Results

The implementation successfully demonstrates:

✔ Centralized Data Warehouse Architecture

✔ Efficient ETL Pipeline

✔ Interactive Business Intelligence Dashboards

✔ Improved Reporting and Analytics

✔ Enhanced Decision Support Capabilities

---

## Future Enhancements

* Real-time data integration
* Automated ETL scheduling
* Advanced predictive analytics
* Machine Learning integration for sales forecasting
* Cloud-based Data Warehouse deployment

---

## License

This project is licensed under the MIT License.
