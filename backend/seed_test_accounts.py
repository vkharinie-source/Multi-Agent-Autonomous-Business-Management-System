#!/usr/bin/env python
"""
Seed script to create or update test accounts for both Manager and Employee roles.

This script creates:
1. Manager account
2. Employee account

Both with verified status and active state.
"""

from datetime import datetime, timezone
from config.database import db
from utils.security import hash_password

# ==================================================
# TEST ACCOUNTS
# ==================================================
TEST_ACCOUNTS = [
    {
        "name": "Manager User",
        "email": "manager@gmail.com",
        "password": "Manager@123",
        "role": "manager",  # lowercase for consistency
        "is_verified": True,
        "is_active": True,
        "employee_id": None,
    },
    {
        "name": "Employee User",
        "email": "employee@gmail.com",
        "password": "Employee@123",
        "role": "employee",  # lowercase for consistency
        "is_verified": True,
        "is_active": True,
        "employee_id": None,
    },
]


def seed_test_accounts():
    """Create or update test accounts in MongoDB."""
    
    users_collection = db["users"]
    current_time = datetime.now(timezone.utc).isoformat()
    
    print("\n" + "=" * 60)
    print("SEEDING TEST ACCOUNTS")
    print("=" * 60 + "\n")
    
    for account in TEST_ACCOUNTS:
        email = account["email"].lower().strip()
        
        # Check if user already exists
        existing_user = users_collection.find_one({"email": email})
        
        if existing_user:
            print(f"[OK] Updating: {email}")
            
            # Update the user
            update_result = users_collection.update_one(
                {"email": email},
                {
                    "$set": {
                        "name": account["name"],
                        "password": hash_password(account["password"]),
                        "role": account["role"].lower(),
                        "is_verified": account["is_verified"],
                        "is_active": account["is_active"],
                        "updated_at": current_time,
                    }
                }
            )
            
            if update_result.modified_count > 0:
                print(f"  -> Password updated for {email}")
                print(f"  -> Role: {account['role'].lower()}")
            else:
                print(f"  -> No changes needed for {email}")
        
        else:
            print(f"[OK] Creating: {email}")
            
            # Create the user
            user_data = {
                "name": account["name"],
                "email": email,
                "password": hash_password(account["password"]),
                "role": account["role"].lower(),
                "is_verified": account["is_verified"],
                "is_active": account["is_active"],
                "created_at": current_time,
                "updated_at": current_time,
            }
            
            if account["employee_id"]:
                user_data["employee_id"] = account["employee_id"]
            
            result = users_collection.insert_one(user_data)
            print(f"  -> Created user with ID: {result.inserted_id}")
            print(f"  -> Role: {account['role'].lower()}")
        
        print(f"  -> Email: {email}")
        print(f"  -> Verified: {account['is_verified']}")
        print(f"  -> Active: {account['is_active']}")
        print()
    
    # Verify the accounts were created/updated
    print("=" * 60)
    print("VERIFICATION")
    print("=" * 60 + "\n")
    
    for account in TEST_ACCOUNTS:
        email = account["email"].lower().strip()
        user = users_collection.find_one({"email": email})
        
        if user:
            print(f"[OK] {email}")
            print(f"  Role: {user.get('role')}")
            print(f"  Verified: {user.get('is_verified')}")
            print(f"  Active: {user.get('is_active')}")
            print()
        else:
            print(f"[FAILED] {email} was not created!")
            print()
    
    print("=" * 60)
    print("SEEDING COMPLETE")
    print("=" * 60)
    print("\nTest Credentials:")
    print("\nManager:")
    print("  Email: manager@gmail.com")
    print("  Password: Manager@123")
    print("\nEmployee:")
    print("  Email: employee@gmail.com")
    print("  Password: Employee@123")
    print()


if __name__ == "__main__":
    seed_test_accounts()
