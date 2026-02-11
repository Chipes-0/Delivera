from fastapi import APIRouter

router = APIRouter(prefix="/expenses", tags=["Expenses"])

@router.get("/")
def get_expenses():
    return {"message": "List of expenses"}

@router.post("/")
def create_expense(expense: dict):
    return {"message": "Expense created", "expense": expense}

@router.get("/{expense_id}")
def get_expense(expense_id: int):
    return {"message": f"Details of expense {expense_id}"} 

@router.put("/{expense_id}")
def update_expense(expense_id: int, expense: dict):
    return {"message": f"Expense {expense_id} updated", "expense": expense}

@router.delete("/{expense_id}")
def delete_expense(expense_id: int):
    return {"message": f"Expense {expense_id} deleted"}