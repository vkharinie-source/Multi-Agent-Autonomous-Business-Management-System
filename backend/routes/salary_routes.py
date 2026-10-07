from __future__ import annotations

import calendar
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status

from config.database import db
from services.salary_service import calculate_salary
from utils.security import get_current_user, require_admin_or_manager

router = APIRouter(
    prefix="/api/salary",
    tags=["Salary"],
)

employee_collection = db["employees"]


def _parse_year_month(month_str: Optional[str]) -> tuple[int, int]:
    """Parse 'YYYY-MM' or return current year and month."""
    if not month_str:
        now = datetime.now()
        return now.year, now.month

    try:
        parts = month_str.strip().split("-")
        if len(parts) == 2:
            year = int(parts[0])
            month = int(parts[1])
            if 1 <= month <= 12 and 2000 <= year <= 2100:
                return year, month
    except Exception:
        pass

    now = datetime.now()
    return now.year, now.month


def _resolve_employee_id(current_user: dict) -> str:
    """Resolve employee_id from authenticated JWT user."""
    emp_id = current_user.get("employee_id")
    if emp_id and str(emp_id).strip():
        return str(emp_id).strip()

    email = str(current_user.get("email", "")).strip().lower()
    if email:
        emp = employee_collection.find_one({"email": email})
        if emp and emp.get("employee_id"):
            return str(emp["employee_id"]).strip()

    # If user ID fallback
    user_id_str = str(current_user.get("_id", "001"))
    suffix = user_id_str[-4:].upper() if len(user_id_str) >= 4 else "001"
    return f"EMP{suffix}"


@router.get("/me")
def get_my_salary(
    month: Optional[str] = Query(
        None,
        description="Month in YYYY-MM format (e.g. 2026-07)",
        examples=["2026-07"],
    ),
    current_user: dict = Depends(get_current_user),
):
    """
    Get calculated salary breakdown for the authenticated employee.
    Calculates dynamic net salary from base salary, attendance, and leave records.
    """
    year, month_num = _parse_year_month(month)
    employee_id = _resolve_employee_id(current_user)

    try:
        salary_data = calculate_salary(
            employee_id=employee_id,
            year=year,
            month=month_num,
        )
        return {
            "status": "success",
            "salary": salary_data,
        }
    except ValueError as e:
        # Check if employee exists in employees collection, if not create default
        email = str(current_user.get("email", "")).strip().lower()
        name = current_user.get("name") or current_user.get("full_name") or "Employee"
        emp = {
            "employee_id": employee_id,
            "name": name,
            "email": email,
            "department": current_user.get("department") or "Engineering",
            "designation": current_user.get("designation") or "Developer",
            "salary": 35000,
            "role": "employee",
            "status": "Active",
            "is_active": True,
        }
        employee_collection.update_one(
            {"employee_id": employee_id},
            {"$setOnInsert": emp},
            upsert=True,
        )

        salary_data = calculate_salary(
            employee_id=employee_id,
            year=year,
            month=month_num,
        )
        return {
            "status": "success",
            "salary": salary_data,
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unable to calculate salary information.",
        ) from e


@router.get("/monthly")
def get_monthly_salaries(
    month: Optional[str] = Query(
        None,
        description="Month in YYYY-MM format (e.g. 2026-07)",
        examples=["2026-07"],
    ),
    current_user: dict = Depends(require_admin_or_manager),
):
    """
    Get monthly salary details for all employees for Manager/Admin view.
    Uses the exact same calculation engine as the employee endpoint.
    """
    year, month_num = _parse_year_month(month)
    employees = list(employee_collection.find().sort("name", 1))

    salaries = []
    for emp in employees:
        emp_id = emp.get("employee_id")
        if not emp_id:
            continue
        try:
            s = calculate_salary(
                employee_id=emp_id,
                year=year,
                month=month_num,
            )
            salaries.append(s)
        except Exception:
            continue

    total_payroll = round(sum(s.get("net_salary", 0) for s in salaries), 2)
    total_gross = round(sum(s.get("gross_salary", 0) for s in salaries), 2)
    total_deductions = round(sum(s.get("total_deductions", 0) for s in salaries), 2)

    return {
        "status": "success",
        "month": f"{year:04d}-{month_num:02d}",
        "month_name": calendar.month_name[month_num],
        "year": year,
        "count": len(salaries),
        "total_payroll": total_payroll,
        "total_gross": total_gross,
        "total_deductions": total_deductions,
        "salaries": salaries,
    }


@router.get("/employee/{employee_id}")
def get_employee_salary(
    employee_id: str,
    month: Optional[str] = Query(
        None,
        description="Month in YYYY-MM format (e.g. 2026-07)",
        examples=["2026-07"],
    ),
    current_user: dict = Depends(require_admin_or_manager),
):
    """Get calculated monthly salary for a specific employee (Manager/Admin only)."""
    year, month_num = _parse_year_month(month)

    try:
        salary_data = calculate_salary(
            employee_id=employee_id,
            year=year,
            month=month_num,
        )
        return {
            "status": "success",
            "salary": salary_data,
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Employee '{employee_id}' not found.",
        ) from e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unable to calculate salary information.",
        ) from e
