import logging
import mysql.connector
from mysql.connector import Error

from core.config import settings

logger = logging.getLogger(__name__)

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            user=settings.DB_USER,
            database=settings.DB_NAME,
            password=settings.DB_PASSWORD,
        )
        return connection
    except Error as e:
        logger.error("MySQL connecting failed: %s", e)
        raise ConnectionError(f"MySQL connecting failed: {e}") from e