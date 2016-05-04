/**
 * Created by Aurelien PRIEUR on 02/05/16 for api.
 */
"use strict";

var path = require('path');
var models = require(path.resolve('models'));

module.exports = function(req, res, next) {
    var userId = (req.body && req.body.userId) || req.headers['x-user-id'];
    var token = (req.body && req.body.access_token) || req.headers['x-access-token'];
    if (!token || !userId) {
        //TODO: Error handling
        next("Token or userId are missing", req, res);
    }
    else {
        models.User.findOne({
            where: {
                id: userId,
                authToken: token
            }
        }).then(function(user) {
            if (!user) {
                //TODO: Error handling
                next("User with this token not found", req, res);
            }
            else {
                req.currentUser = user;
                next();
            }
        }).catch(function(err) {
            //TODO: Error handling
            next("Database error: " + err, req, res);
        })
    }
};