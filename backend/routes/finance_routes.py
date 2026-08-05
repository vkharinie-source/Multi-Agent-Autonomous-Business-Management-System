from datetime import datetime, timezone
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
from schemas.finance_schema import (
    FinanceBudgetUpdate,
    FinanceTransactionCreate,
    FinanceTransactionUpdate,
)
from utils.security import get_current_user


router = APIRouter(
    prefix="/api/finance",
    tags=["Finance"],
)


transaction_collection = db[
    "finance_transactions"
]

budget_collection = db[
    "finance_budgets"
]


transaction_collection.create_index(
    [
        ("owner_email", 1),
        ("date", -1),
    ]
)

budget_collection.create_index(
    "owner_email",
    unique=True,
)


def current_time() -> datetime:
    return datetime.now(timezone.utc)


def get_object_id(
    transaction_id: str,
) -> ObjectId:
    if not ObjectId.is_valid(transaction_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid transaction ID",
        )

    return ObjectId(transaction_id)


def transaction_serializer(
    transaction: dict,
) -> dict:
    return {
        "id": str(transaction["_id"]),
        "title": transaction.get(
            "title",
            "",
        ),
        "category": transaction.get(
            "category",
            "",
        ),
        "amount": transaction.get(
            "amount",
            0,
        ),
        "type": transaction.get(
            "type",
            "",
        ),
        "date": transaction.get(
            "date",
        ),
        "created_at": transaction.get(
            "created_at",
        ),
        "updated_at": transaction.get(
            "updated_at",
        ),
    }


def budget_serializer(
    budget: dict,
) -> dict:
    return {
        "id": str(budget["_id"]),
        "monthly_budget": budget.get(
            "monthly_budget",
            100000,
        ),
        "opening_balance": budget.get(
            "opening_balance",
            0,
        ),
        "updated_at": budget.get(
            "updated_at",
        ),
    }


