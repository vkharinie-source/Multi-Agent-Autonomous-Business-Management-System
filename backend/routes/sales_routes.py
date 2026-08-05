from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from pymongo import ReturnDocument

from config.database import db
from models.sales_model import (
    sales_list_serializer,
    sales_serializer,
)
from schemas.sales_schema import (
    SalesCreate,
    SalesUpdate,
)
from utils.security import (
    require_admin,
    require_admin_or_manager,
)


# ==========================================================
# SALES ROUTER
# ==========================================================
router = APIRouter(
    prefix="/api/sales",
    tags=["Sales"],
)


# ==========================================================
# MONGODB COLLECTIONS
# ==========================================================
sales_collection = db["sales"]
inventory_collection = db["inventory"]


# ==========================================================
# HELPER FUNCTION
# CURRENT DATE AND TIME
# ==========================================================
def get_current_time():

    return datetime.now().strftime(
        "%Y-%m-%d %H:%M:%S"
    )


# ==========================================================
# HELPER FUNCTION
# UPDATE LOW-STOCK STATUS
# ==========================================================
def update_low_stock_status(product_id: str):

    product = inventory_collection.find_one(
        {
            "product_id": product_id
        }
    )

    if product is None:
        return

    quantity = product.get("quantity", 0)
    reorder_level = product.get("reorder_level", 0)

    low_stock = quantity <= reorder_level

    inventory_collection.update_one(
        {
            "product_id": product_id
        },
        {
            "$set": {
                "low_stock": low_stock,
                "updated_at": get_current_time(),
            }
        },
    )


