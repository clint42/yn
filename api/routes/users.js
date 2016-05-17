var express = require('express');
var router = express.Router();
var path = require('path');
var models = require(path.resolve('models'));
var auth = require(path.resolve('middlewares/authentication'));
var request = require('request');

router.post('/signin', function(req, res, next) {
    var identifier = req.body.identifier;
    var password = req.body.password;
    if (!identifier || !password) {
        next("Identifier or password missing", req, res);
    }
    else {
        models.User.getUser(identifier).then(function (user) {
            if (!user) {
                //TODO: Error handling
                next("User not found", req, res);
            }
            else {
                user.verifyPassword(password).then(function (result) {
                    if (!result) {
                        //TODO: error handling
                        next("Error", req, res);
                    }
                    else {
                        if (!user.authToken) {
                            user.generateToken().then(function (token) {
                                if (!token) {
                                    //TODO: error handling
                                    next("Error", req, res);
                                }
                                else {
                                    res.json({userId: user.id, token: user.authToken});
                                }
                            });
                        }
                        else {
                            res.json({token: user.authToken, userId: user.id});
                        }
                    }
                }).catch(function(err) {
                    //TODO: error handling
                    next("error: " + err, req, res);
                })
            }
        });
    }
});

router.post('/fb-signin', function(req, res, next) {
    var token = req.body.token;
    var fbUserId = req.body.userId;
    if (token && fbUserId) {
        var options = {
            url: "https://graph.facebook.com/me?fields=email&access_token="+token,
            method: 'GET'
        };
        request(options, function(error, response, body) {
            if (!error) {
                var result = JSON.parse(body);
                console.log(result);
                models.User.getUser(result.email).then(function(user) {
                    if (user) {
                        if (!user.authToken) {
                            user.generateToken().then(function (token) {
                                console.log("token: " + token);
                                res.json({
                                    success: true,
                                    token: token,
                                    userId: user.id
                                });
                            }).catch(function (err) {
                                console.log(err);
                            });
                        }
                        else {
                            console.log("authToken: " + user.authToken);
                            res.json({
                                success: true,
                                token: user.authToken,
                                userId: user.id
                            })
                        }
                    }
                    else {
                        res.json({
                            success: false,
                            error: 'userNotFound'
                        });
                    }
                }).catch(function(err) {
                    console.log(err);
                })
            }
            console.log(result);
        });
        //res.json({dev: "Not implemented yet"});
    }
    else {
        res.status(422);
        res.json({error: "Missing parameters"});
    }
});

router.post('/signup', function(req, res, next) {
    var email = (req.body.email) ? req.body.email : undefined;
    var phone = (req.body.phone) ? req.body.phone : undefined;
    var firstname = (req.body.firstname) ? req.body.firstname : undefined;
    var lastname = (req.body.lastname) ? req.body.lastname : undefined;
    var password = req.body.password;
    var username = req.body.username;
    var confirmPassword = req.body.confirmPassword;
    if ((!email && !phone) || !password || !confirmPassword) {
        //TODO: Error Handling
        next("Missing parameters", req, res);
    }
    else if (password !== confirmPassword) {
        //TODO: Error Handling
        console.log("Password does not match")
        next("Password does not match", req, res);
    }
    else {
        models.User.create({
            email: email,
            phone: phone,
            firstname: firstname,
            lastname: lastname,
            password: password,
            username: username
        }).then(function(user) {
            if (!user) {
                //TODO: Error Handling
                console.log("Error !");
                next("Sequelize error", req, res);
            }
            else {
                res.status(201);
                res.json({user: user});
            }
        }).catch(function(err) {
            console.log("Err: " + err);
            //TODO: Error handling
            next("Sequelize error" + err, req, res);
        });
    };
});

router.post('/fb-signup', function(req, res, next) {
    var email = req.body.email;
    var phone = req.body.phone;
    var username = req.body.username;
    var firstname = req.body.firstname;
    var lastname = req.body.lastname;
    if (email && username) {
        var user = {
            email: email,
            username: username,
            authWithFacebook: true
        };
        if (phone) {
            user.phone = phone;
        }
        if (firstname) {
            user.firstname = firstname;
        }
        if (lastname) {
            user.lastname = lastname;
        }
        models.User.create(user).then(function(user) {
            if (user) {
                res.status(201);
                res.json({user: user});
            }
            else {
                //TODO: Error handling
                res.status(500);
                res.json({error: "An error occured while creating user"});
            }
        }).catch(function(err) {
            res.status(500);
            res.json({error: "An error occured while creating user: " + err});
        })
    }
    else {
        res.status(422);
        res.json({error: "Missing parameters"});
    }
});

router.get('/search', function(req, res, next) {
    var searchString = req.query.searchString;
    if (searchString) {
        models.User.findAll({
            where: {
                $or: [
                    models.sequelize.where(
                        models.sequelize.fn('lower', models.sequelize.col('username')), ' LIKE ', models.sequelize.fn('lower', searchString+'%')
                    ),
                    models.sequelize.where(
                        models.sequelize.fn('lower', models.sequelize.col('phone')), models.sequelize.fn('lower', searchString)
                    ),
                    models.sequelize.where(
                        models.sequelize.fn('lower', models.sequelize.col('email')), models.sequelize.fn('lower', searchString)
                    )]
            }
        }).then(function(users) {
            res.send({
                users: users
            });
        }).catch(function(err) {
            console.log("Error while searching users: " + err);
            //TODO: Error Handling
            next(err, req, res);
        })
    }
    else {
        res.status(422);
        res.json({error: "Missing parameters"});
    }
});

router.post('/find', auth, function(req, res, next) {
    var numbersOrEmails = JSON.parse(req.body.findArray);
    if (numbersOrEmails) {
        req.currentUser.findUsers(numbersOrEmails).then(function(users) {
            res.json({
                friends: users,
                count: users.length
            });
        }).catch(function(err) {
            console.log("Error while searching users: " + err);
            //TODO: Error Handling
            next(err, req, res);
        })
    }
    else {
        res.status(422);
        res.json({error: "Missing parameters"});
    }
});

module.exports = router;