# ==================================================
# CREATE TRANSACTION
# POST /api/finance/transactions
# ==================================================
@router.post(
    "/transactions",
    status_code=status.HTTP_201_CREATED,
)
def create_transaction(
    data: FinanceTransactionCreate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    transaction_data = data.dict()

    now = current_time()

    transaction_data["title"] = (
        transaction_data["title"].strip()
    )

    transaction_data["category"] = (
        transaction_data["category"].strip()
    )

    if transaction_data.get("date") is None:
        transaction_data["date"] = now

    transaction_data.update(
        {
            "owner_email": current_user[
                "email"
            ],
            "created_at": now,
            "updated_at": now,
        }
    )

    result = transaction_collection.insert_one(
        transaction_data
    )

    created_transaction = (
        transaction_collection.find_one(
            {
                "_id": result.inserted_id,
            }
        )
    )

    return {
        "message": (
            "Transaction created successfully"
        ),
        "transaction": transaction_serializer(
            created_transaction
        ),
    }


# ==================================================
# GET ALL TRANSACTIONS
# GET /api/finance/transactions
# ==================================================
@router.get("/transactions")
def get_transactions(
    transaction_type: Optional[
        Literal[
            "income",
            "expense",
        ]
    ] = Query(
        default=None,
        alias="type",
    ),
    category: Optional[str] = None,
    limit: int = Query(
        default=100,
        ge=1,
        le=500,
    ),
    current_user: dict = Depends(
        get_current_user
    ),
):
    query = {
        "owner_email": current_user["email"],
    }

    if transaction_type is not None:
        query["type"] = transaction_type

    if category is not None:
        query["category"] = {
            "$regex": f"^{category.strip()}$",
            "$options": "i",
        }

    transactions = list(
        transaction_collection.find(query)
        .sort("date", -1)
        .limit(limit)
    )

    return {
        "count": len(transactions),
        "transactions": [
            transaction_serializer(transaction)
            for transaction in transactions
        ],
    }


# ==================================================
# GET ONE TRANSACTION
# GET /api/finance/transactions/{id}
# ==================================================
@router.get(
    "/transactions/{transaction_id}"
)
def get_transaction(
    transaction_id: str,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_object_id(
        transaction_id
    )

    transaction = (
        transaction_collection.find_one(
            {
                "_id": object_id,
                "owner_email": current_user[
                    "email"
                ],
            }
        )
    )

    if transaction is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transaction not found",
        )

    return {
        "transaction": transaction_serializer(
            transaction
        )
    }


# ==================================================
# UPDATE TRANSACTION
# PUT /api/finance/transactions/{id}
# ==================================================
@router.put(
    "/transactions/{transaction_id}"
)
def update_transaction(
    transaction_id: str,
    data: FinanceTransactionUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_object_id(
        transaction_id
    )

    update_data = data.dict(
        exclude_unset=True
    )

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No update data provided",
        )

    if "title" in update_data:
        update_data["title"] = (
            update_data["title"].strip()
        )

    if "category" in update_data:
        update_data["category"] = (
            update_data["category"].strip()
        )

    update_data["updated_at"] = (
        current_time()
    )

    updated_transaction = (
        transaction_collection.find_one_and_update(
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

    if updated_transaction is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transaction not found",
        )

    return {
        "message": (
            "Transaction updated successfully"
        ),
        "transaction": transaction_serializer(
            updated_transaction
        ),
    }


# ==================================================
# DELETE TRANSACTION
# DELETE /api/finance/transactions/{id}
# ==================================================
@router.delete(
    "/transactions/{transaction_id}"
)
def delete_transaction(
    transaction_id: str,
    current_user: dict = Depends(
        get_current_user
    ),
):
    object_id = get_object_id(
        transaction_id
    )

    result = transaction_collection.delete_one(
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
            detail="Transaction not found",
        )

    return {
        "message": (
            "Transaction deleted successfully"
        )
    }


# ==================================================
# GET FINANCE SUMMARY
# GET /api/finance/summary
# ==================================================
@router.get("/summary")
def get_finance_summary(
    current_user: dict = Depends(
        get_current_user
    ),
):
    email = current_user["email"]

    transactions = list(
        transaction_collection.find(
            {
                "owner_email": email,
            }
        )
    )

    total_income = sum(
        float(transaction.get("amount", 0))
        for transaction in transactions
        if transaction.get("type") == "income"
    )

    total_expense = sum(
        float(transaction.get("amount", 0))
        for transaction in transactions
        if transaction.get("type") == "expense"
    )

    net_profit = (
        total_income - total_expense
    )

    budget = budget_collection.find_one(
        {
            "owner_email": email,
        }
    )

    monthly_budget = (
        float(
            budget.get(
                "monthly_budget",
                100000,
            )
        )
        if budget is not None
        else 100000
    )

    opening_balance = (
        float(
            budget.get(
                "opening_balance",
                0,
            )
        )
        if budget is not None
        else 0
    )

    current_balance = (
        opening_balance + net_profit
    )

    remaining_budget = max(
        monthly_budget - total_expense,
        0,
    )

    budget_used_percentage = (
        0
        if monthly_budget <= 0
        else min(
            (
                total_expense
                / monthly_budget
            )
            * 100,
            100,
        )
    )

    income_count = sum(
        1
        for transaction in transactions
        if transaction.get("type") == "income"
    )

    expense_count = sum(
        1
        for transaction in transactions
        if transaction.get("type") == "expense"
    )

    return {
        "total_income": total_income,
        "total_expense": total_expense,
        "net_profit": net_profit,
        "opening_balance": opening_balance,
        "current_balance": current_balance,
        "monthly_budget": monthly_budget,
        "remaining_budget": remaining_budget,
        "budget_used_percentage": round(
            budget_used_percentage,
            2,
        ),
        "income_count": income_count,
        "expense_count": expense_count,
        "transaction_count": len(
            transactions
        ),
    }


# ==================================================
# GET FINANCE BUDGET
# GET /api/finance/budget
# ==================================================
@router.get("/budget")
def get_budget(
    current_user: dict = Depends(
        get_current_user
    ),
):
    email = current_user["email"]

    budget = budget_collection.find_one(
        {
            "owner_email": email,
        }
    )

    if budget is None:
        now = current_time()

        default_budget = {
            "owner_email": email,
            "monthly_budget": 100000,
            "opening_balance": 0,
            "created_at": now,
            "updated_at": now,
        }

        result = budget_collection.insert_one(
            default_budget
        )

        budget = budget_collection.find_one(
            {
                "_id": result.inserted_id,
            }
        )

    return {
        "budget": budget_serializer(budget)
    }


# ==================================================
# UPDATE FINANCE BUDGET
# PUT /api/finance/budget
# ==================================================
@router.put("/budget")
def update_budget(
    data: FinanceBudgetUpdate,
    current_user: dict = Depends(
        get_current_user
    ),
):
    email = current_user["email"]

    now = current_time()

    budget = budget_collection.find_one_and_update(
        {
            "owner_email": email,
        },
        {
            "$set": {
                "monthly_budget": (
                    data.monthly_budget
                ),
                "opening_balance": (
                    data.opening_balance
                ),
                "updated_at": now,
            },
            "$setOnInsert": {
                "owner_email": email,
                "created_at": now,
            },
        },
        upsert=True,
        return_document=ReturnDocument.AFTER,
    )

    return {
        "message": (
            "Finance budget updated successfully"
        ),
        "budget": budget_serializer(budget),
    }