from typing import Optional

from pydantic import BaseModel, Field


# ==================================================
# CREATE SALES SCHEMA
# Used for: POST /api/sales
# ==================================================
class SalesCreate(BaseModel):

    sale_id: str = Field(
        min_length=2,
        max_length=30,
        examples=["SAL001"],
    )

    customer_name: str = Field(
        min_length=2,
        max_length=100,
        examples=["Arun Kumar"],
    )

    product_id: str = Field(
        min_length=2,
        max_length=30,
        examples=["PRD001"],
    )

    quantity: int = Field(
        gt=0,
        examples=[2],
    )

    payment_method: str = Field(
        min_length=2,
        max_length=30,
        examples=["UPI"],
    )

    status: str = Field(
        default="Completed",
        min_length=2,
        max_length=30,
        examples=["Completed"],
    )


# ==================================================
# UPDATE SALES SCHEMA
# Used for: PUT /api/sales/{sale_id}
# ==================================================
class SalesUpdate(BaseModel):

    customer_name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
        examples=["Arun Kumar"],
    )

    product_id: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=30,
        examples=["PRD001"],
    )

    quantity: Optional[int] = Field(
        default=None,
        gt=0,
        examples=[3],
    )

    payment_method: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=30,
        examples=["Cash"],
    )

    status: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=30,
        examples=["Completed"],
    )