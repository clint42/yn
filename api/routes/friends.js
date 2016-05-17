/**
 * Created by Aurelien PRIEUR on 02/05/16 for api.
 */

"use strict";

var path = require('path');
var router = require('express').Router();
var models = require(path.resolve('models'));
var auth = require(path.resolve('middlewares/authentication'));

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
        case "phone":
            orderBy = "phone";
        default:
            wrongValue = true
    }
    if ((orderRule == "DESC" || orderRule == "ASC") && !wrongValue) {
        req.currentUser.getFriendUsers(nResults, offset, orderBy, orderRule).then(function(friends) {
            res.json({friends: friends});
        }).catch(function(err) {
            //TODO: Error handling
            next(err, req, res);
        });
    }
    else {
        res.status(422);
        res.json({error: "Invalid parameter value"});
    }

});

router.get('/receivedRequests', auth, function(req, res, next) {
    var nResults = req.body.nResults ||10;
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
        models.User.getUser(identifier).then(function(userToAdd) {
            //Associate friend
            req.currentUser.addFriend(userToAdd, {requestStatus: 'PENDING'}).then(function(associated) {
                res.status(201);
                res.json({success: true});
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
               //TODO: Error handling
               next(err, req, res);
           })
        }).catch(function(err) {
            //TODO: Error handling
            next(err, req, res);
        });
    }
});

router.post('/answer', auth, function(req, res, next) {
    var identifier = req.body.identifier,
        accept = req.body.accept;
    console.log("ACCEPT IN ROUTE: ", accept);
    if (identifier !== undefined && accept !== undefined) {
        models.User.getUser(identifier).then(function(user) {
            req.currentUser.answerRequest(user, accept).then(function() {
                res.status(201);
                res.json({success: true});
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