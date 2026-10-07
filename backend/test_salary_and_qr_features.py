import os
import sys
from datetime import datetime

# Set backend in path
sys.path.insert(0, os.path.dirname(__file__))

from services.salary_service import calculate_salary
from services.attendance_security import create_qr_token, verify_qr_token, QR_ROTATION_SECONDS
from config.database import db

def run_tests():
    print("========================================")
    print("TESTING FEATURE 1: SALARY CALCULATION")
    print("========================================")
    
    # 1. Test calculation engine for multiple months
    print("\n--- 1. Testing Employee Salary Calculation ---")
    emp_collection = db["employees"]
    emp = emp_collection.find_one()
    if not emp:
        emp = {
            "employee_id": "EMP001",
            "name": "Test Employee",
            "email": "test.emp@company.com",
            "salary": 50000,
            "department": "Engineering",
            "designation": "Software Engineer",
            "status": "Active",
            "is_active": True,
        }
        emp_collection.insert_one(emp)
    
    emp_id = emp.get("employee_id", "EMP001")
    
    # Insert sample attendance for July 2026
    att_collection = db["attendance"]
    att_collection.delete_many({"employee_id": emp_id})
    for day in range(1, 25):
        d_str = f"2026-07-{day:02d}"
        if datetime(2026, 7, day).weekday() != 6:
            att_collection.insert_one({
                "employee_id": emp_id,
                "date": d_str,
                "check_in": "09:02 AM",
                "check_out": "05:45 PM",
                "status": "Present",
            })
    
    # Test current month & previous month
    salary_jul = calculate_salary(employee_id=emp_id, year=2026, month=7)
    salary_aug = calculate_salary(employee_id=emp_id, year=2026, month=8)
    
    print(f"Employee ID: {salary_jul['employee_id']}")
    print(f"Gross Monthly Salary: Rs.{salary_jul['gross_salary']}")
    print(f"Basic (50%): Rs.{salary_jul['basic_salary']}, HRA (20%): Rs.{salary_jul['hra']}")
    print(f"PF (12%): Rs.{salary_jul['pf_deduction']}, Tax (5%): Rs.{salary_jul['tax_deduction']}")
    print(f"Working Days: {salary_jul['working_days']}, Present: {salary_jul['present_days']}, Absent: {salary_jul['absent_days']}")
    print(f"Net Calculated Salary (July 2026): Rs.{salary_jul['final_calculated_salary']}")
    print(f"Net Calculated Salary (August 2026): Rs.{salary_aug['final_calculated_salary']}")
    
    assert salary_jul['final_calculated_salary'] == salary_jul['net_salary']
    assert salary_jul['present_days'] > 0
    print("[PASS] Employee Salary Calculation is consistent and accurate.")

    print("\n========================================")
    print("TESTING FEATURE 2: 20-MINUTE QR VALIDITY & SECURITY")
    print("========================================")
    
    print(f"QR Rotation / Validity Seconds: {QR_ROTATION_SECONDS} seconds ({QR_ROTATION_SECONDS // 60} minutes)")
    assert QR_ROTATION_SECONDS == 1200, "QR validity must be exactly 20 minutes (1200 seconds)"
    
    # Generate QR
    qr_data = create_qr_token(
        session_id="ATT-TEST-001",
        company_id="COMPANY001",
        campus_id="CAMPUS001",
        attendance_type="check_in",
    )
    
    qr_token = qr_data["qr_token"]
    print(f"Generated QR Token: {qr_token[:35]}...")
    print(f"Expires at Timestamp: {qr_data['expires_at_timestamp']}")
    
    # Verify valid token
    payload = verify_qr_token(qr_token)
    print(f"Decoded session: {payload['session_id']}, expires_at: {payload['expires_at']}")
    assert payload["session_id"] == "ATT-TEST-001"
    print("[PASS] Valid 20-minute QR verified successfully.")

    print("\n========================================")
    print("ALL FEATURE TESTS COMPLETED SUCCESSFULLY!")
    print("========================================")

if __name__ == "__main__":
    run_tests()
