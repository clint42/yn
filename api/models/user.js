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
        password: {
            type: DataTypes.STRING,
            allowNull: true,
            defaultValue: null
        },
        authWithFacebook: DataTypes.BOOLEAN,
        authToken: DataTypes.STRING
    }, {
        classMethods: {
            associate: function(models) {
                models.User.belongsToMany(models.User, {as: 'Friends', through: models.Friend, onDelete: 'CASCADE', onUpdate: 'CASCADE'})
                models.User.hasMany(models.Device);
            },
            getUser: function(identifier) {
                var self = this;
                return new Promise(function(resolve, reject) {
                    self.findOne({
                        where: {
                            $or: [{
                                email: identifier
                            },{
                                phone: identifier
                            },{
                                username: identifier
                            }
                            ]
                        }
                    }).then(function(user) {
                        resolve(user);
                    }).catch(function(err) {
                        reject(err);
                    });
                });
            },
            hashPasswordSync: function(password) {
                return bcrypt.hashSync(password, null, null);
            }
        },
        instanceMethods: {
            toJSON: function() {
                var resp = this.get();
                delete resp.authToken;
                delete resp.password;
                delete resp.phone;
                delete resp.email;
                return resp;
            },
            verifyPassword: function(plainPassword) {
                var self = this;
                return new Promise(function(resolve, reject) {
                    if (self.password) {
                        bcrypt.compare(plainPassword, self.password, function (err, res) {
                            if (err || !res) {
                                reject(false);
                            }
                            else {
                                resolve(true);
                            }
                        });
                    }
                    else {
                        reject(false);
                    }
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
            },
            getFriendUsers: function(nbPerPage, offset, orderBy, orderRule) {
                var pagination = nbPerPage && offset;

                var query = "SELECT *, Users.id AS id, Friends.id AS friendshipId FROM " + sequelize.models.User.tableName +
                            " INNER JOIN " + sequelize.models.Friend.tableName + " ON Friends.UserId=Users.id OR Friends.FriendId=Users.id " +
                            " WHERE (Friends.UserId="+this.id+" OR Friends.FriendId="+this.id+") AND Users.id!="+this.id+" AND Friends.status='ACCEPTED' ";
                if (orderBy) {
                    query += " ORDER BY " + orderBy + " " + orderRule
                }
                if (pagination) {
                    query += " LIMIT " + offset + "," + nbPerPage;
                }
                return new Promise(function(resolve, reject) {
                   sequelize.query(query, {type: sequelize.QueryTypes.SELECT, model: sequelize.models.User}).then(function(users) {
                       resolve(users);
                   }).catch(function(err) {
                       reject(err);
                   });
                });
            },
            getFriendRequestUsers: function(nbPerPage, offset) {
                var pagination = nbPerPage && offset;
                var query = "SELECT Users.*, Users.id AS id, Friends.id AS friendshipId FROM " + sequelize.models.User.tableName +
                            " INNER JOIN " + sequelize.models.Friend.tableName + " ON Friends.UserId = Users.id" +
                            " WHERE Friends.FriendId =" + this.id + " AND Friends.UserId != " + this.id + " AND status = 'PENDING'";
                if (pagination) {
                    query += " LIMIT " + offset + "," + nbPerPage
                }
                return new Promise(function(resolve, reject) {
                   sequelize.query(query, {type: sequelize.QueryTypes.SELECT, model: sequelize.models.User}).then(function(users) {
                        resolve(users);
                   }).catch(function(err) {
                        reject(err);
                   });
                });
            },
            getNumberOfFriendRequestUsers: function() {
                var self = this;
                return new Promise(function(resolve, reject) {
                    sequelize.models.Friend.count({
                        where: {
                            $not: {
                                UserId: self.id
                            },
                            FriendId: self.id,
                            status: 'PENDING'
                        }
                    }).then((success) => {
                        resolve(success);
                    }).catch(function(err) {
                        reject(err);
                    });
                });
            },
            getFriendPendingRequestUsers: function(nbPerPage, offset, orderBy, orderRule) {
                var pagination = nbPerPage && offset;
                var query = "SELECT *, Users.id AS id, Friends.id as friendshipId FROM " + sequelize.models.User.tableName +
                            " INNER JOIN " + sequelize.models.Friend.tableName + " ON Friends.UserId=Users.id" +
                            " WHERE Friends.UserId="+this.id+" AND Users.id!="+this.id+" AND Friends.status='PENDING'";
                if (pagination) {
                    query += " LIMIT " + offset + "," + nbPerPage;
                }
                return new Promise(function(resolve, reject) {
                   sequelize.query(query, {type: sequelize.QueryTypes.SELECT, model: sequelize.models.User}).then(function(users) {
                       resolve(users);
                   }).catch(function(err) {
                       reject(err);
                   })
                });
            },
            deleteFriend: function(userToDelete) {
                return new Promise((resolve, reject) => {
                    sequelize.models.Friend.destroy({
                        where: {
                            UserId: this.id,
                            FriendId: userToDelete.id,
                            status: 'ACCEPTED'
                        }
                    }).then((success) => {
                        resolve(success);
                    }).catch((err) => {
                        reject(err);
                    })
                });
            },
            answerRequest: function(user, accept) {
                console.log("ACCEPT IN MODEL: ", accept);
                return new Promise((resolve, reject) => {
                    sequelize.models.Friend.findOne({
                        where: {
                            UserId: user.id,
                            FriendId: this.id
                        }
                    }).then((friendship) => {
                        friendship.update({
                            status: (accept !== undefined && accept == true ? "ACCEPTED" : "DENIED")
                        }).then((friendship) => {
                            resolve(true);
                        }).catch((error) => {
                            reject(error);
                        })
                    }).catch((error) => {
                        reject(error);
                    });
                });
            },
            findUsers: function(numbersOrEmails) {
                var queryId = "SELECT Users.id " +
                    "FROM Users " +
                    "INNER JOIN Friends ON (Users.id = Friends.UserId OR Users.id = Friends.FriendId) " +
                    "WHERE ((Friends.UserId != " + this.id + " AND Friends.FriendId = " + this.id + ") " +
                    "OR (Friends.FriendId != " + this.id + " AND Friends.UserId = " + this.id + ")) " +
                    "AND Users.id != " + this.id + "";
                return new Promise(function(resolve, reject) {
                    sequelize.query(queryId, {type: sequelize.QueryTypes.SELECT, model: sequelize.models.User}).then(function(idFriends) {
                        var notIn = "";
                        for (var count = 0; count < idFriends.length; count++) {
                            notIn += idFriends[count].id;
                            if (count < (idFriends.length - 1))
                                notIn += ",";
                        }
                        var mylist = "\"" + numbersOrEmails.join("\",\"") + "\"";
                        var query = "SELECT Users.* " +
                            "FROM Users " +
                            "LEFT JOIN Friends ON (Friends.UserId = Users.id OR Friends.FriendId = Users.id) " +
                            "WHERE (Users.email IN(" + mylist + ") OR `Users`.`phone` IN (" + mylist + ")) " +
                            "AND Users.id NOT IN(" + notIn + ") " +
                            "GROUP BY Users.username";
                        sequelize.query(query, {
                            type: sequelize.QueryTypes.SELECT,
                            model: sequelize.models.User
                        }).then(function (users) {
                            resolve(users);
                        }).catch(function (err) {
                            reject(err);
                        });
                    }).catch(function (err) {
                        reject(err);
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