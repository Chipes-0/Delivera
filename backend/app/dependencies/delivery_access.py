from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.delivery import Delivery
from app.models.users import RoleEnum, User


def deliveries_query_for_user(db: Session, user: User):
    query = db.query(Delivery)
    if user.role is RoleEnum.DELIVER:
        query = query.filter(Delivery.assigned_to == user.id)
    return query


def get_delivery_for_user(db: Session, delivery_id: UUID, user: User) -> Delivery:
    delivery = db.query(Delivery).filter(Delivery.id == delivery_id).first()
    if not delivery:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Delivery with ID {delivery_id} not found",
        )
    if user.role is RoleEnum.DELIVER and delivery.assigned_to != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes acceso a este viaje.",
        )
    return delivery
