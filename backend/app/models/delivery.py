from sqlalchemy import Column, String, DateTime, ForeignKey, Integer, Numeric, Float, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class Delivery(Base):
    __tablename__ = "deliveries"

    id = Column(UUID(as_uuid=True), primary_key=True)
    status = Column(String)
    created_at = Column(DateTime)
    assigned_at = Column(DateTime)
    delivered_at = Column(DateTime)

    assigned_to = Column(UUID(as_uuid=True), ForeignKey("users.id"))

    receiver_name = Column(String)
    items_description = Column(Text)
    quantity = Column(Float)
    cargo_value = Column(Float)
    unity = Column(String)
    origin = Column(String)
    destiny = Column(String)
    distance = Column(Float)

    evidence = relationship("Evidence", back_populates="delivery")