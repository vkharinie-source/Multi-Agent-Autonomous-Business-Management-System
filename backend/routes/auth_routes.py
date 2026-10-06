from datetime import datetime, timezone
import hashlib
import hmac
import secrets
import time

from fastapi import APIRouter, Depends, HTTPException, status
from pymongo.errors import DuplicateKeyError

from config.database import db
from models.user_model import user_serializer
from schemas.auth_schema import (
    ChangePassword,
    ForgotPasswordRequest,
    ResendOtp,
    ResetPasswordRequest,
    TokenResponse,
    UserLogin,
    UserRegister,
    VerifyOtp,
    VerifyResetOtpRequest,
)
from services.email_service import send_otp_email
from utils.otp_utils import (
    generate_otp,
    hash_otp,
    verify_otp,
)
from utils.security import (
    create_access_token,
    get_current_user,
    hash_password,
    verify_password,
)


# ==================================================
# AUTHENTICATION ROUTER
# ==================================================
router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"],
)


# ==================================================
# MONGODB USER COLLECTION
# ==================================================
user_collection = db["users"]

user_collection.create_index(
    "email",
    unique=True,
)


# ==================================================
# OTP AND RESET TOKEN SETTINGS
# ==================================================
OTP_EXPIRY_MINUTES = 5
OTP_EXPIRY_SECONDS = OTP_EXPIRY_MINUTES * 60

RESET_TOKEN_EXPIRY_MINUTES = 10
RESET_TOKEN_EXPIRY_SECONDS = (
    RESET_TOKEN_EXPIRY_MINUTES * 60
)


# ==================================================
# COMMON HELPER FUNCTIONS
# ==================================================
def get_current_time_string() -> str:
    return datetime.now(timezone.utc).isoformat()


def get_current_timestamp() -> int:
    return int(time.time())


def get_otp_expiry_timestamp() -> int:
    return (
        get_current_timestamp()
        + OTP_EXPIRY_SECONDS
    )


def get_reset_token_expiry_timestamp() -> int:
    return (
        get_current_timestamp()
        + RESET_TOKEN_EXPIRY_SECONDS
    )


def timestamp_has_expired(
    expires_at,
) -> bool:
    if expires_at is None:
        return True

    current_timestamp = get_current_timestamp()

    if isinstance(expires_at, (int, float)):
        return current_timestamp > int(expires_at)

    if isinstance(expires_at, datetime):
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(
                tzinfo=timezone.utc
            )

        return current_timestamp > int(
            expires_at.timestamp()
        )

    return True


# ==================================================
# PASSWORD RESET TOKEN HELPERS
# ==================================================
def generate_reset_token() -> str:
    return secrets.token_urlsafe(32)


def hash_reset_token(
    reset_token: str,
) -> str:
    return hashlib.sha256(
        reset_token.encode("utf-8")
    ).hexdigest()


def verify_reset_token(
    reset_token: str,
    stored_token_hash: str,
) -> bool:
    entered_token_hash = hash_reset_token(
        reset_token
    )

    return hmac.compare_digest(
        entered_token_hash,
        stored_token_hash,
    )


# ==================================================
# 1. REGISTER EMPLOYEE AND SEND OTP
# POST /api/auth/register
# ==================================================
@router.post(
    "/register",
    status_code=status.HTTP_201_CREATED,
)
def register(
    user: UserRegister,
):
    email = user.email.lower().strip()
    name = user.name.strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is not None:
        if existing_user.get(
            "is_verified",
            False,
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Registration already exists but "
                "the email is not verified. "
                "Please use resend OTP."
            ),
        )

    otp = generate_otp()
    current_time = get_current_time_string()

    user_data = {
        "name": name,
        "email": email,
        "password": hash_password(
            user.password
        ),

        # Public registration is always employee.
        # Never accept admin or manager role
        # from the frontend.
        "role": "employee",

        "employee_id": user.employee_id,
        "department": user.department,
        "designation": user.designation,
        "phone": user.phone,

        "is_verified": False,
        "otp_hash": hash_otp(otp),
        "otp_expires_at": (
            get_otp_expiry_timestamp()
        ),
        "created_at": current_time,
        "updated_at": current_time,
    }

    try:
        result = user_collection.insert_one(
            user_data
        )

    except DuplicateKeyError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        ) from error

    try:
        send_otp_email(
            receiver_email=email,
            receiver_name=name,
            otp=otp,
        )

    except Exception as error:
        print(
            "REGISTER OTP EMAIL ERROR:",
            repr(error),
        )

        user_collection.delete_one(
            {
                "_id": result.inserted_id,
                "is_verified": False,
            }
        )

        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "Registration failed because "
                "the OTP email could not be sent. "
                "Check the backend terminal."
            ),
        ) from error

    return {
        "message": (
            "Registration successful. "
            "OTP sent to your email."
        ),
        "email": email,
        "role": "employee",
        "otp_expires_in_minutes": (
            OTP_EXPIRY_MINUTES
        ),
    }


