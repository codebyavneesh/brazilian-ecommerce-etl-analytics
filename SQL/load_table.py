import pandas as pd
from sqlalchemy import create_engine, text

# ---- Edit these 4 lines ----
USER = "root"
PASSWORD = "root"
HOST = "localhost"
FOLDER = r"C:\Users\Sistech Computer\OneDrive\Desktop\sandeep\updated_brazzillian_project\Dataset\Cleaned"   # folder where your cleaned CSVs are
# ----------------------------

DB = "olist_db"
engine = create_engine(f"mysql+pymysql://{USER}:{"root"}@{HOST}/{DB}")

# table name in MySQL -> (csv file name, date columns)
# Change the csv file names if yours are different
files = {
    "customers": ("cleaned_customers.csv", []),
    "orders": ("cleaned_orders.csv", [
        "order_purchase_timestamp", "order_approved_at",
        "order_delivered_carrier_date", "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ]),
    "order_items": ("cleaned_order_items.csv", ["shipping_limit_date"]),
    "products": ("cleaned_products.csv", []),
    "product_category_translation": ("cleaned_product_category.csv", []),
}

for table, (csv_name, date_cols) in files.items():
    df = pd.read_csv(f"{FOLDER}\\{csv_name}", parse_dates=date_cols)

    # drop the extra pandas index column (header is empty or "Unnamed: 0")
    df = df.loc[:, ~df.columns.str.startswith("Unnamed")]

    csv_rows = len(df)
    df.to_sql(table, engine, if_exists="append", index=False, chunksize=5000)

    with engine.connect() as conn:
        db_rows = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()

    status = "OK" if csv_rows == db_rows else "MISMATCH"
    print(f"{table:32} csv={csv_rows:>7}  db={db_rows:>7}  {status}")