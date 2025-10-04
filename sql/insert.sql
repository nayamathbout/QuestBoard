---
--- insert into the tables
---
DELETE FROM streaks;

INSERT INTO streaks
    (streak_id, streak_name, streak_description)
VALUES
    (1, 'Log in streak', 'Days you have logged in, in a row');

INSERT INTO streaks
    (streak_id, streak_name, streak_description)
VALUES
    (2, 'quest completion streak', 'Quests you have completed on time in a row');

