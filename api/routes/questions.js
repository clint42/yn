/**
 * Created by Aurelien PRIEUR on 16/05/16 for api.
 */

"use strict";

var router = require('express').Router();
var path = require('path');
var auth = require(path.resolve('middlewares/authentication.js'));
var upload = require('multer')({dest: 'uploads/'});
var fs = require('fs');

router.post('/', [auth, upload.fields([{
  name: "image", maxCount: 1
}])], function(req, res, next) {
   console.log(req.files);
   res.json({dev: 'Not implemented yet'});
});

module.exports = router;