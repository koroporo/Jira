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
    task_id: int = Field(..., alias="TaskID")
    title: str = Field(..., alias="Title")
    task_priority: int = Field(..., alias="TaskPriority")
    due_date: Optional[datetime] = Field(None, alias="DueDate")
    project_name: str = Field(..., alias="ProjectName")
    assignee_name: Optional[str] = Field(None, alias="AssigneeName")
    status_name: str = Field(..., alias="StatusName")

    class Config:
        from_attributes = True
        populate_by_name = True  # Allow both alias and field name

# sp_report_assignee_performance
class AssigneePerformanceRead(BaseModel):
    staff_name: str = Field(..., alias="StaffName")
    total_tasks_assigned: int = Field(..., alias="TotalTasksAssigned")
    completed_tasks: int = Field(..., alias="CompletedTasks")
    project_name: str = Field(..., alias="ProjectName")

    class Config:
        from_attributes = True
        populate_by_name = True

# sp_get_milestones_report
class MilestoneProgressRead(BaseModel):
    milestone_id: int = Field(..., alias="MilestoneID")
    milestone_name: Optional[str] = Field(None, alias="MilestoneName")
    progress: float = Field(..., alias="Progress")
    end_date: Optional[datetime] = Field(None, alias="EndDate")

    class Config:
        from_attributes = True
        populate_by_name = True