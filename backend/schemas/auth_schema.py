from typing import Literal

from pydantic import BaseModel, EmailStr, Field


# ==================================================
# USER REGISTRATION
# POST /api/auth/register
# ==================================================
class UserRegister(BaseModel):
    name: str = Field(
        min_length=2,
        max_length=100,
        examples=["Harinie V K"],
    )

    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )

    password: str = Field(
        min_length=6,
        max_length=100,
        examples=["Password@123"],
    )

    role: Literal[
        "Admin",
        "Manager",
        "Employee",
    ] = Field(
        default="Employee",
        examples=["Employee"],
    )

    employee_id: str | None = Field(
        default=None,
        examples=["EMP001"],
    )

    department: str | None = Field(
        default=None,
        examples=["IT"],
    )

    designation: str | None = Field(
        default=None,
        examples=["Software Engineer"],
    )

    phone: str | None = Field(
        default=None,
        examples=["+1234567890"],
    )


# ==================================================
# VERIFY OTP
# POST /api/auth/verify-otp
# ==================================================
class VerifyOtp(BaseModel):
    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )

    otp: str = Field(
        min_length=6,
        max_length=6,
        pattern=r"^\d{6}$",
        examples=["123456"],
    )


# ==================================================
# RESEND OTP
# POST /api/auth/resend-otp
# ==================================================
class ResendOtp(BaseModel):
    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )


# ==================================================
# USER LOGIN
# POST /api/auth/login
# ==================================================
class UserLogin(BaseModel):
    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )

    password: str = Field(
        min_length=6,
        max_length=100,
        examples=["Password@123"],
    )


# ==================================================
# TOKEN RESPONSE
# ==================================================
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict


# ==================================================
# CHANGE PASSWORD
# PUT /api/auth/change-password
# ==================================================
class ChangePassword(BaseModel):
    current_password: str = Field(
        min_length=6,
        max_length=100,
        examples=["Password@123"],
    )

    new_password: str = Field(
        min_length=6,
        max_length=100,
        examples=["NewPassword@123"],
    )
    # ==================================================
# FORGOT PASSWORD
# POST /api/auth/forgot-password
# ==================================================
class ForgotPasswordRequest(BaseModel):
    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )


# ==================================================
# VERIFY PASSWORD RESET OTP
# POST /api/auth/verify-reset-otp
# ==================================================
class VerifyResetOtpRequest(BaseModel):
    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )

    otp: str = Field(
        min_length=6,
        max_length=6,
        pattern=r"^\d{6}$",
        examples=["123456"],
    )


# ==================================================
# RESET FORGOTTEN PASSWORD
# POST /api/auth/reset-password
# ==================================================
class ResetPasswordRequest(BaseModel):
    email: EmailStr = Field(
        examples=["harinie@gmail.com"],
    )

    reset_token: str = Field(
        min_length=20,
        max_length=500,
        examples=["secure-reset-token"],
    )

    new_password: str = Field(
        min_length=6,
        max_length=100,
        examples=["NewPassword@123"],
    )