import mysql.connector

conn=mysql.connector.connect(
    host='localhost',
    user='root',
    password='root',
    database='customerdb'
)

cursor=conn.cursor()
cursor.execute("CREATE DATABASE IF NOT EXISTS customerdb")

# TABLE 1- customers
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS customers(
        customer_id VARCHAR(90) PRIMARY KEY,
        customer_unique_id VARCHAR(90),
        customer_zip_code_prefix VARCHAR(90),
        customer_city VARCHAR(90),
        customer_state VARCHAR(90)
    )
    '''
)

# TABLE 2- orders
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS orders(
        order_id VARCHAR(90) PRIMARY KEY,
        customer_id VARCHAR(90),
        order_status VARCHAR(90),
        order_purchase_timestamp DATETIME,
        order_approved_at DATETIME,
        order_delivered_carrier_date DATETIME,
        order_delivered_customer_date DATETIME,
        order_estimated_delivery_date DATETIME,
        order_year VARCHAR(90),
        order_month VARCHAR(90),
        order_quarter VARCHAR(90),
        day_of_week VARCHAR(90),
        delivery_days VARCHAR(90),
        
        CONSTRAINT fk_orders_customers
        FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
    )
    '''
)

# TABLE 3- geolocation
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS geolocation(
    geolocation_zip_code_prefix INT,
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(90),
    geolocation_state VARCHAR(90)
    )
    '''
)

# TABLE 4- sellers
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS sellers(
        seller_id VARCHAR(90) PRIMARY KEY,
        seller_zip_code_prefix INT,
        seller_city VARCHAR(90),
        seller_state VARCHAR(90)
    )
    '''
    
)

# TABLE 5- products
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    product_category_name_english VARCHAR(90)
    )
    '''
)

# TABLE 6- order_items
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS order_items(
    order_id VARCHAR(90),
    order_item_id INT,
    product_id VARCHAR(90),
    seller_id VARCHAR(90),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    total_order_value DECIMAL(10, 2),

    PRIMARY KEY(order_id, order_item_id),

    FOREIGN KEY(order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY(product_id)
        REFERENCES products(product_id),

    FOREIGN KEY(seller_id)
        REFERENCES sellers(seller_id)
    )
    '''
)

# TABLE 7- order_payments
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS order_payments(
        order_id VARCHAR(90),
        payment_sequential INT,
        payment_type VARCHAR(90),
        payment_installments INT,
        payment_value DECIMAL(10, 2),
        
        FOREIGN KEY(order_id) REFERENCES orders(order_id)
    )
    '''    
)

# TABLE 8- order_review
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS order_review(
    review_id VARCHAR(90),
    order_id VARCHAR(90),
    review_score INT,
    review_comment_title VARCHAR(160),
    review_comment_message VARCHAR(350),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,

    PRIMARY KEY(review_id, order_id),

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id)
    )
    '''
)

# TABLE 9- product_category_name_translation
cursor.execute(
    '''
    CREATE TABLE IF NOT EXISTS product_category_name_translation(
        product_category_name VARCHAR(90) PRIMARY KEY,
        product_category_name_english VARCHAR(90)
    )
    '''
)

conn.commit()

cursor.execute("SELECT COUNT(*) FROM orders")
print(cursor.fetchone())