# ==================================================
# 2. VERIFY REGISTRATION OTP
# POST /api/auth/verify-otp
# ==================================================
@router.post("/verify-otp")
def verify_registration_otp(
    data: VerifyOtp,
):
    email = data.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    if existing_user.get(
        "is_verified",
        False,
    ):
        return {
            "message": "Email is already verified",
            "email": email,
        }

    stored_otp_hash = existing_user.get(
        "otp_hash"
    )

    otp_expires_at = existing_user.get(
        "otp_expires_at"
    )

    if (
        stored_otp_hash is None
        or otp_expires_at is None
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "OTP is unavailable. "
                "Please request a new OTP."
            ),
        )

    if timestamp_has_expired(
        otp_expires_at
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "OTP has expired. "
                "Please request a new OTP."
            ),
        )

    if not verify_otp(
        data.otp,
        stored_otp_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid OTP",
        )

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "is_verified": True,
                "updated_at": (
                    get_current_time_string()
                ),
            },
            "$unset": {
                "otp_hash": "",
                "otp_expires_at": "",
            },
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "OTP verification could not "
                "be completed"
            ),
        )

    return {
        "message": (
            "Email verified successfully. "
            "You can now log in."
        ),
        "email": email,
    }


# ==================================================
# 3. RESEND REGISTRATION OTP
# POST /api/auth/resend-otp
# ==================================================
@router.post("/resend-otp")
def resend_registration_otp(
    data: ResendOtp,
):
    email = data.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    if existing_user.get(
        "is_verified",
        False,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already verified",
        )

    otp = generate_otp()

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "otp_hash": hash_otp(otp),
                "otp_expires_at": (
                    get_otp_expiry_timestamp()
                ),
                "updated_at": (
                    get_current_time_string()
                ),
            }
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unable to generate a new OTP",
        )

    try:
        send_otp_email(
            receiver_email=email,
            receiver_name=existing_user.get(
                "name",
                "User",
            ),
            otp=otp,
        )

    except Exception as error:
        print(
            "RESEND OTP EMAIL ERROR:",
            repr(error),
        )

        user_collection.update_one(
            {
                "_id": existing_user["_id"],
            },
            {
                "$unset": {
                    "otp_hash": "",
                    "otp_expires_at": "",
                },
                "$set": {
                    "updated_at": (
                        get_current_time_string()
                    ),
                },
            },
        )

        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "OTP email could not be sent. "
                "Check the backend terminal."
            ),
        ) from error

    return {
        "message": (
            "A new OTP has been sent "
            "to your email."
        ),
        "email": email,
        "otp_expires_in_minutes": (
            OTP_EXPIRY_MINUTES
        ),
    }


# ==================================================
# 4. LOGIN USER
# POST /api/auth/login
# ==================================================
@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(
    user: UserLogin,
):
    email = user.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    password_correct = verify_password(
        user.password,
        existing_user["password"],
    )

    if not password_correct:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not existing_user.get(
        "is_verified",
        False,
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Email is not verified. "
                "Please verify your OTP first."
            ),
        )

    role = str(
        existing_user.get(
            "role",
            "employee",
        )
    ).lower()

    access_token = create_access_token(
        {
            "sub": existing_user["email"],
            "role": role,
            "user_id": str(
                existing_user["_id"]
            ),
            "employee_id": existing_user.get(
                "employee_id"
            ),
        }
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user_serializer(
            existing_user
        ),
    }


# ==================================================
# 5. GET CURRENT LOGGED-IN USER
# GET /api/auth/me
# ==================================================
@router.get("/me")
def get_my_profile(
    current_user: dict = Depends(
        get_current_user
    ),
):
    return {
        "message": (
            "Current user fetched successfully"
        ),
        "user": user_serializer(
            current_user
        ),
    }


# ==================================================
# 6. CHANGE PASSWORD
# PUT /api/auth/change-password
# ==================================================
@router.put("/change-password")
def change_password(
    data: ChangePassword,
    current_user: dict = Depends(
        get_current_user
    ),
):
    password_correct = verify_password(
        data.current_password,
        current_user["password"],
    )

    if not password_correct:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect",
        )

    same_password = verify_password(
        data.new_password,
        current_user["password"],
    )

    if same_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "New password must be different "
                "from the current password"
            ),
        )

    result = user_collection.update_one(
        {
            "_id": current_user["_id"],
        },
        {
            "$set": {
                "password": hash_password(
                    data.new_password
                ),
                "updated_at": (
                    get_current_time_string()
                ),
            }
        },
    )

    if result.matched_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return {
        "message": "Password changed successfully"
    }


