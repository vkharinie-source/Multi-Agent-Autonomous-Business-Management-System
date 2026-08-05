from __future__ import annotations

import secrets
from datetime import datetime, timedelta

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from pymongo.errors import (
    DuplicateKeyError,
)

from config.database import db
from models.attendance_model import (
    attendance_event_serializer,
    attendance_list_serializer,
    attendance_serializer,
)
from schemas.attendance_schema import (
    AttendanceScanRequest,
    AttendanceSessionCreate,
    CampusCreate,
)
from services.attendance_security import (
    account_is_active,
    company_now,
    create_qr_token,
    determine_attendance_status,
    hash_device_id,
    haversine_distance_meters,
    normalize_email,
    normalize_role,
    unix_timestamp,
    verify_qr_token,
)
from utils.security import (
    get_current_user,
)


router = APIRouter(
    prefix="/api/attendance",
    tags=["Attendance"],
)


attendance_collection = db[
    "attendance"
]

attendance_event_collection = db[
    "attendance_events"
]

session_collection = db[
    "attendance_sessions"
]

campus_collection = db[
    "campuses"
]

device_collection = db[
    "employee_devices"
]

employee_collection = db[
    "employees"
]

audit_collection = db[
    "attendance_audit_logs"
]


def require_admin_or_manager(
    current_user: dict = Depends(
        get_current_user
    ),
) -> dict:
    role = normalize_role(
        current_user.get("role")
    )

    if role not in {
        "admin",
        "manager",
    }:
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Only Admin or Manager "
                "can perform this action."
            ),
        )

    if current_user.get(
        "is_verified",
        False,
    ) is False:
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Account is not verified."
            ),
        )

    if not account_is_active(
        current_user
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Account is inactive."
            ),
        )

    return current_user


def require_admin(
    current_user: dict = Depends(
        get_current_user
    ),
) -> dict:
    role = normalize_role(
        current_user.get("role")
    )

    if role != "admin":
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Only Admin can configure "
                "company locations."
            ),
        )

    if current_user.get(
        "is_verified",
        False,
    ) is False:
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Account is not verified."
            ),
        )

    if not account_is_active(
        current_user
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Account is inactive."
            ),
        )

    return current_user


def require_employee(
    current_user: dict = Depends(
        get_current_user
    ),
) -> dict:
    role = normalize_role(
        current_user.get("role")
    )

    if role != "employee":
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Only an Employee account "
                "can scan attendance."
            ),
        )

    if current_user.get(
        "is_verified",
        False,
    ) is False:
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Account is not verified."
            ),
        )

    if not account_is_active(
        current_user
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Account is inactive."
            ),
        )

    return current_user


def resolve_employee(
    current_user: dict,
) -> dict:
    employee = None

    employee_id = (
        current_user.get(
            "employee_id"
        )
    )

    if employee_id:
        employee = (
            employee_collection
            .find_one(
                {
                    "employee_id": (
                        str(
                            employee_id
                        ).strip()
                    )
                }
            )
        )

    if employee is None:
        email = normalize_email(
            current_user.get(
                "email"
            )
        )

        employee = (
            employee_collection
            .find_one(
                {
                    "email": email
                }
            )
        )

    if employee is None:
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Employee account is not "
                "linked to the employee directory."
            ),
        )

    if not account_is_active(
        employee
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Employee record is inactive."
            ),
        )

    if not employee.get(
        "employee_id"
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Employee record does not "
                "contain employee_id."
            ),
        )

    return employee


