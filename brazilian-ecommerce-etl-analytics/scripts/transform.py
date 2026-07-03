from extract import data
import pandas as pd
import os

def transform_data(data):
    # Task 11- order_purchase_timestamp ko datetime me convert karo, order_year, order_month, order_quarter, day_of_week columns banao
    orders=data['orders']
    orders['order_purchase_timestamp']=pd.to_datetime(orders['order_purchase_timestamp'])

    orders['order_year']=orders['order_purchase_timestamp'].dt.year
    orders['order_month']=orders['order_purchase_timestamp'].dt.month
    orders['order_quarter']=orders['order_purchase_timestamp'].dt.quarter
    orders['day_of_week']=orders['order_purchase_timestamp'].dt.day_of_week


    # Task 12- orders table se duplicate order_id rows ko remove karo, kitne removed hue print karo
    orders=data['orders']

    before_rows=len(orders)

    after_rows=len(orders)

    removed_rows=after_rows-before_rows

    print("\nDuplicate order_id rows removed: ", removed_rows)
    print("\nRemaining rows: ",after_rows)


    # Task 13- order_items mein total_order_value = price+freight_value column banao
    order_items=data['order_items']

    order_items['shipping_limit_date']=pd.to_datetime(order_items['shipping_limit_date'])

    order_items['total_order_value']=order_items['price']+order_items['freight_value']

    print("\n",order_items['total_order_value'].head())


    # Task 14- order_items se price<=0 wale invalid rows ko filter karo.
    order_items=data['order_items']

    invalid_rows=order_items['price'].apply(lambda x: "N/A" if x<=0 else x)

    print(invalid_rows.sort_values(ascending=False).tail())


    # Task 15- customers aur sellers table mein customer_city/seller_city ko .str.strip().str.title() se standardize karo.
    customers=data['customers']
    sellers=data['sellers']

    customers['customer_city']=customers['customer_city'].str.strip().str.title()

    sellers['seller_city']=sellers['seller_city'].str.strip().str.title()

    print(customers['customer_city'].head())
    print(sellers['seller_city'].head())


    # Task 16- products table ko product_category_name_translation ke saath merge karo -- English category name add karo, missing ko 'unknown' rakho.

    products=data['products']

    products['product_photos_qty']=products['product_photos_qty'].replace("",pd.NA)

    products['product_length_cm']=products['product_length_cm'].replace("", pd.NA)

    products['product_weight_g']=products['product_weight_g'].replace("", pd.NA)

    products['product_width_cm']=products['product_width_cm'].replace("", pd.NA)

    products['product_height_cm']=products['product_height_cm'].replace("", pd.NA)

    products['product_category_name']=products['product_category_name'].fillna('unknown')

    products['product_name_lenght']=products['product_name_lenght'].fillna(0)

    products['product_description_lenght']=products['product_description_lenght'].fillna(0)

    translation=data['product_category_name_translation']

    translation.columns=translation.columns.str.replace('ï»¿','',regex=False)

    products=products.merge(translation, on="product_category_name", how="left")

    products['product_category_name_english']=(
        products['product_category_name_english'].fillna('unknown')
    )

    print(
        products[
            [
                'product_category_name',
                'product_category_name_english'
            ]
        ].head()
    )


    # Task 17- order_delivered_customer_date - order_purchase_timestamp se delivery_days column banao
    orders=data['orders']

    orders['order_delivered_carrier_date']=orders['order_delivered_carrier_date'].replace("", pd.NA)

    orders['order_approved_at']=orders['order_approved_at'].replace("",pd.NA)

    orders['order_delivered_customer_date']=pd.to_datetime(orders['order_delivered_customer_date'])

    orders['order_delivered_customer_date']=orders['order_delivered_customer_date'].replace("",pd.NA)

    orders['order_purchase_timestamp']=pd.to_datetime(orders['order_purchase_timestamp'])

    orders['delivery_days']=orders['order_delivered_customer_date']-orders['order_purchase_timestamp']

    orders['order_approved_at']=pd.to_datetime(orders['order_approved_at'])

    orders['order_delivered_carrier_date']=pd.to_datetime(orders['order_delivered_carrier_date'])

    orders['order_estimated_delivery_date']=pd.to_datetime(orders['order_estimated_delivery_date'])

    print("\n",orders['delivery_days'].head())

    orders['order_approved_at'] = pd.to_datetime(
        orders['order_approved_at'],
        errors='coerce'
    )

    orders['order_delivered_carrier_date'] = pd.to_datetime(
        orders['order_delivered_carrier_date'],
        errors='coerce'
    )

    orders['order_delivered_customer_date'] = pd.to_datetime(
        orders['order_delivered_customer_date'],
        errors='coerce'
    )
    
    orders = orders.where(pd.notnull(orders), None)
    # Task 18- delivery_days meinn IQR method se outliers detect karo, ek separate DataFrame mein rakho.
    orders=data['orders']
    Q1=orders['delivery_days'].quantile(0.25)
    Q3=orders['delivery_days'].quantile(0.75)

    IQR=Q3-Q1

    lower_bound=Q1-1.5*IQR
    upper_bound=Q3+1.5*IQR

    outliers_df=orders[
        (orders['delivery_days']<lower_bound) | (orders['delivery_days']>upper_bound)
    ]

    print(f"Total Outliers: {len(outliers_df)}")
    print(outliers_df.head())

    # Task 19- payment_type column pe pd.get_dummies() se one-hot encoding karo.
    payments=data['order_payments']

    payments=pd.get_dummies(payments['payment_type'])
    print(payments.head())


    # Task 20- sabhi tables mein 40% + null wale columns drop karo (jaise review_comment_message agar threshold cross kare).
    for name, df in data.items():
        null_percentage=df.isnull().mean()

        cols_to_drop=null_percentage[null_percentage>=0.40].index

        df.drop(columns=cols_to_drop, inplace=True)

        print(f"\n{name}")
        print("Dropped: ",list(cols_to_drop))


    # Task 21- Final cleaned tables mein har table ka .info() run karke confirm karo ki dtypes shi hai (dates datetime, peices float).
    for name, df in data.items():
        print(f"\n{'='*50}")
        print(f"{name}")
        print(f"{df.info()}")
        print(f"{'='*50}")


    # reviews dataset me object datatype ko datetime conversion
    reviews=data['order_reviews']

    reviews['review_creation_date']=pd.to_datetime(reviews['review_creation_date'])
    reviews['review_answer_timestamp']=pd.to_datetime(reviews['review_answer_timestamp'])
    
    geolocation=data['geolocation']
    order_payments=data['order_payments']
    product_category_name_translation=data['product_category_name_translation']
    
    # Update transformed tables back to dictionary
    data['orders'] = orders
    data['order_items'] = order_items
    data['customers'] = customers
    data['sellers'] = sellers
    data['products'] = products
    data['order_reviews'] = reviews
    data['geolocation'] = geolocation
    data['order_payments']=order_payments
    data['product_category_name_translation']=product_category_name_translation
    
    missing = set(order_items['order_id']) - set(orders['order_id'])
    print(len(orders))
    return data



def save_processed_data(data):

    output_path = r"C:\Users\Sistech Computer\OneDrive\Desktop\sandeep\ecommerce-etl-project\data\processed_data"

    os.makedirs(output_path, exist_ok=True)

    for table_name, df in data.items():

        file_path = os.path.join(
            output_path,
            f"{table_name}_cleaned.csv"
        )

        df.to_csv(
            file_path,
            index=False,
            encoding="utf-8"
        )

        print(f"Saved: {file_path}")

    print("\nAll processed files saved successfully!")


# Main execution
# transformed_data = transform_data(data)

# save_processed_data(transformed_data)
    