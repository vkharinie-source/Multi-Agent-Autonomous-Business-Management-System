# ==================================================
# 4. LOGIN USER - CORRECTED VERSION
# POST /api/auth/login
# ==================================================

@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(
    user: UserLogin,
):
    email = user.email.lower().strip()

    existing_user = user_collection.find_one(
        {
            "email": email,
        }
    )

    if existing_user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    # ──── VERIFY PASSWORD USING BCRYPT ────────────────────────────
    # Uses passlib which handles bcrypt verification correctly
    # Never compare plain password with hash directly
    # ───────────────────────────────────────────────────────────────
    password_correct = verify_password(
        user.password,
        existing_user["password"],
    )

    if not password_correct:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    # ──── CHECK ACCOUNT IS ACTIVE ──────────────────────────────────
    # NEW: Added is_active check
    # Prevents inactive accounts from logging in
    # ───────────────────────────────────────────────────────────────
    if not existing_user.get(
        "is_active",
        True,
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Your account is inactive. "
                "Please contact the administrator."
            ),
        )

    # ──── CHECK EMAIL IS VERIFIED ──────────────────────────────────
    # Prevents unverified accounts from logging in
    # ───────────────────────────────────────────────────────────────
    if not existing_user.get(
        "is_verified",
        False,
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Email is not verified. "
                "Please verify your OTP first."
            ),
        )

    # ──── NORMALIZE ROLE TO LOWERCASE ──────────────────────────────
    # Ensures role is consistently lowercase
    # Handles "Manager", "MANAGER", "manager" → "manager"
    # Handles "Employee", "EMPLOYEE", "employee" → "employee"
    # ───────────────────────────────────────────────────────────────
    role = str(
        existing_user.get(
            "role",
            "employee",
        )
    ).lower()

    # ──── CREATE JWT ACCESS TOKEN ──────────────────────────────────
    # Token includes user email, role, and user_id
    # Token expiration: ACCESS_TOKEN_EXPIRE_MINUTES (from .env)
    # ───────────────────────────────────────────────────────────────
    access_token = create_access_token(
        {
            "sub": existing_user["email"],
            "role": role,
            "user_id": str(
                existing_user["_id"]
            ),
            "employee_id": existing_user.get(
                "employee_id"
            ),
        }
    )

    # ──── RETURN LOGIN RESPONSE ────────────────────────────────────
    # Includes access token, token type, and user details
    # user_serializer includes: id, name, email, role, is_verified, 
    #                           is_active, created_at
    # ───────────────────────────────────────────────────────────────
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user_serializer(
            existing_user
        ),
    }
