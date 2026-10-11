
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

load_dotenv()

url = URL.create(
    "postgresql+psycopg2",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT")),
    database=os.getenv("DB_NAME")
)

try:
    engine = create_engine(url)

    with engine.connect() as connection:
        result = connection.execute(
            text("SELECT current_database()")
        )

        print("Connected successfully!")
        print("Database:", result.scalar())

except Exception as e:
    print("Connection failed!")
    print("Error:", e)

finally:
    if "engine" in locals():
        engine.dispose()
