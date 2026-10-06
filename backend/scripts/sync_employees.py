from config.database import db
from datetime import datetime, timezone

users = list(db['users'].find())
now = datetime.now(timezone.utc).isoformat()
for u in users:
    if str(u.get('role', '')).lower() == 'employee':
        email = u.get('email')
        emp = db['employees'].find_one({'email': email})
        if not emp:
            emp_id = u.get('employee_id')
            if not emp_id:
                emp_id = f"EMP{str(u.get('_id'))[-6:].upper()}"
                db['users'].update_one({'_id': u['_id']}, {'$set': {'employee_id': emp_id}})
            new_emp = {
                'employee_id': emp_id,
                'name': u.get('name', 'Employee'),
                'email': email,
                'phone': u.get('phone', ''),
                'department': u.get('department', 'General'),
                'designation': u.get('designation', 'Employee'),
                'salary': 0.0,
                'status': 'Active',
                'created_at': now,
                'updated_at': now,
            }
            db['employees'].insert_one(new_emp)
            print(f'Linked employee: {email} ({emp_id})')
        else:
            print(f'Already linked: {email}')
print('Done!')
