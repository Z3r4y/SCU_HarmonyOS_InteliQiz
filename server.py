from flask import Flask, jsonify, request, send_file, make_response
from flask_sqlalchemy import SQLAlchemy
import pymysql
from PIL import Image, ImageDraw, ImageFont
import random
import io
import base64

# 使用PyMySQL代替MySQLdb
pymysql.install_as_MySQLdb()

app = Flask(__name__)

# 配置MySQL数据库连接
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:my-secret-pw@124.222.136.33/qiz'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class ResponseData:
    def __init__(self, code=None, msg=None, data=None):
        self.code = code
        self.msg = msg
        self.data = data


class QuestionModel(db.Model):
    __tablename__ = 'questions'
    id = db.Column(db.Integer, primary_key=True)
    question = db.Column(db.String(255))
    option_a = db.Column(db.String(255))
    option_b = db.Column(db.String(255))
    correct_option = db.Column(db.String(1))
    explanation = db.Column(db.String(255))
    image_url = db.Column(db.String(255))  # 新增图片URL属性

    def __init__(self, question, option_a, option_b, correct_option, explanation, image_url):
        self.question = question
        self.option_a = option_a
        self.option_b = option_b
        self.correct_option = correct_option
        self.explanation = explanation
        self.image_url = image_url



class UserModel(db.Model):
    __tablename__ = 'users'
    uid = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80))
    userphone = db.Column(db.String(20))
    password = db.Column(db.String(80))
    score = db.Column(db.Integer, default=0)
    token = db.Column(db.String(255), nullable=True)
    trueNumber = db.Column(db.Integer, default=0)
    rate = db.Column(db.Float, default=0.0)

    def __init__(self, username, password, userphone, score=0, trueNumber=0, rate=0.0, token=None):
        self.username = username
        self.password = password
        self.userphone = userphone
        self.score = score
        self.trueNumber = trueNumber
        self.rate = rate
        self.token = token



def generate_captcha():
    # 创建一个白色背景的图像
    image = Image.new('RGB', (150, 60), (255, 255, 255))
    draw = ImageDraw.Draw(image)
    font = ImageFont.truetype('arial.ttf', 36)

    # 生成随机的验证码文本
    captcha_text = ''.join(random.choices('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', k=4))

    # 绘制验证码文本
    for i, char in enumerate(captcha_text):
        # 随机颜色
        color = (random.randint(0, 100), random.randint(0, 100), random.randint(0, 100))
        # 随机位置
        position = (10 + i * 30 + random.randint(-5, 5), random.randint(-5, 5))
        draw.text(position, char, font=font, fill=color)

    # 添加一些干扰线
    for _ in range(5):
        start = (random.randint(0, 150), random.randint(0, 60))
        end = (random.randint(0, 150), random.randint(0, 60))
        color = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
        draw.line([start, end], fill=color, width=2)

    # 添加一些噪点
    for _ in range(50):
        position = (random.randint(0, 150), random.randint(0, 60))
        color = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
        draw.point(position, fill=color)

    # 保存图像到内存中
    buffer = io.BytesIO()
    image.save(buffer, format='PNG')
    buffer.seek(0)
    img_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')

    return captcha_text, img_base64

@app.route('/api/captcha', methods=['GET'])
def get_captcha():
    captcha_text, img_base64 = generate_captcha()
    return jsonify({'captcha_text': captcha_text, 'captcha_image': img_base64})

@app.route('/user/login', methods=['POST'])
def user_login():
    data = request.json
    phone_number = data.get('userphone')
    password = data.get('password')

    user = UserModel.query.filter_by(userphone=phone_number, password=password).first()

    if user:
        # 生成一个token，这里使用简单的示例，你可以使用更复杂的生成方法
        token = generate_token(user.uid)
        user.token = token
        db.session.commit()
        response_data = ResponseData(code=0, msg='Success', data={
            'uid': user.uid,
            'username': user.username,
            'userphone': user.userphone,
            'token': token
        })
    else:
        response_data = ResponseData(code=1, msg='Invalid phone number or password')

    return jsonify(response_data.__dict__)

