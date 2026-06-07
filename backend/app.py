from flask import Flask, request, jsonify
from flask_cors import CORS
import pymysql
from datetime import datetime

app = Flask(__name__)
CORS(app)

from db_config import get_db_connection


# ==================== 用户管理API ====================

# 用户登录
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    user_id = data.get('user_id')
    password = data.get('password')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT user_id, name, role, credit_score FROM users WHERE user_id=%s AND password=%s",
        (user_id, password)
    )
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if user:
        return jsonify({'code': 200, 'data': user, 'message': '登录成功'})
    else:
        return jsonify({'code': 401, 'message': '账号或密码错误'})


# 用户注册
@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    user_id = data.get('user_id')
    name = data.get('name')
    password = data.get('password')
    dorm_building = data.get('dorm_building')
    dorm_room = data.get('dorm_room')
    phone = data.get('phone')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # 检查学号是否已存在
    cursor.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
    if cursor.fetchone():
        cursor.close()
        conn.close()
        return jsonify({'code': 400, 'message': '学号已存在'})
    
    try:
        cursor.execute("""
            INSERT INTO users (user_id, name, password, dorm_building, dorm_room, phone, credit_score, role) 
            VALUES (%s, %s, %s, %s, %s, %s, 100, 'student')
        """, (user_id, name, password, dorm_building, dorm_room, phone))
        conn.commit()
        return jsonify({'code': 200, 'message': '注册成功'})
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)})
    finally:
        cursor.close()
        conn.close()


# 获取个人信息
@app.route('/api/user/<user_id>', methods=['GET'])
def get_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT user_id, name, dorm_building, dorm_room, phone, credit_score FROM users WHERE user_id=%s",
        (user_id,)
    )
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if user:
        return jsonify({'code': 200, 'data': user})
    else:
        return jsonify({'code': 404, 'message': '用户不存在'})


# 修改个人信息
@app.route('/api/user/<user_id>', methods=['PUT'])
def update_user(user_id):
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "UPDATE users SET phone=%s, dorm_room=%s WHERE user_id=%s",
        (data.get('phone'), data.get('dorm_room'), user_id)
    )
    conn.commit()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'message': '修改成功'})


# ==================== 物品管理API ====================

# 获取物品列表（支持搜索）
@app.route('/api/items', methods=['GET'])
def get_items():
    status = request.args.get('status', 'available')
    keyword = request.args.get('keyword', '')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if keyword:
        sql = """
            SELECT i.item_id, i.name, i.description, i.daily_rent, i.deposit, i.status,
                   u.name as owner_name, u.dorm_building
            FROM items i
            JOIN users u ON i.owner_id = u.user_id
            WHERE i.status = %s 
              AND (i.name LIKE %s OR i.description LIKE %s)
        """
        cursor.execute(sql, (status, f'%{keyword}%', f'%{keyword}%'))
    else:
        sql = """
            SELECT i.item_id, i.name, i.description, i.daily_rent, i.deposit, i.status,
                   u.name as owner_name, u.dorm_building
            FROM items i
            JOIN users u ON i.owner_id = u.user_id
            WHERE i.status = %s
        """
        cursor.execute(sql, (status,))
    
    items = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': items})


# 获取我的物品（物主视角）
@app.route('/api/my-items/<user_id>', methods=['GET'])
def get_my_items(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT item_id, name, daily_rent, deposit, status FROM items WHERE owner_id=%s",
        (user_id,)
    )
    items = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify({'code': 200, 'data': items})


# 发布物品
@app.route('/api/items', methods=['POST'])
def add_item():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("""
            INSERT INTO items (owner_id, cat_id, name, description, deposit, daily_rent, location, status) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'available')
        """, (data['owner_id'], 1, data['name'], data['description'], 
              data['deposit'], data['daily_rent'], data['location']))
        conn.commit()
        return jsonify({'code': 200, 'message': '发布成功'})
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)})
    finally:
        cursor.close()
        conn.close()


