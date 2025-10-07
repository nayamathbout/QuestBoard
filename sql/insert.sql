---
--- insert into the tables
---
DELETE FROM streaks;
DELETE FROM badges;
DELETE FROM store;

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

INSERT INTO store
    (item_id, item_name, item_cost, item_description)
VALUES
    (1, 'Kitty Avatar', 150, 'Hello kitty inspired AI generated avatar'),
    (2, 'Sponge Avatar', 150, 'SpongeBob inspired AI generated avatar'),
    (3, 'Teddy Avatar', 150, 'Whinnie The Poo inspiered AI generated avatar'),
    (4, 'Ghost Avatar', 150, 'Ghost Face inspired AI generated avatar'),
    (5, 'Moon Avatar', 150, 'Sailor Moon inspired AI generated avatar'),
    (6, 'Bat Avatar', 150, 'Batman inspired AI generated avatar');


