from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field

from config.database import db
from utils.security import get_current_user, require_admin_or_manager

router = APIRouter(
    prefix="/api/leaves",
    tags=["Leaves"],
)

leave_collection = db["leaves"]
employee_collection = db["employees"]

DEFAULT_SEED_LEAVES = [
    {
        "leave_id": "LV-2026-001",
        "employee_id": "EMP0078",
        "employee_name": "harinievk",
        "email": "harinievk24cs@srishakthi.ac.in",
        "leave_type": "Casual Leave",
        "start_date": "2026-10-15",
        "end_date": "2026-10-16",
        "days_count": 2,
        "reason": "Family function",
        "status": "Pending",
        "created_at": "2026-10-06T10:30:00+00:00",
    },
    {
        "leave_id": "LV-2026-002",
        "employee_id": "EMP_DEMO_01",
        "employee_name": "Arun Kumar",
        "email": "employee.demo@company.com",
        "leave_type": "Sick Leave",
        "start_date": "2026-10-02",
        "end_date": "2026-10-02",
        "days_count": 1,
        "reason": "Doctor appointment",
        "status": "Approved",
        "created_at": "2026-10-01T09:00:00+00:00",
    },
    {
        "leave_id": "LV-2026-003",
        "employee_id": "EMPF48A11",
        "employee_name": "Employee User",
        "email": "employee@gmail.com",
        "leave_type": "Personal Leave",
        "start_date": "2026-10-20",
        "end_date": "2026-10-21",
        "days_count": 2,
        "reason": "Personal work",
        "status": "Pending",
        "created_at": "2026-10-05T14:15:00+00:00",
    },
]


class LeaveApplyRequest(BaseModel):
    leave_type: str = Field(default="Casual Leave")
    start_date: str = Field(examples=["2026-10-15"])
    end_date: str = Field(examples=["2026-10-16"])
    days_count: int = Field(default=1, ge=1)
    reason: str = Field(min_length=2, max_length=500)


class LeaveStatusUpdateRequest(BaseModel):
    status: str = Field(examples=["Approved", "Rejected"])
    notes: Optional[str] = None


def _resolve_employee_info(current_user: dict) -> tuple[str, str, str]:
    emp_id = current_user.get("employee_id")
    email = str(current_user.get("email", "")).strip().lower()
    name = current_user.get("name") or current_user.get("full_name") or "Employee"

    if email:
        emp = employee_collection.find_one({"email": email})
        if emp:
            emp_id = emp.get("employee_id") or emp_id
            name = emp.get("name") or name

    if not emp_id or not str(emp_id).strip():
        user_id_str = str(current_user.get("_id", "001"))
        suffix = user_id_str[-4:].upper() if len(user_id_str) >= 4 else "001"
        emp_id = f"EMP{suffix}"

    return str(emp_id).strip(), name, email


@router.post("/apply", status_code=status.HTTP_201_CREATED)
def apply_leave(
    req: LeaveApplyRequest,
    current_user: dict = Depends(get_current_user),
):
    """Employee submits a new leave application (starts as Pending for Manager review)."""
    emp_id, emp_name, email = _resolve_employee_info(current_user)

    leave_id = f"LV-{datetime.now().strftime('%Y%m%d')}-{int(datetime.now().timestamp()) % 10000:04d}"

    doc = {
        "leave_id": leave_id,
        "employee_id": emp_id,
        "employee_name": emp_name,
        "email": email,
        "leave_type": req.leave_type,
        "start_date": req.start_date,
        "end_date": req.end_date,
        "days_count": req.days_count,
        "days": req.days_count,
        "reason": req.reason,
        "status": "Pending",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "reviewed_by": None,
        "reviewed_at": None,
    }

    leave_collection.insert_one(doc)
    doc.pop("_id", None)

    return {
        "status": "success",
        "message": f"{req.leave_type} request submitted successfully. Awaiting manager approval.",
        "leave": doc,
    }


