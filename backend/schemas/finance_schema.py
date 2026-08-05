from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field


class FinanceTransactionCreate(BaseModel):
    title: str = Field(
        ...,
        min_length=2,
        max_length=100,
    )

    category: str = Field(
        ...,
        min_length=2,
        max_length=50,
    )

    amount: float = Field(
        ...,
        gt=0,
    )

    type: Literal[
        "income",
        "expense",
    ]

    date: Optional[datetime] = None


class FinanceTransactionUpdate(BaseModel):
    title: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
    )

    category: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=50,
    )

    amount: Optional[float] = Field(
        default=None,
        gt=0,
    )

    type: Optional[
        Literal[
            "income",
            "expense",
        ]
    ] = None

    date: Optional[datetime] = None


class FinanceBudgetUpdate(BaseModel):
    monthly_budget: float = Field(
        ...,
        ge=0,
    )

    opening_balance: float = Field(
        default=0,
        ge=0,
    )