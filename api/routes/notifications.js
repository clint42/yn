/**
 * Created by Aurelien PRIEUR on 17/05/16 for api.
 */
"use strict";

var router = require('express').Router();
var path = require('path');
var models = require(path.resolve('models'));
var auth = require(path.resolve('middlewares/authentication'));
var notificationService = require(path.resolve('services/notifications'));

router.post('/register-device', [auth], function(req, res, next) {
    var deviceToken = req.body.deviceToken;
    if (deviceToken) {
        models.Device.create({
            token: deviceToken
        }).then(function(device) {
            if (device) {
                device.setUser(req.currentUser).then(function(associated) {
                    res.status(201);
                    res.json({device: device});
                }).catch(function(err) {
                    //TODO: Error handling
                    res.status(500);
                    res.json({error: 'Error while associating user to device'});
                })
            }
            else {
                //TODO: Error handling
                res.status(500);
                res.json({error: 'Error while creating new device'});
            }
        }).catch(function(err) {
            //TODO: Error handling
            res.status(500);
            res.json({error: 'Error while creating new device: ' + err});
        })
    }
    else {
        res.status(422);
        res.json({error: 'Missing parameters'});
    }
});

router.delete('/unregister-device', [auth], function(req, res, next) {
    var deviceToken = req.query.deviceToken;
    if (deviceToken) {
        models.Device.destroy({
            where: {
                token: deviceToken,
                UserId: req.currentUser.id
            }
        }).then(function(result) {
            res.json({success: true});
        }).catch(function(err) {
            //TODO: Error handling
            res.status(500);
            res.json({error: "An error occurred while deleting user device"});
        })
    }
    else {
        //TODO: Error handling
        res.status(422);
        res.json({error: "Missing parameters"});
    }
});

router.post('/test', function(req, res, next) {
    models.User.getUser("prieur.aurelien@gmail.com").then(function(user) {
        if (user) {
            user.getDevices().then(function(devices) {
                console.log("devices: " + devices);
                res.json({devices: devices});
            }).catch(function(err) {
                console.log("Error while retrieving user devices");
                res.status(500);
                res.json({error: 'Erro while retriving user devices: ' + err});
            })
        }
        else {
            //TODO: Error handling
            res.json({error: "User not found"});
        }
    }).catch(function(err) {
        //TODO: Error handling
        res.status(500);
        res.json({error: 'An error occured while retrieving user: ' + err});
    })
});

module.exports = router;