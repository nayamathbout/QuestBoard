/**
 * General middleware.
 */
"use strict";

/**
 * Log incoming requests to console to see who accesses the server
 * on what route.
 *
 * @param {Request}  req
 * @param {Response} res
 * @param {Function} next
 *
 * @returns {void}
 */
function logIncomingToConsole(req, res, next) {
    console.info(`Got request on ${req.path} (${req.method}).`);
    next();
}



module.exports = {
    logIncomingToConsole: logIncomingToConsole
};