def write_audit_log(
    *,
    current_user: dict,
    result: str,
    reason: str,
    employee_id: str | None = None,
    session_id: str | None = None,
    qr_verified: bool = False,
    location_verified: bool = False,
    device_verified: bool = False,
    distance_meters: float | None = None,
    accuracy_meters: float | None = None,
) -> None:
    audit_collection.insert_one(
        {
            "user_id": str(
                current_user.get(
                    "_id",
                    "",
                )
            ),
            "user_email": (
                normalize_email(
                    current_user.get(
                        "email"
                    )
                )
            ),
            "employee_id": employee_id,
            "session_id": session_id,
            "role": normalize_role(
                current_user.get(
                    "role"
                )
            ),
            "action": (
                "attendance_scan"
            ),
            "result": result,
            "reason": reason,
            "qr_verified": (
                qr_verified
            ),
            "location_verified": (
                location_verified
            ),
            "device_verified": (
                device_verified
            ),
            "distance_from_company_meters": (
                distance_meters
            ),
            "location_accuracy_meters": (
                accuracy_meters
            ),
            "timestamp": (
                company_now().isoformat()
            ),
        }
    )


def serialize_campus(
    campus: dict,
) -> dict:
    return {
        "id": str(
            campus.get(
                "_id",
                "",
            )
        ),
        "company_id": (
            campus.get(
                "company_id"
            )
        ),
        "campus_id": (
            campus.get(
                "campus_id"
            )
        ),
        "name": campus.get(
            "name"
        ),
        "latitude": campus.get(
            "latitude"
        ),
        "longitude": campus.get(
            "longitude"
        ),
        "allowed_radius_meters": (
            campus.get(
                "allowed_radius_meters"
            )
        ),
        "maximum_gps_accuracy_meters": (
            campus.get(
                "maximum_gps_accuracy_meters"
            )
        ),
        "active": campus.get(
            "active",
            False,
        ),
    }


def serialize_session(
    session: dict,
) -> dict:
    return {
        "id": str(
            session.get(
                "_id",
                "",
            )
        ),
        "session_id": (
            session.get(
                "session_id"
            )
        ),
        "company_id": (
            session.get(
                "company_id"
            )
        ),
        "campus_id": (
            session.get(
                "campus_id"
            )
        ),
        "campus_name": (
            session.get(
                "campus_name"
            )
        ),
        "attendance_type": (
            session.get(
                "attendance_type"
            )
        ),
        "active": session.get(
            "active",
            False,
        ),
        "started_at": (
            session.get(
                "started_at"
            )
        ),
        "closes_at": (
            session.get(
                "closes_at"
            )
        ),
        "created_by_email": (
            session.get(
                "created_by_email"
            )
        ),
        "created_by_role": (
            session.get(
                "created_by_role"
            )
        ),
        "closed_at": (
            session.get(
                "closed_at"
            )
        ),
        "close_reason": (
            session.get(
                "close_reason"
            )
        ),
    }


def get_active_session_or_404(
    session_id: str,
) -> dict:
    session = (
        session_collection.find_one(
            {
                "session_id": (
                    session_id
                )
            }
        )
    )

    if session is None:
        raise HTTPException(
            status_code=(
                status.HTTP_404_NOT_FOUND
            ),
            detail=(
                "Attendance session not found."
            ),
        )

    if not session.get(
        "active",
        False,
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Attendance session is closed."
            ),
        )

    if unix_timestamp() > int(
        session[
            "closes_at_timestamp"
        ]
    ):
        session_collection.update_one(
            {
                "_id": session["_id"]
            },
            {
                "$set": {
                    "active": False,
                    "closed_at": (
                        company_now()
                        .isoformat()
                    ),
                    "close_reason": (
                        "expired"
                    ),
                }
            },
        )

        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail=(
                "Attendance session has expired."
            ),
        )

    return session


