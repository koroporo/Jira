"""
src/core/config.py
------------------
Reads all sensitive configuration from the .env file.
Never hardcode credentials in source code.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # ── Database ──────────────────────────────────────────────
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = ""
    DB_NAME: str = "db"

    # ── Application ───────────────────────────────────────────
    APP_TITLE: str = "Koroporo Jira API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

# Single shared instance used across the entire application
settings = Settings()