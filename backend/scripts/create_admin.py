from datetime import datetime, timezone
from getpass import getpass

from pymongo.errors import DuplicateKeyError

from config.database import db
from utils.security import hash_password


user_collection = db["users"]


def normalize_email(value: str) -> str:
    return value.strip().lower()


def get_current_time() -> str:
    return datetime.now(timezone.utc).isoformat()


def main() -> None:
    print("=" * 50)
    print("CREATE AUTONOMOUS BUSINESS AI ADMIN")
    print("=" * 50)

    name = input("Admin name: ").strip()
    email = normalize_email(
        input("Admin email: ")
    )

    if len(name) < 2:
        print("ERROR: Admin name must contain at least 2 characters.")
        return

    if (
        not email
        or "@" not in email
        or "." not in email.split("@")[-1]
    ):
        print("ERROR: Enter a valid email address.")
        return

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is not None:
        existing_role = str(
            existing_user.get(
                "role",
                "unknown",
            )
        )

        print(
            "ERROR: An account already exists "
            f"for {email} with role '{existing_role}'."
        )
        print(
            "Use a different email address "
            "for the Admin account."
        )
        return

    password = getpass(
        "Admin password: "
    )

    confirm_password = getpass(
        "Confirm admin password: "
    )

    if len(password) < 6:
        print(
            "ERROR: Password must contain "
            "at least 6 characters."
        )
        return

    if len(password) > 100:
        print(
            "ERROR: Password cannot exceed "
            "100 characters."
        )
        return

    if password != confirm_password:
        print("ERROR: Passwords do not match.")
        return

    now = get_current_time()

    admin_document = {
        "name": name,
        "email": email,
        "password": hash_password(
            password
        ),
        "role": "admin",
        "is_verified": True,
        "is_active": True,
        "verified_at": now,
        "created_at": now,
        "updated_at": now,
    }

    try:
        result = user_collection.insert_one(
            admin_document
        )

    except DuplicateKeyError:
        print(
            "ERROR: This email is already registered."
        )
        return

    print()
    print("Admin account created successfully.")
    print(f"Admin ID: {result.inserted_id}")
    print(f"Admin email: {email}")
    print("Role: admin")
    print("Verified: True")
    print("Active: True")


if __name__ == "__main__":
    main()