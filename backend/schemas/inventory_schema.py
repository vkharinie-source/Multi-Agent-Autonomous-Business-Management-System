from typing import Optional

from pydantic import BaseModel, Field


# ==========================================
# CREATE INVENTORY PRODUCT SCHEMA
# ==========================================
class InventoryCreate(BaseModel):

    product_id: str = Field(
        min_length=2,
        max_length=30,
        examples=["PRD001"],
    )

    product_name: str = Field(
        min_length=2,
        max_length=100,
        examples=["Wireless Mouse"],
    )

    category: str = Field(
        min_length=2,
        max_length=50,
        examples=["Electronics"],
    )

    quantity: int = Field(
        ge=0,
        examples=[50],
    )

    price: float = Field(
        ge=0,
        examples=[799.0],
    )

    supplier: str = Field(
        min_length=2,
        max_length=100,
        examples=["ABC Suppliers"],
    )

    reorder_level: int = Field(
        ge=0,
        examples=[10],
    )


# ==========================================
# UPDATE INVENTORY PRODUCT SCHEMA
# ==========================================
class InventoryUpdate(BaseModel):

    product_name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
        examples=["Wireless Mouse"],
    )

    category: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=50,
        examples=["Electronics"],
    )

    quantity: Optional[int] = Field(
        default=None,
        ge=0,
        examples=[40],
    )

    price: Optional[float] = Field(
        default=None,
        ge=0,
        examples=[749.0],
    )

    supplier: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
        examples=["XYZ Suppliers"],
    )

    reorder_level: Optional[int] = Field(
        default=None,
        ge=0,
        examples=[10],
    )