from fastapi import APIRouter
from api.endpoints import tasks, users

router = APIRouter()
router.include_router(tasks.router, prefix="/tasks", tags=["Tasks"])
router.include_router(users.router, prefix="/users", tags=["Users"])
