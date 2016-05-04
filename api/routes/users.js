var express = require('express');
var router = express.Router();
var path = require('path');
var models = require(path.resolve('models'));

/*router.post('/test', function(req, res, next) {
  models.User.create({
    email: 'a@a.com',
    username: 'a',
    password: 'a'
  }).then(function(user) {
    console.log(user);
    models.User.create({
      email: 'b@b.com',
      username: 'b',
      password: 'b'
    }).then(function(user) {
      console.log(user);
    }).catch(function(err) {
      console.log(err);
    })
  }).catch(function(err) {
    console.log(err);
  });
  res.json({dev: 'DEV ROUTE ONLY'});
});

router.get('/test', function(req, res, next) {
  models.User.findOne({
    where: {
      email: 'a@a.com'
    }
  }).then(function(user) {
    console.log('USER1 OK');
    models.User.findOne({
      where: {
        email: 'b@b.com'
      }
    }).then(function(user2) {
      console.log('USER2 OK');
      user.addFriend(user2, {status: 'PENDING'});
      user2.addFriend(user, {status: 'PENDING'});
      console.log(user2);
    }).catch(function(err) {
      console.log(err);
    })
  }).catch(function(err) {
    console.log(err);
  });
  res.json({dev: 'DEV ROUTE ONLY'});
});

router.get('/testFriend', function(req, res, next) {
  models.User.findOne({
    where: {
      email: 'a@a.com'
    }
  }).then(function(user) {
    console.log("USER OK: " + user.id);
    user.getFriends({
      through: {
        where: {
          status: 'ACCEPTED'
        }
      }
    }).then(function(friends) {
      console.log(friends);
      res.json(friends);
    }).catch(function(err) {
      console.log(err);
    })
  }).catch(function(err) {
    console.log(err);
  })
  //res.json({dev: 'DEV ROUTE ONLY'});
});*/

router.post('/signin', function(req, res, next) {
  var identifier = req.body.identifier;
  var password = req.body.password;
  if (!identifier || !password) {
    next("Identifier or password missing", req, res);
  }
  else {
    models.User.findOne({
      where: {
        $or: [
          {
            email: identifier
          },
          {
            phone: identifier
          }
        ]
      }
    }).then(function (user) {
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
                  res.json({token: token});
                }
              });
            }
            else {
              res.json({token: user.authToken});
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

module.exports = router;