# ==========================================================
# 1. CREATE SALE API
# Admin and Manager only
# POST /api/sales
# ==========================================================
@router.post("")
def create_sale(
    data: SalesCreate,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    # Convert schema data into dictionary
    sale_data = data.model_dump()

    # ------------------------------------------------------
    # Check duplicate sale ID
    # ------------------------------------------------------
    existing_sale = sales_collection.find_one(
        {
            "sale_id": sale_data["sale_id"]
        }
    )

    if existing_sale is not None:
        raise HTTPException(
            status_code=400,
            detail="Sale ID already exists",
        )

    # ------------------------------------------------------
    # Find product in inventory
    # ------------------------------------------------------
    product = inventory_collection.find_one(
        {
            "product_id": sale_data["product_id"]
        }
    )

    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found in inventory",
        )

    # ------------------------------------------------------
    # Check requested quantity
    # ------------------------------------------------------
    requested_quantity = sale_data["quantity"]
    available_quantity = product.get(
        "quantity",
        0,
    )

    if available_quantity < requested_quantity:
        raise HTTPException(
            status_code=400,
            detail=(
                "Insufficient stock. "
                f"Available quantity: {available_quantity}"
            ),
        )

    # ------------------------------------------------------
    # Get product information
    # ------------------------------------------------------
    product_name = product.get(
        "product_name",
        "",
    )

    unit_price = product.get(
        "price",
        0,
    )

    # Calculate total amount
    total_amount = (
        requested_quantity * unit_price
    )

    current_time = get_current_time()

    # ------------------------------------------------------
    # Create sales document
    # ------------------------------------------------------
    new_sale = {
        "sale_id": sale_data["sale_id"],
        "customer_name": sale_data["customer_name"],
        "product_id": sale_data["product_id"],
        "product_name": product_name,
        "quantity": requested_quantity,
        "unit_price": unit_price,
        "total_amount": total_amount,
        "payment_method": sale_data["payment_method"],
        "status": sale_data["status"],
        "sale_date": current_time,
        "created_at": current_time,
        "updated_at": current_time,
    }

    # ------------------------------------------------------
    # Reduce stock only when enough quantity exists
    # ------------------------------------------------------
    stock_update_result = inventory_collection.update_one(
        {
            "product_id": sale_data["product_id"],
            "quantity": {
                "$gte": requested_quantity
            },
        },
        {
            "$inc": {
                "quantity": -requested_quantity
            },
            "$set": {
                "updated_at": current_time
            },
        },
    )

    # Another sale may have changed the stock
    if stock_update_result.modified_count == 0:

        latest_product = inventory_collection.find_one(
            {
                "product_id": sale_data["product_id"]
            }
        )

        latest_quantity = 0

        if latest_product is not None:
            latest_quantity = latest_product.get(
                "quantity",
                0,
            )

        raise HTTPException(
            status_code=400,
            detail=(
                "Insufficient stock. "
                f"Available quantity: {latest_quantity}"
            ),
        )

    try:

        # Insert sale into MongoDB
        result = sales_collection.insert_one(
            new_sale
        )

    except Exception as error:

        # Restore inventory when sale insertion fails
        inventory_collection.update_one(
            {
                "product_id": sale_data["product_id"]
            },
            {
                "$inc": {
                    "quantity": requested_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        update_low_stock_status(
            sale_data["product_id"]
        )

        raise HTTPException(
            status_code=500,
            detail="Unable to create sale",
        ) from error

    # Recalculate low-stock status
    update_low_stock_status(
        sale_data["product_id"]
    )

    # Fetch created sale
    created_sale = sales_collection.find_one(
        {
            "_id": result.inserted_id
        }
    )

    return {
        "message": "Sale created successfully",
        "sale": sales_serializer(
            created_sale
        ),
    }


# ==========================================================
# 2. GET ALL SALES API
# Admin and Manager only
# GET /api/sales
# ==========================================================
@router.get("")
def get_all_sales(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    sale_records = sales_collection.find().sort(
        "created_at",
        -1,
    )

    sales = sales_list_serializer(
        sale_records
    )

    return {
        "count": len(sales),
        "sales": sales,
    }


# ==========================================================
# 3. SEARCH SALES API
# Admin and Manager only
# GET /api/sales/search?keyword=...
#
# This route must come before /{sale_id}
# ==========================================================
@router.get("/search")
def search_sales(
    keyword: str = Query(
        ...,
        min_length=1,
        description=(
            "Search by sale ID, customer, "
            "product, payment method or status"
        ),
    ),
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    sale_records = sales_collection.find(
        {
            "$or": [
                {
                    "sale_id": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
                {
                    "customer_name": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
                {
                    "product_id": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
                {
                    "product_name": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
                {
                    "payment_method": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
                {
                    "status": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
            ]
        }
    ).sort(
        "created_at",
        -1,
    )

    sales = sales_list_serializer(
        sale_records
    )

    return {
        "count": len(sales),
        "sales": sales,
    }


# ==========================================================
# 4. SALES SUMMARY API
# Admin and Manager only
# GET /api/sales/summary
#
# This route must come before /{sale_id}
# ==========================================================
@router.get("/summary")
def get_sales_summary(
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    pipeline = [
        {
            "$group": {
                "_id": None,
                "total_sales": {
                    "$sum": 1
                },
                "total_quantity_sold": {
                    "$sum": "$quantity"
                },
                "total_revenue": {
                    "$sum": "$total_amount"
                },
            }
        }
    ]

    summary_records = list(
        sales_collection.aggregate(
            pipeline
        )
    )

    if len(summary_records) == 0:
        return {
            "total_sales": 0,
            "total_quantity_sold": 0,
            "total_revenue": 0,
        }

    summary = summary_records[0]

    return {
        "total_sales": summary.get(
            "total_sales",
            0,
        ),
        "total_quantity_sold": summary.get(
            "total_quantity_sold",
            0,
        ),
        "total_revenue": summary.get(
            "total_revenue",
            0,
        ),
    }


# ==========================================================
# 5. GET SALE BY SALE ID API
# Admin and Manager only
# GET /api/sales/{sale_id}
# ==========================================================
@router.get("/{sale_id}")
def get_sale(
    sale_id: str,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    sale = sales_collection.find_one(
        {
            "sale_id": sale_id
        }
    )

    if sale is None:
        raise HTTPException(
            status_code=404,
            detail="Sale not found",
        )

    return {
        "sale": sales_serializer(
            sale
        )
    }


# ==========================================================
# 6. UPDATE SALE API
# Admin and Manager only
# PUT /api/sales/{sale_id}
# ==========================================================
@router.put("/{sale_id}")
def update_sale(
    sale_id: str,
    data: SalesUpdate,
    current_user: dict = Depends(
        require_admin_or_manager
    ),
):

    # ------------------------------------------------------
    # Find existing sale
    # ------------------------------------------------------
    existing_sale = sales_collection.find_one(
        {
            "sale_id": sale_id
        }
    )

    if existing_sale is None:
        raise HTTPException(
            status_code=404,
            detail="Sale not found",
        )

    # Get only fields sent by user
    update_data = data.model_dump(
        exclude_unset=True
    )

    if len(update_data) == 0:
        raise HTTPException(
            status_code=400,
            detail="No update data provided",
        )

    old_product_id = existing_sale["product_id"]
    old_quantity = existing_sale["quantity"]

    new_product_id = update_data.get(
        "product_id",
        old_product_id,
    )

    new_quantity = update_data.get(
        "quantity",
        old_quantity,
    )

    current_time = get_current_time()

    # ------------------------------------------------------
    # Find old product
    # ------------------------------------------------------
    old_product = inventory_collection.find_one(
        {
            "product_id": old_product_id
        }
    )

    if old_product is None:
        raise HTTPException(
            status_code=404,
            detail="Original product not found in inventory",
        )

    # ------------------------------------------------------
    # Restore old sale quantity
    # ------------------------------------------------------
    inventory_collection.update_one(
        {
            "product_id": old_product_id
        },
        {
            "$inc": {
                "quantity": old_quantity
            },
            "$set": {
                "updated_at": current_time
            },
        },
    )

    # ------------------------------------------------------
    # Find new product after old stock restoration
    # ------------------------------------------------------
    new_product = inventory_collection.find_one(
        {
            "product_id": new_product_id
        }
    )

    if new_product is None:

        # Rollback: remove restored old quantity
        inventory_collection.update_one(
            {
                "product_id": old_product_id
            },
            {
                "$inc": {
                    "quantity": -old_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        update_low_stock_status(
            old_product_id
        )

        raise HTTPException(
            status_code=404,
            detail="Updated product not found in inventory",
        )

    available_quantity = new_product.get(
        "quantity",
        0,
    )

    # ------------------------------------------------------
    # Check whether new quantity is available
    # ------------------------------------------------------
    if available_quantity < new_quantity:

        # Rollback original inventory
        inventory_collection.update_one(
            {
                "product_id": old_product_id
            },
            {
                "$inc": {
                    "quantity": -old_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        update_low_stock_status(
            old_product_id
        )

        raise HTTPException(
            status_code=400,
            detail=(
                "Insufficient stock. "
                f"Available quantity: {available_quantity}"
            ),
        )

    # ------------------------------------------------------
    # Reduce stock for updated sale
    # ------------------------------------------------------
    stock_update_result = inventory_collection.update_one(
        {
            "product_id": new_product_id,
            "quantity": {
                "$gte": new_quantity
            },
        },
        {
            "$inc": {
                "quantity": -new_quantity
            },
            "$set": {
                "updated_at": current_time
            },
        },
    )

    if stock_update_result.modified_count == 0:

        # Rollback original inventory
        inventory_collection.update_one(
            {
                "product_id": old_product_id
            },
            {
                "$inc": {
                    "quantity": -old_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        update_low_stock_status(
            old_product_id
        )

        raise HTTPException(
            status_code=400,
            detail="Unable to reserve updated stock",
        )

    # ------------------------------------------------------
    # Calculate updated sale information
    # ------------------------------------------------------
    product_name = new_product.get(
        "product_name",
        "",
    )

    unit_price = new_product.get(
        "price",
        0,
    )

    total_amount = (
        new_quantity * unit_price
    )

    complete_update_data = {
        **update_data,
        "product_id": new_product_id,
        "product_name": product_name,
        "quantity": new_quantity,
        "unit_price": unit_price,
        "total_amount": total_amount,
        "updated_at": current_time,
    }

    try:

        # Update sale document
        updated_sale = sales_collection.find_one_and_update(
            {
                "sale_id": sale_id
            },
            {
                "$set": complete_update_data
            },
            return_document=ReturnDocument.AFTER,
        )

    except Exception as error:

        # Restore newly deducted stock
        inventory_collection.update_one(
            {
                "product_id": new_product_id
            },
            {
                "$inc": {
                    "quantity": new_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        # Deduct old stock again
        inventory_collection.update_one(
            {
                "product_id": old_product_id
            },
            {
                "$inc": {
                    "quantity": -old_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        update_low_stock_status(
            old_product_id
        )

        update_low_stock_status(
            new_product_id
        )

        raise HTTPException(
            status_code=500,
            detail="Unable to update sale",
        ) from error

    # Recalculate low-stock status
    update_low_stock_status(
        old_product_id
    )

    if new_product_id != old_product_id:
        update_low_stock_status(
            new_product_id
        )

    return {
        "message": "Sale updated successfully",
        "sale": sales_serializer(
            updated_sale
        ),
    }


# ==========================================================
# 7. DELETE SALE API
# Admin only
# DELETE /api/sales/{sale_id}
# ==========================================================
@router.delete("/{sale_id}")
def delete_sale(
    sale_id: str,
    current_user: dict = Depends(
        require_admin
    ),
):

    # Find sale before deleting
    sale = sales_collection.find_one(
        {
            "sale_id": sale_id
        }
    )

    if sale is None:
        raise HTTPException(
            status_code=404,
            detail="Sale not found",
        )

    product_id = sale["product_id"]
    sold_quantity = sale["quantity"]
    current_time = get_current_time()

    # ------------------------------------------------------
    # Restore sold quantity to inventory
    # ------------------------------------------------------
    product = inventory_collection.find_one(
        {
            "product_id": product_id
        }
    )

    if product is not None:

        inventory_collection.update_one(
            {
                "product_id": product_id
            },
            {
                "$inc": {
                    "quantity": sold_quantity
                },
                "$set": {
                    "updated_at": current_time
                },
            },
        )

        update_low_stock_status(
            product_id
        )

    # Delete sale
    sales_collection.delete_one(
        {
            "sale_id": sale_id
        }
    )

    return {
        "message": "Sale deleted successfully",
        "sale_id": sale_id,
    }
