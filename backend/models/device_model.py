def device_serializer(
    device: dict | None,
) -> dict | None:
    if device is None:
        return None

    return {
        "id": str(
            device.get(
                "_id",
                "",
            )
        ),
        "employee_id": (
            device.get(
                "employee_id"
            )
        ),
        "device_name": (
            device.get(
                "device_name"
            )
        ),
        "platform": device.get(
            "platform"
        ),
        "status": device.get(
            "status"
        ),
        "active": device.get(
            "active",
            False,
        ),
        "requested_at": (
            device.get(
                "requested_at"
            )
        ),
        "approved_at": (
            device.get(
                "approved_at"
            )
        ),
        "approved_by": (
            device.get(
                "approved_by"
            )
        ),
        "revoked_at": (
            device.get(
                "revoked_at"
            )
        ),
        "revoked_by": (
            device.get(
                "revoked_by"
            )
        ),
        "review_reason": (
            device.get(
                "review_reason"
            )
        ),
    }