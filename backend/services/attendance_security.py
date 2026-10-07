from __future__ import annotations

import base64
import hashlib
import hmac
import json
import math
import os
import time
from datetime import datetime
from typing import Any
from zoneinfo import ZoneInfo

from fastapi import HTTPException, status


COMPANY_TIMEZONE_NAME = os.getenv(
    "COMPANY_TIMEZONE",
    "Asia/Kolkata",
)

COMPANY_TIMEZONE = ZoneInfo(
    COMPANY_TIMEZONE_NAME
)

QR_ROTATION_SECONDS = int(
    os.getenv(
        "QR_ROTATION_SECONDS",
        "1200",
    )
)

QR_CLOCK_SKEW_SECONDS = int(
    os.getenv(
        "QR_CLOCK_SKEW_SECONDS",
        "3",
    )
)

SHIFT_START_HOUR = int(
    os.getenv(
        "SHIFT_START_HOUR",
        "9",
    )
)

SHIFT_START_MINUTE = int(
    os.getenv(
        "SHIFT_START_MINUTE",
        "0",
    )
)

ATTENDANCE_GRACE_MINUTES = int(
    os.getenv(
        "ATTENDANCE_GRACE_MINUTES",
        "15",
    )
)

DEFAULT_ATTENDANCE_QR_SECRET = (
    "autonomous-business-ai-attendance-qr-secret-key-32chars-2026"
)

DEFAULT_DEVICE_HASH_SECRET = (
    "autonomous-business-ai-device-hash-secret-key-32chars-2026"
)

ATTENDANCE_QR_SECRET = os.getenv(
    "ATTENDANCE_QR_SECRET",
    DEFAULT_ATTENDANCE_QR_SECRET,
)

if not ATTENDANCE_QR_SECRET or len(ATTENDANCE_QR_SECRET) < 32:
    ATTENDANCE_QR_SECRET = DEFAULT_ATTENDANCE_QR_SECRET

DEVICE_HASH_SECRET = os.getenv(
    "DEVICE_HASH_SECRET",
    DEFAULT_DEVICE_HASH_SECRET,
)

if not DEVICE_HASH_SECRET or len(DEVICE_HASH_SECRET) < 32:
    DEVICE_HASH_SECRET = DEFAULT_DEVICE_HASH_SECRET


def validate_attendance_secrets() -> None:
    global ATTENDANCE_QR_SECRET, DEVICE_HASH_SECRET
    if not ATTENDANCE_QR_SECRET or len(ATTENDANCE_QR_SECRET) < 32:
        ATTENDANCE_QR_SECRET = DEFAULT_ATTENDANCE_QR_SECRET
    if not DEVICE_HASH_SECRET or len(DEVICE_HASH_SECRET) < 32:
        DEVICE_HASH_SECRET = DEFAULT_DEVICE_HASH_SECRET


def company_now() -> datetime:
    return datetime.now(
        COMPANY_TIMEZONE
    )


def unix_timestamp() -> int:
    return int(time.time())


def normalize_role(value: Any) -> str:
    return str(
        value or ""
    ).strip().lower()


def normalize_email(value: Any) -> str:
    return str(
        value or ""
    ).strip().lower()


def normalize_status(value: Any) -> str:
    return str(
        value or ""
    ).strip().lower()


def account_is_active(
    document: dict,
) -> bool:
    if document.get("is_active") is False:
        return False

    blocked_statuses = {
        "inactive",
        "disabled",
        "blocked",
        "suspended",
        "terminated",
    }

    if normalize_status(
        document.get("account_status")
    ) in blocked_statuses:
        return False

    if normalize_status(
        document.get("status")
    ) in blocked_statuses:
        return False

    return True


def _base64url_encode(
    data: bytes,
) -> str:
    return (
        base64.urlsafe_b64encode(data)
        .decode("utf-8")
        .rstrip("=")
    )


def _base64url_decode(
    value: str,
) -> bytes:
    padding = "=" * (
        (4 - len(value) % 4) % 4
    )

    return base64.urlsafe_b64decode(
        value + padding
    )


