#!/usr/bin/env python
"""Test user_serializer directly"""

from config.database import db
from models.user_model import user_serializer
import json

users_collection = db['users']
user = users_collection.find_one({"email": "manager@gmail.com"})

if user:
    serialized = user_serializer(user)
    print("Serialized User:")
    print(json.dumps(serialized, indent=2, default=str))
else:
    print("User not found")
