/**
 * Created by Aurelien PRIEUR on 18/05/16 for api.
 */
"use strict";

var path = require('path');
var notificationsService = require(path.resolve('services/notifications.js'));

module.exports = (function() {
    var questionsService = {};

    questionsService.notifyUsersNewQuestion = function(users, question) {
        for (var i = 0; i < users.length; ++i) {
            var devices = users[i].Devices;
            for (var i = 0; i < devices.length; ++i) {
                console.log("Send notification");
                notificationsService.sendNotification(devices[i], {title: question.title, body: question.question.substring(0, 50)}, {type: "newQuestion", idQuestion: question.id});
            }
        }
    };

    return questionsService;
})();