# 下架物品
@app.route('/api/items/<int:item_id>/offline', methods=['PUT'])
def offline_item(item_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE items SET status='offline' WHERE item_id=%s", (item_id,))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'code': 200, 'message': '已下架'})


# ==================== 订单管理API ====================

# 创建订单（租借物品）
@app.route('/api/orders', methods=['POST'])
def create_order():
    data = request.json
    item_id = data.get('item_id')
    borrower_id = data.get('borrower_id')
    days = data.get('days')
    
    if not item_id or not borrower_id or not days:
        return jsonify({'code': 400, 'message': '参数不完整'})
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # 检查物品是否可借
        cursor.execute("SELECT status FROM items WHERE item_id = %s", (item_id,))
        item = cursor.fetchone()
        if not item:
            return jsonify({'code': 404, 'message': '物品不存在'})
        if item['status'] != 'available':
            return jsonify({'code': 400, 'message': '物品已被租借'})
        
        # 插入订单
        cursor.execute("""
            INSERT INTO orders (item_id, borrower_id, order_status, borrow_date, due_date) 
            VALUES (%s, %s, 'borrowing', CURDATE(), DATE_ADD(CURDATE(), INTERVAL %s DAY))
        """, (item_id, borrower_id, days))
        
        # 更新物品状态
        cursor.execute("UPDATE items SET status='borrowed' WHERE item_id=%s", (item_id,))
        
        conn.commit()
        return jsonify({'code': 200, 'message': '租借成功'})
        
    except Exception as e:
        conn.rollback()
        return jsonify({'code': 500, 'message': str(e)})
        
    finally:
        cursor.close()
        conn.close()


# 获取我的订单
@app.route('/api/my-orders/<user_id>', methods=['GET'])
def get_my_orders(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT o.order_id, i.name, o.order_status, o.borrow_date, o.due_date, 
               o.actual_return_date, o.total_cost, o.penalty
        FROM orders o
        JOIN items i ON o.item_id = i.item_id
        WHERE o.borrower_id = %s
        ORDER BY o.create_time DESC
    """, (user_id,))
    
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': orders})


# 归还物品
@app.route('/api/orders/<int:order_id>/return', methods=['PUT'])
def return_order(order_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # 获取订单中的物品ID和借用人ID
        cursor.execute("SELECT item_id, borrower_id FROM orders WHERE order_id = %s", (order_id,))
        order = cursor.fetchone()
        if not order:
            return jsonify({'code': 404, 'message': '订单不存在'})
        
        item_id = order['item_id']
        borrower_id = order['borrower_id']
        
        # 更新订单状态
        cursor.execute("""
            UPDATE orders 
            SET actual_return_date = CURDATE(),
                order_status = 'returned'
            WHERE order_id = %s
        """, (order_id,))
        
        # 更新物品状态
        cursor.execute("UPDATE items SET status = 'available' WHERE item_id = %s", (item_id,))
        
        # 给借用人加2分信用分，但不超过100
        cursor.execute("""
            UPDATE users 
            SET credit_score = LEAST(credit_score + 2, 100) 
            WHERE user_id = %s
        """, (borrower_id,))
        
        conn.commit()
        
        return jsonify({'code': 200, 'message': '归还成功'})
        
    except Exception as e:
        conn.rollback()
        return jsonify({'code': 500, 'message': str(e)})
        
    finally:
        cursor.close()
        conn.close()


# ==================== 收藏管理API ====================

# 获取收藏夹
@app.route('/api/favorites/<user_id>', methods=['GET'])
def get_favorites(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT i.item_id, i.name, i.daily_rent, i.deposit, i.status, u.name as owner_name
        FROM favorites f
        JOIN items i ON f.item_id = i.item_id
        JOIN users u ON i.owner_id = u.user_id
        WHERE f.user_id = %s
    """, (user_id,))
    
    favorites = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': favorites})


# 添加收藏
@app.route('/api/favorites', methods=['POST'])
def add_favorite():
    data = request.json
    user_id = data.get('user_id')
    item_id = data.get('item_id')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            "INSERT INTO favorites (user_id, item_id) VALUES (%s, %s)",
            (user_id, item_id)
        )
        conn.commit()
        return jsonify({'code': 200, 'message': '收藏成功'})
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)})
    finally:
        cursor.close()
        conn.close()


# 取消收藏
@app.route('/api/favorites', methods=['DELETE'])
def remove_favorite():
    data = request.json
    user_id = data.get('user_id')
    item_id = data.get('item_id')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "DELETE FROM favorites WHERE user_id=%s AND item_id=%s",
        (user_id, item_id)
    )
    conn.commit()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'message': '取消收藏成功'})


# ==================== 信用分管理API ====================

# 信用分排行榜
@app.route('/api/credit-rank', methods=['GET'])
def get_credit_rank():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT name, credit_score, dorm_building
        FROM users
        WHERE role = 'student'
        ORDER BY credit_score DESC
        LIMIT 10
    """)
    
    ranks = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': ranks})


# 获取信用变动历史
@app.route('/api/credit-logs/<user_id>', methods=['GET'])
def get_credit_logs(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT change_amount, reason, create_time
        FROM credit_logs
        WHERE user_id = %s
        ORDER BY create_time DESC
        LIMIT 20
    """, (user_id,))
    
    logs = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': logs})


