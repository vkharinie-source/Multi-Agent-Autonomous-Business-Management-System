from bson import ObjectId
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)

from config.database import db
from models.device_model import (
    device_serializer,
)
from schemas.device_schema import (
    DeviceRegisterRequest,
    DeviceReviewRequest,
)
from services.attendance_security import (
    account_is_active,
    company_now,
    hash_device_id,
    normalize_email,
    normalize_role,
)
from utils.security import (
    get_current_user,
)


router = APIRouter(
    prefix="/api/devices",
    tags=["Devices"],
)


device_collection = db[
    "employee_devices"
]

employee_collection = db[
    "employees"
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
                "can review devices."
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
        user_role = str(current_user.get("role", "")).lower()
        if user_role == "employee":
            emp_id = str(current_user.get("employee_id") or "").strip()
            if not emp_id:
                emp_id = f"EMP{str(current_user.get('_id', ''))[-6:].upper()}"
            now_iso = current_time().isoformat()
            new_emp = {
                "employee_id": emp_id,
                "name": current_user.get("name", "Employee"),
                "email": normalize_email(current_user.get("email")),
                "phone": current_user.get("phone", ""),
                "department": current_user.get("department", "General"),
                "designation": current_user.get("designation", "Employee"),
                "salary": 0.0,
                "status": "Active",
                "created_at": now_iso,
                "updated_at": now_iso,
            }
            try:
                employee_collection.insert_one(new_emp)
                employee = employee_collection.find_one(
                    {"email": normalize_email(current_user.get("email"))}
                )
                if not current_user.get("employee_id"):
                    user_collection.update_one(
                        {"_id": current_user["_id"]},
                        {"$set": {"employee_id": emp_id}},
                    )
            except Exception:
                employee = employee_collection.find_one(
                    {"email": normalize_email(current_user.get("email"))}
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

    return employee


@router.post(
    "/register-request",
    status_code=(
        status.HTTP_201_CREATED
    ),
)
def request_device_registration(
    data: DeviceRegisterRequest,
    current_user: dict = Depends(
        get_current_user
    ),
):
    role = normalize_role(
        current_user.get("role")
    )

    if role != "employee":
        raise HTTPException(
            status_code=(
                status.HTTP_403_FORBIDDEN
            ),
            detail=(
                "Only Employee accounts "
                "can register attendance devices."
            ),
        )

    employee = resolve_employee(
        current_user
    )

    employee_id = employee[
        "employee_id"
    ]

    device_hash = hash_device_id(
        data.device_id
    )

    existing = (
        device_collection.find_one(
            {
                "employee_id": (
                    employee_id
                ),
                "device_hash": (
                    device_hash
                ),
            }
        )
    )

    if existing is not None:
        return {
            "message": (
                "Device registration request "
                "already exists."
            ),
            "device": (
                device_serializer(
                    existing
                )
            ),
        }

    now = company_now().isoformat()

    document = {
        "employee_id": employee_id,
        "device_hash": device_hash,
        "device_name": (
            data.device_name
        ),
        "platform": data.platform,
        "status": "pending",
        "active": False,
        "requested_at": now,
        "requested_by_email": (
            normalize_email(
                current_user.get(
                    "email"
                )
            )
        ),
        "created_at": now,
        "updated_at": now,
    }

    result = (
        device_collection.insert_one(
            document
        )
    )

    document["_id"] = (
        result.inserted_id
    )

    return {
        "message": (
            "Device registration request "
            "submitted for approval."
        ),
        "device": device_serializer(
            document
        ),
    }


@router.get("/me")
def get_my_devices(
    current_user: dict = Depends(
        get_current_user
    ),
):
    employee = resolve_employee(
        current_user
    )

    devices = list(
        device_collection.find(
            {
                "employee_id": (
                    employee[
                        "employee_id"
                    ]
                )
            }
        ).sort(
            "requested_at",
            -1,
        )
    )

    return {
        "count": len(devices),
        "devices": [
            device_serializer(
                device
            )
            for device in devices
        ],
    }


@router.get("/pending")
def get_pending_devices(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    devices = list(
        device_collection.find(
            {
                "status": "pending"
            }
        ).sort(
            "requested_at",
            1,
        )
    )

    return {
        "count": len(devices),
        "devices": [
            device_serializer(
                device
            )
            for device in devices
        ],
    }


@router.put(
    "/{device_id}/approve"
)
def approve_device(
    device_id: str,
    data: DeviceReviewRequest,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    if not ObjectId.is_valid(
        device_id
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail="Invalid device ID.",
        )

    existing = (
        device_collection.find_one(
            {
                "_id": ObjectId(
                    device_id
                )
            }
        )
    )

    if existing is None:
        raise HTTPException(
            status_code=(
                status.HTTP_404_NOT_FOUND
            ),
            detail=(
                "Device request not found."
            ),
        )

    now = company_now().isoformat()

    device_collection.update_many(
        {
            "employee_id": (
                existing[
                    "employee_id"
                ]
            ),
            "active": True,
            "_id": {
                "$ne": existing["_id"]
            },
        },
        {
            "$set": {
                "active": False,
                "status": "revoked",
                "revoked_at": now,
                "revoked_by": (
                    normalize_email(
                        current_user.get(
                            "email"
                        )
                    )
                ),
                "review_reason": (
                    "Replaced by a newly "
                    "approved device."
                ),
                "updated_at": now,
            }
        },
    )

    device_collection.update_one(
        {
            "_id": existing["_id"]
        },
        {
            "$set": {
                "active": True,
                "status": "approved",
                "approved_at": now,
                "approved_by": (
                    normalize_email(
                        current_user.get(
                            "email"
                        )
                    )
                ),
                "review_reason": (
                    data.reason
                ),
                "updated_at": now,
            }
        },
    )

    updated = (
        device_collection.find_one(
            {
                "_id": existing["_id"]
            }
        )
    )

    return {
        "message": (
            "Device approved."
        ),
        "device": device_serializer(
            updated
        ),
    }


@router.put(
    "/{device_id}/revoke"
)
def revoke_device(
    device_id: str,
    data: DeviceReviewRequest,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    if not ObjectId.is_valid(
        device_id
    ):
        raise HTTPException(
            status_code=(
                status.HTTP_400_BAD_REQUEST
            ),
            detail="Invalid device ID.",
        )

    now = company_now().isoformat()

    result = (
        device_collection.update_one(
            {
                "_id": ObjectId(
                    device_id
                )
            },
            {
                "$set": {
                    "active": False,
                    "status": "revoked",
                    "revoked_at": now,
                    "revoked_by": (
                        normalize_email(
                            current_user.get(
                                "email"
                            )
                        )
                    ),
                    "review_reason": (
                        data.reason
                    ),
                    "updated_at": now,
                }
            },
        )
    )

    if result.matched_count == 0:
        raise HTTPException(
            status_code=(
                status.HTTP_404_NOT_FOUND
            ),
            detail="Device not found.",
        )

    updated = (
        device_collection.find_one(
            {
                "_id": ObjectId(
                    device_id
                )
            }
        )
    )

    return {
        "message": (
            "Device revoked."
        ),
        "device": device_serializer(
            updated
        ),
    }