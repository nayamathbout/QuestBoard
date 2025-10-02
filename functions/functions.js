/**
 * A module exporting functions to access the QuestBoard database.
 */
"use strict";

const bcrypt = require("bcrypt");

module.exports = {
    createUser,
    createQuest,
    completeQuest,
    deleteQuest,
    giveBadge,
    startStreak,
    endStreak,
    buyItem, 
    showQuests,
    showCompletedQuests,
    showUpcomingQuests,
    showDailyQuests,
    showUserBadges,
    showUserStreaks,
    showUserRewards,
    showUserProfile,
    showStore,
    logIn,
    addBirthday,
    addDescriptionToQuest,
    validateEmail, 
    validatePassword,
    ensureEmailIsUnique
};


const mysql  = require("promise-mysql");
const config = require("../config/questboard.json");


async function createUser(user_name, email, password) {
    const db = await mysql.createConnection(config);
    await db.query('CALL create_account(?, ?)', [email, password]);

    const rows = await db.query('SELECT LAST_INSERT_ID() AS user_id');
    const user_id = rows[0].user_id;

    await db.query('CALL create_profile(?, ?)', [user_id, user_name]);
    await db.end();
}

async function createQuest(quest_name, user_id, quest_type, due_date, description) {
    let sql = `CALL create_quest(?, ?, ?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [quest_name, user_id, quest_type, due_date]);

        if (description) {
            const rows = await db.query('SELECT LAST_INSERT_ID() AS quest_id');
            const quest_id = rows[0].quest_id;
            
            let sql = `CALL add_description_to_quest(?, ?);`;
            await db.query(sql, [quest_id, description]);
        };

    await db.end();
}


async function completeQuest(quest_id, user_id) {
    let sql = `CALL complete_quest(?);`;
    let sqlcoins = `CALL earn_coins(?, ?)`
    let sqlxp = `CALL earn_xp(?, ?)`
    const db = await mysql.createConnection(config);

    await db.query(sql, [quest_id]);
    await db.query(sqlcoins, [quest_id, user_id]);
    await db.query(sqlxp, [quest_id, user_id]);

    await db.end();
}

async function deleteQuest(quest_id) {
    let sql = `CALL delete_quest(?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [quest_id]);

    await db.end();
}

async function giveBadge(user_id, badge_id) {
    let sql = `CALL give_badge(?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [user_id, badge_id]);

    await db.end();
}

async function startStreak(user_id, streak_id) {
    let sql = `CALL start_streak(?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [user_id, streak_id]);

    await db.end();
}


async function endStreak(user_id, streak_id) {
    let sql = `CALL end_streak(?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [user_id, streak_id]);

    await db.end();
}

async function buyItem(user_id, item_id, quantitie, item_cost) {
    let sql = `CALL buy_item(?, ?, ?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [user_id, item_id, quantitie, item_cost]);

    await db.end();
}


async function showQuests(user_id) {
    let sql = `CALL show_quests(?);`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql, [user_id]);
    await db.end();

    return res[0];
}

async function showCompletedQuests(user_id) {
    let sql = `CALL show_completed_quests(?);`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql, [user_id]);
    await db.end();

    return res[0];
}

async function showUpcomingQuests(user_id) {
    let sql = `CALL show_upcoming_quests(?);`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql, [user_id]);
    await db.end();

    return res[0];
}

async function showDailyQuests(user_id) {
    let sql = `CALL show_daily_quests(?);`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql, [user_id]);
    await db.end();

    return res[0];
}

async function showUserBadges(user_id) {
    let sql = `CALL show_user_badges(?);`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql, [user_id]);
    await db.end();

    return res[0];
}

async function showUserStreaks(user_id) {
    let sql = `CALL show_user_streaks(?);`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql, [user_id]);
    await db.end();

    return res[0];
}

async function showUserRewards(user_id) {
    let sql = `CALL show_user_rewards(?);`;
    const db = await mysql.createConnection(config);

    const [result] = await db.query(sql, [user_id]);
    await db.end();

    const rows = Array.isArray(result) ? result : [];
    return rows[0];
}


async function showUserProfile(user_id) {
    let sql = `CALL show_user_profile(?);`;
    const db = await mysql.createConnection(config);

    const [result] = await db.query(sql, [user_id]);
    await db.end();

    const rows = Array.isArray(result) ? result : [];
    return rows[0];
}


async function showStore() {
    let sql = `CALL show_store();`;
    const db = await mysql.createConnection(config);

    let res = await db.query(sql);
    await db.end();

    return res[0];
}


async function logIn(email, password) {
    let sql = `SELECT user_id, password_hashed FROM inlogging WHERE email = ?;`;

    const db = await mysql.createConnection(config);
    const [result] = await db.query(sql, [email]);
    const row = Array.isArray(result) ? result[0] : result;

    let userId = null;

    if (row && row.password_hashed) {
        const ok = await bcrypt.compare(password, row.password_hashed);
        if (ok) {
            userId = row.user_id;
        }
    }

    await db.end();
    return userId;
}

async function addBirthday(user_id, birthday) {
    let sql = `CALL add_age_to_profile(?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [user_id, birthday]);

    await db.end();
}


async function addDescriptionToQuest(quest_id, quest_description) {
    let sql = `CALL add_description_to_quest(?, ?);`;
    const db = await mysql.createConnection(config);

    await db.query(sql, [quest_id, quest_description]);

    await db.end();
}

async function validateEmail(email) {
    return /^[a-z0-9][a-z0-9._%+-]*@[a-z0-9.-]+\.[a-z]{2,}$/i.test(email);
}

async function validatePassword(password) {
    return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/.test(password);
}

async function ensureEmailIsUnique(email) {
    let sql = `SELECT email FROM inlogging WHERE email = ?`;
    const db = await mysql.createConnection(config);
    const [rows] = await db.query(sql, [email]);

    if (rows.length === 0){
        return true;
    }
    else {
        return false;
    }
}