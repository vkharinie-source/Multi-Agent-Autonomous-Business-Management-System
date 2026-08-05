from datetime import datetime, timedelta, timezone
from typing import Literal, Optional

from bson import ObjectId
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    status,
)
from pymongo import ReturnDocument

from config.database import db
from schemas.marketing_schema import (
    MarketingCampaignCreate,
    MarketingCampaignUpdate,
    MarketingMetricsUpdate,
    MarketingStatusUpdate,
)
from utils.security import get_current_user


router = APIRouter(
    prefix="/api/marketing",
    tags=["Marketing"],
)


campaign_collection = db["marketing_campaigns"]


campaign_collection.create_index(
    [
        ("owner_email", 1),
        ("created_at", -1),
    ]
)

campaign_collection.create_index(
    [
        ("owner_email", 1),
        ("status", 1),
    ]
)


def current_time() -> datetime:
    return datetime.now(timezone.utc)


def get_campaign_object_id(
    campaign_id: str,
) -> ObjectId:
    if not ObjectId.is_valid(campaign_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid campaign ID",
        )

    return ObjectId(campaign_id)


def campaign_serializer(
    campaign: dict,
) -> dict:
    budget = float(
        campaign.get("budget", 0)
    )

    spent = float(
        campaign.get("spent", 0)
    )

    leads = int(
        campaign.get("leads", 0)
    )

    conversions = int(
        campaign.get("conversions", 0)
    )

    budget_usage_percentage = (
        0
        if budget <= 0
        else min((spent / budget) * 100, 100)
    )

    conversion_rate = (
        0
        if leads <= 0
        else (conversions / leads) * 100
    )

    return {
        "id": str(campaign["_id"]),
        "name": campaign.get("name", ""),
        "channel": campaign.get(
            "channel",
            "",
        ),
        "budget": budget,
        "spent": spent,
        "remaining_budget": max(
            budget - spent,
            0,
        ),
        "budget_usage_percentage": round(
            budget_usage_percentage,
            2,
        ),
        "leads": leads,
        "conversions": conversions,
        "conversion_rate": round(
            conversion_rate,
            2,
        ),
        "status": campaign.get(
            "status",
            "scheduled",
        ),
        "start_date": campaign.get(
            "start_date"
        ),
        "end_date": campaign.get(
            "end_date"
        ),
        "created_at": campaign.get(
            "created_at"
        ),
        "updated_at": campaign.get(
            "updated_at"
        ),
    }


# ==========================================
# CREATE CAMPAIGN
# POST /api/marketing/campaigns
# ==========================================
@router.post(
    "/campaigns",
    status_code=status.HTTP_201_CREATED,
)
def create_campaign(
    data: MarketingCampaignCreate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    campaign_data = data.model_dump()

    now = current_time()

    campaign_data["name"] = (
        campaign_data["name"].strip()
    )

    campaign_data["channel"] = (
        campaign_data["channel"].strip()
    )

    if campaign_data.get("start_date") is None:
        campaign_data["start_date"] = now

    if campaign_data.get("end_date") is None:
        campaign_data["end_date"] = (
            campaign_data["start_date"]
            + timedelta(days=30)
        )

    if (
        campaign_data["end_date"]
        < campaign_data["start_date"]
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "End date cannot be before "
                "start date"
            ),
        )

    if (
        campaign_data["spent"]
        > campaign_data["budget"]
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Spent amount cannot be greater "
                "than campaign budget"
            ),
        )

    if (
        campaign_data["conversions"]
        > campaign_data["leads"]
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Conversions cannot be greater "
                "than leads"
            ),
        )

    campaign_data.update(
        {
            "owner_email": current_user[
                "email"
            ],
            "created_at": now,
            "updated_at": now,
        }
    )

    result = campaign_collection.insert_one(
        campaign_data
    )

    created_campaign = (
        campaign_collection.find_one(
            {
                "_id": result.inserted_id,
            }
        )
    )

    return {
        "message": (
            "Marketing campaign created "
            "successfully"
        ),
        "campaign": campaign_serializer(
            created_campaign
        ),
    }


# ==========================================
# GET CAMPAIGNS
# GET /api/marketing/campaigns
# ==========================================
@router.get("/campaigns")
def get_campaigns(
    campaign_status: Optional[
        Literal[
            "active",
            "scheduled",
            "paused",
            "completed",
        ]
    ] = Query(
        default=None,
        alias="status",
    ),
    channel: Optional[str] = None,
    search: Optional[str] = None,
    limit: int = Query(
        default=100,
        ge=1,
        le=500,
    ),
    current_user: dict = Depends(
        get_current_user
    ),
):
    query: dict = {
        "owner_email": current_user["email"],
    }

    if campaign_status is not None:
        query["status"] = campaign_status

    if channel is not None:
        query["channel"] = {
            "$regex": f"^{channel.strip()}$",
            "$options": "i",
        }

    if search is not None and search.strip():
        query["$or"] = [
            {
                "name": {
                    "$regex": search.strip(),
                    "$options": "i",
                }
            },
            {
                "channel": {
                    "$regex": search.strip(),
                    "$options": "i",
                }
            },
        ]

    campaigns = list(
        campaign_collection.find(query)
        .sort("created_at", -1)
        .limit(limit)
    )

    return {
        "count": len(campaigns),
        "campaigns": [
            campaign_serializer(campaign)
            for campaign in campaigns
        ],
    }


