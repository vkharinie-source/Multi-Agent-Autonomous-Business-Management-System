from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, status

from config.database import db
from schemas.password_reset_schema import (
    ForgotPasswordRequest,
    ResetPasswordRequest,
    VerifyResetOtpRequest,
)
from services.password_reset_email_service import (
    send_password_reset_otp_email,
)
from utils.password_reset_utils import (
    generate_reset_otp,
    get_reset_otp_expiry,
    hash_reset_otp,
    is_reset_otp_expired,
    verify_reset_otp,
)
from utils.security import hash_password


user_collection = db["users"]


router = APIRouter(
    prefix="/api/auth",
    tags=["Password Reset"],
)


# ==================================================
# 1. FORGOT PASSWORD
# POST /api/auth/forgot-password
# ==================================================
@router.post(
    "/forgot-password",
    status_code=status.HTTP_200_OK,
)
def forgot_password(
    request: ForgotPasswordRequest,
):
    email = request.email.strip().lower()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No account was found with this email address.",
        )

    if not existing_user.get(
        "is_verified",
        False,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "This email address is not verified. "
                "Please verify your account first."
            ),
        )

    reset_otp = generate_reset_otp()
    reset_otp_hash = hash_reset_otp(
        reset_otp
    )
    reset_otp_expiry = get_reset_otp_expiry()

    current_time = datetime.now(
        timezone.utc
    )

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "password_reset_otp_hash": (
                    reset_otp_hash
                ),
                "password_reset_otp_expires_at": (
                    reset_otp_expiry
                ),
                "password_reset_otp_verified": False,
                "password_reset_requested_at": (
                    current_time
                ),
                "updated_at": current_time,
            }
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "Unable to create the password "
                "reset request."
            ),
        )

    receiver_name = (
        existing_user.get("full_name")
        or existing_user.get("name")
        or existing_user.get("username")
        or "User"
    )

    try:
        send_password_reset_otp_email(
            receiver_email=email,
            receiver_name=receiver_name,
            otp=reset_otp,
        )

    except Exception as error:
        print(
            "FORGOT PASSWORD EMAIL ERROR:",
            repr(error),
        )

        user_collection.update_one(
            {
                "_id": existing_user["_id"],
            },
            {
                "$unset": {
                    "password_reset_otp_hash": "",
                    "password_reset_otp_expires_at": "",
                    "password_reset_otp_verified": "",
                    "password_reset_requested_at": "",
                }
            },
        )

        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "Unable to send the password reset OTP. "
                "Please try again."
            ),
        ) from error

    return {
        "message": (
            "A password reset OTP has been sent "
            "to your registered email address."
        ),
        "email": email,
        "expires_in_minutes": 5,
    }


# ==================================================
# 2. VERIFY PASSWORD RESET OTP
# POST /api/auth/verify-reset-otp
# ==================================================
@router.post(
    "/verify-reset-otp",
    status_code=status.HTTP_200_OK,
)
def verify_password_reset_otp(
    request: VerifyResetOtpRequest,
):
    email = request.email.lower().strip()
    entered_otp = request.otp.strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "No account was found with this "
                "email address."
            ),
        )

    stored_otp_hash = existing_user.get(
        "password_reset_otp_hash"
    )

    otp_expiry = existing_user.get(
        "password_reset_otp_expires_at"
    )

    if (
        stored_otp_hash is None
        or otp_expiry is None
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset OTP is unavailable. "
                "Please request a new OTP."
            ),
        )

    if is_reset_otp_expired(
        otp_expiry
    ):
        user_collection.update_one(
            {
                "_id": existing_user["_id"],
            },
            {
                "$unset": {
                    "password_reset_otp_hash": "",
                    "password_reset_otp_expires_at": "",
                    "password_reset_otp_verified": "",
                    "password_reset_requested_at": "",
                }
            },
        )

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset OTP has expired. "
                "Please request a new OTP."
            ),
        )

    otp_is_correct = verify_reset_otp(
        plain_otp=entered_otp,
        hashed_otp=stored_otp_hash,
    )

    if not otp_is_correct:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password reset OTP.",
        )

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "password_reset_otp_verified": True,
                "updated_at": datetime.now(
                    timezone.utc
                ),
            }
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "Unable to verify the password "
                "reset OTP."
            ),
        )

    return {
        "message": (
            "Password reset OTP verified successfully. "
            "You can now create a new password."
        ),
        "email": email,
    }


# ==================================================
# 3. RESET PASSWORD
# POST /api/auth/reset-password
# ==================================================
@router.post(
    "/reset-password",
    status_code=status.HTTP_200_OK,
)
def reset_password(
    request: ResetPasswordRequest,
):
    email = request.email.lower().strip()
    entered_otp = request.otp.strip()

    if (
        request.new_password
        != request.confirm_password
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Passwords do not match.",
        )

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    stored_otp_hash = existing_user.get(
        "password_reset_otp_hash"
    )

    otp_expiry = existing_user.get(
        "password_reset_otp_expires_at"
    )

    if (
        stored_otp_hash is None
        or otp_expiry is None
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset OTP is unavailable. "
                "Please request a new OTP."
            ),
        )

    if is_reset_otp_expired(
        otp_expiry
    ):
        user_collection.update_one(
            {
                "_id": existing_user["_id"],
            },
            {
                "$unset": {
                    "password_reset_otp_hash": "",
                    "password_reset_otp_expires_at": "",
                    "password_reset_otp_verified": "",
                    "password_reset_requested_at": "",
                }
            },
        )

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset OTP has expired. "
                "Please request a new OTP."
            ),
        )

    otp_is_correct = verify_reset_otp(
        plain_otp=entered_otp,
        hashed_otp=stored_otp_hash,
    )

    if not otp_is_correct:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password reset OTP.",
        )

    if not existing_user.get(
        "password_reset_otp_verified",
        False,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Please verify your password reset "
                "OTP first."
            ),
        )

    hashed_password = hash_password(
        request.new_password
    )

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "password": hashed_password,
                "updated_at": datetime.now(
                    timezone.utc
                ),
            },
            "$unset": {
                "password_reset_otp_hash": "",
                "password_reset_otp_expires_at": "",
                "password_reset_otp_verified": "",
                "password_reset_requested_at": "",
            },
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail="Unable to update password.",
        )

    return {
        "message": (
            "Password has been reset successfully."
        )
    }