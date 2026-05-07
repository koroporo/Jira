from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from schemas.task import (
    TaskCreate,
    TaskUpdate,
    TaskRead,
    TaskListRead,
    AssigneePerformanceRead,
    MilestoneProgressRead,
)
from crud.crud_task import CRUDTask

router = APIRouter()

@router.post("/", response_model=TaskRead, status_code=status.HTTP_201_CREATED)
def create_task(task_in: TaskCreate):
    result = CRUDTask.create(task_in)
    if result["status"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
    return result["data"]

@router.put("/{task_id}", response_model=TaskRead)
def update_task(task_id: int, task_out: TaskUpdate):
    result = CRUDTask.update(task_id, task_out)
    if result["status"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
    return result["data"]

@router.delete("/{task_id}")
def delete_task(task_id: int, force: bool = False):
    force_val = 1 if force else 0
    result = CRUDTask.delete(task_id, force_val)
    if result["status"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
    return {"message": f"Task {task_id} deleted successfully"}

@router.get("/reports/milestones", response_model=List[MilestoneProgressRead])
def get_milestones_progress_report():
    """Báo cáo tiến độ Milestone - gọi sp_get_milestones_report"""
    return CRUDTask.get_milestones_report()

@router.get("/reports/performance", response_model=List[AssigneePerformanceRead])
def get_assignee_performance(project_id: int, min_tasks: Optional[int] = None):
    """Báo cáo hiệu suất nhân viên theo project - gọi sp_report_assignee_performance"""
    result = CRUDTask.get_assignee_performance(project_id, min_tasks)
    if not result:
        raise HTTPException(status_code=404, detail="Không tìm thấy dữ liệu.")
    return result

