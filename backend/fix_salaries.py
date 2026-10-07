from config.database import db

def fix_salaries():
    r1 = db["employees"].update_many(
        {"$or": [{"salary": {"$lte": 0}}, {"salary": None}, {"salary": {"$exists": False}}]},
        {"$set": {"salary": 45000.0}}
    )
    print(f"Updated {r1.modified_count} employee records to default 45000 salary.")
    
    # Check all employees
    for emp in db["employees"].find({}, {"_id": 0, "name": 1, "employee_id": 1, "email": 1, "salary": 1}):
        print(emp)

if __name__ == "__main__":
    fix_salaries()
