# LOGIN FUNCTIONALITY - COMPLETE CORRECTION GUIDE

## Summary
The login functionality has been fixed for both Manager and Employee roles. All changes maintain backward compatibility with existing features.

---

## FILES THAT WERE CHANGED

### 1. Backend: `backend/models/user_model.py`
**Change**: Added `is_active` field to user serializer

### 2. Backend: `backend/routes/auth_routes.py`
**Change**: Added account active status check in login endpoint

### 3. Flutter: `lib/core/config/api_config.dart`
**Change**: Added iOS platform support and clarified custom base URL usage

### 4. Backend: `backend/seed_test_accounts.py` (NEW FILE)
**Created**: Script to seed test accounts with correct roles and hashed passwords

---

## BACKEND SETUP INSTRUCTIONS

### Step 1: Verify MongoDB Connection
```bash
cd "d:\mca project\autonomous_business_ai\backend"
python check_users.py
```

**Expected Output**: 
- Lists all existing users
- Shows email, role, verified status

### Step 2: Create Test Accounts
```bash
cd "d:\mca project\autonomous_business_ai\backend"
python seed_test_accounts.py
```

**Expected Output**:
```
SEEDING TEST ACCOUNTS
============================================================

✓ Updating: manager@gmail.com
  → Password updated for manager@gmail.com
  → Role: manager

✓ Creating: employee@gmail.com
  → Created user with ID: ...
  → Role: employee

SEEDING COMPLETE

Test Credentials:

Manager:
  Email: manager@gmail.com
  Password: Manager@123

Employee:
  Email: employee@gmail.com
  Password: Employee@123
```

### Step 3: Start FastAPI Backend
```bash
cd "d:\mca project\autonomous_business_ai\backend"
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

**Expected Output**:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
INFO:     Application startup complete
```

---

## BACKEND API TESTING

### Test Manager Login
```bash
$body = @{
  email="manager@gmail.com"
  password="Manager@123"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/login" `
  -Method Post `
  -Body $body `
  -ContentType "application/json" `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

**Expected Response**:
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "user": {
        "id": "...",
        "name": "Manager User",
        "email": "manager@gmail.com",
        "role": "manager",
        "is_verified": true,
        "is_active": true,
        "created_at": "..."
    }
}
```

