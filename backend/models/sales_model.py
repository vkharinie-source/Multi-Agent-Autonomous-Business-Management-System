from bson import ObjectId


# ==================================================
# CONVERT ONE SALES DOCUMENT INTO JSON
# ==================================================
def sales_serializer(sale: dict) -> dict:

    return {
        "id": str(sale["_id"]),
        "sale_id": sale["sale_id"],
        "customer_name": sale["customer_name"],
        "product_id": sale["product_id"],
        "product_name": sale["product_name"],
        "quantity": sale["quantity"],
        "unit_price": sale["unit_price"],
        "total_amount": sale["total_amount"],
        "payment_method": sale["payment_method"],
        "status": sale["status"],
        "sale_date": sale["sale_date"],
        "created_at": sale["created_at"],
        "updated_at": sale["updated_at"],
    }


# ==================================================
# CONVERT MULTIPLE SALES DOCUMENTS INTO JSON
# ==================================================
def sales_list_serializer(sales_list) -> list:

    return [
        sales_serializer(sale)
        for sale in sales_list
    ]


# ==================================================
# CHECK VALID MONGODB OBJECT ID
# ==================================================
def valid_object_id(sale_id: str) -> bool:

    return ObjectId.is_valid(sale_id)