#!/usr/bin/env python
"""Check existing users in MongoDB"""

from config.database import db

users_collection = db['users']
users = users_collection.find()

print("\n=== EXISTING USERS IN DATABASE ===\n")

for user in users:
    print(f"Email: {user.get('email', 'N/A')}")
    print(f"Role: {user.get('role', 'N/A')}")
    print(f"Name: {user.get('name', 'N/A')}")
    print(f"Is Verified: {user.get('is_verified', False)}")
    print(f"Is Active: {user.get('is_active', True)}")
    print(f"Employee ID: {user.get('employee_id', 'N/A')}")
    print("-" * 50)

print("\nTotal users:", users_collection.count_documents({}))
