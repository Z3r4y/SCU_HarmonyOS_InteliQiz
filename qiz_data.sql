-- 使用数据库
USE qiz;

-- 删除现有的表（如果存在）
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;


-- 创建 users 表
CREATE TABLE IF NOT EXISTS users (
    uid INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    userphone VARCHAR(20) NOT NULL,
    password VARCHAR(80) NOT NULL,
    score INT DEFAULT 0,
    trueNumber INT DEFAULT 0,
    rate FLOAT DEFAULT 0.0,
    token VARCHAR(255)
);

-- 插入初始数据到 users 表
INSERT INTO users (username, password, userphone, score, trueNumber, rate, token) VALUES
('Z3r4y', '123456', '13851069604', 90, 10, 90.0, 'dG9rZW4tMQ=='),
('admin', 'admin', '15950231992', 80, 8, 80.0, 'dG9rZW4tMg==');


-- 创建 questions 表
CREATE TABLE IF NOT EXISTS questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question VARCHAR(255) NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    correct_option CHAR(1) NOT NULL,
    explanation VARCHAR(255),
    image_url VARCHAR(255)  -- 新增图片URL属性
);

-- 插入初始数据到 questions 表
INSERT INTO questions (question, option_a, option_b, correct_option, explanation, image_url) VALUES
('请问意大利面能拌42号混凝土吗？', '能', '不能', 'A', '但是鸡蛋发霉后的乳酸菌会促使心脑血管的收缩，同时会影响拉格朗日点的吸收，促使喜羊羊超进化。', 'http://124.222.136.33:1338/img/img1.jpg'),
('喜欢老北京豆汁儿吗？', '喜欢', '不喜欢', 'B', '要是喝完了，跳起来骂街的，肯定不是北京人，要是跳起来问：“有焦圈儿吗？”这肯定是北京人。', 'http://124.222.136.33:1338/img/img2.jpg'),
('请问图中人物的名字是什么', '马+7', '丁程鑫', 'A', '时~代~少年团，我们喜欢你~我们最爱马+7……', 'http://124.222.136.33:1338/img/img3.jpg'),
('量子霍尔反常效应是由哪位院士的团队带领证实的', '掌管黑洞的神·霍金', '沂蒙山走出的科学家：薛其坤', 'B', '在温度降低或粒子密度变大等特殊条件下，宏观物体的个体组分会相干地结合起来，使得整个系统表现出奇特的量子性质。', 'http://124.222.136.33:1338/img/img4.jpg'),
('图中人物这时候会对你说什么呢', 'Yes,my lord', '呀嘞呀嘞，勾兔拜德哟', 'B', '拦不住的大小姐呢，喜欢赛巴斯跳舞吗？', 'http://124.222.136.33:1338/img/img5.jpg'),
('根据图片情景“十年树木”的下一句是什么', '千年树妖', '百年劳伦', 'B', '莉莉：“我长大了要跟牧师大人结婚哦“”我是圣女，但我不想做剩女“', 'http://124.222.136.33:1338/img/img6.jpg'),
('你热爱四川大学吗？你是否愿意为川大的建设奉献宝贵的青春呢？', '海纳百川有容乃大！我必须愿意啊', '我……（有点犹豫）', 'A', '你怎么敢犹豫的（冷笑）？你的信念好想有些动摇了哦（思想钢印）', 'http://124.222.136.33:1338/img/img7.jpg'),
('这把枪为什么弹道偏左?', '剧情需要，早就兵王', '如果我阵亡了，我希望敌人不能立刻用它', 'A', '不要把美式个人英雄主义硬套到我们身上，我们每个人的力量都是珍贵的，没有伟大的个人只有伟大的团体', 'http://124.222.136.33:1338/img/img8.jpg'),
('中国传统文化的哲学中最大的弊病是什么', '没有太多知识分子愿意去理论建设', '哲学分析不具有逻辑性，研究过程中臆想成分偏多', 'B', '中国古代哲学强调的是整体性思维、辩证法和直觉性推理，其中缺乏理性的认知', 'http://124.222.136.33:1338/img/img9.jpg'),
('可以给我们摩多摩多的分数吗？拜托了我什么都会做的', '绝对可以的！！！', '你这人满脑子都只有自己呢', 'A', '：哦内该……哇达西如果没有分数的话……（哭哭）', 'http://124.222.136.33:1338/img/img10.jpg');