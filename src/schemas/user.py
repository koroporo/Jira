"""
src/schemas/user.py
-------------------
Pydantic models for UserAccount and UserProfile.
These schemas validate all user-related data coming from the API layer
before any stored procedure is called.
"""
from __future__ import annotations
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator

# ══════════════════════════════════════════════════════════════════════════════
# UserAccount schemas
# ══════════════════════════════════════════════════════════════════════════════
class UserAccountCreate(BaseModel):
    """Payload required to register a new user account."""
    email: EmailStr = Field(..., description="Must be a valid e-mail address.")
    password: str = Field(
        ...,
        min_length=8,
        description="Plain-text password (hashed automatically by DB trigger).",
    )
    username: str = Field(..., min_length=3, max_length=50)

    @field_validator("username")
    @classmethod
    def username_no_spaces(cls, v: str) -> str:
        if " " in v:
            raise ValueError("Username must not contain spaces.")
        return v.strip()

class UserLogin(BaseModel):
    email: EmailStr = Field(..., description="User email used for login.")
    password: str = Field(..., min_length=8, description="User password.")

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = Field(default="bearer")

class UserAccountOut(BaseModel):
    """Safe public representation of a user account (no password hash)."""
    user_id: int = Field(alias="UserID")
    email: EmailStr = Field(alias="Email")
    username: str = Field(alias="Username")

    model_config = {"populate_by_name": True}

# ══════════════════════════════════════════════════════════════════════════════
# UserProfile schemas
# ══════════════════════════════════════════════════════════════════════════════
VALID_STATUSES = {"Online", "Offline", "Idle", "Do Not Disturb"}

class UserProfileCreate(BaseModel):
    """Payload to create a profile linked to an existing UserAccount."""
    user_id: int = Field(..., gt=0, description="Must match an existing UserAccount.UserID.")
    first_name: str = Field(..., max_length=50)
    last_name: str = Field(..., max_length=50)
    email: EmailStr
    account_status: str = Field(default="Offline")
    timezone: str = Field(default="Asia/Ho_Chi_Minh", max_length=50)
    avatar_url: Optional[str] = Field(default=None, max_length=255)

    @field_validator("account_status")
    @classmethod
    def validate_status(cls, v: str) -> str:
        if v not in VALID_STATUSES:
            raise ValueError(
                f"account_status must be one of {sorted(VALID_STATUSES)}."
            )
        return v

class UserProfileUpdate(BaseModel):
    """All fields are optional; only supplied fields are updated."""
    first_name: Optional[str] = Field(default=None, max_length=50)
    last_name: Optional[str] = Field(default=None, max_length=50)
    account_status: Optional[str] = None
    timezone: Optional[str] = Field(default=None, max_length=50)
    avatar_url: Optional[str] = Field(default=None, max_length=255)

    @field_validator("account_status", mode="before")
    @classmethod
    def validate_status(cls, v):
        if v is not None and v not in VALID_STATUSES:
            raise ValueError(
                f"account_status must be one of {sorted(VALID_STATUSES)}."
            )
        return v

class UserProfileOut(BaseModel):
    """Full profile data returned to the client."""
    profile_id: int = Field(alias="ProfileID")
    first_name: str = Field(alias="FirstName")
    last_name: str = Field(alias="LastName")
    email: EmailStr = Field(alias="Email")
    account_status: str = Field(alias="AccountStatus")
    last_login_time: Optional[datetime] = Field(default=None, alias="LastLoginTime")
    creation_time: datetime = Field(alias="CreationTime")
    timezone: str = Field(alias="Timezone")
    avatar_url: Optional[str] = Field(default=None, alias="AvatarURL")
    user_id: int = Field(alias="UserID")

    model_config = {"populate_by_name": True}

# ══════════════════════════════════════════════════════════════════════════════
# PhoneNumber schemas
# ══════════════════════════════════════════════════════════════════════════════
# DB table: PhoneNumber(ProfileID, PhoneNumber)  — composite PK
# PhoneNumber is CHAR(10): exactly 10 digits, Vietnamese mobile format.

import re as _re
_PHONE_RE = _re.compile(r"^\d{10}$")

class PhoneNumberAdd(BaseModel):
    """Payload to add a phone number to a user profile."""
    phone_number: str = Field(
        ...,
        description="Exactly 10 digits, e.g. '0900124501'.",
    )

    @field_validator("phone_number")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        v = v.strip()
        if not _PHONE_RE.match(v):
            raise ValueError(
                "Phone number must be exactly 10 digits (e.g. '0900124501')."
            )
        return v

class PhoneNumberOut(BaseModel):
    """A single phone number record belonging to a profile."""
    profile_id: int = Field(alias="ProfileID")
    phone_number: str = Field(alias="PhoneNumber")

    model_config = {"populate_by_name": True}

class PhoneNumberDelete(BaseModel):
    """Payload to remove a specific phone number from a profile."""
    phone_number: str = Field(..., description="The exact 10-digit number to remove.")

    @field_validator("phone_number")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        v = v.strip()
        if not _PHONE_RE.match(v):
            raise ValueError(
                "Phone number must be exactly 10 digits (e.g. '0900124501')."
            )
        return v