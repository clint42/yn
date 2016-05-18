/**
 * Created by Aurelien PRIEUR on 17/05/16 for api.
 */
"use strict";

var path = require('path');
var apn = require('apn');

module.exports = (function() {
    var notificationService = {};

    var options = {
        cert: path.resolve("apns/apnsCertDev.pem"),
        key: path.resolve("apns/apnsKeyDev.pem")
    };

    var apnConnection = apn.Connection(options);

    notificationService.sendNotificationToDevice = function(deviceToken) {
        var device = apn.device(token);
        var notif = apn.Notification();
        notif.badge = 1;
        notif.alert = "Test Notification";
        notif.payload = {dev: "Test"}
        apnConnection.pushNotification(notif, device);
    };

    return notificationService;
})();