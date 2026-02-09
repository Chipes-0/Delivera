from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
# local imports
from app.dependencies.db import get_db
from app.models.user import User
from app.models.delivery import Delivery

router = APIRouter(prefix="/drivers", tags=["Drivers"])

@router.get("/")
def get_drivers(db: Session = Depends(get_db)):
    drivers = db.query(User).filter(User.role == "DRIVER").all()
    return {"message": "List of drivers", "data": drivers}

@router.get("/{driver_id}")
def get_driver(driver_id: int, db: Session = Depends(get_db)):
    driver = db.query(User).filter(User.id == driver_id).first()
    if not driver:
        return {"message": f"Driver with ID {driver_id} not found", "data": None}
    return {"message": f"Details of driver {driver_id}", "data": driver}

@router.get("/{driver_id}/deliveries")
def get_driver_deliveries(driver_id: int, db: Session = Depends(get_db)):
    driver = db.query(User).filter(User.id == driver_id).first()
    if not driver:
        return {"message": f"Driver with ID {driver_id} not found", "data": None}
    deliveries = db.query(Delivery).filter(Delivery.assigned_to == driver_id).all()
    return {"message": f"Deliveries assigned to driver {driver_id}", "data": deliveries}