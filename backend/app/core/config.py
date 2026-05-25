import os
from dotenv import load_dotenv

load_dotenv()
def get_secret_key() -> str:
    key = os.getenv("DELIVERA_SECRET_KEY")
    if key:
        return key
    return "dev-only-change-me-in-production"

DATABASE_URL = os.getenv("DATABASE_URL")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("DELIVERA_ACCESS_TOKEN_MINUTES", "1440"))

JWT_ALGORITHM = "HS256"
