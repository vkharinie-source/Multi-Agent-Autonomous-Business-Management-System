def attendance_serializer(
    attendance: dict | None,
) -> dict | None:
    if attendance is None:
        return None

    return {
        "id": str(
            attendance.get(
                "_id",
                "",
            )
        ),
        "employee_id": (
            attendance.get(
                "employee_id"
            )
        ),
        "employee_name": (
            attendance.get(
                "employee_name"
            )
        ),
        "department": (
            attendance.get(
                "department"
            )
        ),
        "designation": (
            attendance.get(
                "designation"
            )
        ),
        "company_id": (
            attendance.get(
                "company_id"
            )
        ),
        "campus_id": (
            attendance.get(
                "campus_id"
            )
        ),
        "date": attendance.get(
            "date"
        ),
        "check_in": attendance.get(
            "check_in"
        ),
        "check_in_at": (
            attendance.get(
                "check_in_at"
            )
        ),
        "check_out": (
            attendance.get(
                "check_out"
            )
        ),
        "check_out_at": (
            attendance.get(
                "check_out_at"
            )
        ),
        "status": attendance.get(
            "status"
        ),
        "late": attendance.get(
            "late",
            False,
        ),
        "working_hours": (
            attendance.get(
                "working_hours",
                0,
            )
        ),
        "qr_verified": (
            attendance.get(
                "qr_verified",
                False,
            )
        ),
        "location_verified": (
            attendance.get(
                "location_verified",
                False,
            )
        ),
        "device_verified": (
            attendance.get(
                "device_verified",
                False,
            )
        ),
        "mock_location_detected": (
            attendance.get(
                "mock_location_detected",
                False,
            )
        ),
        "distance_from_company_meters": (
            attendance.get(
                "distance_from_company_meters"
            )
        ),
        "location_accuracy_meters": (
            attendance.get(
                "location_accuracy_meters"
            )
        ),
        "source": attendance.get(
            "source"
        ),
        "created_at": (
            attendance.get(
                "created_at"
            )
        ),
        "updated_at": (
            attendance.get(
                "updated_at"
            )
        ),
    }


def attendance_list_serializer(
    attendance_list,
) -> list:
    return [
        attendance_serializer(
            attendance
        )
        for attendance
        in attendance_list
    ]


def attendance_event_serializer(
    event: dict | None,
) -> dict | None:
    if event is None:
        return None

    return {
        "id": str(
            event.get(
                "_id",
                "",
            )
        ),
        "employee_id": (
            event.get(
                "employee_id"
            )
        ),
        "employee_name": (
            event.get(
                "employee_name"
            )
        ),
        "session_id": (
            event.get(
                "session_id"
            )
        ),
        "attendance_type": (
            event.get(
                "attendance_type"
            )
        ),
        "recorded_at": (
            event.get(
                "recorded_at"
            )
        ),
        "status": event.get(
            "status"
        ),
        "qr_verified": (
            event.get(
                "qr_verified",
                False,
            )
        ),
        "location_verified": (
            event.get(
                "location_verified",
                False,
            )
        ),
        "device_verified": (
            event.get(
                "device_verified",
                False,
            )
        ),
        "distance_from_company_meters": (
            event.get(
                "distance_from_company_meters"
            )
        ),
        "location_accuracy_meters": (
            event.get(
                "location_accuracy_meters"
            )
        ),
    }