"""
src/schemas/task.py
-------------------
Pydantic models for Task, Story, Bug, Epic, and related entities.
Validates all task-related API input before calling stored procedures.
"""
from __future__ import annotations
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, field_validator, model_validator

# ══════════════════════════════════════════════════════════════════════════════
# Enums / constants
# ══════════════════════════════════════════════════════════════════════════════
VALID_PRIORITIES = {0: "None", 1: "Low", 2: "Medium", 3: "High", 4: "Critical"}
VALID_TASK_TYPES = {"story", "bug", "epic", "subtask"}

# ══════════════════════════════════════════════════════════════════════════════
# Task schemas
# ══════════════════════════════════════════════════════════════════════════════
class TaskCreate(BaseModel):
    """
    Payload to create a new task.
    Maps directly to sp_create_task parameters.
    """
    title: str = Field(..., min_length=1, max_length=50, description="Task title, must not be blank.")
    description: Optional[str] = Field(default=None, max_length=500)
    priority: int = Field(default=0, ge=0, le=4, description="0=None,1=Low,2=Medium,3=High,4=Critical")
    due_date: Optional[datetime] = Field(default=None, description="Must be a future date.")
    parent_task_id: Optional[int] = Field(default=None, gt=0)
    status_id: Optional[int] = Field(default=None, gt=0)
    milestone_id: Optional[int] = Field(default=None, gt=0)
    reporter_id: int = Field(..., gt=0)
    assignee_id: Optional[int] = Field(default=None, gt=0)
    project_id: int = Field(..., gt=0)

    # Optional specialisation fields
    task_type: Optional[str] = Field(
        default=None,
        description="One of: story, bug, epic, subtask"
    )
    # Story-specific
    story_point: Optional[int] = Field(default=None, ge=0)
    # Bug-specific
    severity: Optional[int] = Field(default=None, ge=1, le=5)
    # Epic-specific
    goal: Optional[str] = Field(default=None, max_length=250)

    @field_validator("title")
    @classmethod
    def title_not_blank(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Task title must not be blank.")
        return v.strip()

    @field_validator("priority")
    @classmethod
    def priority_in_range(cls, v: int) -> int:
        if v not in VALID_PRIORITIES:
            raise ValueError(
                f"Priority must be one of {list(VALID_PRIORITIES.keys())} "
                f"({VALID_PRIORITIES})."
            )
        return v

    @field_validator("due_date")
    @classmethod
    def due_date_future(cls, v: Optional[datetime]) -> Optional[datetime]:
        if v is not None and v < datetime.now():
            raise ValueError("Due date must not be in the past.")
        return v

    @field_validator("task_type")
    @classmethod
    def task_type_valid(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v.lower() not in VALID_TASK_TYPES:
            raise ValueError(f"task_type must be one of {VALID_TASK_TYPES}.")
        return v.lower() if v else v

    @model_validator(mode="after")
    def check_type_fields(self) -> "TaskCreate":
        t = self.task_type
        if t == "story" and self.story_point is None:
            self.story_point = 0
        if t == "bug" and self.severity is None:
            raise ValueError("Bug tasks require a 'severity' field (1–5).")
        if t == "epic" and not self.goal:
            raise ValueError("Epic tasks require a 'goal' field.")
        return self

class TaskUpdate(BaseModel):
    """
    Partial update payload.
    Maps to sp_update_task (JSON argument).
    Only supplied fields are applied; omitted fields stay unchanged.
    Pass due_date as '1970-01-01T00:00:00' to explicitly clear it.
    """
    title: Optional[str] = Field(default=None, min_length=1, max_length=50)
    description: Optional[str] = Field(default=None, max_length=500)
    priority: Optional[int] = Field(default=None, ge=0, le=4)
    due_date: Optional[datetime] = None
    status_id: Optional[int] = Field(default=None, gt=0)
    milestone_id: Optional[int] = Field(default=None, gt=0)
    assignee_id: Optional[int] = Field(
        default=None,
        description="Pass -1 to remove the assignee."
    )

    @field_validator("title")
    @classmethod
    def title_not_blank(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and not v.strip():
            raise ValueError("Task title must not be blank.")
        return v.strip() if v else v

    @field_validator("priority")
    @classmethod
    def priority_in_range(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and v not in VALID_PRIORITIES:
            raise ValueError(f"Priority must be 0-4 ({VALID_PRIORITIES}).")
        return v

class TaskOut(BaseModel):
    """Full task record returned to the client."""
    task_id: int = Field(alias="TaskID")
    title: str = Field(alias="Title")
    description: Optional[str] = Field(default=None, alias="TaskDescription")
    priority: int = Field(alias="TaskPriority")
    due_date: Optional[datetime] = Field(default=None, alias="DueDate")
    creation_time: datetime = Field(alias="CreationTime")
    update_time: Optional[datetime] = Field(default=None, alias="UpdateTime")
    parent_task_id: Optional[int] = Field(default=None, alias="ParentTaskID")
    status_id: Optional[int] = Field(default=None, alias="StatusID")
    milestone_id: Optional[int] = Field(default=None, alias="MilestoneID")
    reporter_id: Optional[int] = Field(default=None, alias="ReporterID")
    assignee_id: Optional[int] = Field(default=None, alias="AssigneeID")
    project_id: int = Field(alias="ProjectID")

    model_config = {"populate_by_name": True}

# ══════════════════════════════════════════════════════════════════════════════
# Lightweight list item (used in GET /tasks/)
# ══════════════════════════════════════════════════════════════════════════════
class TaskListItem(BaseModel):
    task_id: int = Field(alias="TaskID")
    title: str = Field(alias="Title")
    priority: int = Field(alias="TaskPriority")
    status_id: Optional[int] = Field(default=None, alias="StatusID")
    assignee_id: Optional[int] = Field(default=None, alias="AssigneeID")
    due_date: Optional[datetime] = Field(default=None, alias="DueDate")
    project_id: int = Field(alias="ProjectID")

    model_config = {"populate_by_name": True}

# ══════════════════════════════════════════════════════════════════════════════
# API response wrappers
# ══════════════════════════════════════════════════════════════════════════════
class TaskCreateResponse(BaseModel):
    message: str
    task_id: Optional[int] = None

class TaskDeleteResponse(BaseModel):
    message: str