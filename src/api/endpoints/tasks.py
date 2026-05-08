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

@router.get("/", response_model=List[TaskListRead])
def list_tasks(project_id: Optional[int] = None, status_id: Optional[int] = None):
    try:
        return CRUDTask.get_detailed_list(project_id, status_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load tasks: {str(e)}")

@router.get("/{task_id}", response_model=TaskRead)
def get_task(task_id: int):
    task = CRUDTask.get_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail=f"Task {task_id} not found.")
    return task

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
def get_assignee_performance(project_id: int, min_tasks: Optional[int] = 0):
    """Báo cáo hiệu suất nhân viên theo project - gọi sp_report_assignee_performance"""
    result = CRUDTask.get_assignee_performance(project_id, min_tasks)
    if not result:
        raise HTTPException(status_code=404, detail="Không tìm thấy dữ liệu.")
    return result

@router.get("/reports/staff/{profile_id}")
def get_staff_report(profile_id: int):
    """Báo cáo tổng quan nhân viên - gọi sp_get_staff_dashboard"""
    data = CRUDTask.get_staff_dashboard(profile_id)
    if not data:
        raise HTTPException(status_code=404, detail="Không tìm thấy nhân viên.")
    return data