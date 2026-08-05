from typing import Literal, Optional

from pydantic import BaseModel, Field


# ==================================================
# MANUAL ATTENDANCE CHECK-IN
# Admin or Manager only
# ==================================================
class AttendanceCheckIn(BaseModel):
    employee_id: str = Field(
        ...,
        min_length=2,
        max_length=30,
        examples=["EMP001"],
    )


# ==================================================
# ATTENDANCE CHECK-OUT
# ==================================================
class AttendanceCheckOut(BaseModel):
    employee_id: str = Field(
        ...,
        min_length=2,
        max_length=30,
        examples=["EMP001"],
    )


# ==================================================
# MANUAL ATTENDANCE UPDATE
# Admin or Manager only
# ==================================================
class AttendanceUpdate(BaseModel):
    status: Optional[
        Literal[
            "Present",
            "Late",
            "Absent",
            "Leave",
        ]
    ] = None

    check_in: Optional[str] = Field(
        default=None,
        pattern=r"^([01]\d|2[0-3]):[0-5]\d$",
        examples=["09:05"],
    )

    check_out: Optional[str] = Field(
        default=None,
        pattern=r"^([01]\d|2[0-3]):[0-5]\d$",
        examples=["18:15"],
    )


# ==================================================
# COMPANY OR CAMPUS LOCATION
# Admin only
# ==================================================
class CampusCreate(BaseModel):
    company_id: str = Field(
        default="COMPANY001",
        min_length=2,
        max_length=50,
        examples=["COMPANY001"],
    )

    campus_id: str = Field(
        ...,
        min_length=2,
        max_length=50,
        examples=["CAMPUS001"],
    )

    name: str = Field(
        ...,
        min_length=2,
        max_length=150,
        examples=["Main Company Campus"],
    )

    latitude: float = Field(
        ...,
        ge=-90,
        le=90,
        examples=[11.0168],
    )

    longitude: float = Field(
        ...,
        ge=-180,
        le=180,
        examples=[76.9558],
    )

    allowed_radius_meters: float = Field(
        default=100,
        gt=0,
        le=5000,
        examples=[150],
    )

    maximum_gps_accuracy_meters: float = Field(
        default=50,
        gt=0,
        le=500,
        examples=[50],
    )


# ==================================================
# ATTENDANCE SESSION
# Admin or Manager creates a temporary session
# ==================================================
class AttendanceSessionCreate(BaseModel):
    campus_id: str = Field(
        ...,
        min_length=2,
        max_length=50,
        examples=["CAMPUS001"],
    )

    attendance_type: Literal[
        "check_in",
        "check_out",
    ] = Field(
        ...,
        examples=["check_in"],
    )

    duration_minutes: int = Field(
        default=5,
        ge=1,
        le=480,
        examples=[5],
    )


# ==================================================
# SECURE EMPLOYEE ATTENDANCE SCAN
#
# Employee identity comes from the JWT token.
# Employee ID must not be accepted from the app.
# ==================================================
class AttendanceScanRequest(BaseModel):
    qr_token: str = Field(
        ...,
        min_length=20,
        max_length=2000,
        examples=[
            "secure-signed-attendance-qr-token"
        ],
    )

    device_id: str = Field(
        ...,
        min_length=16,
        max_length=200,
        examples=[
            "550e8400-e29b-41d4-a716-446655440000"
        ],
    )

    platform: Literal[
        "android",
        "ios",
    ] = Field(
        ...,
        examples=["android"],
    )

    latitude: float = Field(
        ...,
        ge=-90,
        le=90,
        examples=[11.0168],
    )

    longitude: float = Field(
        ...,
        ge=-180,
        le=180,
        examples=[76.9558],
    )

    location_accuracy_meters: float = Field(
        ...,
        gt=0,
        le=500,
        examples=[12.5],
    )

    is_mock_location: bool = Field(
        default=False,
        examples=[False],
    )


# ==================================================
# LEGACY SHORT-LIVED QR GENERATION
# Kept for compatibility with earlier routes
# ==================================================
class AttendanceQrGenerate(BaseModel):
    valid_for_seconds: int = Field(
        default=30,
        ge=15,
        le=120,
        examples=[30],
    )


# ==================================================
# LEGACY QR SCAN MODEL
# Kept so older code does not break
# ==================================================
class AttendanceQrScan(BaseModel):
    qr_token: str = Field(
        ...,
        min_length=20,
        max_length=2000,
    )

    device_id: str = Field(
        ...,
        min_length=16,
        max_length=200,
    )

    latitude: float = Field(
        ...,
        ge=-90,
        le=90,
    )

    longitude: float = Field(
        ...,
        ge=-180,
        le=180,
    )

    accuracy: float = Field(
        ...,
        gt=0,
        le=500,
    )

    captured_at: str = Field(
        ...,
        min_length=10,
        max_length=80,
    )

    is_mocked: bool = False