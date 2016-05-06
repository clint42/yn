/**
 * Created by Aurelien PRIEUR on 05/05/16 for api.
 */
"use strict";

var path = require('path');
var models = require(path.resolve('models'));

describe("Create & Save Users in DB", function() {
    before(function(done) {
        models.sequelize.transaction(function(t) {
            var options = { raw: true, transaction: t }
            return models.sequelize
                .query('SET FOREIGN_KEY_CHECKS = 0', options)
                .then(function() {
                    return models.sequelize.query('truncate table Users', options);
                })
                .then(function() {
                    return models.sequelize.query('SET FOREIGN_KEY_CHECKS = 1', options);
                })
        }).then(function() {
            done();
        }).catch(function(err) {
            console.log(err);
        })
    });

    it("Create 100 User", function(done) {
        var baseEmail= ['test', '@test.com'];
        var baseUsername = 'test';
        var password = models.User.hashPasswordSync('test');
        var completed = 0;
        var users = [];
        for (var i = 0; i < 100; i++) {
            var email = baseEmail[0]+i + baseEmail[1];
            var username = baseUsername + i;
            users[i] = {
                email: email,
                username: username,
                password: password
            };
        }
        models.User.bulkCreate(users).then(function(users) {
            if (!users) {
                console.log("Error: " + users);
            }
            else {
                console.log("Users created");
            }
            done();
        }).catch(function(err) {
            console.log(err);
            done();
        });
    });
});