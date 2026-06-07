import pymysql
import os

def get_db_connection():
    connection = pymysql.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', '123456'),
        database=os.getenv('DB_NAME', 'dorm_share'),
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection
