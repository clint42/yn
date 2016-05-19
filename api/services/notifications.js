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
        key: path.resolve("apns/apnsKeyDev.pem"),
        production: false
    };

    var apnConnection = apn.Connection(options);

    notificationService.sendNotificationToDevice = function(deviceToken) {
        var device = apn.device(token);
        var notif = new apn.Notification();
        notif.badge = 1;
        notif.alert = "Test Notification";
        notif.payload = {dev: "Test"}
        apnConnection.pushNotification(notif, device);
    };

    notificationService.sendNotification = function(device, alertTitle, payload, badgeUpdate) {
        if (badgeUpdate === undefined) {
            badgeUpdate = true
        }
        var apnDevice = apn.device(device.token);
        var notif = new apn.Notification();
        if (badgeUpdate) {
            device.badgeValue += 1;
            device.save({transaction: null});
        }
        notif.badge = device.badgeValue;
        notif.alert = alertTitle;
        notif.payload = payload;
        apnConnection.pushNotification(notif, apnDevice);
    };

    return notificationService;
})();