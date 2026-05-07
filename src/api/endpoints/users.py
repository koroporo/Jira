from fastapi import APIRouter, HTTPException, status
from schemas.user import (
    UserRegister,
    UserLogin,
    TokenResponse,
    UserProfileCreate,
    UserProfileUpdate,
    UserProfileResponse,
    StaffDashboardResponse,
)
from crud.crud_user import CRUDUser

router = APIRouter()


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(user_in: UserRegister):
    result = CRUDUser.create(user_in)
    if result["status"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
    return result["data"]


@router.post("/login", response_model=TokenResponse)
def login(user_in: UserLogin):
    result = CRUDUser.login(user_in)
    if result["status"] == "error":
        raise HTTPException(status_code=401, detail=result["message"])
    return result["data"]


@router.post("/{user_id}/profile", status_code=status.HTTP_201_CREATED)
def create_profile(user_id: int, profile_in: UserProfileCreate):
    result = CRUDUser.create_profile(user_id, profile_in)
    if result["status"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
    return result["data"]


@router.put("/{profile_id}/profile", response_model=UserProfileResponse)
def update_profile(profile_id: int, profile_out: UserProfileUpdate):
    result = CRUDUser.update_profile(profile_id, profile_out)
    if result["status"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
    return result["data"]


@router.get("/{profile_id}/profile", response_model=UserProfileResponse)
def get_profile(profile_id: int):
    result = CRUDUser.get_profile_by_id(profile_id)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Profile {profile_id} not exists."
        )
    return result


@router.get("/{profile_id}/dashboard", response_model=StaffDashboardResponse)
def get_staff_dashboard(profile_id: int):
    """Báo cáo tổng quan nhân viên (gọi Procedure lồng Function)"""
    result = CRUDUser.get_staff_dashboard(profile_id)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Profile {profile_id} not exists."
        )
    return result