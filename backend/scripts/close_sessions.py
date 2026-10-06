from config.database import db

res = db['attendance_sessions'].update_many({}, {'$set': {'active': False}})
print('Closed sessions count:', res.modified_count)
