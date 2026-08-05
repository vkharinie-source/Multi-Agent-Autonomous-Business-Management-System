import hashlib
import secrets
from datetime import datetime, timedelta, timezone


OTP_LENGTH = 6
OTP_EXPIRY_MINUTES = 5


def generate_reset_otp() -> str:
    return "".join(
        str(secrets.randbelow(10))
        for _ in range(OTP_LENGTH)
    )


def hash_reset_otp(
    otp: str,
) -> str:
    return hashlib.sha256(
        otp.strip().encode("utf-8")
    ).hexdigest()


def verify_reset_otp(
    plain_otp: str,
    hashed_otp: str,
) -> bool:
    entered_hash = hash_reset_otp(
        plain_otp
    )

    return secrets.compare_digest(
        entered_hash,
        hashed_otp,
    )


def get_reset_otp_expiry() -> datetime:
    return (
        datetime.now(timezone.utc)
        + timedelta(
            minutes=OTP_EXPIRY_MINUTES
        )
    )


def is_reset_otp_expired(
    expiry_time: datetime,
) -> bool:
    if expiry_time is None:
        return True

    if expiry_time.tzinfo is None:
        expiry_time = expiry_time.replace(
            tzinfo=timezone.utc
        )

    return (
        datetime.now(timezone.utc)
        > expiry_time
    )