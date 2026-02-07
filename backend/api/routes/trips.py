from fastapi import APIRouter

router = APIRouter(prefix="/trips", tags=["Trips"])

@router.get("/")
def get_trips():
    return {"message": "List of trips"}

@router.post("/")
def create_trip(trip: dict):
    return {"message": "Trip created", "trip": trip}

@router.get("/{trip_id}")
def get_trip(trip_id: int):
    return {"message": f"Details of trip {trip_id}"}

@router.put("/{trip_id}")
def update_trip(trip_id: int, trip: dict):
    return {"message": f"Trip {trip_id} updated", "trip": trip}

@router.delete("/{trip_id}")
def delete_trip(trip_id: int):
    return {"message": f"Trip {trip_id} deleted"}