"""
src/api/endpoints/users.py
--------------------------
Routes for user account and profile management.
All mutations delegate to crud_user which calls stored procedures.
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Query, status

import src.crud.crud_user as crud
from src.schemas.user import (
    UserAccountCreate,
    UserAccountOut,
    UserProfileCreate,
    UserProfileOut,
    UserProfileUpdate,
)

logger = logging.getLogger(__name__)
router = APIRouter()


# ══════════════════════════════════════════════════════════════════════════════
# UserAccount endpoints
# ══════════════════════════════════════════════════════════════════════════════

@router.post(
    "/accounts/",
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user account",
    tags=["Users"],
)
def create_account(payload: UserAccountCreate):
    """
    Create a new UserAccount.
    The DB trigger automatically hashes the password with SHA-256 + salt.
    """
    try:
        return crud.create_user_account(payload)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@router.get(
    "/accounts/",
    summary="List all user accounts",
    tags=["Users"],
)
def list_accounts(
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
):
    return crud.get_user_accounts(limit=limit, offset=offset)


@router.get(
    "/accounts/{user_id}",
    summary="Get a user account by ID",
    tags=["Users"],
)
def get_account(user_id: int):
    record = crud.get_user_account_by_id(user_id)
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"UserAccount with ID {user_id} not found.",
        )
    return record


# ══════════════════════════════════════════════════════════════════════════════
# UserProfile endpoints
# ══════════════════════════════════════════════════════════════════════════════

@router.post(
    "/profiles/",
    status_code=status.HTTP_201_CREATED,
    summary="Create a user profile",
    tags=["Users"],
)
def create_profile(payload: UserProfileCreate):
    """
    Create a UserProfile linked to an existing UserAccount.
    account_status must be one of: Online, Offline, Idle, Do Not Disturb.
    """
    try:
        return crud.create_user_profile(payload)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@router.get(
    "/profiles/",
    summary="List all user profiles",
    tags=["Users"],
)
def list_profiles(
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
):
    return crud.get_user_profiles(limit=limit, offset=offset)


@router.get(
    "/profiles/{profile_id}",
    summary="Get a user profile by ID",
    tags=["Users"],
)
def get_profile(profile_id: int):
    record = crud.get_user_profile_by_id(profile_id)
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"UserProfile with ID {profile_id} not found.",
        )
    return record


@router.put(
    "/profiles/{profile_id}",
    summary="Update a user profile",
    tags=["Users"],
)
def update_profile(profile_id: int, payload: UserProfileUpdate):
    """
    Partially update a user profile.
    Only fields provided in the request body are changed.
    """
    try:
        return crud.update_user_profile(profile_id, payload)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


# ══════════════════════════════════════════════════════════════════════════════
# Analytics endpoint (calls DB function)
# ══════════════════════════════════════════════════════════════════════════════

@router.get(
    "/profiles/{profile_id}/overdue-tasks",
    summary="Count overdue tasks assigned to a user",
    tags=["Users"],
)
def overdue_tasks(profile_id: int):
    """
    Calls the DB function num_of_overdue_task(profileID).
    Returns the number of active tasks past their due date for this user.
    """
    try:
        return crud.get_overdue_task_count(profile_id)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))