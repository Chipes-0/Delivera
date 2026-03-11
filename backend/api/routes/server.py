from fastapi import APIRouter
from datetime import datetime

router = APIRouter(prefix="/health", tags=["Server"])

@router.get("/")
def server_status():

    return {
        "success": True,
        "data": {
            "status": "ok",
            "service": "delivera-api",
            "timestamp": datetime.now(datetime.timezone.utc).isoformat()
        }
    }