import hashlib
import secrets


def generate_otp() -> str:
    """
    Generate a secure 6-digit OTP.

    Example:
    483921
    """
    return str(secrets.randbelow(900000) + 100000)


def hash_otp(otp: str) -> str:
    """
    Convert the OTP into a SHA-256 hash before saving it in MongoDB.
    The plain OTP should never be stored.
    """
    return hashlib.sha256(
        otp.encode("utf-8")
    ).hexdigest()


def verify_otp(
    entered_otp: str,
    stored_otp_hash: str,
) -> bool:
    """
    Check whether the OTP entered by the user matches
    the OTP hash stored in MongoDB.
    """
    entered_otp_hash = hash_otp(entered_otp)

    return secrets.compare_digest(
        entered_otp_hash,
        stored_otp_hash,
    )