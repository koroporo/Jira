"""
src/api/api_router.py
---------------------
Central router that assembles all endpoint modules under their
respective URL prefixes.  main.py includes this single router.
"""
from fastapi import APIRouter
from src.api.endpoints import tasks, users

api_router = APIRouter()
api_router.include_router(tasks.router)
api_router.include_router(users.router)