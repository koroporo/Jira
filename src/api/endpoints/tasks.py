from fastapi import APIRouter, HTTPException, Depends, status
from typing import List
from schemas.task import TaskCreate, TaskUpdate, TaskRead
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

@router.get("/{task_id}", response_model=TaskRead)
def get_task(task_id: int):

    task = CRUDTask.get_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.get("/{task_id}", response_model=TaskRead)
def get_task(task_id: int):
    """
    Endpoint lấy chi tiết một task theo ID.
    Trả về TaskRead schema (đã map snake_case).
    """
    task = CRUDTask.get_by_id(task_id)

    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task {task_id} not exists."
        )
    return task

@router.get("/reports/staff/{profile_id}")
def get_staff_report(profile_id: int):
    """Báo cáo tổng quan nhân viên (gọi Procedure lồng Function)"""
    data = CRUDTask.get_staff_dashboard(profile_id)
    if not data:
        raise HTTPException(status_code=404, detail="Không tìm thấy nhân viên")
    return data

@router.get("/reports/milestones")
def get_milestones_progress_report():
    """Báo cáo tiến độ Milestone (gọi Procedure lồng Function)"""
    return CRUDTask.get_milestones_report()