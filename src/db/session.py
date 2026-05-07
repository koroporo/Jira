import mysql.connector
from mysql.connector import Error

import os
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=os.getenv("DB_PORT", "3306"),
            user=os.getenv("DB_USER", "root"),
            database=os.getenv("DB_NAME", "db"),
            password=os.getenv("DB_PASSWORD", "1")
        )
        return connection
    except Error as e:
        print(f"MySQL connecting failed: {e}")
        return None