from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field

from config.database import db
from utils.security import get_current_user, require_admin_or_manager

router = APIRouter(
    prefix="/api/tasks",
    tags=["Tasks"],
)

tasks_collection = db["tasks"]
employee_collection = db["employees"]

DEFAULT_SEED_TASKS = [
    {
        "task_id": "TASK-01",
        "title": "Complete monthly sales report",
        "deadline": "Today, 4:00 PM",
        "priority": "High",
        "completed": False,
        "status": "Pending",
    },
    {
        "task_id": "TASK-02",
        "title": "Update customer information",
        "deadline": "Tomorrow",
        "priority": "Medium",
        "completed": False,
        "status": "Pending",
    },
    {
        "task_id": "TASK-03",
        "title": "Attend team meeting",
        "deadline": "Friday, 3:00 PM",
        "priority": "Medium",
        "completed": False,
        "status": "Pending",
    },
    {
        "task_id": "TASK-04",
        "title": "Review assigned documents",
        "deadline": "30 July 2026",
        "priority": "Low",
        "completed": False,
        "status": "Pending",
    },
]


class TaskCreate(BaseModel):
    employee_id: str
    title: str = Field(min_length=2, max_length=200)
    deadline: str = Field(default="Tomorrow")
    priority: str = Field(default="Medium")  # High, Medium, Low


def _resolve_employee_id(current_user: dict) -> str:
    emp_id = current_user.get("employee_id")
    if emp_id and str(emp_id).strip():
        return str(emp_id).strip()

    email = str(current_user.get("email", "")).strip().lower()
    if email:
        emp = employee_collection.find_one({"email": email})
        if emp and emp.get("employee_id"):
            return str(emp["employee_id"]).strip()

    user_id_str = str(current_user.get("_id", "001"))
    suffix = user_id_str[-4:].upper() if len(user_id_str) >= 4 else "001"
    return f"EMP{suffix}"


@router.get("/me")
def get_my_tasks(current_user: dict = Depends(get_current_user)):
    """Fetch assigned tasks for the authenticated employee."""
    emp_id = _resolve_employee_id(current_user)
    email = str(current_user.get("email", "")).strip().lower()

    tasks = list(
        tasks_collection.find(
            {"$or": [{"employee_id": emp_id}, {"email": email}]},
            {"_id": 0}
        )
    )

    if not tasks:
        # Seed default tasks for this employee
        for t in DEFAULT_SEED_TASKS:
            task_doc = dict(t)
            task_doc["employee_id"] = emp_id
            task_doc["email"] = email
            task_doc["created_at"] = datetime.now(timezone.utc).isoformat()
            tasks_collection.insert_one(task_doc)

        tasks = list(
            tasks_collection.find(
                {"$or": [{"employee_id": emp_id}, {"email": email}]},
                {"_id": 0}
            )
        )

    completed_count = sum(1 for t in tasks if t.get("completed"))
    total_count = len(tasks)

    return {
        "status": "success",
        "employee_id": emp_id,
        "total_tasks": total_count,
        "completed_tasks": completed_count,
        "progress_percentage": round((completed_count / total_count) * 100) if total_count > 0 else 0,
        "tasks": tasks,
    }


@router.patch("/{task_id}/toggle")
def toggle_task_completion(
    task_id: str,
    current_user: dict = Depends(get_current_user),
):
    """Toggle completion status for a specific task and update performance."""
    emp_id = _resolve_employee_id(current_user)
    email = str(current_user.get("email", "")).strip().lower()

    # Find task
    task = tasks_collection.find_one(
        {"task_id": task_id, "$or": [{"employee_id": emp_id}, {"email": email}]}
    )

    if not task:
        task = tasks_collection.find_one({"task_id": task_id})

    if not task:
        # If not in collection, search matching default and insert toggled
        matching_seed = next((t for t in DEFAULT_SEED_TASKS if t["task_id"] == task_id), None)
        if matching_seed:
            task_doc = dict(matching_seed)
            task_doc["employee_id"] = emp_id
            task_doc["email"] = email
            task_doc["completed"] = True
            task_doc["status"] = "Completed"
            task_doc["updated_at"] = datetime.now(timezone.utc).isoformat()
            tasks_collection.insert_one(task_doc)
            return {
                "status": "success",
                "task_id": task_id,
                "completed": True,
                "task_status": "Completed",
            }
        raise HTTPException(status_code=404, detail="Task not found")

    new_completed = not task.get("completed", False)
    new_status = "Completed" if new_completed else "Pending"

    tasks_collection.update_one(
        {"_id": task["_id"]},
        {
            "$set": {
                "completed": new_completed,
                "status": new_status,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            }
        },
    )

    # Recalculate employee performance percentage based on completed tasks
    user_tasks = list(
        tasks_collection.find(
            {"$or": [{"employee_id": emp_id}, {"email": email}]}
        )
    )
    if user_tasks:
        done = sum(1 for t in user_tasks if t.get("completed"))
        total = len(user_tasks)
        perf_score = min(100, max(50, round((done / total) * 40 + 60)))
        employee_collection.update_one(
            {"$or": [{"employee_id": emp_id}, {"email": email}]},
            {"$set": {"performance": perf_score}}
        )

    return {
        "status": "success",
        "task_id": task_id,
        "completed": new_completed,
        "task_status": new_status,
        "message": f"Task marked as {new_status.lower()}",
    }


@router.get("")
def get_all_tasks_for_manager(
    employee_id: Optional[str] = Query(None),
    current_user: dict = Depends(require_admin_or_manager),
):
    """Manager view: Get all assigned tasks and completion status across employees."""
    query = {}
    if employee_id:
        query["$or"] = [{"employee_id": employee_id}, {"email": employee_id}]

    tasks = list(tasks_collection.find(query, {"_id": 0}))

    # Aggregate completion per employee
    emp_summary = {}
    for t in tasks:
        eid = t.get("employee_id", "Unknown")
        if eid not in emp_summary:
            emp_summary[eid] = {"total": 0, "completed": 0}
        emp_summary[eid]["total"] += 1
        if t.get("completed"):
            emp_summary[eid]["completed"] += 1

    return {
        "status": "success",
        "total_tasks": len(tasks),
        "employee_summary": emp_summary,
        "tasks": tasks,
    }


@router.post("", status_code=status.HTTP_201_CREATED)
def assign_task_to_employee(
    task: TaskCreate,
    current_user: dict = Depends(require_admin_or_manager),
):
    """Manager assigns a new task to an employee."""
    task_id = f"TASK-{int(datetime.now().timestamp()) % 100000:05d}"
    doc = {
        "task_id": task_id,
        "employee_id": task.employee_id,
        "title": task.title,
        "deadline": task.deadline,
        "priority": task.priority,
        "completed": False,
        "status": "Pending",
        "assigned_by": current_user.get("email", "Manager"),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    tasks_collection.insert_one(doc)
    doc.pop("_id", None)
    return {
        "status": "success",
        "message": "Task assigned successfully to employee",
        "task": doc,
    }
