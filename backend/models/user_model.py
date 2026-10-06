from bson import ObjectId


# ==================================================
# CONVERT MONGODB DOCUMENT TO JSON
# ==================================================
def user_serializer(user) -> dict:
    return {
        "id": str(user["_id"]),
        "name": user["name"],
        "email": user["email"],
        "role": user["role"],
        "employee_id": user.get("employee_id"),
        "department": user.get("department"),
        "designation": user.get("designation"),
        "phone": user.get("phone"),
        "is_verified": user.get(
            "is_verified",
            False,
        ),
        "created_at": user.get("created_at"),
    }


# ==================================================
# CONVERT MULTIPLE USERS
# ==================================================
def user_list_serializer(users):
    return [
        user_serializer(user)
        for user in users
    ]


# ==================================================
# VALIDATE OBJECT ID
# ==================================================
def valid_object_id(id: str):
    return ObjectId.is_valid(id)