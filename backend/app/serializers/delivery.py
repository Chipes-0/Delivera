from datetime import datetime, timezone

from app.models.delivery import Delivery


def _datetime_to_iso(value: datetime | None) -> str | None:
    if value is None:
        return None
    if value.tzinfo is None:
        value = value.replace(tzinfo=timezone.utc)
    return value.isoformat()


def delivery_to_dict(delivery: Delivery) -> dict:
    assigned_to = delivery.assigned_to
    return {
        "id": str(delivery.id),
        "status": delivery.status,
        "created_at": _datetime_to_iso(delivery.created_at),
        "assigned_at": _datetime_to_iso(delivery.assigned_at),
        "delivered_at": _datetime_to_iso(delivery.delivered_at),
        "assigned_to": str(assigned_to) if assigned_to is not None else None,
        "receiver_name": delivery.receiver_name,
        "items_description": delivery.items_description,
        "quantity": delivery.quantity,
        "cargo_value": delivery.cargo_value,
        "unity": delivery.unity,
        "origin": delivery.origin,
        "destiny": delivery.destiny,
        "distance": delivery.distance,
    }
