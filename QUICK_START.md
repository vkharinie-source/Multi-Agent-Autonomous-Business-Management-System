# QUICK START REFERENCE

## TLDR - Get Running in 5 Minutes

### Start Backend
```bash
cd "d:\mca project\autonomous_business_ai\backend"
python seed_test_accounts.py
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

### Start Flutter (Android Emulator)
```bash
cd "d:\mca project\autonomous_business_ai"
flutter run
```

### Start Flutter (Android Physical Device - IP: 10.47.131.48)
```bash
cd "d:\mca project\autonomous_business_ai"
flutter run --dart-define=API_BASE_URL=http://10.47.131.48:8000
```

---

## Test Accounts Ready to Use

| Role | Email | Password |
|------|-------|----------|
| Manager | manager@gmail.com | Manager@123 |
| Employee | employee@gmail.com | Employee@123 |

---

## What Works Now

✅ Manager Login → Manager Dashboard
✅ Employee Login → Employee Dashboard  
✅ Wrong Password → Error Message
✅ Account Status Checking
✅ Token Storage & Restoration
✅ Role-Based Navigation
✅ Logout Functionality
✅ Android Device IP Support

---

## Files Changed (3 Total)

1. `backend/models/user_model.py` - Added is_active field
2. `backend/routes/auth_routes.py` - Added is_active check
3. `lib/core/config/api_config.dart` - Added iOS + documentation

---

## Files Created (4 Total)

1. `backend/seed_test_accounts.py` - Seed test accounts
2. `backend/check_users.py` - Check users in database
3. `backend/test_serializer.py` - Test user serializer
4. Documentation files (guides and summaries)

---

## API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /api/auth/login | User login |
| GET | /api/auth/me | Current user info |

---

## Response Example

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "role": "manager",
    "is_verified": true,
    "is_active": true
  }
}
```

---

## Troubleshooting Quick Fixes

**"Invalid credentials"** → Run: `python seed_test_accounts.py`

**"Cannot connect"** → Verify backend running: `http://127.0.0.1:8000/docs`

**"Does not have access"** → Check role lowercase: `python check_users.py`

**Physical device no connect** → Use: `--dart-define=API_BASE_URL=http://<your-ip>:8000`

---

## No Breaking Changes

- ✅ Existing code preserved
- ✅ All existing features work
- ✅ Database unchanged
- ✅ Backward compatible

---

## Documentation

| File | Purpose |
|------|---------|
| IMPLEMENTATION_COMPLETE.md | Full detailed guide |
| LOGIN_FIX_GUIDE.md | Setup & testing instructions |
| COMPLETE_FILE_CHANGES_SUMMARY.md | File change details |
| QUICK_START.md | This file - 5-minute summary |

---

## Next Steps

1. ✅ Run seed script
2. ✅ Start backend
3. ✅ Run Flutter app
4. ✅ Test manager login
5. ✅ Test employee login

**Everything else just works!**

