from fastapi import APIRouter, HTTPException
from schemas.user import UserLogin, TokenResponse
from crud.crud_user import CRUDUser

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
def login(user_in: UserLogin):
    result = CRUDUser.login(user_in)
    if result["status"] == "error":
        raise HTTPException(status_code=401, detail=result["message"])
    return result["data"]

# Trong src/api/endpoints/users.py
@router.post("/login-id")
def login_by_id(profile_id: int):
    from crud.crud_task import CRUDTask # Re-use crud_task để gọi dashboard
    
    user_data = CRUDTask.get_staff_dashboard(profile_id)
    
    if not user_data:
        raise HTTPException(status_code=404, detail="ID người dùng không tồn tại!")
    
    return {
        "status": "success",
        "user": user_data 
    }