# ==================== 数据分析API ====================

# 仪表盘统计数据
@app.route('/api/dashboard', methods=['GET'])
def get_dashboard():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("SELECT COUNT(*) as total FROM users WHERE role='student'")
    total_users = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as total FROM items WHERE status='available'")
    available_items = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as total FROM orders WHERE order_status='borrowing'")
    active_orders = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as total FROM orders WHERE order_status='returned'")
    completed_orders = cursor.fetchone()
    
    cursor.execute("SELECT ROUND(AVG(credit_score),1) as avg FROM users WHERE role='student'")
    avg_credit = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    return jsonify({
        'code': 200,
        'data': {
            'total_users': total_users['total'],
            'available_items': available_items['total'],
            'active_orders': active_orders['total'],
            'completed_orders': completed_orders['total'],
            'avg_credit': avg_credit['avg'] if avg_credit['avg'] else 0
        }
    })


# 热门物品排行榜
@app.route('/api/popular-items', methods=['GET'])
def get_popular_items():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT i.name, COUNT(o.order_id) as rent_count,
               ROUND(AVG(r.rating), 1) as avg_rating
        FROM items i
        LEFT JOIN orders o ON i.item_id = o.item_id
        LEFT JOIN reviews r ON o.order_id = r.order_id
        GROUP BY i.item_id
        ORDER BY rent_count DESC
        LIMIT 5
    """)
    
    items = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': items})


# ==================== 管理员API ====================

# 管理员统计
@app.route('/api/admin/stats', methods=['GET'])
def admin_stats():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("SELECT COUNT(*) as total FROM orders")
    total_orders = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as total FROM orders WHERE order_status = 'borrowing'")
    active_orders = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as total FROM orders WHERE order_status = 'borrowing' AND due_date < CURDATE()")
    overdue_orders = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as total FROM users WHERE role = 'student'")
    total_users = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    return jsonify({
        'code': 200,
        'data': {
            'total_orders': total_orders['total'],
            'active_orders': active_orders['total'],
            'overdue_orders': overdue_orders['total'],
            'total_users': total_users['total']
        }
    })


# 管理员查看所有订单
@app.route('/api/admin/orders', methods=['GET'])
def admin_orders():
    status = request.args.get('status', '')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if status == 'borrowing':
        sql = """
            SELECT o.order_id, i.name as item_name, u.name as borrower_name,
                   u2.name as owner_name, o.borrow_date, o.due_date, o.actual_return_date, o.order_status
            FROM orders o
            JOIN items i ON o.item_id = i.item_id
            JOIN users u ON o.borrower_id = u.user_id
            JOIN users u2 ON i.owner_id = u2.user_id
            WHERE o.order_status = 'borrowing'
            ORDER BY o.create_time DESC
        """
        cursor.execute(sql)
    elif status == 'returned':
        sql = """
            SELECT o.order_id, i.name as item_name, u.name as borrower_name,
                   u2.name as owner_name, o.borrow_date, o.due_date, o.actual_return_date, o.order_status
            FROM orders o
            JOIN items i ON o.item_id = i.item_id
            JOIN users u ON o.borrower_id = u.user_id
            JOIN users u2 ON i.owner_id = u2.user_id
            WHERE o.order_status = 'returned'
            ORDER BY o.create_time DESC
        """
        cursor.execute(sql)
    elif status == 'overdue':
        sql = """
            SELECT o.order_id, i.name as item_name, u.name as borrower_name,
                   u2.name as owner_name, o.borrow_date, o.due_date, o.actual_return_date, o.order_status
            FROM orders o
            JOIN items i ON o.item_id = i.item_id
            JOIN users u ON o.borrower_id = u.user_id
            JOIN users u2 ON i.owner_id = u2.user_id
            WHERE o.order_status = 'borrowing' AND o.due_date < CURDATE()
            ORDER BY o.create_time DESC
        """
        cursor.execute(sql)
    else:
        sql = """
            SELECT o.order_id, i.name as item_name, u.name as borrower_name,
                   u2.name as owner_name, o.borrow_date, o.due_date, o.actual_return_date, o.order_status
            FROM orders o
            JOIN items i ON o.item_id = i.item_id
            JOIN users u ON o.borrower_id = u.user_id
            JOIN users u2 ON i.owner_id = u2.user_id
            ORDER BY o.create_time DESC
        """
        cursor.execute(sql)
    
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': orders})


# 搜索订单（管理员）
@app.route('/api/admin/orders/search', methods=['GET'])
def admin_search_orders():
    keyword = request.args.get('keyword', '')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT o.order_id, i.name as item_name, u.name as borrower_name,
               u2.name as owner_name, o.borrow_date, o.due_date, o.actual_return_date, o.order_status
        FROM orders o
        JOIN items i ON o.item_id = i.item_id
        JOIN users u ON o.borrower_id = u.user_id
        JOIN users u2 ON i.owner_id = u2.user_id
        WHERE i.name LIKE %s OR u.name LIKE %s
        ORDER BY o.create_time DESC
    """, (f'%{keyword}%', f'%{keyword}%'))
    
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': orders})


