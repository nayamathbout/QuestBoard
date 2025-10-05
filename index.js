// "use strict";

// const port    = process.env.DBWEBB_PORT || 1337;
// const path    = require("path");
// const express = require("express");
// // const session = require("express-session");
// const app     = express();
// const routeQuestBoard = require("./route/route.js");
// const middleware = require("./middleware/index.js");

// app.set("view engine", "ejs");

// app.use(middleware.logIncomingToConsole);
// app.use(express.static(path.join(__dirname, "public")));
// app.use(express.urlencoded({ extended: false }));
// /* app.use(session({
//     secret: "REDACTED_SESSION_SECRET",
//     resave: false,
//     saveUninitialized: true,
//     cookie: {
//     httpOnly: true,
//     secure: process.env.NODE_ENV === "production",
//     maxAge: 1000 * 60 * 60 * 24 
// }})); */
// app.use("/QuestBoard", routeQuestBoard);
// app.listen(port, logStartUpDetailsToConsole);



// /**
//  * Log app details to console when starting up.
//  *
//  * @return {void}
//  */
// function logStartUpDetailsToConsole() {
//     let routes = [];

//     // Find what routes are supported
//     app._router.stack.forEach((middleware) => {
//         if (middleware.route) {
//             // Routes registered directly on the app
//             routes.push(middleware.route);
//         } else if (middleware.name === "router") {
//             // Routes added as router middleware
//             middleware.handle.stack.forEach((handler) => {
//                 let route;

//                 route = handler.route;
//                 route && routes.push(route);
//             });
//         }
//     });

//     console.info(`Server is listening on port ${port}.`);
//     console.info("Available routes are:");
//     console.info(routes);
// }

"use strict";

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
    secret: "REDACTED_SESSION_SECRET",
    resave: false,
    saveUninitialized: true
}));
app.use("/QuestBoard", routeQuestBoard);
app.listen(port);



/**
 * Log app details to console when starting up.
 *
 * @return {void}
 */
function logStartUpDetailsToConsole() {
    let routes = [];

    // Find what routes are supported
    app._router.stack.forEach((middleware) => {
        if (middleware.route) {
            // Routes registered directly on the app
            routes.push(middleware.route);
        } else if (middleware.name === "router") {
            // Routes added as router middleware
            middleware.handle.stack.forEach((handler) => {
                let route;

                route = handler.route;
                route && routes.push(route);
            });
        }
    });

    console.info(`Server is listening on port ${port}.`);
    console.info("Available routes are:");
    console.info(routes);
}
