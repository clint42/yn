/**
 * Created by Aurelien PRIEUR on 16/05/16 for api.
 */

"use strict";

var router = require('express').Router();
var path = require('path');
var auth = require(path.resolve('middlewares/authentication'));
var upload = require('multer')({dest: 'uploads/'});
var models = require(path.resolve('models'));
var uploadImage = upload.fields([{
    name: "image", maxCount: 1
}]);
var questionsService = require(path.resolve('services/questions'));

router.post('/', [auth, uploadImage], function(req, res, next) {
    var title = req.body.title;
    var questionText = req.body.question;
    var friendsJson = req.body.friends;
    if (title && questionText && friendsJson) {
            var questionData = {
                title: title,
                question: questionText
            };
            if (req.files['images']) {
                questionData.imageUrl = req.files['image'].destination + req.files['images'].filename;
            }

            var findFriendsOrClause = new Array();
            var friends = JSON.parse(friendsJson);
            for (var i = 0; i < friends.length; ++i) {
                findFriendsOrClause.push({id: friends[i]});
            }

            var friends;
            var questionObj;

            models.sequelize.transaction(function(t) {
                return models.User.findAll({
                    where: {
                        $or: findFriendsOrClause
                    },
                    include: [{model: models.Device}],
                    transaction: t
                }).then(function(friendsAsked) {
                    friends = friendsAsked;
                    return models.Question.create(questionData, {raw: false, transaction: t}).then(function(question) {
                        questionObj = question
                        return question.setOwner(req.currentUser, {transaction: t}).then(function(associated){
                            //console.log(models.Question.instance.prototype);
                            return question.addUsersAsked(friendsAsked, {transaction: t}).then(function(associated) {
                                console.log("FriendsAsked associated:  " + associated);
                            })
                        })
                    })
                })
            }).then(function(result) {
                questionsService.notifyUsersNewQuestion(friends, questionObj);
                res.status(201);
                res.json({success: true});
            }).catch(function(err) {
                console.log("Transaction error: " + err);
                res.status(500);
                res.json({error: 'Transaction error: ' + err});
            });



    }
    else {
        res.status(422);
        res.json({error: 'Invalid parameters'});
    }
});

router.get('/asked', auth, function(req, res, next) {
    var nResults = req.query.nResults || 10;
    var offset = req.query.offset || 0;
    var orderBy = req.query.orderBy || undefined;
    var orderRule = req.query.orderRule || "ASC";
    var wrongValue = false;
    switch (orderBy) {
        case "updatedAt":
            orderBy = "updatedAt";
            break;
        case "createdAt":
            orderBy = "createdAt";
        case "title":
            orderBy = "title";
        default:
            wrongValue = true
    }
    if ((orderRule == "DESC" || orderRule == "ASC") && !wrongValue) {
        req.currentUser.getQuestionsAsked(nResults, offset, orderBy, orderRule).then(function(questions) {
            res.json({questions: questions});
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

module.exports = router;