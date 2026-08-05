import os

from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

mongodb_uri = os.getenv("MONGODB_URI")
database_name = os.getenv("DATABASE_NAME")

if not mongodb_uri:
    raise ValueError("MONGODB_URI is missing in .env")

if not database_name:
    raise ValueError("DATABASE_NAME is missing in .env")

client = MongoClient(
    mongodb_uri,
    serverSelectionTimeoutMS=5000,
)

client.admin.command("ping")

db = client[database_name]

print("MongoDB connected successfully")