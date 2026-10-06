import sys
import os
import json
from datetime import datetime, timezone, timedelta

# Add backend directory to sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config.database import db
from services.attendance_security import (
    create_qr_token,
    verify_qr_token,
    haversine_distance_meters,
    company_now,
    unix_timestamp,
)
from routes.attendance_routes import (
    resolve_employee,
    get_active_session_or_404,
)
from utils.security import create_access_token

def test_all():
    print("========================================")
    print("TESTING ATTENDANCE QR WORKFLOW")
    print("========================================")

    # 1. Test QR Token generation & verification
    print("\n--- 1. Testing QR Token Generation & Verification ---")
    session_id = f"ATT-TEST-{int(unix_timestamp())}"
    company_id = "COMPANY001"
    campus_id = "CAMPUS001"
    attendance_type = "check_in"

    qr_data = create_qr_token(
        session_id=session_id,
        company_id=company_id,
        campus_id=campus_id,
        attendance_type=attendance_type,
    )
    qr_token = qr_data["qr_token"]
    print(f"Generated QR Token: {qr_token[:30]}...")

    payload = verify_qr_token(qr_token)
    assert payload["session_id"] == session_id
    assert payload["company_id"] == company_id
    assert payload["campus_id"] == campus_id
    assert payload["attendance_type"] == attendance_type
    print("[PASS] QR Token signed and verified successfully!")

    # 2. Test Geofence Distance Calculation
    print("\n--- 2. Testing Haversine Distance & Geofence ---")
    campus_lat = 11.0168
    campus_lon = 76.9558
    allowed_radius = 500.0

    # Inside location (40m away)
    inside_lat = 11.0171
    inside_lon = 76.9560
    dist_inside = haversine_distance_meters(
        latitude_1=inside_lat,
        longitude_1=inside_lon,
        latitude_2=campus_lat,
        longitude_2=campus_lon,
    )
    print(f"Inside location distance: {dist_inside}m (allowed: {allowed_radius}m)")
    assert dist_inside <= allowed_radius, "Inside location should be <= allowed_radius"
    print("[PASS] Inside Geofence validation passed!")

    # Outside location (~5.5 km away)
    outside_lat = 11.0668
    outside_lon = 77.0058
    dist_outside = haversine_distance_meters(
        latitude_1=outside_lat,
        longitude_1=outside_lon,
        latitude_2=campus_lat,
        longitude_2=campus_lon,
    )
    print(f"Outside location distance: {dist_outside}m ({dist_outside/1000:.2f} km) (allowed: {allowed_radius}m)")
    assert dist_outside > allowed_radius, "Outside location should be > allowed_radius"
    print("[PASS] Outside Geofence validation passed!")

    # 3. Test JWT Token creation & decoding
    print("\n--- 3. Testing Authentication & JWT ---")
    test_user_email = "test.employee@example.com"
    token = create_access_token(data={"sub": test_user_email, "role": "Employee"})
    print(f"Created access token for {test_user_email}")
    assert token is not None and len(token) > 20
    print("[PASS] JWT creation passed!")

    # 4. Test Expired QR rejection
    print("\n--- 4. Testing Expired QR Rejection ---")
    expired_payload = {
        "session_id": session_id,
        "company_id": company_id,
        "campus_id": campus_id,
        "attendance_type": attendance_type,
        "token_version": 100,
        "issued_at": unix_timestamp() - 100,
        "expires_at": unix_timestamp() - 70, # Expired 70 seconds ago
    }
    from services.attendance_security import _base64url_encode, _sign
    enc_exp = _base64url_encode(json.dumps(expired_payload, separators=(",", ":"), sort_keys=True).encode("utf-8"))
    sig_exp = _sign(enc_exp)
    expired_token = f"{enc_exp}.{sig_exp}"
    
    try:
        verify_qr_token(expired_token)
        print("❌ Error: Expired token was not rejected!")
        sys.exit(1)
    except Exception as e:
        print(f"[PASS] Expired QR correctly rejected with error: {e}")

    print("\n========================================")
    print("ALL WORKFLOW INTEGRATION TESTS PASSED!")
    print("========================================")

if __name__ == "__main__":
    test_all()