# 管理员强制归还
@app.route('/api/admin/orders/<int:order_id>/force-return', methods=['PUT'])
def admin_force_return(order_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # 获取订单信息
        cursor.execute("""
            SELECT o.item_id, o.borrower_id, o.due_date, i.owner_id
            FROM orders o
            JOIN items i ON o.item_id = i.item_id
            WHERE o.order_id = %s AND o.order_status = 'borrowing'
        """, (order_id,))
        result = cursor.fetchone()
        
        if not result:
            return jsonify({'code': 404, 'message': '订单不存在或已归还'})
        
        item_id = result['item_id']
        borrower_id = result['borrower_id']
        due_date = result['due_date']
        
        # 计算逾期天数
        from datetime import date
        today = date.today()
        overdue_days = 0
        if due_date and due_date < today:
            overdue_days = (today - due_date).days
        
        # 1. 更新订单状态
        cursor.execute("""
            UPDATE orders 
            SET actual_return_date = CURDATE(),
                order_status = 'returned'
            WHERE order_id = %s
        """, (order_id,))
        
        # 2. 更新物品状态
        cursor.execute("UPDATE items SET status = 'available' WHERE item_id = %s", (item_id,))
        
        # 3. 处理信用分
        penalty_points = 0
        if overdue_days > 0:
            # 逾期扣分：每天5分，最多30分
            penalty_points = min(overdue_days * 5, 30)
            cursor.execute("""
                UPDATE users 
                SET credit_score = GREATEST(credit_score - %s, 0)
                WHERE user_id = %s
            """, (penalty_points, borrower_id))
            
            # 记录信用变动日志
            cursor.execute("""
                INSERT INTO credit_logs (user_id, change_amount, reason)
                VALUES (%s, %s, %s)
            """, (borrower_id, -penalty_points, f'管理员强制归还，逾期{overdue_days}天'))
        
        conn.commit()
        
        message = f'归还成功'
        if penalty_points > 0:
            message += f'，借用人扣除{penalty_points}信用分'
        else:
            message += '，借用人无逾期扣分'
        
        return jsonify({'code': 200, 'message': message})
        
    except Exception as e:
        conn.rollback()
        print(f"强制归还失败: {str(e)}")
        return jsonify({'code': 500, 'message': str(e)})
    finally:
        cursor.close()
        conn.close()


# 管理员获取所有用户
@app.route('/api/admin/users', methods=['GET'])
def admin_get_users():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT user_id, name, dorm_building, dorm_room, phone, credit_score, role, created_at
        FROM users
        ORDER BY created_at DESC
    """)
    
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': users})


# 搜索用户（管理员）
@app.route('/api/admin/users/search', methods=['GET'])
def admin_search_users():
    keyword = request.args.get('keyword', '')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT user_id, name, dorm_building, dorm_room, phone, credit_score, role
        FROM users
        WHERE user_id LIKE %s OR name LIKE %s
        ORDER BY created_at DESC
    """, (f'%{keyword}%', f'%{keyword}%'))
    
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'data': users})


# 管理员修改用户信用分
@app.route('/api/admin/user/<user_id>/credit', methods=['PUT'])
def admin_update_credit(user_id):
    data = request.json
    credit_score = data.get('credit_score')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("UPDATE users SET credit_score=%s WHERE user_id=%s", (credit_score, user_id))
    conn.commit()
    cursor.close()
    conn.close()
    
    return jsonify({'code': 200, 'message': '信用分修改成功'})


# 管理员删除用户
@app.route('/api/admin/user/<user_id>', methods=['DELETE'])
def admin_delete_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("DELETE FROM users WHERE user_id=%s", (user_id,))
        conn.commit()
        return jsonify({'code': 200, 'message': '删除成功'})
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)})
    finally:
        cursor.close()
        conn.close()


# 启动服务器
if __name__ == '__main__':
    app.run(debug=True, port=5000)
