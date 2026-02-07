from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from app.dependencies.db import get_db
from sqlalchemy import text

app = FastAPI()

@app.get("/test-db")
def test_db(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT 1")).fetchone()
    return {"db_connection": "ok", "result": result[0]}