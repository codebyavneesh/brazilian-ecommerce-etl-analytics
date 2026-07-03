import pandas as pd
from sqlalchemy import create_engine

def load_data():
    engine = create_engine(
        "mysql+pymysql://root:root@localhost/customerdb"
    )
    
    tables = {
        "customers":"customers_cleaned.csv",
        "sellers":"sellers_cleaned.csv",
        "products":"products_cleaned.csv",
        "orders":"orders_cleaned.csv",
        "order_items":"order_items_cleaned.csv",
        "order_payments":"order_payments_cleaned.csv",
        "order_review":"order_reviews_cleaned.csv",
        "geolocation":"geolocation_cleaned.csv",
        "product_category_name_translation":"product_category_name_translation_cleaned.csv"
    }
    
    for table, file in tables.items():
    
        df = pd.read_csv(
            f"C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/processed_data/{file}"
        )
    
        df.to_sql(
            table,
            con=engine,
            if_exists="append",
            index=False,
            chunksize=5000
        )
    
        print(f"{table} loaded")
    
    print("All tables loaded successfully!")