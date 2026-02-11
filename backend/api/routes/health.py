from fastapi import APIRouter

router = APIRouter()

@router.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok"}

@router.get("/ready", tags=["Health"])
def readiness_check():
    return {"status": "ready"}

@router.get("/version", tags=["Health"])
def version_check():
    return {"version": "1.0.0"}