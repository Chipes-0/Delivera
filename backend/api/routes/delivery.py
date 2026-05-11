from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
# local imports
from app.dependencies.auth import get_current_user
from app.dependencies.db import get_db
from app.models.delivery import Delivery, StatusEnum
from app.models.users import User, RoleEnum

router = APIRouter(prefix="/deliveries", tags=["Deliveries"])


def _apply_delivery_status(db: Session, delivery_id: UUID, new_status: str) -> Delivery:
    delivery_obj = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if not delivery_obj:
        raise HTTPException(status_code=404, detail=f"Delivery with ID {delivery_id} not found")
    if new_status not in StatusEnum._value2member_map_:
        raise HTTPException(status_code=400, detail=f"Invalid status value: {new_status}")
    delivery_obj.status = new_status
    db.commit()
    db.refresh(delivery_obj)
    return delivery_obj


@router.get("/", status_code=status.HTTP_200_OK)
def get_deliveries(
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    deliveries = db.query(Delivery).all()
    return {"message": "List of deliveries", "data": deliveries}

@router.get("/{delivery_id}", status_code=status.HTTP_200_OK)
def get_delivery(
    delivery_id: UUID,
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    delivery = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if not delivery:
        raise HTTPException(status_code=404, detail=f"Delivery with ID {delivery_id} not found")
    return {"message": f"Details of delivery {delivery_id}", "data": delivery}

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_delivery(
    delivery: dict,
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    new_delivery = Delivery(**delivery)
    db.add(new_delivery)
    db.commit()
    db.refresh(new_delivery)
    return {"message": "Delivery created", "data": new_delivery}

@router.put("/{delivery_id}", status_code=status.HTTP_200_OK)
def update_delivery(
    delivery_id: UUID,
    delivery: dict,
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    delivery_obj = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if not delivery_obj:
        raise HTTPException(status_code=404, detail=f"Delivery with ID {delivery_id} not found")
    for key, value in delivery.items():
        if key in ["id", "created_at", "status", "assigned_to"]:
            raise HTTPException(status_code=400, detail=f"{key} field cannot be updated via this endpoint")
        setattr(delivery_obj, key, value)
    db.commit()
    db.refresh(delivery_obj)
    return {"message": f"Delivery {delivery_id} updated", "data": delivery_obj}

@router.delete("/{delivery_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_delivery(
    delivery_id: UUID,
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    delivery_obj = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if not delivery_obj:
        raise HTTPException(status_code=404, detail=f"Delivery with ID {delivery_id} not found")
    db.delete(delivery_obj)
    db.commit()
    return {"message": f"Delivery {delivery_id} deleted"}

@router.put("/{delivery_id}/status", status_code=status.HTTP_200_OK)
def update_delivery_status(
    delivery_id: UUID,
    status: str,
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    delivery_obj = _apply_delivery_status(db, delivery_id, status)
    return {
        "message": f"Delivery {delivery_id} status updated to {status}",
        "data": delivery_obj,
    }

@router.get("/{delivery_id}/assign", status_code=status.HTTP_200_OK)
def assign_delivery(
    delivery_id: UUID,
    driver_id: UUID,
    db: Session = Depends(get_db),
    _current_user: User = Depends(get_current_user),
):
    delivery_obj = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if not delivery_obj:
        raise HTTPException(status_code=404, detail=f"Delivery with ID {delivery_id} not found")
    driver = db.query(User).filter(User.id == driver_id, User.role == RoleEnum.DRIVER.value).first()
    if not driver:
        raise HTTPException(status_code=404, detail=f"Driver with ID {driver_id} not found")
    delivery_obj.assigned_to = driver_id
    db.commit()
    _apply_delivery_status(db, delivery_id, StatusEnum.ASSIGNED.value)
    db.refresh(delivery_obj)
    return {"message": f"Delivery {delivery_id} assigned to driver {driver_id}", "data": delivery_obj}