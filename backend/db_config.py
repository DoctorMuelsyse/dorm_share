import pymysql
import os
import re

def get_db_connection():
    # 优先使用 MYSQL_PUBLIC_URL 环境变量（Railway 公网连接）
    mysql_url = os.getenv('MYSQL_PUBLIC_URL')
    if mysql_url:
        # 解析 mysql://user:pass@host:port/dbname 格式
        match = re.match(r'mysql://([^:]+):([^@]+)@([^:]+):(\d+)/(.+)', mysql_url)
        if match:
            user, password, host, port, database = match.groups()
            connection = pymysql.connect(
                host=host,
                user=user,
                password=password,
                database=database,
                port=int(port),
                cursorclass=pymysql.cursors.DictCursor
            )
            return connection
    
    # 本地开发环境使用单独的环境变量或默认值
    connection = pymysql.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', '123456'),
        database=os.getenv('DB_NAME', 'dorm_share'),
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection
