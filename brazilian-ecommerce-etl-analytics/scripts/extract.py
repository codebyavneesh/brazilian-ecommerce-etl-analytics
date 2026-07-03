import pandas as pd

# Task 1- Extract all files using dictionary
data={
        'customers':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_customers_dataset.csv', encoding='latin1'),
        'geolocation':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_geolocation_dataset.csv', encoding='latin1'),
        'order_items':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_order_items_dataset.csv', encoding='latin1'),
        'order_payments':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_order_payments_dataset.csv', encoding='latin1'),
        'order_reviews':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_order_reviews_dataset.csv', encoding='latin1'),
        'orders':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_orders_dataset.csv', encoding='latin1'),
        'products':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_products_dataset.csv', encoding='latin1'),
        'sellers':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/olist_sellers_dataset (1).csv', encoding='latin1'),
        'product_category_name_translation':pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/ecommerce-etl-project/data/raw_data/product_category_name_translation.csv', encoding='latin1')
    }

print('Data Successfully Extracted!!')


def extract_data(data):
    # Task 2- Print all files name, rows and columns
    for name, df in data.items():
        print(f"\n{name}: {df.shape[0]} {df.shape[1]}")


    # Task 3- order_perchase_timestamp ka min aur max nikalo-- dataset ka range confirm kro
    data['orders']['order_purchase_timestamp']=pd.to_datetime(data['orders']['order_purchase_timestamp'])

    min_date=data['orders']['order_purchase_timestamp'].min()

    max_date=data['orders']['order_purchase_timestamp'].max()

    print("\nRange in Days: ",max_date-min_date)


    # Task 4- Count NULL values in all files and print the NULL columns
    for name, df in data.items():
        print(f'\n{name} NULL values: {df.isnull().sum()}')
    # order_reviews, orders and products in this dataset have NULL values


    # Task 5- order_status ke unique values aur unka count nikalo
    print("\norder_status: ",data['orders']['order_status'].unique())
    print("order_status values:",data['orders']['order_status'].nunique())


    # Task 6- order_deliverd_customer_date and order_estimated_delivery_date compare karke late delivery wale orders count karo.
    data['orders']['order_delivered_customer_date']=pd.to_datetime(data['orders']['order_delivered_customer_date'], errors='coerce')

    data['orders']['order_estimated_delivery_date']=pd.to_datetime(data['orders']['order_estimated_delivery_date'], errors='coerce')

    late_delivery=data['orders']['order_estimated_delivery_date']-data['orders']['order_delivered_customer_date']

    late_delivery=late_delivery.dropna()
    print('\nTop 5 late delivery orders: \n',late_delivery.sort_values(ascending=False).head())


    # Task 7- order_items mein price<=0 wale rows dhundo aur count print karo
    print("\nPrice <= 0 Rows Count: ",(data['order_items']['price']<=0).sum())


    # Task 8- orders mein order_purchase_timestamp 2018 ke baad ka koi rows hai kya check kro
    data['orders']['order_purchase_timestamp']=pd.to_datetime(data['orders']['order_purchase_timestamp'])

    data['orders']['purchase_year']=data['orders']['order_purchase_timestamp'].dt.year

    future_orders=(data['orders']['purchase_year']>2018)

    print("\nCount after 2018: ",(future_orders).sum())


    # Task 10- Orphan records dhundho-- order_items mein jo order_id hain jo orders table me exists nhi karte. extract_all() function se yeh sab dictionary return karo.
    order=data['orders']
    order_items=data['order_items']

    orphan_orders=order_items[~order_items['order_id'].isin(order['order_id'])]

    print("\nOrphan Records Count:", len(orphan_orders))

    print(orphan_orders.head())


    # Task 10- Har table ke columns print karke manually PK/FK map banao -- dictionary mein store karo.
    for table, df in data.items():
        print(f"\n{'='*50}")
        print(f"Table: {table}")
        print(f"\n{'='*50}")

        print(df.columns)


    schema_mapping={
        'customers':{
            'PK':['customer_id'],
            'FK':[]
        },
        'orders':{
            'PK':['order_id'],
            'FK':['customer_id']
        },
        'order_items':{
            'PK':['order_item_id'],
            'FK':['product_id', 'seller_id', 'order_id']
        },
        'geolocation':{
            'PK':['geolocation_zip_code_prefix'],
            'FK':[]
        },
        'order_payments':{
            'PK':['order_id'],
            'FK':[]
        },
        'order_reviews':{
            'PK':['review_id', ],
            'FK':['order_id']
        },
        'products':{
            'PK':['product_id'],
            'FK':[]
        },
        'sellers':{
            'PK':['seller_id'],
            'FK':[]
        },
        'product_category_name':{
            'PK':[],
            'FK':[]
        }
    }

    for table, keys in schema_mapping.items():
        print(f"\nTable: {table}")
        print("PK: ", keys["PK"])
        print("FK: ", keys["FK"])
    
    return data