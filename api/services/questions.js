/**
 * Created by Aurelien PRIEUR on 18/05/16 for api.
 */
"use strict";

var path = require('path');
var notificationsService = require(path.resolve('services/notifications.js'));

module.exports = (function() {
    var questionsService = {};

    questionsService.notifyUsersNewQuestion = function(users, question) {
        console.log(users.length);
        for (var i = 0; i < users.length; ++i) {
            var devices = users[i].Devices;
            for (var j = 0; j < devices.length; ++j) {
                var questionTextPayload = (question.question) ? question.question.substring(0, 50) : "";
                notificationsService.sendNotification(devices[j], {title: question.title, body: questionTextPayload}, {type: "newQuestion", questionId: question.id});
            }
        }
    };

    return questionsService;
})();