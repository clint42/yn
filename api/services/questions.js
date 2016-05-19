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
                var questionTitle
                if (question.question) {
                    questionTitle = {title: question.title, body: question.question.substring(0, 50)};
                }
                else {
                    questionTitle = question.title;
                }
                notificationsService.sendNotification(devices[j], questionTitle, {type: "newQuestion", questionId: question.id});
            }
        }
    };

    return questionsService;
})();