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
    console.log("OK");
    var title = req.body.title;
    var questionText = req.body.question;
    var friendsJson = req.body.friends;
    if (title && questionText && friendsJson) {
            var questionData = {
                title: title,
                question: questionText
            };
            if (req.files && req.files['image']) {
                questionData.imageUrl = req.files['image'][0].filename;
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
    nResults = parseInt(nResults);
    offset = parseInt(offset);
    switch (orderBy) {
        case "updatedAt":
            orderBy = "updatedAt";
            break;
        case "createdAt":
            orderBy = "createdAt";
            break;
        case "title":
            orderBy = "title";
            break;
        default:
            wrongValue = true
    };
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

router.get('/all', auth, function(req, res, next) {
    var nResults = req.query.nResults || 10;
    var offset = req.query.offset || 0;
    var orderBy = req.query.orderBy || undefined;
    var orderRule = req.query.orderRule || "ASC";

    if ((orderRule == "DESC" || orderRule == "ASC")) {
        req.currentUser.getAllQuestions(nResults, offset, orderBy, orderRule).then(function(questions) {
            res.json({
                questions: questions,
                userId: req.currentUser.id
            });
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

router.get('/details/:id((\\d+))', auth, function(req, res, next) {
    var qId = req.params.id;
    models.Question.findOne({
        where: {
            id: qId
        }
    }).then((question) => {
        question.getAnswers().then((answers) => {
            res.json({
                question: question,
                answers: answers
            });
        }).catch((error) => {
            next(error, req, res);
        });
    }).catch((error) => {
        next(error, req, res);
    });
});

router.get('/:questionId', [auth], function(req, res, next) {
    var questionId = req.params.questionId;
    if (questionId) {
        var questionToReturn = false;
        models.sequelize.transaction(function(t) {
            return models.Question.findOne({
                where: {
                    id: questionId
                }
            }).then(function(question) {
                return question.hasUserAsked(req.currentUser).then(function(result) {
                    if (result) {
                        questionToReturn = question;
                    }
                })
            })
        }).then(function(result) {
            if (questionToReturn) {
                res.json({question: questionToReturn});
            }
            else {
                res.status(403);
                res.json({error: "Unauthorized to see this question"});
            }
        }).catch(function(err) {
            console.log("An error occurred while retrieving question: " + err);
            res.status(500);
            res.json({error: "An error occurred while retrieving question: " + err});
        });
    }
    else {
        res.status(422);
        res.json({error: "Missing parameters"});
    }
});

router.post('/answerTo', auth, function(req, res, next) {
    var questionId = req.body.questionId;
    var answer = req.body.answer;

    req.currentUser.answerToQuestion(questionId, answer).then(function() {
        res.status(201);
        res.json({success: true});
    }).catch(function(err) {
       next(err, req, res);
    });
});

module.exports = router;