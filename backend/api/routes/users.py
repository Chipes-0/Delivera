from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.dependencies.db import get_db
from app.models import User
from uuid import UUID

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/")
def get_users(db: Session = Depends(get_db)):
    
    users = db.query(User).all()

    data = [
        {
            "id": str(user.id),
            "name": user.name,
            "role": user.role,
            "created_at": user.created_at
        }
        for user in users
    ]

    return {
        "success": True,
        "data": data,
        "count": len(data)
    }


@router.post("/")
def create_user(user: dict, db: Session = Depends(get_db)):

    new_user = User(
        name=user.get("name"),
        password=user.get("password"),
        role=user.get("role")
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "success": True,
        "message": "User created successfully",
        "data": {
            "id": str(new_user.id),
            "name": new_user.name,
            "role": new_user.role
        }
    }

@router.get("/{user_id}")
def get_user(user_id: UUID, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        return {
            "success": False,
            "message": "User not found"
        }

    return {
        "success": True,
        "data": {
            "id": str(user.id),
            "name": user.name,
            "role": user.role,
            "created_at": user.created_at
        }
    }


@router.put("/{user_id}")
def update_user(user_id: UUID, user: dict, db: Session = Depends(get_db)):

    db_user = db.query(User).filter(User.id == user_id).first()

    if not db_user:
        return {
            "success": False,
            "message": "User not found"
        }

    db_user.name = user.get("name", db_user.name)
    db_user.role = user.get("role", db_user.role)

    db.commit()
    db.refresh(db_user)

    return {
        "success": True,
        "message": "User updated successfully",
        "data": {
            "id": str(db_user.id),
            "name": db_user.name,
            "role": db_user.role
        }
    }


@router.delete("/{user_id}")
def delete_user(user_id: UUID, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        return {
            "success": False,
            "message": "User not found"
        }

    db.delete(user)
    db.commit()

    return {
        "success": True,
        "message": f"User {user_id} deleted successfully"
    }