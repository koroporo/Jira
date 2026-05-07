from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class TaskBase(BaseModel):
    title: str = Field(..., description="Title of the task", max_length=50)
    task_description: str = Field(..., description="Description of the task", max_length=500)
    task_priority: int = Field(0, description="Priority of the task")
    due_date: Optional[datetime] = None

class TaskCreate(TaskBase):
    project_id: int
    reporter_id: int
    parent_task_id: int
    status_id: Optional[int] = 1
    milestone_id: Optional[int] = None
    assignee_id: Optional[int] = None

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    task_description: Optional[str] = None
    task_priority: Optional[int] = None
    due_date: Optional[datetime] = None
    status_id: Optional[int] = None
    milestone_id: Optional[int] = None
    assignee_id: Optional[int] = None

class TaskRead(TaskBase):
    task_id: int
    creation_time: datetime
    update_time: Optional[datetime]

    class Config:
        from_attributes = True
