"use strict";
require("dotenv").config();

const port    = process.env.DBWEBB_PORT || 1337;
const path    = require("path");
const express = require("express");
const session = require("express-session");
const app     = express();
app.use("/style", express.static(path.join(__dirname, "./views/style")));
const routeQuestBoard = require("./route/route.js");
const middleware = require("./middleware/index.js");
app.set("view engine", "ejs");

app.use(middleware.logIncomingToConsole);
app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: false }));
app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true
}));
app.use("/QuestBoard", routeQuestBoard);
app.listen(port);

module.exports = app;