from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/users")
def get_users():
    return {"message": "List of users"}

@router.post("/users")
def create_user(user: dict):
    return {"message": "User created", "user": user}

@router.get("/users/{user_id}")
def get_user(user_id: int):
    return {"message": f"Details of user {user_id}"}

@router.put("/users/{user_id}")
def update_user(user_id: int, user: dict):
    return {"message": f"User {user_id} updated", "user": user}

@router.delete("/users/{user_id}")
def delete_user(user_id: int):
    return {"message": f"User {user_id} deleted"}