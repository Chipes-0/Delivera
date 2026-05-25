import hmac
from datetime import datetime, timedelta, timezone
from typing import Any

from jose import jwt
from passlib.context import CryptContext

from app.core.config import JWT_ALGORITHM, get_secret_key

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(plain: str) -> str:
    return pwd_context.hash(plain)


def verify_password(plain: str, stored: str | None) -> bool:
    if not stored:
        return False
    if stored.startswith("$2"):
        return pwd_context.verify(plain, stored)
    return hmac.compare_digest(plain, stored)


def create_access_token(data: dict[str, Any], expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta if expires_delta is not None else timedelta(minutes=30)
    )
    to_encode["exp"] = expire
    return jwt.encode(to_encode, get_secret_key(), algorithm=JWT_ALGORITHM)


def decode_access_token(token: str) -> dict[str, Any]:
    return jwt.decode(token, get_secret_key(), algorithms=[JWT_ALGORITHM])
