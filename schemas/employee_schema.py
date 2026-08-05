from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class EmployeeCreate(BaseModel):
    employee_id: str = Field(
        min_length=2,
        max_length=30,
        examples=["EMP001"],
    )

    name: str = Field(
        min_length=2,
        max_length=100,
        examples=["Harinie V K"],
    )

    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )

    phone: str = Field(
        min_length=7,
        max_length=20,
        examples=["9876543210"],
    )

    department: str = Field(
        min_length=2,
        max_length=50,
        examples=["IT"],
    )

    designation: str = Field(
        min_length=2,
        max_length=50,
        examples=["Software Developer"],
    )

    salary: float = Field(
        ge=0,
        examples=[45000],
    )

    status: str = Field(
        default="Active",
        examples=["Active"],
    )


class EmployeeUpdate(BaseModel):
    name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
    )

    email: Optional[EmailStr] = None

    phone: Optional[str] = Field(
        default=None,
        min_length=7,
        max_length=20,
    )

    department: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=50,
    )

    designation: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=50,
    )

    salary: Optional[float] = Field(
        default=None,
        ge=0,
    )

    status: Optional[str] = None