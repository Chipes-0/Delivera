from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from app.dependencies.db import get_db
from sqlalchemy import text

from ..api.router import api_router

app = FastAPI()
app.include_router(api_router, prefix="/v1")

@app.get("/test-db")
def test_db(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT 1")).fetchone()
    return {"db_connection": "ok", "result": result[0]}