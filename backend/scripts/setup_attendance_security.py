from config.database import db


def main() -> None:
    attendance_collection = db[
        "attendance"
    ]

    attendance_event_collection = db[
        "attendance_events"
    ]

    session_collection = db[
        "attendance_sessions"
    ]

    campus_collection = db[
        "campuses"
    ]

    device_collection = db[
        "employee_devices"
    ]

    audit_collection = db[
        "attendance_audit_logs"
    ]

    attendance_collection.create_index(
        [
            ("employee_id", 1),
            ("date", 1),
        ],
        unique=True,
        name=(
            "unique_daily_attendance"
        ),
    )

    attendance_event_collection.create_index(
        [
            ("employee_id", 1),
            ("session_id", 1),
            ("attendance_type", 1),
        ],
        unique=True,
        name=(
            "unique_employee_session_event"
        ),
    )

    session_collection.create_index(
        "session_id",
        unique=True,
        name=(
            "unique_attendance_session_id"
        ),
    )

    session_collection.create_index(
        [
            ("active", 1),
            (
                "closes_at_timestamp",
                1,
            ),
        ],
        name=(
            "active_attendance_sessions"
        ),
    )

    campus_collection.create_index(
        "campus_id",
        unique=True,
        name="unique_campus_id",
    )

    device_collection.create_index(
        [
            ("employee_id", 1),
            ("device_hash", 1),
        ],
        unique=True,
        name=(
            "unique_employee_device"
        ),
    )

    audit_collection.create_index(
        [
            ("employee_id", 1),
            ("timestamp", -1),
        ],
        name=(
            "employee_audit_timeline"
        ),
    )

    print(
        "Secure attendance indexes created."
    )


if __name__ == "__main__":
    main()