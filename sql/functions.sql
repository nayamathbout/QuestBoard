---
--- triggers, functions & procedures
---

DROP PROCEDURE IF EXISTS create_account;
DROP PROCEDURE IF EXISTS create_profile;
DROP PROCEDURE IF EXISTS create_quest;
DROP PROCEDURE IF EXISTS add_description_to_quest;
DROP PROCEDURE IF EXISTS complete_quest;
DROP PROCEDURE IF EXISTS get_badge;
DROP PROCEDURE IF EXISTS start_streak;
DROP PROCEDURE IF EXISTS buy_items;
DROP PROCEDURE IF EXISTS earn_coins;
DROP PROCEDURE IF EXISTS earn_xp;
DROP PROCEDURE IF EXISTS end_streak;
DROP PROCEDURE IF EXISTS delete_quest;
DROP PROCEDURE IF EXISTS show_quests;
DROP PROCEDURE IF EXISTS show_completed_quests;
DROP PROCEDURE IF EXISTS show_upcoming_quests;
DROP PROCEDURE IF EXISTS show_daily_quests;
DROP PROCEDURE IF EXISTS show_user_badges;
DROP PROCEDURE IF EXISTS show_user_streaks;
DROP PROCEDURE IF EXISTS show_user_rewards;
DROP PROCEDURE IF EXISTS show_user_profile;
DROP PROCEDURE IF EXISTS show_store;
DROP PROCEDURE IF EXISTS add_age_to_profile;
DROP TRIGGER IF EXISTS complete_status;
--DROP EVENT IF EXISTS late_status;
DROP FUNCTION IF EXISTS get_user_id;
DROP FUNCTION IF EXISTS add_age_to_profile;
DROP EVENT IF EXISTS reset_daily_quests;
DROP EVENT IF EXISTS reset_weekly_quests;

DELIMITER ;;

CREATE PROCEDURE create_account(
    IN a_email VARCHAR(255),
    IN a_password_hashed VARCHAR(255)
)
BEGIN
    INSERT INTO inlogging
        (email, password_hashed) 
    VALUES
    (a_email, a_password_hashed);
END;;

CREATE PROCEDURE create_profile(
    IN a_user_id INT,
    IN a_user_name VARCHAR(255)
)
BEGIN
    INSERT INTO profiles
        (user_id, user_name)
    VALUES
        (a_user_id, a_user_name);
END;;

    CREATE PROCEDURE create_quest(
    IN a_quest_name VARCHAR(255),
    IN a_user_id INT,
    IN a_quest_type VARCHAR(50),
    IN a_due_time DATE
)
BEGIN 

    DECLARE b_due_time DATE;

    IF a_due_time IS NULL THEN
        IF a_quest_type = 'daily' THEN
            SET b_due_time = CURDATE();
        ELSEIF a_quest_type = 'weekly' THEN
            SET b_due_time = DATE_ADD(CURDATE(), INTERVAL 7 DAY);
        END IF;
    ELSE
        SET b_due_time = a_due_time;
    END IF;

    INSERT INTO quests
        (quest_name, user_id, quest_type, due_time)
    VALUES 
        (a_quest_name, a_user_id, a_quest_type, b_due_time);
END;;

CREATE PROCEDURE add_description_to_quest(
    IN a_quest_id INT,
    IN a_description TEXT
)
BEGIN
    UPDATE quests
    SET quest_description = a_description
    WHERE quest_id = a_quest_id;
END;;

CREATE PROCEDURE complete_quest(
    IN a_quest_id INT
)
BEGIN
    DECLARE a_user_id INT;
    DECLARE a_quest_name VARCHAR(255);
    DECLARE a_quest_description TEXT;
    DECLARE a_quest_type VARCHAR(6);

    UPDATE quests
    SET completed_time = CURDATE()
    WHERE quest_id = a_quest_id;

    SELECT 
        user_id,
        quest_name,
        quest_description,
        quest_type
    INTO 
        a_user_id,
        a_quest_name,
        a_quest_description,
        a_quest_type
    FROM quests
    WHERE quest_id = a_quest_id;

    INSERT INTO completed_quests
        (quest_id, user_id, quest_name, quest_description, quest_type, completed_time)
    VALUES
        (a_quest_id, a_user_id, a_quest_name, a_quest_description, a_quest_type, CURDATE());