def _sign(
    encoded_payload: str,
) -> str:
    validate_attendance_secrets()

    digest = hmac.new(
        ATTENDANCE_QR_SECRET.encode(
            "utf-8"
        ),
        encoded_payload.encode(
            "utf-8"
        ),
        hashlib.sha256,
    ).digest()

    return _base64url_encode(
        digest
    )


def create_qr_token(
    *,
    session_id: str,
    company_id: str,
    campus_id: str,
    attendance_type: str,
) -> dict:
    now = unix_timestamp()

    token_version = (
        now // QR_ROTATION_SECONDS
    )

    issued_at = (
        token_version
        * QR_ROTATION_SECONDS
    )

    expires_at = (
        issued_at
        + QR_ROTATION_SECONDS
    )

    payload = {
        "session_id": session_id,
        "company_id": company_id,
        "campus_id": campus_id,
        "attendance_type": (
            attendance_type
        ),
        "token_version": token_version,
        "issued_at": issued_at,
        "expires_at": expires_at,
    }

    encoded_payload = (
        _base64url_encode(
            json.dumps(
                payload,
                separators=(",", ":"),
                sort_keys=True,
            ).encode("utf-8")
        )
    )

    signature = _sign(
        encoded_payload
    )

    return {
        "qr_token": (
            f"{encoded_payload}.{signature}"
        ),
        "token_version": token_version,
        "issued_at_timestamp": (
            issued_at
        ),
        "expires_at_timestamp": (
            expires_at
        ),
        "rotation_seconds": (
            QR_ROTATION_SECONDS
        ),
    }


def verify_qr_token(
    qr_token: str,
) -> dict:
    try:
        encoded_payload, signature = (
            qr_token.strip().split(
                ".",
                1,
            )
        )
    except ValueError as error:
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Invalid attendance QR format."
            ),
        ) from error

    expected_signature = _sign(
        encoded_payload
    )

    if not hmac.compare_digest(
        signature,
        expected_signature,
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Invalid attendance QR signature."
            ),
        )

    try:
        payload = json.loads(
            _base64url_decode(
                encoded_payload
            ).decode("utf-8")
        )
    except Exception as error:
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Invalid attendance QR payload."
            ),
        ) from error

    required_fields = {
        "session_id",
        "company_id",
        "campus_id",
        "attendance_type",
        "token_version",
        "issued_at",
        "expires_at",
    }

    if not required_fields.issubset(
        payload
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Attendance QR data is incomplete."
            ),
        )

    now = unix_timestamp()

    if (
        now
        > int(payload["expires_at"])
        + QR_CLOCK_SKEW_SECONDS
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "This attendance QR has expired."
            ),
        )

    if (
        now + QR_CLOCK_SKEW_SECONDS
        < int(payload["issued_at"])
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Attendance QR is not active yet."
            ),
        )

    return payload


def hash_device_id(
    device_id: str,
) -> str:
    validate_attendance_secrets()

    return hmac.new(
        DEVICE_HASH_SECRET.encode(
            "utf-8"
        ),
        device_id.strip().encode(
            "utf-8"
        ),
        hashlib.sha256,
    ).hexdigest()


def haversine_distance_meters(
    *,
    latitude_1: float,
    longitude_1: float,
    latitude_2: float,
    longitude_2: float,
) -> float:
    earth_radius_meters = (
        6_371_000.0
    )

    lat_1 = math.radians(
        latitude_1
    )

    lat_2 = math.radians(
        latitude_2
    )

    lat_diff = math.radians(
        latitude_2 - latitude_1
    )

    lon_diff = math.radians(
        longitude_2 - longitude_1
    )

    a = (
        math.sin(lat_diff / 2) ** 2
        + math.cos(lat_1)
        * math.cos(lat_2)
        * math.sin(lon_diff / 2) ** 2
    )

    c = 2 * math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a),
    )

    return round(
        earth_radius_meters * c,
        2,
    )


def determine_attendance_status(
    now: datetime,
) -> tuple[str, bool]:
    current_minutes = (
        now.hour * 60
        + now.minute
    )

    late_after_minutes = (
        SHIFT_START_HOUR * 60
        + SHIFT_START_MINUTE
        + ATTENDANCE_GRACE_MINUTES
    )

    late = (
        current_minutes
        > late_after_minutes
    )

    return (
        "Late" if late else "Present",
        late,
    )