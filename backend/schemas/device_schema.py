from typing import Literal, Optional

from pydantic import BaseModel, Field


class DeviceRegisterRequest(BaseModel):
    device_id: str = Field(
        ...,
        min_length=8,
        max_length=500,
    )

    device_name: str = Field(
        ...,
        min_length=2,
        max_length=150,
    )

    platform: Literal[
        "android",
        "ios",
    ]


class DeviceReviewRequest(BaseModel):
    reason: Optional[str] = Field(
        default=None,
        min_length=3,
        max_length=500,
    )