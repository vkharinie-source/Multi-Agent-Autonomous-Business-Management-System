from bson import ObjectId
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from pymongo.errors import DuplicateKeyError

from config.database import db
from models.employee_model import (
    employee_list_serializer,
    employee_serializer,
    valid_object_id,
)
from schemas.employee_schema import (
    EmployeeCreate,
    EmployeeUpdate,
)
from utils.security import (
    require_admin,
    require_admin_or_manager,
)


router = APIRouter(
    prefix="/api/employees",
    tags=["Employees"],
)


employee_collection = db["employees"]


employee_collection.create_index(
    "employee_id",
    unique=True,
)

employee_collection.create_index(
    "email",
    unique=True,
)


# ==================================================
# CREATE EMPLOYEE
# Admin or Manager only
# ==================================================
@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
)
def create_employee(
    employee: EmployeeCreate,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    employee_data = employee.model_dump()

    existing = employee_collection.find_one({
        "$or": [
            {"employee_id": employee_data.get("employee_id")},
            {"email": employee_data.get("email")}
        ]
    })

    if existing:
        employee_collection.update_one(
            {"_id": existing["_id"]},
            {"$set": employee_data}
        )
        updated_emp = employee_collection.find_one({"_id": existing["_id"]})
        return {
            "message": "Employee updated successfully",
            "employee": employee_serializer(updated_emp),
        }

    try:
        result = employee_collection.insert_one(
            employee_data
        )

    except DuplicateKeyError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Employee ID or email already exists",
        ) from error

    created_employee = employee_collection.find_one(
        {
            "_id": result.inserted_id
        }
    )

    return {
        "message": "Employee created successfully",
        "employee": employee_serializer(
            created_employee
        ),
    }


# ==================================================
# GET ALL EMPLOYEES
# Admin or Manager only
# ==================================================
@router.get("")
def get_all_employees(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    employees = employee_collection.find().sort(
        "name",
        1,
    )

    data = employee_list_serializer(
        employees
    )

    return {
        "count": len(data),
        "employees": data,
    }


# ==================================================
# SEARCH EMPLOYEES
# Admin or Manager only
# ==================================================
@router.get("/search")
def search_employees(
    query: str,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    employees = employee_collection.find(
        {
            "$or": [
                {
                    "name": {
                        "$regex": query,
                        "$options": "i",
                    }
                },
                {
                    "employee_id": {
                        "$regex": query,
                        "$options": "i",
                    }
                },
                {
                    "email": {
                        "$regex": query,
                        "$options": "i",
                    }
                },
                {
                    "department": {
                        "$regex": query,
                        "$options": "i",
                    }
                },
                {
                    "designation": {
                        "$regex": query,
                        "$options": "i",
                    }
                },
            ]
        }
    ).sort(
        "name",
        1,
    )

    data = employee_list_serializer(
        employees
    )

    return {
        "count": len(data),
        "employees": data,
    }


# ==================================================
# GET ONE EMPLOYEE
# Admin or Manager only
# ==================================================
@router.get("/{employee_id}")
def get_employee(
    employee_id: str,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    if not valid_object_id(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID",
        )

    employee = employee_collection.find_one(
        {
            "_id": ObjectId(employee_id)
        }
    )

    if employee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found",
        )

    return {
        "employee": employee_serializer(
            employee
        )
    }


# ==================================================
# UPDATE EMPLOYEE
# Admin or Manager only
# ==================================================
@router.put("/{employee_id}")
def update_employee(
    employee_id: str,
    employee: EmployeeUpdate,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):
    query = (
        {"_id": ObjectId(employee_id)}
        if valid_object_id(employee_id)
        else {"$or": [{"employee_id": employee_id}, {"email": employee_id}]}
    )

    update_data = employee.model_dump(
        exclude_none=True
    )

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields supplied for update",
        )

    try:
        result = employee_collection.update_one(
            query,
            {
                "$set": update_data
            },
        )

    except DuplicateKeyError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Employee email already exists",
        ) from error

    if result.matched_count == 0:
        # If not matched yet, upsert or return 404
        update_data["employee_id"] = employee_id
        employee_collection.update_one(
            {"employee_id": employee_id},
            {"$set": update_data},
            upsert=True
        )

    updated_employee = employee_collection.find_one(query) or employee_collection.find_one({"employee_id": employee_id})

    return {
        "message": "Employee updated successfully",
        "employee": employee_serializer(
            updated_employee
        ),
    }


# ==================================================
# DELETE EMPLOYEE
# Admin only
# ==================================================
@router.delete("/{employee_id}")
def delete_employee(
    employee_id: str,
    current_user: dict = Depends(
        require_admin
    ),
):
    if not valid_object_id(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID",
        )

    result = employee_collection.delete_one(
        {
            "_id": ObjectId(employee_id)
        }
    )

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found",
        )

    return {
        "message": "Employee deleted successfully"
    }