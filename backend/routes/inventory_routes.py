from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query

from config.database import db
from models.inventory_model import inventory_list_serializer
from schemas.inventory_schema import (
    InventoryCreate,
    InventoryUpdate,
)
from utils.security import (
    get_current_user,
    require_admin,
    require_admin_or_manager,
)


# Create Inventory router
router = APIRouter(
    prefix="/api/inventory",
    tags=["Inventory"],
)


# MongoDB inventory collection
inventory_collection = db["inventory"]


# ==================================================
# 1. CREATE PRODUCT API
# Admin and Manager only
# POST /api/inventory
# ==================================================
@router.post("")
def create_product(
    data: InventoryCreate,
    current_user: dict = Depends(require_admin_or_manager),
):

    # Check whether product_id already exists
    existing_product = inventory_collection.find_one(
        {
            "product_id": data.product_id
        }
    )

    # Prevent duplicate product IDs
    if existing_product is not None:
        raise HTTPException(
            status_code=400,
            detail="Product ID already exists",
        )

    # Check whether stock is low
    is_low_stock = data.quantity <= data.reorder_level

    # Get current date and time
    current_time = datetime.now().strftime(
        "%Y-%m-%d %H:%M:%S"
    )

    # Create product document
    product = {
        "product_id": data.product_id,
        "product_name": data.product_name,
        "category": data.category,
        "quantity": data.quantity,
        "price": data.price,
        "supplier": data.supplier,
        "reorder_level": data.reorder_level,
        "low_stock": is_low_stock,
        "created_at": current_time,
        "updated_at": current_time,
    }

    # Insert product into MongoDB
    result = inventory_collection.insert_one(product)

    # Convert MongoDB ObjectId into string
    product["id"] = str(result.inserted_id)

    # Remove MongoDB _id field
    product.pop("_id", None)

    # Return success response
    return {
        "message": "Product created successfully",
        "product": product,
    }


# ==================================================
# 2. GET ALL PRODUCTS API
# All logged-in users
# GET /api/inventory
# ==================================================
@router.get("")
def get_all_products(
    current_user: dict = Depends(get_current_user),
):

    # Fetch all products from MongoDB
    product_records = inventory_collection.find().sort(
        "created_at",
        -1,
    )

    # Convert MongoDB documents into JSON-friendly format
    products = inventory_list_serializer(
        product_records
    )

    # Return all products
    return {
        "count": len(products),
        "products": products,
    }


# ==================================================
# 3. SEARCH PRODUCT API
# All logged-in users
# GET /api/inventory/search
# ==================================================
@router.get("/search")
def search_products(
    keyword: str = Query(...),
    current_user: dict = Depends(get_current_user),
):

    # Search by product name, category or product ID
    product_records = inventory_collection.find(
        {
            "$or": [
                {
                    "product_name": {
                        "$regex": keyword,
                        "$options": "i",
                    }
                },
                {
                    "category": {
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
            ]
        }
    )

    # Convert MongoDB documents into JSON-friendly format
    products = inventory_list_serializer(
        product_records
    )

    # Return search results
    return {
        "count": len(products),
        "products": products,
    }


# ==================================================
# 4. GET LOW-STOCK PRODUCTS API
# All logged-in users
# GET /api/inventory/low-stock
# ==================================================
@router.get("/low-stock")
def get_low_stock_products(
    current_user: dict = Depends(get_current_user),
):

    # Find products where low_stock is true
    product_records = inventory_collection.find(
        {
            "low_stock": True
        }
    ).sort(
        "quantity",
        1,
    )

    # Convert MongoDB documents into JSON-friendly format
    products = inventory_list_serializer(
        product_records
    )

    # Return low-stock products
    return {
        "count": len(products),
        "products": products,
    }


# ==================================================
# 5. GET PRODUCT BY ID API
# All logged-in users
# GET /api/inventory/{product_id}
# ==================================================
@router.get("/{product_id}")
def get_product(
    product_id: str,
    current_user: dict = Depends(get_current_user),
):

    # Find product using product_id
    product = inventory_collection.find_one(
        {
            "product_id": product_id
        }
    )

    # Return error if product not found
    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    # Convert MongoDB document into JSON-friendly format
    product_data = inventory_list_serializer(
        [product]
    )[0]

    # Return product details
    return {
        "product": product_data
    }


# ==================================================
# 6. UPDATE PRODUCT API
# Admin and Manager only
# PUT /api/inventory/{product_id}
# ==================================================
@router.put("/{product_id}")
def update_product(
    product_id: str,
    data: InventoryUpdate,
    current_user: dict = Depends(require_admin_or_manager),
):

    # Find product
    product = inventory_collection.find_one(
        {
            "product_id": product_id
        }
    )

    # Product not found
    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    # Get only fields sent by the user
    update_data = data.model_dump(
        exclude_unset=True
    )

    # Prevent empty update
    if len(update_data) == 0:
        raise HTTPException(
            status_code=400,
            detail="No update data provided",
        )

    # Update date and time
    update_data["updated_at"] = datetime.now().strftime(
        "%Y-%m-%d %H:%M:%S"
    )

    # Get updated quantity or current quantity
    quantity = update_data.get(
        "quantity",
        product["quantity"],
    )

    # Get updated reorder level or current reorder level
    reorder_level = update_data.get(
        "reorder_level",
        product["reorder_level"],
    )

    # Recalculate low-stock status
    update_data["low_stock"] = (
        quantity <= reorder_level
    )

    # Update MongoDB document
    inventory_collection.update_one(
        {
            "product_id": product_id
        },
        {
            "$set": update_data
        }
    )

    # Fetch updated product
    updated_product = inventory_collection.find_one(
        {
            "product_id": product_id
        }
    )

    # Convert MongoDB document into JSON-friendly format
    updated_product_data = inventory_list_serializer(
        [updated_product]
    )[0]

    # Return updated product
    return {
        "message": "Product updated successfully",
        "product": updated_product_data,
    }


# ==================================================
# 7. DELETE PRODUCT API
# Admin only
# DELETE /api/inventory/{product_id}
# ==================================================
@router.delete("/{product_id}")
def delete_product(
    product_id: str,
    current_user: dict = Depends(require_admin),
):

    # Find the product before deleting
    product = inventory_collection.find_one(
        {
            "product_id": product_id
        }
    )

    # Return error if product does not exist
    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    # Delete product from MongoDB
    inventory_collection.delete_one(
        {
            "product_id": product_id
        }
    )

    # Return success message
    return {
        "message": "Product deleted successfully",
        "product_id": product_id,
    }