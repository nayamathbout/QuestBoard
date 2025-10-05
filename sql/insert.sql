---
--- insert into the tables
---
DELETE FROM streaks;
DELETE FROM badges;

INSERT INTO streaks
    (streak_id, streak_name, streak_description)
VALUES
    (1, 'Log in streak', 'Days you have logged in, in a row'),
    (2, 'Quest completion streak', 'Quests you have completed on time in a row');

INSERT INTO badges
    (badge_id, badge_name, badge_description)
VALUES 
    (1, '7 Days Streak Badge', 'You have completed a 7 days streak!'),
    (2, '10 Quests Badge', 'You have completed 10 quests!'),
    (3, 'Weekly Quest Badge', 'You have completed a weekly quest!');