# ==========================================
# GET ONE CAMPAIGN
# GET /api/marketing/campaigns/{id}
# ==========================================
@router.get(
    "/campaigns/{campaign_id}"
)
def get_campaign(
    campaign_id: str,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_campaign_object_id(
        campaign_id
    )

    campaign = campaign_collection.find_one(
        {
            "_id": object_id,
            "owner_email": current_user[
                "email"
            ],
        }
    )

    if campaign is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Campaign not found",
        )

    return {
        "campaign": campaign_serializer(
            campaign
        )
    }


# ==========================================
# UPDATE CAMPAIGN
# PUT /api/marketing/campaigns/{id}
# ==========================================
@router.put(
    "/campaigns/{campaign_id}"
)
def update_campaign(
    campaign_id: str,
    data: MarketingCampaignUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_campaign_object_id(
        campaign_id
    )

    existing_campaign = (
        campaign_collection.find_one(
            {
                "_id": object_id,
                "owner_email": current_user[
                    "email"
                ],
            }
        )
    )

    if existing_campaign is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Campaign not found",
        )

    update_data = data.model_dump(
        exclude_unset=True
    )

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No update data provided",
        )

    if "name" in update_data:
        update_data["name"] = (
            update_data["name"].strip()
        )

    if "channel" in update_data:
        update_data["channel"] = (
            update_data["channel"].strip()
        )

    final_budget = float(
        update_data.get(
            "budget",
            existing_campaign.get(
                "budget",
                0,
            ),
        )
    )

    final_spent = float(
        update_data.get(
            "spent",
            existing_campaign.get(
                "spent",
                0,
            ),
        )
    )

    final_leads = int(
        update_data.get(
            "leads",
            existing_campaign.get(
                "leads",
                0,
            ),
        )
    )

    final_conversions = int(
        update_data.get(
            "conversions",
            existing_campaign.get(
                "conversions",
                0,
            ),
        )
    )

    final_start_date = update_data.get(
        "start_date",
        existing_campaign.get(
            "start_date"
        ),
    )

    final_end_date = update_data.get(
        "end_date",
        existing_campaign.get(
            "end_date"
        ),
    )

    if final_spent > final_budget:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Spent amount cannot be greater "
                "than campaign budget"
            ),
        )

    if final_conversions > final_leads:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Conversions cannot be greater "
                "than leads"
            ),
        )

    if (
        final_start_date is not None
        and final_end_date is not None
        and final_end_date < final_start_date
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "End date cannot be before "
                "start date"
            ),
        )

    update_data["updated_at"] = current_time()

    updated_campaign = (
        campaign_collection.find_one_and_update(
            {
                "_id": object_id,
                "owner_email": current_user[
                    "email"
                ],
            },
            {
                "$set": update_data,
            },
            return_document=(
                ReturnDocument.AFTER
            ),
        )
    )

    return {
        "message": (
            "Marketing campaign updated "
            "successfully"
        ),
        "campaign": campaign_serializer(
            updated_campaign
        ),
    }


# ==========================================
# UPDATE CAMPAIGN STATUS
# PATCH /api/marketing/campaigns/{id}/status
# ==========================================
@router.patch(
    "/campaigns/{campaign_id}/status"
)
def update_campaign_status(
    campaign_id: str,
    data: MarketingStatusUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_campaign_object_id(
        campaign_id
    )

    updated_campaign = (
        campaign_collection.find_one_and_update(
            {
                "_id": object_id,
                "owner_email": current_user[
                    "email"
                ],
            },
            {
                "$set": {
                    "status": data.status,
                    "updated_at": current_time(),
                }
            },
            return_document=(
                ReturnDocument.AFTER
            ),
        )
    )

    if updated_campaign is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Campaign not found",
        )

    return {
        "message": (
            "Campaign status updated "
            "successfully"
        ),
        "campaign": campaign_serializer(
            updated_campaign
        ),
    }


# ==========================================
# UPDATE CAMPAIGN METRICS
# PUT /api/marketing/campaigns/{id}/metrics
# ==========================================
@router.put(
    "/campaigns/{campaign_id}/metrics"
)
def update_campaign_metrics(
    campaign_id: str,
    data: MarketingMetricsUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_campaign_object_id(
        campaign_id
    )

    existing_campaign = (
        campaign_collection.find_one(
            {
                "_id": object_id,
                "owner_email": current_user[
                    "email"
                ],
            }
        )
    )

    if existing_campaign is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Campaign not found",
        )

    budget = float(
        existing_campaign.get(
            "budget",
            0,
        )
    )

    if data.spent > budget:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Spent amount cannot be greater "
                "than campaign budget"
            ),
        )

    if data.conversions > data.leads:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Conversions cannot be greater "
                "than leads"
            ),
        )

    updated_campaign = (
        campaign_collection.find_one_and_update(
            {
                "_id": object_id,
                "owner_email": current_user[
                    "email"
                ],
            },
            {
                "$set": {
                    "spent": data.spent,
                    "leads": data.leads,
                    "conversions": (
                        data.conversions
                    ),
                    "updated_at": current_time(),
                }
            },
            return_document=(
                ReturnDocument.AFTER
            ),
        )
    )

    return {
        "message": (
            "Campaign metrics updated "
            "successfully"
        ),
        "campaign": campaign_serializer(
            updated_campaign
        ),
    }


