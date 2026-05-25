from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.config import ACCESS_TOKEN_EXPIRE_MINUTES
from app.core.security import create_access_token, hash_password, verify_password
from app.dependencies.auth import get_current_user
from app.dependencies.db import get_db
from app.models import User

router = APIRouter(prefix="/auth", tags=["Auth"])


class LoginRequest(BaseModel):
    name: str
    password: str


def _role_value(user: User) -> str | None:
    r = user.role
    if r is None:
        return None
    return getattr(r, "value", str(r))


@router.post("/login")
def login(body: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.name == body.name).first()
    if not user or not verify_password(body.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales inválidas",
        )

    if user.password and not user.password.startswith("$2"):
        user.password = hash_password(body.password)
        db.add(user)
        db.commit()
        db.refresh(user)

    token = create_access_token(
        {
            "sub": str(user.id),
            "name": user.name,
            "role": _role_value(user),
        },
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": str(user.id),
            "name": user.name,
            "role": _role_value(user),
        },
    }


@router.get("/me")
def me(user: User = Depends(get_current_user)):
    return {
        "id": str(user.id),
        "name": user.name,
        "role": _role_value(user),
    }
