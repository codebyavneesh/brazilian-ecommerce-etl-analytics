from extract import data, extract_data
from transform import transform_data, save_processed_data
from load import load_data


def main():

    print("=" * 50)
    print("ETL PIPELINE STARTED")
    print("=" * 50)

    # Extract
    print("\n[1] Extracting Data...")
    extracted_data = extract_data(data)

    # Transform
    print("\n[2] Transforming Data...")
    transformed_data = transform_data(extracted_data)

    # Save Processed CSV Files
    print("\n[3] Saving Processed Files...")
    save_processed_data(transformed_data)

    # Load into MySQL
    print("\n[4] Loading Data Into MySQL...")
    load_data()

    print("\n" + "=" * 50)
    print("ETL PIPELINE COMPLETED SUCCESSFULLY")
    print("=" * 50)


if __name__ == "__main__":
    main()