@router.post(
    "/campuses",
    status_code=(
        status.HTTP_201_CREATED
    ),
)
def create_or_update_campus(
    data: CampusCreate,
    current_user: dict = Depends(
        require_admin
    ),
):
    now = company_now().isoformat()

    campus_collection.update_one(
        {
            "campus_id": (
                data.campus_id
            )
        },
        {
            "$set": {
                "company_id": (
                    data.company_id
                ),
                "campus_id": (
                    data.campus_id
                ),
                "name": data.name,
                "latitude": (
                    data.latitude
                ),
                "longitude": (
                    data.longitude
                ),
                "allowed_radius_meters": (
                    data.allowed_radius_meters
                ),
                "maximum_gps_accuracy_meters": (
                    data.maximum_gps_accuracy_meters
                ),
                "active": True,
                "updated_at": now,
                "updated_by": (
                    normalize_email(
                        current_user.get(
                            "email"
                        )
                    )
                ),
            },
            "$setOnInsert": {
                "created_at": now,
            },
        },
        upsert=True,
    )

    campus = (
        campus_collection.find_one(
            {
                "campus_id": (
                    data.campus_id
                )
            }
        )
    )

    return {
        "message": (
            "Campus location saved successfully."
        ),
        "campus": (
            serialize_campus(
                campus
            )
        ),
    }