END;;

CREATE PROCEDURE get_badge(
    IN a_user_id INT,
    IN a_badge_id INT
)
BEGIN
    INSERT INTO owned_badges 
        (user_id, badge_id)
    VALUES
        (a_user_id, a_badge_id);
END;;

CREATE PROCEDURE start_streak(
    IN a_user_id INT,
    IN a_streak_id INT
)
BEGIN
    INSERT INTO ongoing_streaks 
        (user_id, streak_id)
    VALUES
        (a_user_id, a_streak_id);
END;;


CREATE PROCEDURE buy_items(
    IN a_user_id INT,
    IN a_item_id INT,
    IN a_quantitie INT,
    IN a_item_cost INT
)
BEGIN
    INSERT INTO owned_items
        (user_id, item_id, quantitie)
    VALUES
        (a_user_id, a_item_id, a_quantitie)
    ON DUPLICATE KEY UPDATE 
        quantitie = quantitie + a_quantitie;
    
    UPDATE profiles
    SET coins = coins - a_item_cost
    WHERE user_id = a_user_id;
END;;


CREATE PROCEDURE earn_coins(
    IN a_quest_id INT,
    IN a_user_id INT
)
BEGIN
    DECLARE a_quest_type VARCHAR(50);
    DECLARE a_coins INT;

    SELECT quest_type INTO a_quest_type
    FROM quests
    WHERE quest_id = a_quest_id;

    IF a_quest_type = 'weekly'
    THEN SET a_coins = 100;

    ELSEIF a_quest_type = 'daily'
    THEN SET a_coins = 50;

    ELSE SET a_coins = 200;
    END IF;

    UPDATE profiles
    SET coins = coins + a_coins
    WHERE user_id = a_user_id;
END;;



CREATE PROCEDURE earn_xp(
    IN a_quest_id INT,
    IN a_user_id INT
)
BEGIN
    DECLARE a_quest_type VARCHAR(50);
    DECLARE a_xp INT;

    SELECT quest_type INTO a_quest_type
    FROM quests
    WHERE quest_id = a_quest_id;

    IF a_quest_type = 'weekly'
    THEN SET a_xp = 10;

    ELSEIF a_quest_type = 'daily'
    THEN SET a_xp = 5;

    ELSE SET a_xp = 20;
    END IF;

    UPDATE profiles
    SET xp = xp + a_xp
    WHERE user_id = a_user_id;
END;;

CREATE PROCEDURE end_streak(
    IN streak_id INT,
    IN user_id INT
)
BEGIN 
    DELETE FROM ongoing_streaks
    WHERE streak_id = a_streak_id
    AND user_id = a_user_id;
END;;

CREATE PROCEDURE delete_quest(
    IN a_quest_id INT
)
BEGIN
    DELETE FROM quests
    WHERE quest_id = a_quest_id;
END;;

CREATE PROCEDURE show_quests(
    IN a_user_id INT
)
BEGIN
    SELECT
        quest_name,
        quest_description,
        quest_type,
        due_time,
        quest_status
    FROM quests
    WHERE user_id = a_user_id;
END;;

CREATE PROCEDURE show_completed_quests(
    IN a_user_id INT
)
BEGIN 
    SELECT 
        quest_name,
        quest_description,
        DATE_FORMAT(completed_time, '%Y-%m-%d') AS completed_time,
        quest_type
    FROM completed_quests
    WHERE user_id = a_user_id;
END;;

CREATE PROCEDURE show_upcoming_quests(
    IN a_user_id INT
)
BEGIN
    SELECT
        quest_name,
        quest_description,
        quest_type,
        DATE_FORMAT(due_time, '%Y-%m-%d') AS due_time,
        DATEDIFF(due_time, CURRENT_DATE()) AS 'due_in',
        quest_status,
        quest_id
    FROM quests
    WHERE user_id = a_user_id
    AND quest_status = 'uncompleted';
END;;

CREATE PROCEDURE show_daily_quests(
    IN a_user_id INT
)
BEGIN
    SELECT 
        quest_name,
        quest_description,
        quest_status
    FROM quests
    WHERE user_id = a_user_id
    AND quest_type = 'daily';
