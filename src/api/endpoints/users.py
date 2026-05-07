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