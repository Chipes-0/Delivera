from fastapi import APIRouter

router = APIRouter(prefix="/drivers", tags=["Drivers"])

@router.get("/")
def get_drivers():
    return {"message": "List of drivers"}

@router.post("/")
def create_driver(driver: dict):
    return {"message": "Driver created", "driver": driver}

@router.get("/{driver_id}")
def get_driver(driver_id: int):
    return {"message": f"Details of driver {driver_id}"}

@router.put("/{driver_id}")
def update_driver(driver_id: int, driver: dict):
    return {"message": f"Driver {driver_id} updated", "driver": driver}

@router.delete("/{driver_id}")
def delete_driver(driver_id: int):
    return {"message": f"Driver {driver_id} deleted"}