from typing import Literal, Optional

from pydantic import BaseModel, Field


ThemeMode = Literal[
    "light",
    "dark",
    "system",
]


LanguageCode = Literal[
    "en",
    "ta",
    "hi",
]


class UserPreferencesUpdate(BaseModel):
    theme_mode: Optional[ThemeMode] = None

    language: Optional[LanguageCode] = None

    notifications_enabled: Optional[bool] = None


class NotificationPreferencesUpdate(BaseModel):
    notifications_enabled: bool = True

    email_notifications: bool = True

    attendance_alerts: bool = True

    inventory_alerts: bool = True

    sales_alerts: bool = True

    finance_alerts: bool = True

    marketing_alerts: bool = True


class UserProfileUpdate(BaseModel):
    name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
    )

    phone: Optional[str] = Field(
        default=None,
        min_length=7,
        max_length=20,
    )

    company_name: Optional[str] = Field(
        default=None,
        max_length=120,
    )

    designation: Optional[str] = Field(
        default=None,
        max_length=100,
    )

    department: Optional[str] = Field(
        default=None,
        max_length=100,
    )

    address: Optional[str] = Field(
        default=None,
        max_length=300,
    )