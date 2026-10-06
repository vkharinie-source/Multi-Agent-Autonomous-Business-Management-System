import sys
import os
import json
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from main import app
from config.database import db
from utils.security import create_access_token

client = TestClient(app)

def test_api():
    print("========================================")
    print("TESTING FASTAPI ATTENDANCE ENDPOINTS")
    print("========================================")

    # 1. Setup Test Users
    manager_email = "test.manager@example.com"
    employee_email = "test.employee.scan@example.com"
    employee_id = "EMPTEST01"

    db["users"].update_one(
        {"email": manager_email},
        {"$set": {"email": manager_email, "role": "Manager", "name": "Test Manager", "is_verified": True, "is_active": True, "status": "Active"}},
        upsert=True
    )
    db["users"].update_one(
        {"email": employee_email},
        {"$set": {"email": employee_email, "role": "Employee", "name": "Harini VK", "employee_id": employee_id, "is_verified": True, "is_active": True, "status": "Active"}},
        upsert=True
    )
    db["employees"].update_one(
        {"employee_id": employee_id},
        {"$set": {"employee_id": employee_id, "email": employee_email, "name": "Harini VK", "department": "IT", "designation": "AI Engineer", "is_active": True, "status": "Active"}},
        upsert=True
    )

    manager_token = create_access_token(data={"sub": manager_email, "role": "Manager"})
    employee_token = create_access_token(data={"sub": employee_email, "role": "Employee"})

    manager_headers = {"Authorization": f"Bearer {manager_token}"}
    employee_headers = {"Authorization": f"Bearer {employee_token}"}

    # 2. Get Campuses
    print("\n--- 1. Testing GET /api/attendance/campuses ---")
    res = client.get("/api/attendance/campuses", headers=manager_headers)
    print(f"Campuses response code: {res.status_code}")
    assert res.status_code == 200
    campuses = res.json()["campuses"]
    assert len(campuses) > 0
    campus_id = campuses[0]["campus_id"]
    print(f"[PASS] Retrieved campus: {campus_id} ({campuses[0]['name']})")

    # 3. Create Attendance Session
    print("\n--- 2. Testing POST /api/attendance/sessions (Manager QR Gen) ---")
    # Clean up any active session for this campus first
    db["attendance_sessions"].delete_many({"campus_id": campus_id, "active": True})

    session_payload = {
        "campus_id": campus_id,
        "attendance_type": "check_in",
        "duration_minutes": 15
    }
    res = client.post("/api/attendance/sessions", json=session_payload, headers=manager_headers)
    print(f"Create session status: {res.status_code}")
    assert res.status_code == 201
    session_data = res.json()
    session_id = session_data["session"]["session_id"]
    qr_token = session_data["qr"]["qr_token"]
    print(f"[PASS] Created Session: {session_id}")
    print(f"[PASS] QR Token generated successfully!")

    # 4. Employee Scan: Outside Location (Location Mismatch)
    print("\n--- 3. Testing POST /api/attendance/scan (Outside Geofence) ---")
    # Clean previous records for clean test
    current_date = datetime.now().strftime("%Y-%m-%d")
    db["attendance"].delete_many({"employee_id": employee_id, "date": current_date})
    db["attendance_events"].delete_many({"session_id": session_id})

    outside_scan = {
        "qr_token": qr_token,
        "device_id": "TEST-DEVICE-001",
        "platform": "android",
        "latitude": 11.0800, # ~7 km outside
        "longitude": 77.0200,
        "location_accuracy_meters": 15.0,
        "is_mock_location": False
    }
    res = client.post("/api/attendance/scan", json=outside_scan, headers=employee_headers)
    print(f"Outside scan response code: {res.status_code}")
    assert res.status_code == 403
    detail = res.json()["detail"]
    print(f"Detail: {detail}")
    assert "outside the authorized attendance location" in detail
    print("[PASS] Location Mismatch correctly rejected with 403!")

    # 5. Check Manager Live Events for Location Mismatch alert
    print("\n--- 4. Testing GET /api/attendance/sessions/{session_id}/events (Manager Polls Events) ---")
    res = client.get(f"/api/attendance/sessions/{session_id}/events", headers=manager_headers)
    assert res.status_code == 200
    events = res.json()["events"]
    print(f"Events count: {len(events)}")
    assert len(events) >= 1
    mismatch_event = events[0]
    print(f"Event Status: {mismatch_event['status']}")
    print(f"Location Verified: {mismatch_event['location_verified']}")
    print(f"Distance: {mismatch_event.get('distance_from_company_meters')}m")
    assert mismatch_event["status"] == "Location Mismatch"
    assert mismatch_event["location_verified"] is False
    print("[PASS] Location Mismatch event appeared in Manager Panel events!")

    # 6. Employee Scan: Inside Location (Successful Attendance)
    print("\n--- 5. Testing POST /api/attendance/scan (Inside Geofence - Successful) ---")
    inside_scan = {
        "qr_token": qr_token,
        "device_id": "TEST-DEVICE-001",
        "platform": "android",
        "latitude": 11.0168, # Inside campus
        "longitude": 76.9558,
        "location_accuracy_meters": 10.0,
        "is_mock_location": False
    }
    res = client.post("/api/attendance/scan", json=inside_scan, headers=employee_headers)
    print(f"Inside scan response code: {res.status_code}")
    assert res.status_code == 200
    success_json = res.json()
    print(f"Success message: {success_json['message']}")
    assert success_json["message"] == "Attendance recorded successfully."
    print("[PASS] Attendance recorded successfully!")

    # 7. Check Manager Live Events for Successful Attendance
    print("\n--- 6. Testing Manager Live Events Update ---")
    res = client.get(f"/api/attendance/sessions/{session_id}/events", headers=manager_headers)
    assert res.status_code == 200
    events = res.json()["events"]
    print(f"Updated Events count: {len(events)}")
    success_event = next((e for e in events if e["location_verified"] is True), None)
    assert success_event is not None
    print(f"Success event employee: {success_event['employee_name']} (Status: {success_event['status']}, Loc: {success_event['location_verified']})")
    print("[PASS] Success event appeared in Manager Panel live list!")

    # 8. Duplicate Scan Attempt
    print("\n--- 7. Testing Duplicate Scan Prevention ---")
    res = client.post("/api/attendance/scan", json=inside_scan, headers=employee_headers)
    print(f"Duplicate scan response code: {res.status_code}")
    assert res.status_code == 409
    assert "already been recorded" in res.json()["detail"]
    print("[PASS] Duplicate attendance rejected with 409!")

    # 9. Check Today's Attendance endpoint
    print("\n--- 8. Testing GET /api/attendance/today ---")
    res = client.get("/api/attendance/today", headers=manager_headers)
    assert res.status_code == 200
    today_data = res.json()
    print(f"Today's present count: {today_data['summary']['present']}")
    assert today_data["summary"]["present"] >= 1
    print("[PASS] Today's attendance updated correctly!")

    print("\n========================================")
    print("ALL API ENDPOINT INTEGRATION TESTS PASSED!")
    print("========================================")

if __name__ == "__main__":
    test_api()
