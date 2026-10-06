#!/usr/bin/env python
"""Check user fields in MongoDB"""

from config.database import db

users_collection = db['users']
user = users_collection.find_one({"email": "manager@gmail.com"})

if user:
    print("Manager User Document:")
    print("-" * 50)
    for key, value in user.items():
        print(f"{key}: {value}")
else:
    print("User not found")