@app.route('/user/reg', methods=['POST'])
def user_register():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    userphone = data.get('userphone')
    sms_code = data.get('smsCode')

    if not username or not password or not userphone or not sms_code:
        response_data = ResponseData(code=400, msg='All fields are required')
        return jsonify(response_data.__dict__), 400

    if UserModel.query.filter_by(userphone=userphone).first():
        response_data = ResponseData(code=409, msg='Phone number already registered')
        return jsonify(response_data.__dict__), 409

    # 首先创建用户，不生成 token
    new_user = UserModel(username=username, password=password, userphone=userphone)
    db.session.add(new_user)
    db.session.commit()

    # 生成 token
    token = generate_token(new_user.uid)
    new_user.token = token
    db.session.commit()

    response_data = ResponseData(code=0, msg='Registration successful', data={
        'uid': new_user.uid,
        'username': new_user.username,
        'userphone': new_user.userphone,
        'token': token
    })

    return jsonify(response_data.__dict__), 200

def generate_token(uid):
    # 简单生成 token 的方法，可以用更安全的方式生成 token
    return base64.b64encode(f'token-{uid}'.encode()).decode()


@app.route('/api/question', methods=['GET'])
def get_question():
    page = request.args.get('page', 1, type=int)
    per_page = 1
    pagination = QuestionModel.query.paginate(page=page, per_page=per_page, error_out=False)
    if pagination.items:
        question = pagination.items[0]
        question_data = {
            'id': question.id,
            'question': question.question,
            'option_a': question.option_a,
            'option_b': question.option_b,
            'correct_option': question.correct_option,
            'explanation': question.explanation,
            'image_url': question.image_url
        }
        response_data = ResponseData(code=0, msg='Registration successful', data=question_data)
        return jsonify(response_data.__dict__), 200
    else:
        return jsonify({'message': 'No more questions'}), 404


@app.route('/api/question/answer', methods=['POST'])
def answer_question():
    data = request.json
    userphone = data.get('userphone')
    answer = data.get('answer')
    question_id = data.get('question_id')

    user = UserModel.query.filter_by(userphone=userphone).first()
    question = db.session.get(QuestionModel, question_id)

    if user and question:
        if answer == question.correct_option:
            user.trueNumber += 1
            user.score += 10
            user.rate = user.score

        db.session.commit()

        response_data = ResponseData(code=0, msg='Answer submitted successfully', data={
            'trueNumber': user.trueNumber,
            'score': user.score
        })
        return jsonify(response_data.__dict__), 200
    else:
        response_data = ResponseData(code=1, msg='Invalid user or question')
        return jsonify(response_data.__dict__), 404



@app.route('/user/data', methods=['GET'])
def get_user_data():
    token = request.args.get('token')
    user = UserModel.query.filter_by(token=token).first()
    if user:
        user_data = {
            'username': user.username,
            'userphone': user.userphone,
            'score': user.score,
            'trueNumber': user.trueNumber,
            'rate': user.rate
        }
        print(user_data)
        response_data = ResponseData(code=0, msg='Answer submitted successfully', data=user_data)
        return jsonify(response_data.__dict__),200
    else:
        response_data = ResponseData(code=1, msg='Invalid user')
        return jsonify(response_data.__dict__),404


@app.route('/api/users', methods=['GET'])
def get_users():
    try:
        users = UserModel.query.all()
        print(f"Fetched users: {users}")
        
        if not users:
            print("No users found.")
            response_data = ResponseData(code=1, msg='No users found', data=[])
            return jsonify(response_data.__dict__), 404
        
        user_list = [{
            'uid': user.uid,
            'username': user.username,
            'userphone': user.userphone,
            'password': user.password,
            'trueNumber': user.trueNumber,
            'rate': user.rate
        } for user in users]
        
        response_data = ResponseData(code=0, msg='Success', data=user_list)
        return jsonify(response_data.__dict__), 200
    
    except Exception as e:
        print(f"Error occurred: {e}")
        response_data = ResponseData(code=1, msg='Internal server error', data=[])
        return jsonify(response_data.__dict__), 500


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=1337)