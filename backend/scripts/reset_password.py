import sys
import os

os.chdir(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ".")

from config.database import db
from utils.security import hash_password
from datetime import datetime, timezone

now = datetime.now(timezone.utc).isoformat()

# Reset password for admin@autonomousbusiness.ai
new_hash = hash_password("admin123")
result = db["users"].update_one(
    {"email": "admin@autonomousbusiness.ai"},
    {
        "$set": {
            "password": new_hash,
            "is_verified": True,
            "is_active": True,
            "verified_at": now,
        }
    },
)

print(f"Matched: {result.matched_count}")
print(f"Modified: {result.modified_count}")
print("Password for admin@autonomousbusiness.ai has been reset to: admin123")