# ==================================================
# 7. FORGOT PASSWORD - SEND RESET OTP
# POST /api/auth/forgot-password
# ==================================================
@router.post("/forgot-password")
def forgot_password(
    data: ForgotPasswordRequest,
):
    email = data.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "No registered account was found "
                "with this email."
            ),
        )

    if not existing_user.get(
        "is_verified",
        False,
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "This email is not verified. "
                "Please complete registration first."
            ),
        )

    reset_otp = generate_otp()

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "reset_otp_hash": hash_otp(
                    reset_otp
                ),
                "reset_otp_expires_at": (
                    get_otp_expiry_timestamp()
                ),
                "updated_at": (
                    get_current_time_string()
                ),
            },
            "$unset": {
                "reset_token_hash": "",
                "reset_token_expires_at": "",
            },
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Unable to create password "
                "reset request."
            ),
        )

    try:
        send_otp_email(
            receiver_email=email,
            receiver_name=existing_user.get(
                "name",
                "User",
            ),
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
                    "reset_otp_hash": "",
                    "reset_otp_expires_at": "",
                },
                "$set": {
                    "updated_at": (
                        get_current_time_string()
                    ),
                },
            },
        )

        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "Password reset OTP could not "
                "be sent. Check the backend terminal."
            ),
        ) from error

    return {
        "message": (
            "Password reset OTP has been sent "
            "to your registered email."
        ),
        "email": email,
        "otp_expires_in_minutes": (
            OTP_EXPIRY_MINUTES
        ),
    }


# ==================================================
# 8. VERIFY PASSWORD RESET OTP
# POST /api/auth/verify-reset-otp
# ==================================================
@router.post("/verify-reset-otp")
def verify_password_reset_otp(
    data: VerifyResetOtpRequest,
):
    email = data.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    stored_otp_hash = existing_user.get(
        "reset_otp_hash"
    )

    otp_expires_at = existing_user.get(
        "reset_otp_expires_at"
    )

    if (
        stored_otp_hash is None
        or otp_expires_at is None
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset OTP is unavailable. "
                "Request a new OTP."
            ),
        )

    if timestamp_has_expired(
        otp_expires_at
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset OTP has expired. "
                "Request a new OTP."
            ),
        )

    if not verify_otp(
        data.otp,
        stored_otp_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password reset OTP",
        )

    reset_token = generate_reset_token()

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "reset_token_hash": (
                    hash_reset_token(
                        reset_token
                    )
                ),
                "reset_token_expires_at": (
                    get_reset_token_expiry_timestamp()
                ),
                "updated_at": (
                    get_current_time_string()
                ),
            },
            "$unset": {
                "reset_otp_hash": "",
                "reset_otp_expires_at": "",
            },
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset verification "
                "could not be completed."
            ),
        )

    return {
        "message": (
            "OTP verified successfully. "
            "You can now reset your password."
        ),
        "email": email,
        "reset_token": reset_token,
        "reset_token_expires_in_minutes": (
            RESET_TOKEN_EXPIRY_MINUTES
        ),
    }


# ==================================================
# 9. RESET FORGOTTEN PASSWORD
# POST /api/auth/reset-password
# ==================================================
@router.post("/reset-password")
def reset_forgotten_password(
    data: ResetPasswordRequest,
):
    email = data.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    stored_token_hash = existing_user.get(
        "reset_token_hash"
    )

    reset_token_expires_at = existing_user.get(
        "reset_token_expires_at"
    )

    if (
        stored_token_hash is None
        or reset_token_expires_at is None
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset token is unavailable. "
                "Start the password reset process again."
            ),
        )

    if timestamp_has_expired(
        reset_token_expires_at
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Password reset token has expired. "
                "Start the password reset process again."
            ),
        )

    token_is_valid = verify_reset_token(
        data.reset_token,
        stored_token_hash,
    )

    if not token_is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password reset token",
        )

    same_password = verify_password(
        data.new_password,
        existing_user["password"],
    )

    if same_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "New password must be different "
                "from the previous password"
            ),
        )

    update_result = user_collection.update_one(
        {
            "_id": existing_user["_id"],
        },
        {
            "$set": {
                "password": hash_password(
                    data.new_password
                ),
                "updated_at": (
                    get_current_time_string()
                ),
            },
            "$unset": {
                "reset_token_hash": "",
                "reset_token_expires_at": "",
                "reset_otp_hash": "",
                "reset_otp_expires_at": "",
            },
        },
    )

    if update_result.matched_count == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password could not be reset",
        )

    return {
        "message": (
            "Password reset successfully. "
            "You can now log in."
        )
    }