@router.get("/campuses")
def get_campuses(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    campuses = list(
        campus_collection.find(
            {
                "active": True
            }
        ).sort(
            "name",
            1,
        )
    )

    return {
        "count": len(campuses),
        "campuses": [
            serialize_campus(
                campus
            )
            for campus in campuses
        ],
    }


@router.post(
    "/sessions",
    status_code=(
        status.HTTP_201_CREATED
    ),
)
def create_attendance_session(
    data: AttendanceSessionCreate,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    campus = (
        campus_collection.find_one(
            {
                "campus_id": (
                    data.campus_id
                ),
                "active": True,
            }
        )
    )

    if campus is None:
        raise HTTPException(
            status_code=(
                status.HTTP_404_NOT_FOUND
            ),
            detail=(
                "Active company or campus "
                "location was not found."
            ),
        )

    existing = (
        session_collection.find_one(
            {
                "campus_id": (
                    data.campus_id
                ),
                "attendance_type": (
                    data.attendance_type
                ),
                "active": True,
                "closes_at_timestamp": {
                    "$gt": (
                        unix_timestamp()
                    )
                },
            }
        )
    )

    if existing is not None:
        raise HTTPException(
            status_code=(
                status.HTTP_409_CONFLICT
            ),
            detail=(
                "An active attendance session "
                "already exists for this campus "
                "and attendance type."
            ),
        )

    now = company_now()

    closes_at = now + timedelta(
        minutes=data.duration_minutes
    )

    session_id = (
        "ATT-"
        + now.strftime(
            "%Y%m%d-%H%M%S"
        )
        + "-"
        + secrets.token_hex(
            4
        ).upper()
    )

    document = {
        "session_id": session_id,
        "company_id": campus.get(
            "company_id",
            "COMPANY001",
        ),
        "campus_id": campus[
            "campus_id"
        ],
        "campus_name": campus.get(
            "name"
        ),
        "attendance_type": (
            data.attendance_type
        ),
        "created_by_user_id": str(
            current_user.get(
                "_id",
                "",
            )
        ),
        "created_by_email": (
            normalize_email(
                current_user.get(
                    "email"
                )
            )
        ),
        "created_by_role": (
            normalize_role(
                current_user.get(
                    "role"
                )
            )
        ),
        "started_at": (
            now.isoformat()
        ),
        "started_at_timestamp": (
            int(now.timestamp())
        ),
        "closes_at": (
            closes_at.isoformat()
        ),
        "closes_at_timestamp": (
            int(
                closes_at.timestamp()
            )
        ),
        "active": True,
        "created_at": (
            now.isoformat()
        ),
    }

    result = (
        session_collection.insert_one(
            document
        )
    )

    document["_id"] = (
        result.inserted_id
    )

    qr = create_qr_token(
        session_id=session_id,
        company_id=document[
            "company_id"
        ],
        campus_id=document[
            "campus_id"
        ],
        attendance_type=document[
            "attendance_type"
        ],
    )

    return {
        "message": (
            "Attendance session started."
        ),
        "session": (
            serialize_session(
                document
            )
        ),
        "qr": qr,
    }


@router.get(
    "/sessions/active"
)
def get_active_sessions(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    now_timestamp = (
        unix_timestamp()
    )

    sessions = list(
        session_collection.find(
            {
                "active": True,
                "closes_at_timestamp": {
                    "$gt": now_timestamp
                },
            }
        ).sort(
            "started_at_timestamp",
            -1,
        )
    )

    return {
        "count": len(sessions),
        "sessions": [
            serialize_session(
                session
            )
            for session in sessions
        ],
    }


@router.get(
    "/sessions/{session_id}/qr"
)
def get_rotating_qr(
    session_id: str,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    session = (
        get_active_session_or_404(
            session_id
        )
    )

    qr = create_qr_token(
        session_id=session[
            "session_id"
        ],
        company_id=session[
            "company_id"
        ],
        campus_id=session[
            "campus_id"
        ],
        attendance_type=session[
            "attendance_type"
        ],
    )

    return {
        "session": (
            serialize_session(
                session
            )
        ),
        "qr": qr,
    }


@router.post(
    "/sessions/{session_id}/close"
)
def close_attendance_session(
    session_id: str,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    now = company_now()

    result = (
        session_collection.update_one(
            {
                "session_id": (
                    session_id
                ),
                "active": True,
            },
            {
                "$set": {
                    "active": False,
                    "closed_at": (
                        now.isoformat()
                    ),
                    "closed_by_user_id": (
                        str(
                            current_user.get(
                                "_id",
                                "",
                            )
                        )
                    ),
                    "closed_by_email": (
                        normalize_email(
                            current_user.get(
                                "email"
                            )
                        )
                    ),
                    "close_reason": (
                        "closed_by_admin_or_manager"
                    ),
                }
            },
        )
    )

    if result.matched_count == 0:
        raise HTTPException(
            status_code=(
                status.HTTP_404_NOT_FOUND
            ),
            detail=(
                "Active attendance session "
                "was not found."
            ),
        )

    return {
        "message": (
            "Attendance session closed."
        )
    }


@router.post("/scan")
def scan_attendance(
    data: AttendanceScanRequest,
    current_user: dict = Depends(
        require_employee
    ),
):
    employee = resolve_employee(
        current_user
    )

    employee_id = str(
        employee[
            "employee_id"
        ]
    )

    qr_verified = False
    location_verified = False
    device_verified = False
    session_id = None
    distance_meters = None

    try:
        payload = verify_qr_token(
            data.qr_token
        )

        qr_verified = True

        session_id = str(
            payload[
                "session_id"
            ]
        )

        session = (
            get_active_session_or_404(
                session_id
            )
        )

        for field_name in (
            "company_id",
            "campus_id",
            "attendance_type",
        ):
            if (
                str(
                    session[
                        field_name
                    ]
                )
                != str(
                    payload[
                        field_name
                    ]
                )
            ):
                raise HTTPException(
                    status_code=(
                        status.HTTP_400_BAD_REQUEST
                    ),
                    detail=(
                        "Attendance QR does not "
                        "match the active session."
                    ),
                )

        device_hash = hash_device_id(
            data.device_id
        )

        device = (
            device_collection.find_one(
                {
                    "employee_id": (
                        employee_id
                    ),
                    "device_hash": (
                        device_hash
                    ),
                    "status": (
                        "approved"
                    ),
                    "active": True,
                    "platform": (
                        data.platform
                    ),
                }
            )
        )

        if device is None:
            raise HTTPException(
                status_code=(
                    status.HTTP_403_FORBIDDEN
                ),
                detail=(
                    "This device is not approved "
                    "for attendance."
                ),
            )

        device_verified = True

        if data.is_mock_location:
            raise HTTPException(
                status_code=(
                    status.HTTP_403_FORBIDDEN
                ),
                detail=(
                    "Mock location was detected. "
                    "Attendance was rejected."
                ),
            )

        campus = (
            campus_collection.find_one(
                {
                    "campus_id": (
                        session[
                            "campus_id"
                        ]
                    ),
                    "active": True,
                }
            )
        )

        if campus is None:
            raise HTTPException(
                status_code=(
                    status.HTTP_404_NOT_FOUND
                ),
                detail=(
                    "Registered campus location "
                    "was not found."
                ),
            )

        maximum_accuracy = float(
            campus.get(
                "maximum_gps_accuracy_meters",
                50,
            )
        )

        if (
            data.location_accuracy_meters
            > maximum_accuracy
        ):
            raise HTTPException(
                status_code=(
                    status.HTTP_400_BAD_REQUEST
                ),
                detail=(
                    "GPS accuracy is too low. "
                    "Move to an open area and retry."
                ),
            )

        distance_meters = (
            haversine_distance_meters(
                latitude_1=(
                    data.latitude
                ),
                longitude_1=(
                    data.longitude
                ),
                latitude_2=float(
                    campus[
                        "latitude"
                    ]
                ),
                longitude_2=float(
                    campus[
                        "longitude"
                    ]
                ),
            )
        )

        allowed_radius = float(
            campus.get(
                "allowed_radius_meters",
                100,
            )
        )

        if (
            distance_meters
            > allowed_radius
        ):
            raise HTTPException(
                status_code=(
                    status.HTTP_403_FORBIDDEN
                ),
                detail=(
                    "You are outside the allowed "
                    "company or campus location."
                ),
            )

        location_verified = True

        attendance_type = str(
            session[
                "attendance_type"
            ]
        )

        duplicate_event = (
            attendance_event_collection
            .find_one(
                {
                    "employee_id": (
                        employee_id
                    ),
                    "session_id": (
                        session_id
                    ),
                    "attendance_type": (
                        attendance_type
                    ),
                }
            )
        )

        if duplicate_event is not None:
            return {
                "message": (
                    "Attendance was already "
                    "recorded for this session."
                ),
                "duplicate": True,
                "event": (
                    attendance_event_serializer(
                        duplicate_event
                    )
                ),
            }

        now = company_now()

        current_date = now.strftime(
            "%Y-%m-%d"
        )

        current_time = now.strftime(
            "%H:%M:%S"
        )

        status_value, late = (
            determine_attendance_status(
                now
            )
        )

        daily_record = (
            attendance_collection
            .find_one(
                {
                    "employee_id": (
                        employee_id
                    ),
                    "date": (
                        current_date
                    ),
                }
            )
        )

        if (
            attendance_type
            == "check_in"
            and daily_record
            is not None
            and daily_record.get(
                "check_in_at"
            )
        ):
            raise HTTPException(
                status_code=(
                    status.HTTP_409_CONFLICT
                ),
                detail=(
                    "Daily check-in was "
                    "already recorded."
                ),
            )

        if (
            attendance_type
            == "check_out"
            and (
                daily_record is None
                or not daily_record.get(
                    "check_in_at"
                )
            )
        ):
            raise HTTPException(
                status_code=(
                    status.HTTP_409_CONFLICT
                ),
                detail=(
                    "Check-in must be "
                    "recorded before check-out."
                ),
            )

        if (
            attendance_type
            == "check_out"
            and daily_record
            is not None
            and daily_record.get(
                "check_out_at"
            )
        ):
            raise HTTPException(
                status_code=(
                    status.HTTP_409_CONFLICT
                ),
                detail=(
                    "Daily check-out was "
                    "already recorded."
                ),
            )

        event_document = {
            "employee_id": (
                employee_id
            ),
            "employee_name": (
                employee.get(
                    "name",
                    "Employee",
                )
            ),
            "department": (
                employee.get(
                    "department"
                )
            ),
            "designation": (
                employee.get(
                    "designation"
                )
            ),
            "company_id": (
                session[
                    "company_id"
                ]
            ),
            "campus_id": (
                session[
                    "campus_id"
                ]
            ),
            "session_id": (
                session_id
            ),
            "attendance_type": (
                attendance_type
            ),
            "recorded_at": (
                now.isoformat()
            ),
            "recorded_time": (
                current_time
            ),
            "status": (
                status_value
                if attendance_type
                == "check_in"
                else "Checked Out"
            ),
            "late": (
                late
                if attendance_type
                == "check_in"
                else False
            ),
            "qr_verified": True,
            "location_verified": True,
            "device_verified": True,
            "mock_location_detected": (
                data.is_mock_location
            ),
            "distance_from_company_meters": (
                distance_meters
            ),
            "location_accuracy_meters": (
                data.location_accuracy_meters
            ),
            "device_reference": (
                str(
                    device["_id"]
                )
            ),
            "source": (
                "secure_qr_scan"
            ),
            "created_at": (
                now.isoformat()
            ),
        }

        try:
            event_result = (
                attendance_event_collection
                .insert_one(
                    event_document
                )
            )
        except DuplicateKeyError:
            existing_event = (
                attendance_event_collection
                .find_one(
                    {
                        "employee_id": (
                            employee_id
                        ),
                        "session_id": (
                            session_id
                        ),
                        "attendance_type": (
                            attendance_type
                        ),
                    }
                )
            )

            return {
                "message": (
                    "Attendance was already "
                    "recorded for this session."
                ),
                "duplicate": True,
                "event": (
                    attendance_event_serializer(
                        existing_event
                    )
                ),
            }

        event_document["_id"] = (
            event_result.inserted_id
        )

        common_values = {
            "employee_id": (
                employee_id
            ),
            "employee_name": (
                employee.get(
                    "name",
                    "Employee",
                )
            ),
            "department": (
                employee.get(
                    "department"
                )
            ),
            "designation": (
                employee.get(
                    "designation"
                )
            ),
            "company_id": (
                session[
                    "company_id"
                ]
            ),
            "campus_id": (
                session[
                    "campus_id"
                ]
            ),
            "date": current_date,
            "qr_verified": True,
            "location_verified": True,
            "device_verified": True,
            "mock_location_detected": (
                False
            ),
            "distance_from_company_meters": (
                distance_meters
            ),
            "location_accuracy_meters": (
                data.location_accuracy_meters
            ),
            "source": (
                "secure_qr_scan"
            ),
            "updated_at": (
                now.isoformat()
            ),
        }

        if (
            attendance_type
            == "check_in"
        ):
            attendance_collection.update_one(
                {
                    "employee_id": (
                        employee_id
                    ),
                    "date": (
                        current_date
                    ),
                },
                {
                    "$setOnInsert": {
                        "created_at": (
                            now.isoformat()
                        ),
                        "check_out": None,
                        "check_out_at": None,
                        "working_hours": 0,
                    },
                    "$set": {
                        **common_values,
                        "check_in": (
                            current_time
                        ),
                        "check_in_at": (
                            now.isoformat()
                        ),
                        "check_in_session_id": (
                            session_id
                        ),
                        "status": (
                            status_value
                        ),
                        "late": late,
                    },
                },
                upsert=True,
            )

        else:
            check_in_at = (
                datetime.fromisoformat(
                    daily_record[
                        "check_in_at"
                    ]
                )
            )

            working_hours = round(
                (
                    now - check_in_at
                ).total_seconds()
                / 3600,
                2,
            )

            attendance_collection.update_one(
                {
                    "_id": (
                        daily_record[
                            "_id"
                        ]
                    )
                },
                {
                    "$set": {
                        **common_values,
                        "check_out": (
                            current_time
                        ),
                        "check_out_at": (
                            now.isoformat()
                        ),
                        "check_out_session_id": (
                            session_id
                        ),
                        "working_hours": (
                            working_hours
                        ),
                    }
                },
            )

        updated_daily = (
            attendance_collection
            .find_one(
                {
                    "employee_id": (
                        employee_id
                    ),
                    "date": (
                        current_date
                    ),
                }
            )
        )

        write_audit_log(
            current_user=(
                current_user
            ),
            result="accepted",
            reason=(
                "attendance_recorded"
            ),
            employee_id=(
                employee_id
            ),
            session_id=(
                session_id
            ),
            qr_verified=True,
            location_verified=True,
            device_verified=True,
            distance_meters=(
                distance_meters
            ),
            accuracy_meters=(
                data.location_accuracy_meters
            ),
        )

        return {
            "message": (
                "Attendance recorded successfully."
            ),
            "duplicate": False,
            "attendance": (
                attendance_serializer(
                    updated_daily
                )
            ),
            "event": (
                attendance_event_serializer(
                    event_document
                )
            ),
        }

    except HTTPException as error:
        write_audit_log(
            current_user=(
                current_user
            ),
            result="rejected",
            reason=str(
                error.detail
            ),
            employee_id=(
                employee_id
            ),
            session_id=(
                session_id
            ),
            qr_verified=(
                qr_verified
            ),
            location_verified=(
                location_verified
            ),
            device_verified=(
                device_verified
            ),
            distance_meters=(
                distance_meters
            ),
            accuracy_meters=(
                data.location_accuracy_meters
            ),
        )

        raise


@router.get("/today")
def get_today_attendance(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    current_date = (
        company_now().strftime(
            "%Y-%m-%d"
        )
    )

    records = list(
        attendance_collection.find(
            {
                "date": current_date
            }
        ).sort(
            "check_in_at",
            -1,
        )
    )

    active_employee_query = {
        "$and": [
            {
                "$or": [
                    {
                        "is_active": {
                            "$exists": False
                        }
                    },
                    {
                        "is_active": True
                    },
                ]
            },
            {
                "$or": [
                    {
                        "status": {
                            "$exists": False
                        }
                    },
                    {
                        "status": {
                            "$nin": [
                                "Inactive",
                                "Terminated",
                                "Suspended",
                            ]
                        }
                    },
                ]
            },
        ]
    }

    total_employees = (
        employee_collection
        .count_documents(
            active_employee_query
        )
    )

    checked_in_count = sum(
        1
        for record in records
        if record.get(
            "check_in_at"
        )
    )

    late_count = sum(
        1
        for record in records
        if record.get(
            "late"
        ) is True
    )

    absent_count = max(
        total_employees
        - checked_in_count,
        0,
    )

    attendance_rate = (
        round(
            checked_in_count
            / total_employees
            * 100,
            2,
        )
        if total_employees > 0
        else 0
    )

    return {
        "date": current_date,
        "summary": {
            "total_employees": (
                total_employees
            ),
            "present": (
                checked_in_count
            ),
            "late": late_count,
            "absent": absent_count,
            "attendance_rate": (
                attendance_rate
            ),
        },
        "attendance": (
            attendance_list_serializer(
                records
            )
        ),
    }


@router.get("/me")
def get_my_attendance(
    current_user: dict = Depends(
        require_employee
    ),
):
    employee = resolve_employee(
        current_user
    )

    employee_id = employee[
        "employee_id"
    ]

    records = list(
        attendance_collection.find(
            {
                "employee_id": (
                    employee_id
                )
            }
        ).sort(
            "date",
            -1,
        )
    )

    current_date = (
        company_now().strftime(
            "%Y-%m-%d"
        )
    )

    today = next(
        (
            record
            for record in records
            if record.get(
                "date"
            )
            == current_date
        ),
        None,
    )

    return {
        "employee_id": (
            employee_id
        ),
        "count": len(records),
        "today": (
            attendance_serializer(
                today
            )
        ),
        "attendance": (
            attendance_list_serializer(
                records
            )
        ),
    }


@router.get("/audit-logs")
def get_audit_logs(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    logs = list(
        audit_collection.find()
        .sort(
            "timestamp",
            -1,
        )
        .limit(500)
    )

    for log in logs:
        log["id"] = str(
            log.pop("_id")
        )

    return {
        "count": len(logs),
        "logs": logs,
    }
