from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import (
    HTTPAuthorizationCredentials,
    HTTPBearer,
)
from jose import ExpiredSignatureError, JWTError, jwt
from passlib.context import CryptContext

from config.database import db


# ==================================================
# PASSWORD HASHING
# ==================================================
password_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


# ==================================================
# JWT SETTINGS
# ==================================================
SECRET_KEY = "autonomous-business-ai-secret-key-2026"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


# ==================================================
# BEARER TOKEN SECURITY
# ==================================================
bearer_scheme = HTTPBearer(
    auto_error=True,
)


# ==================================================
# DATABASE COLLECTION
# ==================================================
user_collection = db["users"]


# ==================================================
# HASH PASSWORD
# ==================================================
def hash_password(password: str) -> str:

    return password_context.hash(password)


# ==================================================
# VERIFY PASSWORD
# ==================================================
def verify_password(
    plain_password: str,
    hashed_password: str,
) -> bool:

    return password_context.verify(
        plain_password,
        hashed_password,
    )


# ==================================================
# CREATE JWT ACCESS TOKEN
# ==================================================
def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None,
) -> str:

    token_data = data.copy()

    if expires_delta is None:
        expires_delta = timedelta(
            minutes=ACCESS_TOKEN_EXPIRE_MINUTES
        )

    expire_time = (
        datetime.now(timezone.utc)
        + expires_delta
    )

    token_data.update(
        {
            # Save expiration as Unix timestamp
            "exp": int(expire_time.timestamp()),

            # Token created time
            "iat": int(
                datetime.now(
                    timezone.utc
                ).timestamp()
            ),
        }
    )

    return jwt.encode(
        token_data,
        SECRET_KEY,
        algorithm=ALGORITHM,
    )


# ==================================================
# DECODE JWT ACCESS TOKEN
# ==================================================
def decode_access_token(token: str) -> dict:

    # Remove accidental spaces
    clean_token = token.strip()

    # Remove Bearer if it was accidentally included twice
    if clean_token.lower().startswith("bearer "):
        clean_token = clean_token[7:].strip()

    try:
        return jwt.decode(
            clean_token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )

    except ExpiredSignatureError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired. Please login again.",
            headers={
                "WWW-Authenticate": "Bearer"
            },
        ) from error

    except JWTError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token. Please login again.",
            headers={
                "WWW-Authenticate": "Bearer"
            },
        ) from error


# ==================================================
# GET CURRENT LOGGED-IN USER
# ==================================================
def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(
        bearer_scheme
    ),
) -> dict:

    token = credentials.credentials

    payload = decode_access_token(token)

    email = payload.get("sub")

    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token does not contain user email",
            headers={
                "WWW-Authenticate": "Bearer"
            },
        )

    user = user_collection.find_one(
        {
            "email": email.lower()
        }
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User associated with token was not found",
            headers={
                "WWW-Authenticate": "Bearer"
            },
        )

    return user
# ==================================================
# REQUIRE ADMIN ROLE
# ==================================================
def require_admin(
    current_user: dict = Depends(
        get_current_user
    ),
) -> dict:

    role = str(current_user.get("role", "")).lower()
    if role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )

    return current_user


# ==================================================
# REQUIRE MANAGER ROLE
# ==================================================
def require_manager(
    current_user: dict = Depends(
        get_current_user
    ),
) -> dict:

    role = str(current_user.get("role", "")).lower()
    if role != "manager":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Manager access required",
        )

    return current_user


# ==================================================
# REQUIRE ADMIN OR MANAGER ROLE
# ==================================================
def require_admin_or_manager(
    current_user: dict = Depends(
        get_current_user
    ),
) -> dict:

    role = str(current_user.get("role", "")).lower()
    allowed_roles = ["admin", "manager"]

    if role not in allowed_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin or Manager access required",
        )

    return current_user