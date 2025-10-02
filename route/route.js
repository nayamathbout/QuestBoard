/**
 * Route for QuestBoard.
 */

"use strict";


const express = require("express");
const router  = express.Router();
const bcrypt = require("bcrypt");
const questboard    = require("../functions/functions.js");

function ensureLoggedIn(req, res, next) {
    if (req.session && req.session.userId) {
        return next();
    }
    return res.redirect("QuestBoard/login");
}

router.get("/signup", async (req, res) => {
    let data = {
        title: "Sign up"
    };

    res.render("QuestBoard/signup", data);
});

router.post("/signup", async (req, res) => {
    let { user_name, email, password } = req.body;

    const hashedPassword = await bcrypt.hash(password, 12);
    await questboard.createUser(user_name, email, hashedPassword);

    res.redirect("/QuestBoard/account_created");
});


router.get("/account_created", async (req, res) => {
    let data = {
        title: "Account Created"
    };

    res.render("QuestBoard/account_created", data);
});

router.get("/login", async (req, res) => {
    let data = { title: "Log In", error: null };

    if (req.session.flash && req.session.flash.error) {
        data.error = req.session.flash.error;
        delete req.session.flash; 
    }

    res.render("QuestBoard/login", data);
});

router.post("/login", async (req, res) => {
    let { email, password } = req.body;
    const userId = await questboard.logIn(email, password);

    if (userId) {
        req.session.userId = userId;
        return res.redirect("/QuestBoard/dashboard");
    }

    req.session.flash = { error: "Email or password are not correct." };
    return res.redirect("/QuestBoard/login");
});

router.get("/dashboard", ensureLoggedIn, async (req, res) => {
    let user_id = req.session.userId;
    const upcomingQuests = await questboard.showUpcomingQuests(user_id);
    const completedQuests = await questboard.showCompletedQuests(user_id);
    const dailyQuests = await questboard.showDailyQuests(user_id);
    const rewards = await questboard.showUserRewards(user_id);

    res.render("QuestBoard/dashboard", {
        title: "View Profile", upcomingQuests, completedQuests, dailyQuests, rewards});
});


router.post("/dashboard", ensureLoggedIn, async (req, res) => {
    const quest_id  = req.body.quest_id;
    let user_id = req.session.userId;
    await questboard.completeQuest(quest_id, user_id);

    res.redirect("/QuestBoard/dashboard");
});


router.get("/quest", ensureLoggedIn, async (req, res) => {
    let data = {
        title: "Create a Quest"
    };

    res.render("QuestBoard/quest", data);
});


router.post("/quest", ensureLoggedIn, async (req, res) => {
    let { quest_name, quest_type, due_date, description } = req.body;
    const newDue = due_date && due_date.trim() !== '' ? due_date : null;
    let user_id = req.session.userId;
    await questboard.createQuest(quest_name, user_id, quest_type, newDue, description);

    res.redirect("/QuestBoard/dashboard");
});


router.get("/profile", ensureLoggedIn, async (req, res) => {

    let user_id = req.session.userId;
    const profile = await questboard.showUserProfile(user_id);
    const rewards = await questboard.showUserRewards(user_id);

    res.render("QuestBoard/profile", {
        title: "View Profile", profile, rewards});
});

router.get("/add_birthday", ensureLoggedIn, async (req, res) => {
    let data = {
        title: "Add your birthday"
    };

    res.render("QuestBoard/add_birthday", data);
});

router.post("/add_birthday", ensureLoggedIn, async (req, res) => {
    let { birthday } = req.body;
    let user_id = req.session.userId;
    await questboard.addBirthday(user_id, birthday);

    res.redirect("/QuestBoard/profile");
});

//

router.get("/add_description", ensureLoggedIn, async (req, res) => {
    const quest_id = req.query.quest_id;
    let data = {
        title: "Add description to quest",
        quest_id
    };

    res.render("QuestBoard/add_description", data);
});

router.post("/add_description", ensureLoggedIn, async (req, res) => {
    let { quest_id, description } = req.body;
    await questboard.addDescriptionToQuest(quest_id, description);

    res.redirect("/QuestBoard/dashboard");
});



router.get("/logout", (req, res) => {
    req.session.destroy(err => {
        res.redirect("/QuestBoard/login");
    });
});


module.exports = router;