END;;



CREATE PROCEDURE show_user_badges(
    IN a_user_id INT
)
BEGIN
    SELECT 
        b.badge_name AS 'Badge name',
        b.badge_description AS 'Describtion'
    FROM badges AS b
    JOIN owned_badges AS ob
        ON ob.badge_id = b.badge_id
    WHERE ob.user_id = a_user_id;
END;;


CREATE PROCEDURE show_user_streaks(
    IN a_user_id INT
)
BEGIN
    SELECT 
        s.streak_name AS 'Streak name',
        s.streak_description AS 'Describtion'
    FROM streaks AS s
    JOIN ongoing_streaks AS os
        ON os.streak_id = s.streak_id
    WHERE os.user_id = a_user_id;
END;;

CREATE PROCEDURE show_user_rewards (
    IN a_user_id INT
)
BEGIN
    SELECT 
        coins,
        xp
    FROM profiles
    WHERE user_id = a_user_id;
END;

CREATE PROCEDURE show_user_profile (
    IN a_user_id INT
)
BEGIN
    SELECT 
        p.user_name AS 'user_name',
        DATE_FORMAT(p.user_age, '%Y-%m-%d') AS 'user_birthday',
        i.email AS 'email',
        i.password_hashed AS 'password_hashed'
    FROM profiles AS p 
    JOIN inlogging AS i 
        ON i.user_id = p.user_id
    WHERE p.user_id = a_user_id;
END;;

CREATE PROCEDURE show_store(
)
BEGIN
    SELECT 
        item_name AS 'Item name', 
        item_cost AS 'Cost',
        item_description AS 'Describtion'
    FROM store;
END;;

CREATE PROCEDURE add_age_to_profile(
    IN a_user_id INT,
    IN a_user_age DATE
)
BEGIN
    UPDATE profiles
    SET user_age = a_user_age
    WHERE user_id = a_user_id;
END;;

---
--- Triggers
---

CREATE TRIGGER complete_status
BEFORE UPDATE 
ON quests FOR EACH ROW
BEGIN 
    IF NEW.completed_time IS NOT NULL
    AND (OLD.completed_time IS NULL OR NEW.completed_time != OLD.completed_time) THEN
        IF NEW.completed_time = NEW.due_time THEN
            SET NEW.quest_status = 'completed on time';

            UPDATE completed_quests
            SET quest_status = 'completed on time'
            WHERE quest_id = NEW.quest_id;

        ELSEIF NEW.completed_time < NEW.due_time THEN
            SET NEW.quest_status = 'completed early';

            UPDATE completed_quests
            SET quest_status = 'completed early'
            WHERE quest_id = NEW.quest_id;

        ELSE
            SET NEW.quest_status = 'completed late';

            UPDATE completed_quests
            SET quest_status = 'completed late'
            WHERE quest_id = NEW.quest_id;
        END IF;
    END IF;
END;;

---
--- funtions
---

CREATE FUNCTION get_user_id (
    a_email VARCHAR(255),
    a_password_hashed VARCHAR(255)
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE a_user_id INT;
    SELECT user_id 
    INTO a_user_id
    FROM inlogging
    WHERE email = a_email 
    AND password_hashed = a_password_hashed;

    RETURN a_user_id;
END;;

DELIMITER ;
---
--- Events
---

CREATE EVENT reset_daily_quests
    ON SCHEDULE EVERY 1 DAY
    STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
UPDATE quests
SET
    due_time     = CURRENT_DATE + INTERVAL 1 DAY,
    quest_status = 'uncompleted'
WHERE quest_type = 'daily';

CREATE EVENT reset_weekly_quests
    ON SCHEDULE EVERY 1 DAY
    STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
UPDATE quests
SET
    due_time = DATE_ADD(
        due_time,
        INTERVAL 7 * (DATEDIFF(CURRENT_DATE, due_time) DIV 7 + 1) DAY
        ),
    quest_status = 'uncompleted'
WHERE quest_type = 'weekly'
AND due_time <= CURRENT_DATE;

/* CREATE EVENT late_status
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE quests
    SET quest_status = 'late'
    WHERE completed_time IS NULL
    AND due_time < NOW(); */