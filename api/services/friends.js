/**
 * Created by Aurelien PRIEUR on 19/05/16 for api.
 */
"use strict";

var path = require('path');
var notificationsService = require(path.resolve('services/notifications'));

module.exports = (function() {
    var friendsService = {};

    friendsService.notifyRequest = function(devices, userRequesting) {
        for (var i = 0; i < devices; ++i) {
            notificationsService.sendNotification(devices[i], userRequesting.username + " wants to be friend with you", {type: "friendRequest", userId: userRequesting.id});
        }
    };
    return friendsService;
})();