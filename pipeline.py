
import os
import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
import logging
from sqlalchemy import text
# Load database credentials
load_dotenv()

# Connect to PostgreSQL
url = URL.create(
    "postgresql+psycopg2",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT")),
    database=os.getenv("DB_NAME")
)

engine = create_engine(url)

# Location of CSV files
data_folder = Path(__file__).resolve().parent / "data"

# CSV filenames and corresponding table names
files = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "payments",
    "olist_order_reviews_dataset.csv": "reviews",
    "olist_customers_dataset.csv": "customers",
    "olist_sellers_dataset.csv": "sellers",
    "olist_products_dataset.csv": "products",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "category_translation"
}


logging.basicConfig(
    filename="pipeline.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def run_sql_file(connection, filename):
    sql_path = Path(__file__).resolve().parent / "sql" / filename

    if not sql_path.exists():
        raise FileNotFoundError(
            f"Missing SQL file: {sql_path}"
        )

    sql = sql_path.read_text(encoding="utf-8")

    # Execute each statement separately.
    statements = sql.split(";")

    for statement in statements:
        if statement.strip():
            connection.execute(text(statement))

    logging.info("%s executed successfully", filename)
    print(f"{filename} executed successfully")


def run_quality_checks(connection):
    checks = {
        "check1.sql": "Null or duplicate order IDs",
        "check2.sql": "Invalid delivery dates",
        "check3.sql": "Payment mismatches",
        "check4.sql": "Missing customer records",
        "check5.sql": "Invalid review scores"
    }

    for filename, description in checks.items():

        sql_path = (
            Path(__file__).resolve().parent
            / "sql"
            / "data_quality"
            / filename
        )

        if not sql_path.exists():
            raise FileNotFoundError(
                f"Missing quality check: {filename}"
            )

        sql_query = sql_path.read_text(encoding="utf-8")
        result = connection.execute(text(sql_query)).mappings().one()

        # Check 1 returns two counts; the others return one.
        failure_count = sum(int(value) for value in result.values())

        if failure_count == 0:
            message = f"PASS: {description} - 0 issues"
            print(message)
            logging.info(message)

        elif filename == "check3.sql":
            # Payment differences require investigation.
            message = (
                f"WARNING: {description} - "
                f"{failure_count} mismatches flagged"
            )
            print(message)
            logging.warning(message)

        else:
            message = (
                f"FAIL: {description} - "
                f"{failure_count} invalid records"
            )
            logging.error(message)
            raise ValueError(message)



try:
    logging.info("Pipeline started")
    print("Pipeline started")

    with engine.begin() as connection:

        # Step 1: Load raw CSV data
        for filename, table_name in files.items():

            file_path = data_folder / filename

            if not file_path.exists():
                raise FileNotFoundError(
                    f"Missing file: {filename}"
                )

            print(f"Loading {filename}...")

            df = pd.read_csv(file_path, dtype=str)

            df.to_sql(
                name=table_name,
                con=connection,
                schema="raw",
                if_exists="replace",
                index=False,
                chunksize=5000
            )

            logging.info(
                "Loaded %s: %d rows",
                table_name, len(df)
            )

        run_sql_file(connection, "staging.sql")

    
        run_quality_checks(connection)

        
        run_sql_file(connection, "mart.sql")

    logging.info("Pipeline completed successfully")
    print("Pipeline completed successfully!")

except Exception:
    logging.exception("Pipeline failed")
    print("Pipeline failed. Check pipeline.log")
    raise

finally:
    engine.dispose()

