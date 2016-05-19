/**
 * Created by Aurelien PRIEUR on 02/05/16 for api.
 */

"use strict";

var path = require('path');
var router = require('express').Router();
var models = require(path.resolve('models'));
var auth = require(path.resolve('middlewares/authentication'));
var friendsService = require(path.resolve('services/friends'));

router.get('/my', auth, function(req, res, next) {
    var nResults = req.query.nResults || 10;
    var offset = req.query.offset || 0;
    var orderBy = req.query.orderBy || undefined;
    var orderRule = req.query.orderRule || "ASC";
    var wrongValue = false;
    switch (orderBy) {
        case "username":
            orderBy = "username";
            break;
        case "email":
            orderBy = "email";
            break;
        case "phone":
            orderBy = "phone";
            break;
        default:
            wrongValue = true
    }
    if ((orderRule == "DESC" || orderRule == "ASC") && !wrongValue) {
        req.currentUser.getFriendUsers(nResults, offset, orderBy, orderRule).then(function(friends) {
            res.json({friends: friends});
        }).catch(function(err) {
            //TODO: Error handling
            console.log("error: " + err);
            res.status(500);
            res.json({error: "Error: " + err});
        });
    }
    else {
        res.status(422);
        res.json({error: "Invalid parameter value"});
    }

});

router.get('/receivedRequests', auth, function(req, res, next) {
    var nResults = req.body.nResults || 10;
    var offset = req.body.offset || 0;
    req.currentUser.getFriendRequestUsers(nResults, offset).then(function(usersWithRequest) {
        res.json({
            usersRequests: usersWithRequest
        });
    }).catch(function(err) {
       //TODO: Error handling
        console.log(err);
        next(err, req, res);
    });
});

router.get('/countPendingRequests', auth, function(req, res, next) {
    req.currentUser.getNumberOfFriendRequestUsers().then(function(count) {
        res.json({
            count: count
        });
    }).catch(function(err) {
        //TODO: Error handling
        console.log(err);
        next(err, req, res);
    });
});

router.get('/sendedRequests', auth, function(req, res, next) {
    var nResults = req.body.nResults || 10;
    var offset = req.body.offset || 0;
    req.currentUser.getFriendPendingRequestUsers(nResults, offset).then(function(usersWithRequest) {
        res.json({
            usersRequests: usersWithRequest
        });
    }).catch(function(err) {
        //TODO: Error handling
        next(err, req, res);
    })

});

router.post('/add', auth, function(req, res, next) {
    var identifier = req.body.identifier;
    if (identifier) {
        //Retrieve user to add as friend
        //TODO: Put these two query inside a transaction
        models.User.getUser(identifier).then(function(userToAdd) {
            //Associate friend
            req.currentUser.addFriend(userToAdd, {requestStatus: 'PENDING'}).then(function(associated) {
                userToAdd.getDevices().then(function(devices) {
                    friendsService.notifyRequest(devices, req.currentUser);
                    res.status(201);
                    res.json({success: true});
                }).catch(function(err) {
                    //TODO: Error handling
                    res.status(500);
                    res.json({error: "Error while retrieving user devices"});
                });
            }).catch(function(err) {
                //TODO: Error handling
                next(err, req, res);
            })
        }).catch(function(err) {
            //TODO: Error Handling
            next(err, req, res);
        });
    }
});

router.post('/delete', auth, function(req, res, next) {
   var identifier = req.body.identifier;
    if (identifier) {
        models.User.getUser(identifier).then(function(userToDelete) {
           req.currentUser.deleteFriend(userToDelete).then(function(associated) {
             res.status(201);
               res.json({success: true});
           }).catch(function(err) {
               res.status(422);
               res.json({error: err.detail});
           })
        }).catch(function(err) {
            res.status(422);
            res.json({error: err.detail});
        });
    }
});

router.post('/answer', auth, function(req, res, next) {
    var identifier = req.body.identifier,
        accept = req.body.accept;
    console.log("ACCEPT IN ROUTE: ", accept);
    if (identifier !== undefined && accept !== undefined) {
        //TODO:  Put these two query inside a transaction
        models.User.getUser(identifier).then(function(user) {
            req.currentUser.answerRequest(user, accept).then(function() {
                user.getDevices().then(function(devices) {
                    friendsService.notifyAccepted(devices, user);
                    res.status(201);
                    res.json({success: true});
                }).catch(function(err) {
                    //TODO: Error handling
                    res.status(500);
                    res.json({error: "An error occurred while retrieving user devices: " + err});
                });

            }).catch(function(err) {
                //TODO: Error handling
                next(err, req, res);
            })
        }).catch(function(err) {
            //TODO: Error handling
            next(err, req, res);
        });
    }
});

module.exports = router;