/**
 * Created by Aurelien PRIEUR on 16/05/16 for api.
 */

"use strict";

var router = require('express').Router();
var path = require('path');
var auth = require(path.resolve('middlewares/authentication.js'));
var upload = require('multer')({dest: 'uploads/'});
var models = require(path.resolve('models'));
var uploadImage = upload.fields([{
    name: "image", maxCount: 1
}]);

router.post('/', [auth, uploadImage], function(req, res, next) {
    var title = req.body.title;
    var questionText = req.body.question;
    if (title && questionText) {
        var question = {
            title: title,
            question: questionText
        };
        if (req.files['images']) {
            question.imageUrl = req.files['image'].destination + req.files['images'].filename;
        }
        models.Question.create(question).then(function(question) {
            console.log("Question created: " + question);
            question.setUser(req.currentUser).then(function(associated){
                console.log("Associated: " + associated);
                res.status(201);
                res.json({success: true});
            }).catch(function(err) {
                console.log("Association error: " + err);
                res.status(500);
                res.json({error: 'Error while associating question with user'});
            })
        }).catch(function(err) {
            console.log("Question creation error " + err);
            res.status(500);
            res.json({error: 'Error while creating question'});
        });
    }
    else {
        res.status(422);
        res.json({error: 'Invalid parameters'});
    }
});

module.exports = router;