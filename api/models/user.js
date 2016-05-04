/**
 * Created by Aurelien PRIEUR on 04/05/16 for api.
 */
"use strict";

var bcrypt = require('bcrypt-nodejs');
var uuid = require('node-uuid');

module.exports = function(sequelize, DataTypes) {

    var user = sequelize.define('User', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        firstname: {
            type: DataTypes.STRING,
            allowNull: true
        },
        lastname: {
            type: DataTypes.STRING,
            allowNull: true
        },
        username: DataTypes.STRING,
        email: DataTypes.STRING,
        phone: DataTypes.STRING,
        password: DataTypes.STRING,
        authWithFacebook: DataTypes.BOOLEAN,
        authToken: DataTypes.STRING,
        createdAt: {
            defaultValue: sequelize.NOW,
            type: DataTypes.DATE
        }
    }, {
        classMethods: {
            associate: function(models) {
                models.User.belongsToMany(models.User, {as: 'Friends', through: models.Friend})
                //models.User.hasMany(models.Friend, {foreignKey: 'userId1', allowNull: false});
                //models.User.hasMany(models.Friend, {foreignKey: 'userId2', allowNull: false});
            }
        },
        instanceMethods: {
            verifyPassword: function(plainPassword) {
                var self = this;
                return new Promise(function(resolve, reject) {
                    bcrypt.compare(plainPassword, self.password, function(err, res) {
                        if (err || !res) {
                           reject(false);
                        }
                        else {
                          resolve(true);
                       }
                    });
                });
            },
            generateToken: function() {
                var self = this;
                return new Promise(function(resolve, reject) {
                   self.update({
                       authToken: uuid.v1()
                   }).then(function(user) {
                       resolve(user.authToken);
                   }).catch(function(err) {
                      reject(false);
                   });
                });
            }
        },
        hooks: {
            afterValidate: function(user, options, done) {
                if (user.changed('password')) {
                    bcrypt.hash(user.password, null, null, function(error, hashPassword) {
                        user.password = hashPassword;
                        done();
                    });
                }
                else {
                    done();
                }
            }
        }
    });
    return user;
};