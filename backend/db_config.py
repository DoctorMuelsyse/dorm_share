import pymysql

def get_db_connection():
    connection = pymysql.connect(
        host='localhost',
        user='root',          # 你的MySQL用户名
        password='123456',   # 你的MySQL密码
        database='dorm_share',
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection
