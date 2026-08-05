from bson import ObjectId


# Convert one MongoDB inventory document into JSON format
def inventory_serializer(product: dict) -> dict:

    return {
        "id": str(product["_id"]),
        "product_id": product["product_id"],
        "product_name": product["product_name"],
        "category": product["category"],
        "quantity": product["quantity"],
        "price": product["price"],
        "supplier": product["supplier"],
        "reorder_level": product["reorder_level"],
        "low_stock": product.get("low_stock", False),
        "created_at": product.get("created_at"),
        "updated_at": product.get("updated_at"),
    }


# Convert multiple MongoDB inventory documents into JSON list
def inventory_list_serializer(product_list) -> list:

    return [
        inventory_serializer(product)
        for product in product_list
    ]


# Check whether MongoDB ObjectId is valid
def valid_object_id(product_id: str) -> bool:

    return ObjectId.is_valid(product_id)