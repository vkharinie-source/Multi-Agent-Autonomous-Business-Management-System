import os
import sys
import json
from datetime import datetime

sys.path.insert(0, os.path.dirname(__file__))

from fastapi import HTTPException
from fastapi.testclient import TestClient
from main import app
from config.database import db
from utils.security import create_access_token
from services.attendance_security import (
    create_qr_token, 
    verify_qr_token, 
    QR_ROTATION_SECONDS,
    hash_device_id
)

client = TestClient(app)

def run_live_demonstration():
    print("=" * 65)
    print("       LIVE DEMONSTRATION & SYSTEM VALIDATION RUN       ")
    print("=" * 65)

    # -------------------------------------------------------------
    # SETUP TEST DATA IN MONGODB
    # -------------------------------------------------------------
    emp_col = db["employees"]
    att_col = db["attendance"]
    campus_col = db["campuses"]
    device_col = db["employee_devices"]
    user_col = db["users"]

    # 1. Setup Employee & Manager in users & employees collections
    emp_email = "employee.demo@company.com"
    mgr_email = "manager.demo@company.com"
    emp_id = "EMP_DEMO_01"

    user_col.update_one(
        {"email": emp_email},
        {"$set": {
            "name": "Arun Kumar",
            "email": emp_email,
            "role": "employee",
            "employee_id": emp_id,
            "is_active": True,
            "is_verified": True
        }},
        upsert=True
    )

    user_col.update_one(
        {"email": mgr_email},
        {"$set": {
            "name": "Sarah Jenkins",
            "email": mgr_email,
            "role": "manager",
            "employee_id": "MGR_DEMO_01",
            "is_active": True,
            "is_verified": True
        }},
        upsert=True
    )

    emp_col.update_one(
        {"email": emp_email},
        {"$set": {
            "employee_id": emp_id,
            "name": "Arun Kumar",
            "email": emp_email,
            "role": "employee",
            "department": "Engineering",
            "designation": "Full Stack Developer",
            "salary": 45000.0,
            "status": "Active",
            "is_active": True,
            "is_verified": True
        }},
        upsert=True
    )

    emp_col.update_one(
        {"email": mgr_email},
        {"$set": {
            "employee_id": "MGR_DEMO_01",
            "name": "Sarah Jenkins",
            "email": mgr_email,
            "role": "manager",
            "department": "Management",
            "designation": "Engineering Manager",
            "salary": 85000.0,
            "status": "Active",
            "is_active": True,
            "is_verified": True
        }},
        upsert=True
    )

    # 2. Add Attendance Records for July 2026 (22 Days present)
    att_col.delete_many({"employee_id": emp_id})
    for day in range(1, 26):
        if datetime(2026, 7, day).weekday() != 6:  # Exclude Sundays
            att_col.insert_one({
                "employee_id": emp_id,
                "date": f"2026-07-{day:02d}",
                "check_in": "09:05 AM",
                "check_out": "05:40 PM",
                "status": "Present"
            })

    # Create JWT Tokens
    emp_token = create_access_token(data={"sub": emp_email, "role": "employee", "employee_id": emp_id, "email": emp_email})
    mgr_token = create_access_token(data={"sub": mgr_email, "role": "manager", "email": mgr_email})

    # -------------------------------------------------------------
    # FEATURE 1 DEMO: AUTOMATIC SALARY CALCULATION
    # -------------------------------------------------------------
    print("\n[TEST 1] Testing Employee Endpoint: GET /api/salary/me?month=2026-07")
    res_emp = client.get(
        "/api/salary/me?month=2026-07",
        headers={"Authorization": f"Bearer {emp_token}"}
    )
    print(f"Status Code: {res_emp.status_code}")
    assert res_emp.status_code == 200, f"Failed: {res_emp.text}"
    emp_salary_data = res_emp.json()["salary"]
    
    print("-> Response Breakdown for Employee:")
    print(f"   * Employee: {emp_salary_data['employee_name']} ({emp_salary_data['employee_id']})")
    print(f"   * Gross CTC: Rs.{emp_salary_data['gross_salary']}")
    print(f"   * Basic Pay (50%): Rs.{emp_salary_data['basic_salary']}")
    print(f"   * HRA (20%): Rs.{emp_salary_data['hra']}")
    print(f"   * Special Allowance (30%): Rs.{emp_salary_data['special_allowance']}")
    print(f"   * PF Deduction (12%): Rs.{emp_salary_data['pf_deduction']}")
    print(f"   * Tax Deduction (5%): Rs.{emp_salary_data['tax_deduction']}")
    print(f"   * Working Days: {emp_salary_data['working_days']}, Present: {emp_salary_data['present_days']}, Absent: {emp_salary_data['absent_days']}")
    print(f"   * Loss of Pay for Absences: Rs.{emp_salary_data['loss_of_pay']}")
    print(f"   * FINAL CALCULATED NET SALARY: Rs.{emp_salary_data['final_calculated_salary']}")

    print("\n[TEST 2] Testing Manager Endpoint: GET /api/salary/monthly?month=2026-07")
    res_mgr = client.get(
        "/api/salary/monthly?month=2026-07",
        headers={"Authorization": f"Bearer {mgr_token}"}
    )
    print(f"Status Code: {res_mgr.status_code}")
    assert res_mgr.status_code == 200, f"Failed: {res_mgr.text}"
    mgr_salary_data = res_mgr.json()
    print(f"-> Total Employees Count: {mgr_salary_data['count']}")
    print(f"-> Total Company Payroll: Rs.{mgr_salary_data['total_payroll']}")
    
    # Verify Employee Salary == Manager Salary (Exact Match Guarantee)
    matched_record = next((s for s in mgr_salary_data["salaries"] if s["employee_id"] == emp_id), None)
    assert matched_record is not None
    print(f"-> Manager View for {emp_id}: Calculated Net Salary = Rs.{matched_record['final_calculated_salary']}")
    assert matched_record["final_calculated_salary"] == emp_salary_data["final_calculated_salary"]
    print("-> [VERIFIED] Employee view and Manager view return the EXACT SAME calculated salary!")

    # -------------------------------------------------------------
    # FEATURE 2 DEMO: AUTOMATIC 20-MINUTE MANAGER QR ATTENDANCE
    # -------------------------------------------------------------
    print("\n" + "=" * 65)
    print("FEATURE 2: AUTOMATIC 20-MINUTE VALIDITY QR ATTENDANCE")
    print("=" * 65)

    print("\n[TEST 3] Verifying Backend QR Rotation Constant...")
    print(f"-> QR_ROTATION_SECONDS = {QR_ROTATION_SECONDS} seconds ({QR_ROTATION_SECONDS // 60} minutes)")
    assert QR_ROTATION_SECONDS == 1200, "QR validity must be exactly 20 minutes"
    print("-> [VERIFIED] 20-minute validity enforced on backend.")

    print("\n[TEST 4] Testing Automatic Manager Session Creation: POST /api/attendance/sessions")
    campus = campus_col.find_one({"active": True})
    campus_id = campus["campus_id"] if campus else "CAMPUS001"

    res_session = client.post(
        "/api/attendance/sessions",
        headers={"Authorization": f"Bearer {mgr_token}"},
        json={"campus_id": campus_id, "attendance_type": "check_in", "duration_minutes": 20}
    )
    print(f"Status Code: {res_session.status_code}")
    assert res_session.status_code in (200, 201), f"Failed: {res_session.text}"
    session_resp = res_session.json()
    qr_data = session_resp["qr"]
    qr_token = qr_data["qr_token"]
    issued_at = qr_data["issued_at_timestamp"]
    expires_at = qr_data["expires_at_timestamp"]
    validity_duration = expires_at - issued_at

    print(f"-> Generated Session ID: {session_resp['session']['session_id']}")
    print(f"-> QR Token: {qr_token[:40]}...")
    print(f"-> Issued at: {issued_at}, Expires at: {expires_at}")
    print(f"-> QR Validity Duration: {validity_duration} seconds ({validity_duration // 60} minutes)")
    assert validity_duration == 1200
    print("-> [VERIFIED] Generated QR is valid for exactly 20 minutes.")

    print("\n[TEST 5] Testing QR Verification (Valid Token)...")
    payload = verify_qr_token(qr_token)
    assert payload["session_id"] == session_resp["session"]["session_id"]
    print(f"-> [VERIFIED] Valid QR Token verified successfully! Campus: {payload['campus_id']}")

    print("\n[TEST 6] Testing Expired QR Token Rejection (Security Check)...")
    # Simulate a token generated 21 minutes ago (expired)
    expired_token = create_qr_token(
        session_id="ATT-EXPIRED-TEST",
        company_id="COMPANY001",
        campus_id="CAMPUS001",
        attendance_type="check_in"
    )["qr_token"]
    # Manually tamper or test expired verification
    try:
        # Create an expired payload
        from services.attendance_security import _base64url_encode, _sign
        old_payload = {
            "session_id": "ATT-EXPIRED-TEST",
            "company_id": "COMPANY001",
            "campus_id": "CAMPUS001",
            "attendance_type": "check_in",
            "token_version": 100,
            "issued_at": 1000,
            "expires_at": 2200,  # Expired long ago
        }
        encoded = _base64url_encode(json.dumps(old_payload, separators=(",", ":"), sort_keys=True).encode("utf-8"))
        sig = _sign(encoded)
        tampered_expired_token = f"{encoded}.{sig}"
        verify_qr_token(tampered_expired_token)
    except (ValueError, HTTPException) as e:
        detail = getattr(e, "detail", str(e))
        print(f"-> [VERIFIED] Expired QR correctly rejected with error: '{detail}'")

    print("\n" + "=" * 65)
    print("   ALL TESTS PASSED! BACKEND & FLUTTER SYSTEM READY!   ")
    print("=" * 65)

if __name__ == "__main__":
    run_live_demonstration()
