from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field


CampaignStatus = Literal[
    "active",
    "scheduled",
    "paused",
    "completed",
]


class MarketingCampaignCreate(BaseModel):
    name: str = Field(
        ...,
        min_length=2,
        max_length=150,
    )

    channel: str = Field(
        ...,
        min_length=2,
        max_length=60,
    )

    budget: float = Field(
        ...,
        gt=0,
    )

    spent: float = Field(
        default=0,
        ge=0,
    )

    leads: int = Field(
        default=0,
        ge=0,
    )

    conversions: int = Field(
        default=0,
        ge=0,
    )

    status: CampaignStatus = "scheduled"

    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None


class MarketingCampaignUpdate(BaseModel):
    name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=150,
    )

    channel: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=60,
    )

    budget: Optional[float] = Field(
        default=None,
        gt=0,
    )

    spent: Optional[float] = Field(
        default=None,
        ge=0,
    )

    leads: Optional[int] = Field(
        default=None,
        ge=0,
    )

    conversions: Optional[int] = Field(
        default=None,
        ge=0,
    )

    status: Optional[CampaignStatus] = None

    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None


class MarketingStatusUpdate(BaseModel):
    status: CampaignStatus


class MarketingMetricsUpdate(BaseModel):
    spent: float = Field(
        ...,
        ge=0,
    )

    leads: int = Field(
        ...,
        ge=0,
    )

    conversions: int = Field(
        ...,
        ge=0,
    )