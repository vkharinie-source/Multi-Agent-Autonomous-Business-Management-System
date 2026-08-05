from bson import ObjectId


def employee_serializer(employee: dict) -> dict:
    return {
        "id": str(employee["_id"]),
        "employee_id": employee["employee_id"],
        "name": employee["name"],
        "email": employee["email"],
        "phone": employee["phone"],
        "department": employee["department"],
        "designation": employee["designation"],
        "salary": employee["salary"],
        "status": employee.get("status", "Active"),
    }


def employee_list_serializer(employees) -> list:
    return [
        employee_serializer(employee)
        for employee in employees
    ]


def valid_object_id(employee_id: str) -> bool:
    return ObjectId.is_valid(employee_id)