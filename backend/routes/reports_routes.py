from datetime import datetime

from fastapi import APIRouter, Depends

from config.database import db
from models.employee_model import employee_list_serializer
from models.inventory_model import inventory_list_serializer
from models.sales_model import sales_list_serializer
from utils.security import require_admin_or_manager


# ==========================================================
# REPORTS ROUTER
# ==========================================================
router = APIRouter(
    prefix="/api/reports",
    tags=["Reports"],
)


# ==========================================================
# MONGODB COLLECTIONS
# ==========================================================
employee_collection = db["employees"]
attendance_collection = db["attendance"]
inventory_collection = db["inventory"]
sales_collection = db["sales"]


# ==========================================================
# HELPER FUNCTION
# GET TODAY DATE
# ==========================================================
def get_today_date():

    return datetime.now().strftime(
        "%Y-%m-%d"
    )


# ==========================================================
# 1. DASHBOARD SUMMARY REPORT
# Admin and Manager only
# GET /api/reports/dashboard
# ==========================================================
@router.get("/dashboard")
def get_dashboard_report(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    today = get_today_date()

    # ------------------------------------------------------
    # EMPLOYEE COUNTS
    # ------------------------------------------------------
    total_employees = employee_collection.count_documents(
        {}
    )

    active_employees = employee_collection.count_documents(
        {
            "status": {
                "$regex": "^Active$",
                "$options": "i",
            }
        }
    )

    # ------------------------------------------------------
    # ATTENDANCE COUNTS
    # ------------------------------------------------------
    today_attendance = attendance_collection.count_documents(
        {
            "$or": [
                {
                    "date": {
                        "$regex": f"^{today}"
                    }
                },
                {
                    "check_in": {
                        "$regex": f"^{today}"
                    }
                },
                {
                    "created_at": {
                        "$regex": f"^{today}"
                    }
                },
            ]
        }
    )

    late_arrivals = attendance_collection.count_documents(
        {
            "$and": [
                {
                    "$or": [
                        {
                            "date": {
                                "$regex": f"^{today}"
                            }
                        },
                        {
                            "check_in": {
                                "$regex": f"^{today}"
                            }
                        },
                        {
                            "created_at": {
                                "$regex": f"^{today}"
                            }
                        },
                    ]
                },
                {
                    "$or": [
                        {
                            "status": {
                                "$regex": "late",
                                "$options": "i",
                            }
                        },
                        {
                            "late": True
                        },
                        {
                            "is_late": True
                        },
                    ]
                },
            ]
        }
    )

    # ------------------------------------------------------
    # INVENTORY COUNTS
    # ------------------------------------------------------
    total_products = inventory_collection.count_documents(
        {}
    )

    low_stock_products = inventory_collection.count_documents(
        {
            "low_stock": True
        }
    )

    total_stock_quantity_result = list(
        inventory_collection.aggregate(
            [
                {
                    "$group": {
                        "_id": None,
                        "total_quantity": {
                            "$sum": "$quantity"
                        },
                    }
                }
            ]
        )
    )

    total_stock_quantity = 0

    if len(total_stock_quantity_result) > 0:

        total_stock_quantity = (
            total_stock_quantity_result[0].get(
                "total_quantity",
                0,
            )
        )

    # ------------------------------------------------------
    # SALES COUNTS
    # ------------------------------------------------------
    total_sales = sales_collection.count_documents(
        {}
    )

    today_sales = sales_collection.count_documents(
        {
            "sale_date": {
                "$regex": f"^{today}"
            }
        }
    )

    revenue_result = list(
        sales_collection.aggregate(
            [
                {
                    "$group": {
                        "_id": None,
                        "total_revenue": {
                            "$sum": "$total_amount"
                        },
                        "total_quantity_sold": {
                            "$sum": "$quantity"
                        },
                    }
                }
            ]
        )
    )

    total_revenue = 0
    total_quantity_sold = 0

    if len(revenue_result) > 0:

        total_revenue = revenue_result[0].get(
            "total_revenue",
            0,
        )

        total_quantity_sold = revenue_result[0].get(
            "total_quantity_sold",
            0,
        )

    today_revenue_result = list(
        sales_collection.aggregate(
            [
                {
                    "$match": {
                        "sale_date": {
                            "$regex": f"^{today}"
                        }
                    }
                },
                {
                    "$group": {
                        "_id": None,
                        "today_revenue": {
                            "$sum": "$total_amount"
                        },
                    }
                },
            ]
        )
    )

    today_revenue = 0

    if len(today_revenue_result) > 0:

        today_revenue = today_revenue_result[0].get(
            "today_revenue",
            0,
        )

    return {
        "employees": {
            "total_employees": total_employees,
            "active_employees": active_employees,
        },
        "attendance": {
            "today_attendance": today_attendance,
            "late_arrivals": late_arrivals,
        },
        "inventory": {
            "total_products": total_products,
            "total_stock_quantity": total_stock_quantity,
            "low_stock_products": low_stock_products,
        },
        "sales": {
            "total_sales": total_sales,
            "today_sales": today_sales,
            "total_quantity_sold": total_quantity_sold,
            "total_revenue": total_revenue,
            "today_revenue": today_revenue,
        },
    }


# ==========================================================
# 2. EMPLOYEE REPORT
# Admin and Manager only
# GET /api/reports/employees
# ==========================================================
@router.get("/employees")
def get_employee_report(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    total_employees = employee_collection.count_documents(
        {}
    )

    active_employees = employee_collection.count_documents(
        {
            "status": {
                "$regex": "^Active$",
                "$options": "i",
            }
        }
    )

    inactive_employees = employee_collection.count_documents(
        {
            "status": {
                "$regex": "^Inactive$",
                "$options": "i",
            }
        }
    )

    department_pipeline = [
        {
            "$group": {
                "_id": "$department",
                "employee_count": {
                    "$sum": 1
                },
            }
        },
        {
            "$sort": {
                "employee_count": -1
            }
        },
    ]

    department_records = list(
        employee_collection.aggregate(
            department_pipeline
        )
    )

    employees_by_department = []

    for record in department_records:

        employees_by_department.append(
            {
                "department": record.get(
                    "_id",
                    "Unknown",
                ),
                "employee_count": record.get(
                    "employee_count",
                    0,
                ),
            }
        )

    employee_records = employee_collection.find().sort(
        "name",
        1,
    )

    employees = employee_list_serializer(
        employee_records
    )

    return {
        "total_employees": total_employees,
        "active_employees": active_employees,
        "inactive_employees": inactive_employees,
        "employees_by_department": employees_by_department,
        "employees": employees,
    }


# ==========================================================
# 3. INVENTORY REPORT
# Admin and Manager only
# GET /api/reports/inventory
# ==========================================================
@router.get("/inventory")
def get_inventory_report(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    total_products = inventory_collection.count_documents(
        {}
    )

    low_stock_count = inventory_collection.count_documents(
        {
            "low_stock": True
        }
    )

    out_of_stock_count = inventory_collection.count_documents(
        {
            "quantity": {
                "$lte": 0
            }
        }
    )

    stock_summary = list(
        inventory_collection.aggregate(
            [
                {
                    "$group": {
                        "_id": None,
                        "total_quantity": {
                            "$sum": "$quantity"
                        },
                        "total_inventory_value": {
                            "$sum": {
                                "$multiply": [
                                    "$quantity",
                                    "$price",
                                ]
                            }
                        },
                    }
                }
            ]
        )
    )

    total_quantity = 0
    total_inventory_value = 0

    if len(stock_summary) > 0:

        total_quantity = stock_summary[0].get(
            "total_quantity",
            0,
        )

        total_inventory_value = stock_summary[0].get(
            "total_inventory_value",
            0,
        )

    category_pipeline = [
        {
            "$group": {
                "_id": "$category",
                "product_count": {
                    "$sum": 1
                },
                "total_quantity": {
                    "$sum": "$quantity"
                },
            }
        },
        {
            "$sort": {
                "product_count": -1
            }
        },
    ]

    category_records = list(
        inventory_collection.aggregate(
            category_pipeline
        )
    )

    products_by_category = []

    for record in category_records:

        products_by_category.append(
            {
                "category": record.get(
                    "_id",
                    "Unknown",
                ),
                "product_count": record.get(
                    "product_count",
                    0,
                ),
                "total_quantity": record.get(
                    "total_quantity",
                    0,
                ),
            }
        )

    low_stock_records = inventory_collection.find(
        {
            "low_stock": True
        }
    ).sort(
        "quantity",
        1,
    )

    low_stock_products = inventory_list_serializer(
        low_stock_records
    )

    return {
        "total_products": total_products,
        "total_quantity": total_quantity,
        "total_inventory_value": total_inventory_value,
        "low_stock_count": low_stock_count,
        "out_of_stock_count": out_of_stock_count,
        "products_by_category": products_by_category,
        "low_stock_products": low_stock_products,
    }


# ==========================================================
# 4. SALES REPORT
# Admin and Manager only
# GET /api/reports/sales
# ==========================================================
@router.get("/sales")
def get_sales_report(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    today = get_today_date()

    total_sales = sales_collection.count_documents(
        {}
    )

    today_sales = sales_collection.count_documents(
        {
            "sale_date": {
                "$regex": f"^{today}"
            }
        }
    )

    sales_summary = list(
        sales_collection.aggregate(
            [
                {
                    "$group": {
                        "_id": None,
                        "total_revenue": {
                            "$sum": "$total_amount"
                        },
                        "total_quantity_sold": {
                            "$sum": "$quantity"
                        },
                        "average_sale_amount": {
                            "$avg": "$total_amount"
                        },
                    }
                }
            ]
        )
    )

    total_revenue = 0
    total_quantity_sold = 0
    average_sale_amount = 0

    if len(sales_summary) > 0:

        total_revenue = sales_summary[0].get(
            "total_revenue",
            0,
        )

        total_quantity_sold = sales_summary[0].get(
            "total_quantity_sold",
            0,
        )

        average_sale_amount = sales_summary[0].get(
            "average_sale_amount",
            0,
        )

    payment_pipeline = [
        {
            "$group": {
                "_id": "$payment_method",
                "sale_count": {
                    "$sum": 1
                },
                "revenue": {
                    "$sum": "$total_amount"
                },
            }
        },
        {
            "$sort": {
                "sale_count": -1
            }
        },
    ]

    payment_records = list(
        sales_collection.aggregate(
            payment_pipeline
        )
    )

    sales_by_payment_method = []

    for record in payment_records:

        sales_by_payment_method.append(
            {
                "payment_method": record.get(
                    "_id",
                    "Unknown",
                ),
                "sale_count": record.get(
                    "sale_count",
                    0,
                ),
                "revenue": record.get(
                    "revenue",
                    0,
                ),
            }
        )

    product_pipeline = [
        {
            "$group": {
                "_id": {
                    "product_id": "$product_id",
                    "product_name": "$product_name",
                },
                "quantity_sold": {
                    "$sum": "$quantity"
                },
                "revenue": {
                    "$sum": "$total_amount"
                },
            }
        },
        {
            "$sort": {
                "quantity_sold": -1
            }
        },
        {
            "$limit": 10
        },
    ]

    product_records = list(
        sales_collection.aggregate(
            product_pipeline
        )
    )

    top_products = []

    for record in product_records:

        product_data = record.get(
            "_id",
            {},
        )

        top_products.append(
            {
                "product_id": product_data.get(
                    "product_id",
                    "",
                ),
                "product_name": product_data.get(
                    "product_name",
                    "",
                ),
                "quantity_sold": record.get(
                    "quantity_sold",
                    0,
                ),
                "revenue": record.get(
                    "revenue",
                    0,
                ),
            }
        )

    sale_records = sales_collection.find().sort(
        "created_at",
        -1,
    )

    sales = sales_list_serializer(
        sale_records
    )

    return {
        "total_sales": total_sales,
        "today_sales": today_sales,
        "total_quantity_sold": total_quantity_sold,
        "total_revenue": total_revenue,
        "average_sale_amount": round(
            average_sale_amount,
            2,
        ),
        "sales_by_payment_method": sales_by_payment_method,
        "top_products": top_products,
        "sales": sales,
    }