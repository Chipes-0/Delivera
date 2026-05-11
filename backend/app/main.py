from pathlib import Path

from dotenv import load_dotenv

_backend_dir = Path(__file__).resolve().parent.parent
load_dotenv(_backend_dir / ".env")

from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
# local imports
from app.dependencies.db import get_db
from app.core.database import Base, engine
import app.models

from api.router import api_router

app = FastAPI()
app.include_router(api_router, prefix="/v1")

@app.get("/test-db")
def test_db(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT 1")).fetchone()
    return {"db_connection": "ok", "result": result[0]}