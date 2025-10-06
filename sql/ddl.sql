--- 
--- create tables
---

DROP TABLE IF EXISTS owned_items;
DROP TABLE IF EXISTS store;
DROP TABLE IF EXISTS ongoing_streaks;
DROP TABLE IF EXISTS streaks;
DROP TABLE IF EXISTS owned_badges;
DROP TABLE IF EXISTS badges;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS completed_quests;
DROP TABLE IF EXISTS inlogging;

CREATE TABLE inlogging 
(
    user_id INT AUTO_INCREMENT NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hashed VARCHAR(255) NOT NULL, 

    PRIMARY KEY(user_id)
);

CREATE TABLE profiles 
(
    user_id INT NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    user_age DATE,
    user_bio TEXT DEFAULT 'QuestBoard User',
    coins INT UNSIGNED NOT NULL DEFAULT 0,
    xp INT UNSIGNED NOT NULL DEFAULT 0, 
    user_level INT AS (FLOOR(xp / 30) + 1) VIRTUAL,
    xp_left INT AS (
        CASE 
        WHEN (xp % 30) = 0 THEN 30
        ELSE 30 - (xp % 30)
        END
    ) VIRTUAL,

    PRIMARY KEY(user_id),
    FOREIGN KEY(user_id) REFERENCES inlogging(user_id) ON DELETE CASCADE
);


CREATE TABLE quests
(
    quest_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    quest_name VARCHAR(255) NOT NULL,
    quest_description TEXT,
    quest_type VARCHAR(6) NOT NULL,
    created_time DATE DEFAULT CURRENT_DATE,
    completed_time DATE NULL,
    due_time DATE NOT NULL,
    quest_status VARCHAR(20) NOT NULL DEFAULT 'uncompleted',

    PRIMARY KEY(quest_id),
    FOREIGN KEY(user_id) REFERENCES inlogging(user_id) ON DELETE CASCADE
); 

CREATE TABLE completed_quests 
(
    quest_id INT NOT NULL,
    user_id INT NOT NULL,
    quest_name VARCHAR(255) NOT NULL,
    quest_description TEXT,
    quest_type VARCHAR(6),
    completed_time DATE NOT NULL,
    quest_status VARCHAR(20),

    PRIMARY KEY(quest_id),
    FOREIGN KEY(user_id) REFERENCES inlogging(user_id) ON DELETE CASCADE
);

CREATE TABLE badges
(
    badge_id INT NOT NULL,
    badge_name VARCHAR(50) NOT NULL,
    badge_description TEXT,

    PRIMARY KEY(badge_id)
);

CREATE TABLE owned_badges
(
    badge_id INT NOT NULL,
    user_id INT NOT NULL,

    PRIMARY KEY(badge_id, user_id),
    FOREIGN KEY(user_id) REFERENCES inlogging(user_id) ON DELETE CASCADE,
    FOREIGN KEY(badge_id) REFERENCES badges(badge_id) ON DELETE CASCADE
);

CREATE TABLE streaks 
(
    streak_id int NOT NULL,
    streak_name VARCHAR(50) NOT NULL,
    streak_description TEXT,

    PRIMARY KEY(streak_id)
);


CREATE TABLE ongoing_streaks
(
    streak_id INT NOT NULL,
    user_id INT NOT NULL,
    streak_duration INT DEFAULT 0,
    last_login DATE,

    PRIMARY KEY(streak_id, user_id),
    FOREIGN KEY(user_id) REFERENCES inlogging(user_id) ON DELETE CASCADE,
    FOREIGN KEY(streak_id) REFERENCES streaks(streak_id) ON DELETE CASCADE
);

CREATE TABLE store 
(
    item_id INT AUTO_INCREMENT NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_cost INT UNSIGNED NOT NULL,
    item_description TEXT,

    PRIMARY KEY(item_id)
);


CREATE TABLE owned_items
(
    item_id INT NOT NULL,
    user_id INT NOT NULL,
    quantitie INT NOT NULL DEFAULT 1,

    PRIMARY KEY(item_id, user_id),
    FOREIGN KEY(user_id) REFERENCES inlogging(user_id) ON DELETE CASCADE,
    FOREIGN KEY(item_id) REFERENCES store(item_id) ON DELETE CASCADE
);
