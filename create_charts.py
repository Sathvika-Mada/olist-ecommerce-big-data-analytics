
from pathlib import Path
import os

import pandas as pd
import matplotlib.pyplot as plt
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

# Load PostgreSQL connection details
load_dotenv()

db_url = URL.create(
    "postgresql+psycopg2",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "5433")),
    database=os.getenv("DB_NAME")
)

engine = create_engine(db_url)

BASE_DIR = Path(__file__).resolve().parent
CHART_DIR = BASE_DIR / "charts"
CHART_DIR.mkdir(exist_ok=True)


def load_query(filename):
    sql_path = BASE_DIR / "sql" / filename

    query = sql_path.read_text(encoding="utf-8")

    with engine.connect() as connection:
        return pd.read_sql_query(text(query), connection)


# Chart 1: Monthly GMV
df = load_query("metrics/monthly_gmv.sql")
df["month"] = pd.to_datetime(df["month"])

plt.figure(figsize=(10, 5))
plt.plot(df["month"], df["monthly_gmv"], marker="o")
plt.title("Monthly Delivered GMV")
plt.xlabel("Month")
plt.ylabel("GMV (R$)")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(CHART_DIR / "monthly_gmv.png", dpi=150)
plt.close()

print("Chart 1 created")


# Chart 2: Top product categories
df = load_query("analysis/query2.sql")
df = df.sort_values("revenue")

plt.figure(figsize=(10, 6))
plt.barh(df["category"], df["revenue"])
plt.title("Top Product Categories by Revenue")
plt.xlabel("Product Revenue (R$)")
plt.tight_layout()
plt.savefig(CHART_DIR / "top_categories.png", dpi=150)
plt.close()

print("Chart 2 created")


# Chart 3: Customer purchase behavior
df = load_query("analysis/query4.sql")

plt.figure(figsize=(7, 5))
plt.bar(df["customer_type"], df["percentage_of_customers"])
plt.title("One-time vs Repeat Customers")
plt.xlabel("Customer Type")
plt.ylabel("Percentage of Customers (%)")
plt.tight_layout()
plt.savefig(CHART_DIR / "repeat_customers.png", dpi=150)
plt.close()

print("Chart 3 created")


# Chart 4: Late deliveries by state
df = load_query("analysis/query5.sql")
df = df.sort_values(
    "late_delivery_percentage",
    ascending=False
).head(10)
df = df.sort_values("late_delivery_percentage")

plt.figure(figsize=(9, 6))
plt.barh(
    df["customer_state"],
    df["late_delivery_percentage"]
)
plt.title("Top 10 States by Late Delivery Rate")
plt.xlabel("Late Delivery Rate (%)")
plt.tight_layout()
plt.savefig(CHART_DIR / "late_deliveries.png", dpi=150)
plt.close()

print("Chart 4 created")

engine.dispose()
print("All 4 charts created successfully!")
