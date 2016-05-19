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
            for (var j = 0; j < devices.length; ++j) {
                console.log("Send notification");
                notificationsService.sendNotification(devices[j], {title: question.title, body: question.question.substring(0, 50)}, {type: "newQuestion", questionId: question.id});
            }
        }
    };

    return questionsService;
})();