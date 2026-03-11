import uuid
import enum
from sqlalchemy import Column, Enum, String, Time
from sqlalchemy.dialects.postgresql import UUID
#local imports
from app.core.database import Base


class RoleEnum(enum.Enum):
    ADMIN = "ADMIN"
    DELIVER = "DELIVER"
    RECEPTOR = "RECEPTOR"

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=True)
    password = Column(String, nullable=True)
    role = Column(Enum(RoleEnum, name="Role"), nullable=True)
    created_at = Column(Time(timezone=True), nullable=True)
