from sqlalchemy import Column, String, DateTime, ForeignKey, Integer, Text, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base

class Evidence(Base):
    __tablename__ = "delivery_evidence"

    id = Column(Integer, primary_key=True, index=True)
    delivery_id = Column(
        UUID(as_uuid=True),
        ForeignKey("deliveries.id")
    )

    title = Column(String)
    photo = Column(Text)
    signature = Column(Text)
    mileage = Column(Float)
    created_at = Column(DateTime)

    delivery = relationship("Delivery", back_populates="evidence")