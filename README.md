# E-Commerce Sales Analysis (SQL Project)

I built this project to practice SQL by analyzing sales data for an online store. It uses a small relational database with customers, products, categories, orders, and order items — and I wrote 15 queries to answer real business questions like who the top customers are, which products sell the most, and how revenue changes month to month.

## What's in this repo

- **01_schema_sqlserver.sql** – creates the database tables
- **02_data_sqlserver.sql** – inserts sample data (customers, products, orders)
- **03_queries_sqlserver.sql** – 15 SQL queries that analyze the data

## How to run it

1. Open SQL Server Management Studio
2. Run `01_schema_sqlserver.sql` first
3. Then run `02_data_sqlserver.sql`
4. Then open `03_queries_sqlserver.sql` and run each query to see the results

## What I learned / practiced

- Writing SELECT, WHERE, GROUP BY, and HAVING queries
- Joining multiple tables (INNER JOIN, LEFT JOIN)
- Using subqueries and window functions like RANK()
- Writing CTEs for cleaner, multi-step queries
- Turning query results into simple business insights

## A few things I found in the data

- Electronics is the top-selling category
- A small group of customers account for most of the revenue
- Some customers signed up but never placed an order
- Revenue peaks around October–November
