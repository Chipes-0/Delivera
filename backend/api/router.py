from fastapi import APIRouter
# local imports
from .routes.health import router as health_router
from .routes.drivers import router as drivers_router
from .routes.delivery import router as deliveries_router
from .routes.expenses import router as expenses_router
from .routes.users import router as users_router

api_router = APIRouter()

api_router.include_router(health_router)
api_router.include_router(drivers_router)
api_router.include_router(deliveries_router)
api_router.include_router(expenses_router)
api_router.include_router(users_router)