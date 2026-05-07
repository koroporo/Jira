from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class TaskBase(BaseModel):
    title: str = Field(..., description="Title of the task", max_length=50)
    task_description: Optional[str] = Field(None, description="Description of the task", max_length=500)
    task_priority: int = Field(0, description="Priority of the task")
    due_date: Optional[datetime] = None

class TaskCreate(TaskBase):
    project_id: int
    reporter_id: int
    parent_task_id: Optional[int] = None
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
    update_time: Optional[datetime] = None

    class Config:
        from_attributes = True

# sp_get_task_list_detailed
class TaskListRead(BaseModel):
    task_id: int
    title: str
    task_priority: int
    due_date: Optional[datetime]
    project_name: str
    assignee_name: Optional[str]
    status_name: str

    class Config:
        from_attributes = True

# sp_report_assignee_performance
class AssigneePerformanceRead(BaseModel):
    staff_name: str
    total_tasks_assigned: int
    completed_tasks: int
    project_name: str

    class Config:
        from_attributes = True

# sp_get_milestones_report
class MilestoneProgressRead(BaseModel):
    milestone_id: int
    milestone_name: Optional[str]
    progress: float
    end_date: Optional[datetime]

    class Config:
        from_attributes = True