### Test Employee Login
```bash
$body = @{
  email="employee@gmail.com"
  password="Employee@123"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/login" `
  -Method Post `
  -Body $body `
  -ContentType "application/json" `
  -UseBasicParsing

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

**Expected Response**:
- role: "employee" (not "manager")
- access_token: Valid JWT
- is_active: true
- is_verified: true

### Test Invalid Password (Should Return 401)
```bash
$body = @{
  email="employee@gmail.com"
  password="WrongPassword"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/login" `
  -Method Post `
  -Body $body `
  -ContentType "application/json" `
  -UseBasicParsing -ErrorAction SilentlyContinue

$_.Exception.Response.StatusCode
```

**Expected**:
- Status: 401 Unauthorized
- Message: "Invalid email or password"

---

## FLUTTER SETUP & TESTING

### Android Emulator (Default)
The app automatically uses `http://10.0.2.2:8000` for Android emulator.

```bash
cd "d:\mca project\autonomous_business_ai"
flutter clean
flutter pub get
flutter run
```

### Android Physical Device (Custom IP)
For your physical Android phone with laptop IP `10.47.131.48`:

```bash
cd "d:\mca project\autonomous_business_ai"
flutter clean
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://10.47.131.48:8000
```

### iOS Simulator/Physical Device
```bash
cd "d:\mca project\autonomous_business_ai"
flutter clean
flutter pub get
flutter run
```

---

## TEST SCENARIOS

### Scenario 1: Manager Login
1. Open app
2. Tap "Manager" or navigate to Manager Login screen
3. Enter:
   - Email: `manager@gmail.com`
   - Password: `Manager@123`
4. Tap "Sign In as Manager"
5. Expected: Navigate to **Manager Dashboard** (not Employee Dashboard)
6. Verify: User can access manager-only features

### Scenario 2: Employee Login
1. Open app
2. Tap "Employee" or navigate to Employee Login screen
3. Enter:
   - Email: `employee@gmail.com`
   - Password: `Employee@123`
4. Tap "Sign In as Employee"
5. Expected: Navigate to **Employee Dashboard** (not Manager Dashboard)
6. Verify: User can access employee-only features

### Scenario 3: Wrong Password
1. Enter correct email but wrong password
2. Expected: Error message "Invalid email or password"
3. User stays on login screen

### Scenario 4: Inactive Account
1. Database account with `is_active: false`
2. Try to login
3. Expected: Error message "Your account is inactive. Please contact the administrator."

### Scenario 5: Unverified Account
1. Database account with `is_verified: false`
2. Try to login
3. Expected: Error message "Email is not verified. Please verify your OTP first."

### Scenario 6: Token Storage & Restoration
1. Login successfully
2. Force close the app
3. Reopen the app
4. Expected: App restores authentication state
5. Navigate directly to appropriate dashboard (Manager or Employee)
6. No need to login again

### Scenario 7: Logout
1. Login and navigate to dashboard
2. Logout (through settings or profile menu)
3. Expected: Token cleared from secure storage
4. App returns to login/onboarding screen
5. Subsequent app opens require login again

---

## FIELD MAPPING

### Login Request Body
```json
{
  "email": "string (lowercase, trimmed)",
  "password": "string"
}
```

### Login Response Body
```json
{
  "access_token": "JWT token",
  "token_type": "bearer",
  "user": {
    "id": "MongoDB ObjectId as string",
    "name": "User's name",
    "email": "User's email (lowercase)",
    "role": "manager|employee|admin (lowercase)",
    "is_verified": "boolean",
    "is_active": "boolean",
    "created_at": "ISO 8601 timestamp"
  }
}
```

### Error Responses

#### 401 Unauthorized
```json
{
  "detail": "Invalid email or password"
}
```

#### 403 Forbidden (Inactive)
```json
{
  "detail": "Your account is inactive. Please contact the administrator."
}
```

#### 403 Forbidden (Unverified)
```json
{
  "detail": "Email is not verified. Please verify your OTP first."
}
```

---

## ROLE NORMALIZATION

All roles are normalized to lowercase in the backend and stored/compared as lowercase:

| Input | Stored As | Checked As |
|-------|-----------|-----------|
| MANAGER | manager | manager |
| Manager | manager | manager |
| manager | manager | manager |
| EMPLOYEE | employee | employee |
| Employee | employee | employee |
| employee | employee | employee |

Flutter also normalizes roles:
```dart
final String role = user['role']?.toString().trim().toLowerCase() ?? '';
```

---

## SECURE TOKEN STORAGE

### Stored By: `SecureStorageService`
- **Key**: `access_token`
- **Storage**: Flutter Secure Storage (platform-native)
- **Fallback Keys**: `auth_token`, `token` (for backward compatibility)
- **Cleared On**: Logout

### Token Usage in Authenticated Requests
```
Authorization: Bearer <access_token>
```

Implemented by `ApiService._buildHeaders()` automatically.

---

## VERIFIED ACCOUNTS

The following test accounts are available:

| Email | Password | Role | Verified | Active |
|-------|----------|------|----------|--------|
| manager@gmail.com | Manager@123 | manager | ✓ | ✓ |
| employee@gmail.com | Employee@123 | employee | ✓ | ✓ |

---

## TROUBLESHOOTING

### Manager Login Shows "Does Not Have Manager Access"
- Check response: Is role exactly "manager" (lowercase)?
- Check auth_routes.py normalization: `role = str(existing_user.get("role", "employee")).lower()`
- Check manager login screen logic: `if (role != 'manager' && role != 'admin')`
- Restart backend if code was modified

### Employee Redirected to Manager Dashboard After Login
- Check employee login screen role check
- Verify user role in database is "employee" (lowercase)
- Check RoleNavigationService switch statement

### "Account Is Inactive" Error
- Verify user document has `is_active: true`
- Run: `python check_users.py` to see is_active status
- Update with: `python seed_test_accounts.py`

### "Email Not Verified" Error
- Verify user document has `is_verified: true`
- Check `is_verified` field in user collection
- Run: `python seed_test_accounts.py` to update

### Backend Not Reflecting Code Changes
- Stop uvicorn process
- Remove Python cache: `rm -r __pycache__ *.pyc`
- Restart: `python -m uvicorn main:app --host 127.0.0.1 --port 8000`

### Flutter App Cannot Connect to Backend (Android Device)
- Use: `flutter run --dart-define=API_BASE_URL=http://10.47.131.48:8000`
- Verify laptop firewall allows port 8000 from phone
- Test from phone browser: http://10.47.131.48:8000/docs

### Token Invalid After App Restart
- Check token stored in secure storage: `SecureStorageService.readAccessToken()`
- Verify JWT expiration: `ACCESS_TOKEN_EXPIRE_MINUTES=30` in .env
- Check token format: Should start with `eyJ...`
- Re-login to get fresh token

---

## CODE SUMMARY

### Key Functions Modified

#### Backend: Login Validation
```python
# password_context.verify(password, hash) - Uses bcrypt
# user_serializer(user) - Includes is_active field
# create_access_token(data) - Creates valid JWT
# verify_password(plain, hashed) - Passlib verification
```

#### Flutter: Token Management
```dart
// SecureStorageService.saveAccessToken(token)
// SecureStorageService.readAccessToken()
// SecureStorageService.clearAuthenticationData()
```

#### Flutter: Role Routing
```dart
// Manager: role == 'manager' || role == 'admin' → Manager Dashboard
// Employee: role == 'employee' → Employee Dashboard
// Normalize: role.toString().trim().toLowerCase()
```

---

## FINAL VERIFICATION CHECKLIST

- [ ] Backend running on http://127.0.0.1:8000
- [ ] MongoDB connected and test users exist
- [ ] Manager login endpoint returns role: "manager"
- [ ] Employee login endpoint returns role: "employee"
- [ ] Invalid password returns 401
- [ ] is_active field included in all user responses
- [ ] Flutter app builds without errors
- [ ] Manager can login and navigate to Manager Dashboard
- [ ] Employee can login and navigate to Employee Dashboard
- [ ] Token stored in secure storage after login
- [ ] App restores login state after restart (if token valid)
- [ ] Logout clears token and returns to login
- [ ] API Base URL supports custom define for Android device

---

## END OF GUIDE
