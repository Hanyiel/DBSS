-- 1. 用户表 (users)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    display_name VARCHAR(100),
    personal_tag VARCHAR(100),
    status ENUM('online', 'offline', 'busy') DEFAULT 'offline',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. 好友分类表 (friend_categories)
CREATE TABLE IF NOT EXISTS friend_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    is_system BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 好友关系表 (friendships)
CREATE TABLE IF NOT EXISTS friendships (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    category_id INT NOT NULL DEFAULT 1,
    custom_category_name VARCHAR(50),
    note VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES friend_categories(id),
    UNIQUE KEY unique_friendship (user_id, friend_id)
);

-- 4. 待处理好友请求表 (friend_requests)
CREATE TABLE IF NOT EXISTS friend_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    message VARCHAR(200),
    category_id INT NOT NULL DEFAULT 1,
    status ENUM('pending', 'accepted', 'rejected', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES friend_categories(id),
    UNIQUE KEY unique_friend_request (from_user_id, to_user_id, status)
);

-- 5. 会议室表 (rooms)
CREATE TABLE IF NOT EXISTS rooms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    meeting_code VARCHAR(10) UNIQUE NOT NULL COMMENT '会议编号 MTC+6位数字',
    name VARCHAR(200) NOT NULL,
    description TEXT,
    host_id INT NOT NULL COMMENT '主持人用户ID',
    password VARCHAR(100) NULL COMMENT '会议密码，可为空',
    max_participants INT DEFAULT 50,
    is_waiting_room_enabled BOOLEAN DEFAULT TRUE,
    room_settings JSON COMMENT '存储会议类型、安全设置等',
    scheduled_start TIMESTAMP NULL,
    scheduled_end TIMESTAMP NULL,
    actual_start TIMESTAMP NULL COMMENT '实际开始时间',
    actual_end TIMESTAMP NULL COMMENT '实际结束时间',
    status ENUM('active', 'ended', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_meeting_code (meeting_code),
    INDEX idx_host_id (host_id),
    INDEX idx_status (status),
    INDEX idx_actual_start (actual_start)
);

-- 6. 权限角色表 (permission_roles)
CREATE TABLE IF NOT EXISTS permission_roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'host, co-host, participant',
    description VARCHAR(255),
    
    -- 具体权限配置
    can_mute_others BOOLEAN DEFAULT FALSE,
    can_assign_cohost BOOLEAN DEFAULT FALSE,
    can_kick_participants BOOLEAN DEFAULT FALSE,
    can_record_meeting BOOLEAN DEFAULT FALSE,
    can_manage_chat BOOLEAN DEFAULT FALSE,
    can_end_meeting BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 7. 会议权限表 (meeting_permissions)
CREATE TABLE IF NOT EXISTS meeting_permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    meeting_id INT NOT NULL,
    user_id INT NOT NULL,
    role_id INT NOT NULL COMMENT '引用权限角色',
    
    -- 权限信息
    assigned_by INT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    
    -- 外键约束
    FOREIGN KEY (meeting_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES permission_roles(id),
    FOREIGN KEY (assigned_by) REFERENCES users(id),
    
    -- 唯一约束
    UNIQUE KEY unique_meeting_user (meeting_id, user_id),
    
    -- 索引
    INDEX idx_meeting (meeting_id),
    INDEX idx_user (user_id),
    INDEX idx_role (role_id)
);

-- 8. 会议参会记录表 (room_participants)
CREATE TABLE IF NOT EXISTS room_participants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP NULL,
    participant_status ENUM('active', 'inactive', 'kicked', 'left') DEFAULT 'active',
    
    -- 实时状态字段
    is_muted BOOLEAN DEFAULT FALSE,
    is_video_enabled BOOLEAN DEFAULT TRUE,
    is_screen_sharing BOOLEAN DEFAULT FALSE,
    is_hand_raised BOOLEAN DEFAULT FALSE,
    
    -- 权限控制字段
    can_speak BOOLEAN DEFAULT TRUE,
    can_share_screen BOOLEAN DEFAULT TRUE,
    can_enable_video BOOLEAN DEFAULT TRUE,
    can_chat BOOLEAN DEFAULT TRUE,
    
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_room_user (room_id, user_id),
    
    -- 添加索引
    INDEX idx_room_status (room_id, participant_status),
    INDEX idx_user_status (user_id, participant_status)
);

-- 9. 聊天消息表 (messages)
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    message_type ENUM('text', 'image', 'file', 'emoji', 'system') DEFAULT 'text',
    content TEXT,
    file_url VARCHAR(255),
    file_name VARCHAR(255),
    file_size INT,
    parent_message_id INT NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_message_id) REFERENCES messages(id) ON DELETE SET NULL,
    
    -- 添加索引
    INDEX idx_room_created (room_id, created_at),
    INDEX idx_user_room (user_id, room_id)
);

-- 10. 等待室表 (waiting_room)
CREATE TABLE IF NOT EXISTS waiting_room (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    admitted_by INT NULL,
    admitted_at TIMESTAMP NULL,
    status ENUM('waiting', 'admitted', 'rejected') DEFAULT 'waiting',
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (admitted_by) REFERENCES users(id) ON DELETE SET NULL,
    
    -- 添加索引
    INDEX idx_room_status (room_id, status),
    INDEX idx_user_room (user_id, room_id)
);

-- 11. 会议录制表 (meeting_recordings)
CREATE TABLE meeting_recordings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  meeting_id INT NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (meeting_id) REFERENCES rooms(id) ON DELETE CASCADE,
  INDEX idx_meeting_id (meeting_id)
);

-- 创建索引以提高查询性能
ALTER TABLE users ADD INDEX idx_users_email (email);
ALTER TABLE users ADD INDEX idx_users_username (username);

ALTER TABLE friendships ADD INDEX idx_friendships_user_id (user_id);
ALTER TABLE friendships ADD INDEX idx_friendships_friend_id (friend_id);
ALTER TABLE friendships ADD INDEX idx_friendships_category_id (category_id);

ALTER TABLE friend_requests ADD INDEX idx_friend_requests_from_user (from_user_id);
ALTER TABLE friend_requests ADD INDEX idx_friend_requests_to_user (to_user_id);
ALTER TABLE friend_requests ADD INDEX idx_friend_requests_status (status);

ALTER TABLE rooms ADD INDEX idx_rooms_host_id (host_id);
ALTER TABLE rooms ADD INDEX idx_rooms_scheduled_start (scheduled_start);

ALTER TABLE room_participants ADD INDEX idx_room_participants_room_id (room_id);
ALTER TABLE room_participants ADD INDEX idx_room_participants_user_id (user_id);

ALTER TABLE messages ADD INDEX idx_messages_room_id (room_id);
ALTER TABLE messages ADD INDEX idx_messages_created_at (created_at);

-- 初始化数据
INSERT IGNORE INTO friend_categories (name, is_system, sort_order) VALUES 
('other', TRUE, 1),
('family', TRUE, 2),
('friend', TRUE, 3),
('workmate', TRUE, 4),
('boss', TRUE, 5),
('classmate', TRUE, 6),
('teacher', TRUE, 7);

-- 插入预设角色
INSERT IGNORE INTO permission_roles (role_name, description, can_mute_others, can_assign_cohost, can_kick_participants, can_record_meeting, can_manage_chat, can_end_meeting) VALUES
('host', '会议主持人', TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
('co-host', '联席主持人', TRUE, FALSE, TRUE, TRUE, TRUE, FALSE),
('participant', '普通参会者', FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);

-- 显示创建的表信息
SHOW TABLES;