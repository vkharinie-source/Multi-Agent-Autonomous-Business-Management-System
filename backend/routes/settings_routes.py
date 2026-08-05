from datetime import datetime, timezone

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from pymongo import ReturnDocument

from config.database import db
from schemas.settings_schema import (
    NotificationPreferencesUpdate,
    UserPreferencesUpdate,
    UserProfileUpdate,
)
from utils.security import get_current_user


router = APIRouter(
    prefix="/api/settings",
    tags=["Settings"],
)


settings_collection = db["user_settings"]
user_collection = db["users"]


settings_collection.create_index(
    "owner_email",
    unique=True,
)


def current_time() -> datetime:
    return datetime.now(timezone.utc)


def default_settings(
    owner_email: str,
) -> dict:
    now = current_time()

    return {
        "owner_email": owner_email,
        "theme_mode": "light",
        "language": "en",
        "notifications_enabled": True,
        "email_notifications": True,
        "attendance_alerts": True,
        "inventory_alerts": True,
        "sales_alerts": True,
        "finance_alerts": True,
        "marketing_alerts": True,
        "created_at": now,
        "updated_at": now,
    }


def settings_serializer(
    settings: dict,
) -> dict:
    return {
        "id": str(settings["_id"]),
        "theme_mode": settings.get(
            "theme_mode",
            "light",
        ),
        "language": settings.get(
            "language",
            "en",
        ),
        "notifications_enabled": settings.get(
            "notifications_enabled",
            True,
        ),
        "email_notifications": settings.get(
            "email_notifications",
            True,
        ),
        "attendance_alerts": settings.get(
            "attendance_alerts",
            True,
        ),
        "inventory_alerts": settings.get(
            "inventory_alerts",
            True,
        ),
        "sales_alerts": settings.get(
            "sales_alerts",
            True,
        ),
        "finance_alerts": settings.get(
            "finance_alerts",
            True,
        ),
        "marketing_alerts": settings.get(
            "marketing_alerts",
            True,
        ),
        "updated_at": settings.get(
            "updated_at",
        ),
    }


def profile_serializer(
    user: dict,
) -> dict:
    return {
        "id": str(user["_id"]),
        "name": user.get(
            "name",
            "",
        ),
        "email": user.get(
            "email",
            "",
        ),
        "role": user.get(
            "role",
            "",
        ),
        "phone": user.get(
            "phone",
            "",
        ),
        "company_name": user.get(
            "company_name",
            "",
        ),
        "designation": user.get(
            "designation",
            "",
        ),
        "department": user.get(
            "department",
            "",
        ),
        "address": user.get(
            "address",
            "",
        ),
        "is_verified": user.get(
            "is_verified",
            False,
        ),
        "updated_at": user.get(
            "updated_at",
        ),
    }


def get_or_create_settings(
    email: str,
) -> dict:
    existing_settings = (
        settings_collection.find_one(
            {
                "owner_email": email,
            }
        )
    )

    if existing_settings is not None:
        return existing_settings

    data = default_settings(email)

    result = settings_collection.insert_one(
        data
    )

    return settings_collection.find_one(
        {
            "_id": result.inserted_id,
        }
    )


# ==========================================
# GET USER PREFERENCES
# GET /api/settings/preferences
# ==========================================
@router.get("/preferences")
def get_preferences(
    current_user: dict = Depends(
        get_current_user
    ),
):
    settings = get_or_create_settings(
        current_user["email"]
    )

    return {
        "message": (
            "Preferences fetched successfully"
        ),
        "preferences": settings_serializer(
            settings
        ),
    }


# ==========================================
# UPDATE USER PREFERENCES
# PUT /api/settings/preferences
# ==========================================
@router.put("/preferences")
def update_preferences(
    data: UserPreferencesUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    update_data = data.model_dump(
        exclude_unset=True
    )

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "No preference data provided"
            ),
        )

    now = current_time()

    update_data["updated_at"] = now

    settings = (
        settings_collection.find_one_and_update(
            {
                "owner_email": current_user[
                    "email"
                ],
            },
            {
                "$set": update_data,
                "$setOnInsert": {
                    "owner_email": current_user[
                        "email"
                    ],
                    "email_notifications": True,
                    "attendance_alerts": True,
                    "inventory_alerts": True,
                    "sales_alerts": True,
                    "finance_alerts": True,
                    "marketing_alerts": True,
                    "created_at": now,
                },
            },
            upsert=True,
            return_document=(
                ReturnDocument.AFTER
            ),
        )
    )

    return {
        "message": (
            "Preferences updated successfully"
        ),
        "preferences": settings_serializer(
            settings
        ),
    }


# ==========================================
# UPDATE NOTIFICATION SETTINGS
# PUT /api/settings/notifications
# ==========================================
@router.put("/notifications")
def update_notification_preferences(
    data: NotificationPreferencesUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    now = current_time()

    notification_data = data.model_dump()

    notification_data["updated_at"] = now

    settings = (
        settings_collection.find_one_and_update(
            {
                "owner_email": current_user[
                    "email"
                ],
            },
            {
                "$set": notification_data,
                "$setOnInsert": {
                    "owner_email": current_user[
                        "email"
                    ],
                    "theme_mode": "light",
                    "language": "en",
                    "created_at": now,
                },
            },
            upsert=True,
            return_document=(
                ReturnDocument.AFTER
            ),
        )
    )

    return {
        "message": (
            "Notification settings updated "
            "successfully"
        ),
        "preferences": settings_serializer(
            settings
        ),
    }


# ==========================================
# GET USER PROFILE
# GET /api/settings/profile
# ==========================================
@router.get("/profile")
def get_profile(
    current_user: dict = Depends(
        get_current_user
    ),
):
    user = user_collection.find_one(
        {
            "_id": current_user["_id"],
        }
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return {
        "message": (
            "Profile fetched successfully"
        ),
        "profile": profile_serializer(user),
    }


# ==========================================
# UPDATE USER PROFILE
# PUT /api/settings/profile
# ==========================================
@router.put("/profile")
def update_profile(
    data: UserProfileUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    update_data = data.model_dump(
        exclude_unset=True
    )

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No profile data provided",
        )

    for field_name in [
        "name",
        "phone",
        "company_name",
        "designation",
        "department",
        "address",
    ]:
        if field_name in update_data:
            value = update_data[field_name]

            if isinstance(value, str):
                update_data[field_name] = (
                    value.strip()
                )

    update_data["updated_at"] = (
        current_time()
    )

    updated_user = (
        user_collection.find_one_and_update(
            {
                "_id": current_user["_id"],
            },
            {
                "$set": update_data,
            },
            return_document=(
                ReturnDocument.AFTER
            ),
        )
    )

    if updated_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return {
        "message": (
            "Profile updated successfully"
        ),
        "profile": profile_serializer(
            updated_user
        ),
    }