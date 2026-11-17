CREATE DATABASE IF NOT EXISTS olist_db;
USE olist_db;
SHOW TABLES;
CREATE TABLE customers (
    customer_id              VARCHAR(32) PRIMARY KEY,
    customer_unique_id       VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city            VARCHAR(100),
    customer_state           CHAR(2)
);

CREATE TABLE orders (
    order_id                      VARCHAR(32) PRIMARY KEY,
    customer_id                   VARCHAR(32) NOT NULL,
    order_status                  VARCHAR(20),
    order_purchase_timestamp      DATETIME,
    order_approved_at             DATETIME NULL,
    order_delivered_carrier_date  DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL
);

CREATE TABLE order_items (
    order_id            VARCHAR(32) NOT NULL,
    order_item_id       INT NOT NULL,
    product_id          VARCHAR(32) NOT NULL,
    seller_id           VARCHAR(32),
    shipping_limit_date DATETIME,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE products (
    product_id                 VARCHAR(32) PRIMARY KEY,
    product_category_name      VARCHAR(100) NULL,
    product_name_lenght        INT NULL,
    product_description_lenght INT NULL,
    product_photos_qty         INT NULL,
    product_weight_g           INT NULL,
    product_length_cm          INT NULL,
    product_height_cm          INT NULL,
    product_width_cm           INT NULL
);

CREATE TABLE product_category_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);
