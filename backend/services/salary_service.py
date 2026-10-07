"""
Salary Calculation Service
--------------------------
Computes monthly salary breakdown for an employee based on:
  - Base salary from the employees collection
  - Attendance records from the attendance collection
  - Approved leave records from leaves collections
  - Working days in the requested month (Mon-Sat, excluding Sun)

Calculation logic:
  gross_salary   = employee["salary"]  (monthly CTC stored in employees, default 35000)
  basic_salary   = gross_salary * 0.50
  hra            = gross_salary * 0.20
  special_allow  = gross_salary * 0.13
  pf_deduction   = gross_salary * 0.12
  tax_deduction  = gross_salary * 0.05

  per_day_salary = gross_salary / total_working_days
  loss_of_pay    = unexcused_absent_days * per_day_salary

  net_salary     = gross_salary - pf_deduction - tax_deduction - loss_of_pay
"""

from __future__ import annotations

import calendar
from datetime import date

from config.database import db

attendance_collection = db["attendance"]
employee_collection = db["employees"]
leave_collection = db["leaves"]


def _working_days_in_month(
    year: int,
    month: int,
) -> int:
    """Count Mon-Sat working days in a given month."""
    total = 0
    num_days = calendar.monthrange(year, month)[1]
    for day in range(1, num_days + 1):
        # 6 = Sunday in calendar.weekday (Mon=0 … Sun=6)
        if date(year, month, day).weekday() != 6:
            total += 1
    return max(total, 1)


def calculate_salary(
    *,
    employee_id: str,
    year: int,
    month: int,
) -> dict:
    """
    Return a complete salary breakdown dict for the given
    employee_id and year/month.

    Raises ValueError if the employee is not found.
    """

    employee = employee_collection.find_one(
        {"employee_id": employee_id}
    )

    if employee is None:
        raise ValueError(
            f"Employee {employee_id} not found."
        )

    raw_salary = employee.get("salary")
    try:
        gross_salary = float(raw_salary) if raw_salary is not None and float(raw_salary) > 0 else 35000.0
    except (ValueError, TypeError):
        gross_salary = 35000.0

    # --- Earnings breakdown ---
    basic_salary = round(gross_salary * 0.50, 2)
    hra = round(gross_salary * 0.20, 2)
    special_allowance = round(gross_salary * 0.30, 2)
    total_earnings = gross_salary

    # --- Statutory deductions ---
    pf_deduction = round(gross_salary * 0.12, 2)
    tax_deduction = round(gross_salary * 0.05, 2)

    # --- Attendance-based loss-of-pay ---
    total_working_days = _working_days_in_month(year, month)

    month_start = f"{year:04d}-{month:02d}-01"
    last_day = calendar.monthrange(year, month)[1]
    month_end = f"{year:04d}-{month:02d}-{last_day:02d}"

    present_records = list(
        attendance_collection.find(
            {
                "employee_id": employee_id,
                "date": {
                    "$gte": month_start,
                    "$lte": month_end,
                },
            }
        )
    )

    days_present = len(present_records)
    late_days = sum(
        1
        for r in present_records
        if r.get("late") is True or str(r.get("status", "")).lower() == "late"
    )

    # Check for approved leaves in this month
    approved_leave_days = 0
    try:
        leaves = list(
            leave_collection.find(
                {
                    "employee_id": employee_id,
                    "status": {"$in": ["approved", "Approved"]},
                }
            )
        )
        for lv in leaves:
            # Count days falling in this month
            lv_start = lv.get("start_date", "")
            lv_end = lv.get("end_date", "")
            if lv_start and lv_start <= month_end and lv_end >= month_start:
                approved_leave_days += int(lv.get("days_count", lv.get("days", 1)))
    except Exception:
        pass

    # Attendance calculation
    today = date.today()
    is_current_month = (year == today.year and month == today.month)
    is_future_month = (date(year, month, 1) > today)

    if is_current_month:
        # Mon-Sat working days up to today
        working_days_evaluated = 0
        for day in range(1, today.day + 1):
            if date(year, month, day).weekday() != 6:
                working_days_evaluated += 1
        raw_absent = max(working_days_evaluated - days_present, 0)
    elif is_future_month:
        working_days_evaluated = 0
        raw_absent = 0
    else:
        working_days_evaluated = total_working_days
        raw_absent = max(total_working_days - days_present, 0)

    # Absent days excluding approved paid leaves
    unexcused_absent = max(raw_absent - approved_leave_days, 0)

    per_day_salary = (
        round(gross_salary / total_working_days, 2)
        if total_working_days > 0
        else 0
    )

    loss_of_pay = round(unexcused_absent * per_day_salary, 2)

    total_deductions = round(
        pf_deduction + tax_deduction + loss_of_pay,
        2,
    )

    net_salary = max(
        0.0,
        round(total_earnings - total_deductions, 2)
    )

    return {
        "employee_id": employee_id,
        "employee_name": employee.get("name", ""),
        "department": employee.get("department", "General"),
        "designation": employee.get("designation", "Employee"),
        "year": year,
        "month": month,
        "salary_month": f"{year:04d}-{month:02d}",
        "month_name": calendar.month_name[month],
        # Earnings
        "gross_salary": gross_salary,
        "monthly_salary": gross_salary,
        "basic_salary": basic_salary,
        "hra": hra,
        "special_allowance": special_allowance,
        "total_earnings": total_earnings,
        # Deductions
        "pf_deduction": pf_deduction,
        "tax_deduction": tax_deduction,
        "loss_of_pay": loss_of_pay,
        "total_deductions": total_deductions,
        # Attendance & Leave summary
        "working_days": total_working_days,
        "total_working_days": total_working_days,
        "present_days": days_present,
        "days_present": days_present,
        "absent_days": raw_absent,
        "days_absent": raw_absent,
        "approved_leave_days": approved_leave_days,
        "late_days": late_days,
        "per_day_salary": per_day_salary,
        # Final
        "final_calculated_salary": net_salary,
        "net_salary": net_salary,
    }