# ==========================================
# DELETE CAMPAIGN
# DELETE /api/marketing/campaigns/{id}
# ==========================================
@router.delete(
    "/campaigns/{campaign_id}"
)
def delete_campaign(
    campaign_id: str,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_campaign_object_id(
        campaign_id
    )

    result = campaign_collection.delete_one(
        {
            "_id": object_id,
            "owner_email": current_user[
                "email"
            ],
        }
    )

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Campaign not found",
        )

    return {
        "message": (
            "Marketing campaign deleted "
            "successfully"
        )
    }


# ==========================================
# MARKETING SUMMARY
# GET /api/marketing/summary
# ==========================================
@router.get("/summary")
def get_marketing_summary(
    current_user: dict = Depends(
        get_current_user
    ),
):
    campaigns = list(
        campaign_collection.find(
            {
                "owner_email": current_user[
                    "email"
                ]
            }
        )
    )

    total_budget = sum(
        float(campaign.get("budget", 0))
        for campaign in campaigns
    )

    total_spent = sum(
        float(campaign.get("spent", 0))
        for campaign in campaigns
    )

    total_leads = sum(
        int(campaign.get("leads", 0))
        for campaign in campaigns
    )

    total_conversions = sum(
        int(
            campaign.get(
                "conversions",
                0,
            )
        )
        for campaign in campaigns
    )

    active_campaigns = sum(
        1
        for campaign in campaigns
        if campaign.get("status") == "active"
    )

    scheduled_campaigns = sum(
        1
        for campaign in campaigns
        if campaign.get("status")
        == "scheduled"
    )

    paused_campaigns = sum(
        1
        for campaign in campaigns
        if campaign.get("status") == "paused"
    )

    completed_campaigns = sum(
        1
        for campaign in campaigns
        if campaign.get("status")
        == "completed"
    )

    conversion_rate = (
        0
        if total_leads <= 0
        else (
            total_conversions
            / total_leads
        )
        * 100
    )

    budget_usage_percentage = (
        0
        if total_budget <= 0
        else min(
            (total_spent / total_budget)
            * 100,
            100,
        )
    )

    return {
        "total_campaigns": len(campaigns),
        "active_campaigns": active_campaigns,
        "scheduled_campaigns": (
            scheduled_campaigns
        ),
        "paused_campaigns": paused_campaigns,
        "completed_campaigns": (
            completed_campaigns
        ),
        "total_budget": total_budget,
        "total_spent": total_spent,
        "remaining_budget": max(
            total_budget - total_spent,
            0,
        ),
        "budget_usage_percentage": round(
            budget_usage_percentage,
            2,
        ),
        "total_leads": total_leads,
        "total_conversions": (
            total_conversions
        ),
        "conversion_rate": round(
            conversion_rate,
            2,
        ),
    }


# ==========================================
# CHANNEL PERFORMANCE
# GET /api/marketing/channels
# ==========================================
@router.get("/channels")
def get_channel_performance(
    current_user: dict = Depends(
        get_current_user
    ),
):
    campaigns = list(
        campaign_collection.find(
            {
                "owner_email": current_user[
                    "email"
                ]
            }
        )
    )

    channel_data: dict = {}

    for campaign in campaigns:
        channel = campaign.get(
            "channel",
            "Other",
        )

        if channel not in channel_data:
            channel_data[channel] = {
                "channel": channel,
                "campaigns": 0,
                "budget": 0.0,
                "spent": 0.0,
                "leads": 0,
                "conversions": 0,
            }

        channel_data[channel]["campaigns"] += 1

        channel_data[channel]["budget"] += (
            float(campaign.get("budget", 0))
        )

        channel_data[channel]["spent"] += (
            float(campaign.get("spent", 0))
        )

        channel_data[channel]["leads"] += (
            int(campaign.get("leads", 0))
        )

        channel_data[channel][
            "conversions"
        ] += int(
            campaign.get(
                "conversions",
                0,
            )
        )

    channels = []

    for item in channel_data.values():
        leads = item["leads"]

        item["conversion_rate"] = round(
            0
            if leads <= 0
            else (
                item["conversions"] / leads
            )
            * 100,
            2,
        )

        channels.append(item)

    channels.sort(
        key=lambda item: item["leads"],
        reverse=True,
    )

    return {
        "count": len(channels),
        "channels": channels,
    }