@router.get("/me")
def get_my_leaves(current_user: dict = Depends(get_current_user)):
    """Employee view: Get all leave applications and approval statuses."""
    emp_id, _, email = _resolve_employee_info(current_user)

    leaves = list(
        leave_collection.find(
            {"$or": [{"employee_id": emp_id}, {"email": email}]},
            {"_id": 0}
        ).sort("created_at", -1)
    )

    if not leaves:
        # Seed initial sample for this employee if empty
        for s in DEFAULT_SEED_LEAVES:
            doc = dict(s)
            doc["employee_id"] = emp_id
            doc["email"] = email
            leave_collection.insert_one(doc)

        leaves = list(
            leave_collection.find(
                {"$or": [{"employee_id": emp_id}, {"email": email}]},
                {"_id": 0}
            ).sort("created_at", -1)
        )

    pending_count = sum(1 for l in leaves if l.get("status") == "Pending")
    approved_count = sum(1 for l in leaves if l.get("status") == "Approved")
    rejected_count = sum(1 for l in leaves if l.get("status") == "Rejected")

    return {
        "status": "success",
        "employee_id": emp_id,
        "total_leaves": len(leaves),
        "pending_leaves": pending_count,
        "approved_leaves": approved_count,
        "rejected_leaves": rejected_count,
        "leaves": leaves,
    }


@router.get("")
def get_all_leaves_for_manager(
    status_filter: Optional[str] = Query(None, description="Pending, Approved, Rejected"),
    current_user: dict = Depends(require_admin_or_manager),
):
    """Manager view: View all submitted leave requests across all employees."""
    query = {}
    if status_filter and status_filter.strip():
        query["status"] = {"$regex": f"^{status_filter.strip()}$", "$options": "i"}

    leaves = list(leave_collection.find(query, {"_id": 0}).sort("created_at", -1))

    if not leaves and not status_filter:
        for s in DEFAULT_SEED_LEAVES:
            leave_collection.insert_one(dict(s))
        leaves = list(leave_collection.find({}, {"_id": 0}).sort("created_at", -1))

    pending_count = sum(1 for l in leaves if l.get("status", "").capitalize() == "Pending")
    approved_count = sum(1 for l in leaves if l.get("status", "").capitalize() == "Approved")
    rejected_count = sum(1 for l in leaves if l.get("status", "").capitalize() == "Rejected")

    return {
        "status": "success",
        "total_requests": len(leaves),
        "pending_count": pending_count,
        "approved_count": approved_count,
        "rejected_count": rejected_count,
        "leaves": leaves,
    }


@router.patch("/{leave_id}/status")
def update_leave_status(
    leave_id: str,
    req: LeaveStatusUpdateRequest,
    current_user: dict = Depends(require_admin_or_manager),
):
    """Manager action: Approve or Reject an employee's leave application."""
    normalized_status = req.status.strip().capitalize()
    if normalized_status not in ["Approved", "Rejected"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Status must be either 'Approved' or 'Rejected'",
        )

    leave = leave_collection.find_one({"leave_id": leave_id})
    if not leave:
        raise HTTPException(status_code=404, detail="Leave request not found")

    manager_name = current_user.get("name") or current_user.get("email") or "Manager"

    update_payload = {
        "status": normalized_status,
        "reviewed_by": manager_name,
        "reviewed_at": datetime.now(timezone.utc).isoformat(),
        "manager_notes": req.notes,
    }

    leave_collection.update_one(
        {"leave_id": leave_id},
        {"$set": update_payload}
    )

    # If approved, increment employee leave taken count
    if normalized_status == "Approved":
        emp_id = leave.get("employee_id")
        days = int(leave.get("days_count", leave.get("days", 1)))
        employee_collection.update_one(
            {"$or": [{"employee_id": emp_id}, {"email": leave.get("email")}]},
            {"$inc": {"leave": days}}
        )

    updated_leave = leave_collection.find_one({"leave_id": leave_id}, {"_id": 0})

    return {
        "status": "success",
        "message": f"Leave request has been {normalized_status.lower()} by {manager_name}",
        "leave": updated_leave,
    }
