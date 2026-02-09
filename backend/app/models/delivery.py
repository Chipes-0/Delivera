import enum
from sqlalchemy import Column, String, Text, Numeric, ForeignKey, Enum, text, Time
from sqlalchemy.dialects.postgresql import UUID
# local imports
from app.core.database import Base

class StatusEnum(enum.Enum):
    pending = "PENDING"
    assigned = "ASSIGNED"
    delivered = "DELIVERED"
    in_transit = "IN_TRANSIT"


class Delivery(Base):
    __tablename__ = "deliveries"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    status = Column(Enum(StatusEnum, name="Status"), nullable=True)
    created_at = Column(Time(timezone=True), nullable=False, server_default=text("now()"))
    assigned_at = Column(Time(timezone=True), nullable=True)
    delivered_at = Column(Time(timezone=True), nullable=True)
    assigned_to = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    receiver_name = Column(String, nullable=True)
    items_description = Column(Text, nullable=True)
    quantity = Column(Numeric, nullable=True)
    unity = Column(String, nullable=True)
    cargo_value = Column(Numeric, nullable=True)
    origin = Column(String, nullable=True)
    destiny = Column(String, nullable=True)
    distance = Column(Numeric, nullable=True)
