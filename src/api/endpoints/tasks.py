"""
src/api/endpoints/tasks.py
--------------------------
Routes for Task management (Create, Read, Update, Delete).
All state-changing operations call stored procedures via crud_task.
"""
from __future__ import annotations
import logging
from fastapi import APIRouter, HTTPException, Query, status
import src.crud.crud_task as crud
from src.schemas.task import (
    TaskCreate,
    TaskCreateResponse,
    TaskDeleteResponse,
    TaskListItem,
    TaskOut,
    TaskUpdate,
)

logger = logging.getLogger(__name__)
router = APIRouter()

# ══════════════════════════════════════════════════════════════════════════════
# Task CRUD
# ══════════════════════════════════════════════════════════════════════════════
@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    response_model=TaskCreateResponse,
    summary="Create a new task",
    tags=["Tasks"],
)
def create_task(payload: TaskCreate):
    """
    Create a new task by calling **sp_create_task**.
    - `task_type` can be `story`, `bug`, `epic`, or `subtask`.
    - Story tasks require `story_point`.
    - Bug tasks require `severity` (1 = low … 5 = critical).
    - Epic tasks require `goal`.
    - The hierarchy rule (Epic → Story/Bug → Subtask) is enforced by a DB trigger.
    """
    try:
        result = crud.create_task(payload)
        return result
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))

@router.get(
    "/",
    summary="List tasks with optional filters",
    tags=["Tasks"],
)
def list_tasks(
    project_id: int | None = Query(default=None, description="Filter by project"),
    assignee_id: int | None = Query(default=None, description="Filter by assignee profile ID"),
    status_id: int | None = Query(default=None, description="Filter by task status"),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
):
    """
    Retrieve a filtered, paginated task list via **sp_get_tasks**.
    All filter parameters are optional and passed as WHERE-clause inputs.
    """
    try:
        return crud.get_tasks(
            project_id=project_id,
            assignee_id=assignee_id,
            status_id=status_id,
            limit=limit,
            offset=offset,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

@router.get(
    "/{task_id}",
    response_model=TaskOut,
    summary="Get a task by ID",
    tags=["Tasks"],
)
def get_task(task_id: int):
    """Return the full detail of a single task."""
    record = crud.get_task_by_id(task_id)
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with ID {task_id} not found.",
        )
    return record

@router.put(
    "/{task_id}",
    summary="Update an existing task",
    tags=["Tasks"],
)
def update_task(task_id: int, payload: TaskUpdate):
    """
    Partial update via **sp_update_task** (JSON patch strategy).
    - Only supplied fields are updated.
    - Status changes are validated against the project's Transition table.
    - Pass `assignee_id: -1` to unassign the current assignee.
    - Pass `due_date: '1970-01-01T00:00:00'` to clear the due date.
    """
    try:
        return crud.update_task(task_id, payload)
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))

@router.delete(
    "/{task_id}",
    response_model=TaskDeleteResponse,
    summary="Delete a task",
    tags=["Tasks"],
)
def delete_task(
    task_id: int,
    force: bool = Query(
        default=False,
        description=(
            "false (default): blocked if active child tasks or linked notifications exist. "
            "true: force-remove the task and all cascading records."
        ),
    ),
):
    """
    Delete a task via **sp_delete_task**.
    **When deletion is allowed:**
    - The task exists.
    - No active (non-finished) child tasks are attached (unless force=true).
    **When deletion is blocked:**
    - Active child tasks still exist (force=false).
    - Notifications linked to the task's comments still exist (force=false).
    **Why:** Silently deleting a parent while children are in-progress would
    destroy audit history and hide unfinished work from reports.
    """
    try:
        result = crud.delete_task(task_id, force=force)
        return result
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))

# ══════════════════════════════════════════════════════════════════════════════
# Milestone analytics (calls DB function)
# ══════════════════════════════════════════════════════════════════════════════
@router.get(
    "/milestones/{milestone_id}/progress",
    summary="Get milestone completion percentage",
    tags=["Tasks"],
)
def milestone_progress(milestone_id: int):
    """
    Calls the DB function **calculate_milestone_progress(milestoneID)**.

    Returns the percentage of tasks in the milestone that are in a finished status.
    Returns -1 if the milestone does not exist.
    """
    try:
        return crud.get_milestone_progress(milestone_id)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))