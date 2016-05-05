/**
 * Created by Aurelien PRIEUR on 02/05/16 for api.
 */

"use strict";

var path = require('path');
var router = require('express').Router();
var models = require(path.resolve('models'));
var auth = require(path.resolve('middlewares/authentication'));

router.get('/my', auth, function(req, res, next) {
    var nResults = req.body.nResults || 10;
    var offset = req.body.offset || 0;
    models.Friend.findAll({
        where: {
            'UserId': req.currentUser.id
        }
    });
    models.User.findAll({
        where: {
            'id': req.currentUser.id
        },
        include: [{
            model: models.Friend,
            through: {where: {
                'Friend.statusRequest': 'ACCEPTED'
            }}
        }]
    }).then(function(friends) {
        res.json({
            friends: friends
        });
    }).catch(function(err) {
        console.log("Error while retreving friends: " + err);
        next("Error while retriveing friends", req, res);
    });
});

router.get('/requests', auth, function(req, res, next) {
    var nResults = req.body.nResults ||10;
    var offset = req.body.offset || 0;
    models.Friend.findAll({
        where: {
            'UserId': req.currentUser.id,
            'requestStatus': 'SENT'
        },
        include: [models.User]
    }).then(function(friendRequests) {
        /*console.log(friendRequests[0]);
        friendRequests.prototype.toJSON = function() {
            var resp = this.get();
            delete resp.User.password;
            return resp;
        };*/
        res.json({friendRequests: friendRequests});
    }).catch(function(err) {
        console.log(err);
    });

    /*req.currentUser.getFriends({
        limit: parseInt(nResults),
        offset: parseInt(offset),
        where: {
            'Friends.UserId': req.currentUser.id,
            'Friends.requestStatus': 'SENT'
        },
        include: [models.Friend]
    }).then(function(friends) {
        for (var i = 0; i < friends.length; ++i) {
            console.log(friends[0].email);
        }
    }).catch(function(err) {
        console.log("Error: " + err);
    });*/
    //res.json({devMsg: 'Not implemented yet'});
});

router.post('/add', auth, function(req, res, next) {
    var identifier = req.body.identifier;
    if (identifier) {
        //Retrieve user to add as friend
        models.User.getUser(identifier).then(function(userToAdd) {
            console.log('UserToAdd');
            req.currentUser.addFriend(userToAdd, {requestStatus: 'PENDING'}).then(function(associated) {
                console.log("Associate 1: " + associated);
                userToAdd.addFriend(req.currentUser).then(function(associated) {
                    console.log("Associate 2: " + associated);
                }).catch(function(err) {
                    console.log("Error Associate 2:  " + err);
                })
            }).catch(function(err) {
                console.log("Error Associate 1: " + err);
            })
        }).catch(function(err) {
            console.log("Error while retrieving user to add: " + err);
        });
    }
    res.json({devMsg: "Not implemented yet"});
});


module.exports = router;