from config.database import db

res = db['campuses'].update_one(
    {'campus_id': 'CAMPUS001'},
    {'$set': {
        'latitude': 11.0396,
        'longitude': 77.0743,
        'allowed_radius_meters': 5000.0,
        'maximum_gps_accuracy_meters': 500.0
    }}
)
print('Updated campus location to user GPS:', res.modified_count)
