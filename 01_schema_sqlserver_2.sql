create database EcommerceDB

use EcommerceDB

IF OBJECT_ID('order_items', 'U') IS NOT NULL DROP TABLE order_items;
IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products;
IF OBJECT_ID('categories', 'U') IS NOT NULL DROP TABLE categories;
IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;
GO

CREATE TABLE categories (
    category_id   INT PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    description   VARCHAR(200)
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    category_id   INT NOT NULL,
    price         DECIMAL(10,2) NOT NULL,
    stock         INT NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    city          VARCHAR(50) NOT NULL,
    state         VARCHAR(50) NOT NULL,
    joined_date   DATE NOT NULL
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT NOT NULL,
    order_date    DATE NOT NULL,
    total_amount  DECIMAL(10,2) NOT NULL,
    status        VARCHAR(20) NOT NULL CHECK(status IN ('completed','pending','cancelled','returned')),
    payment_mode  VARCHAR(30) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id       INT PRIMARY KEY,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT NOT NULL DEFAULT 1,
    unit_price    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

