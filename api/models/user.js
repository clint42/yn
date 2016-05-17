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

                var query = "SELECT *, Users.id AS id, Friends.id as friendshipId FROM " + sequelize.models.User.tableName +
                            " INNER JOIN " + sequelize.models.Friend.tableName + " ON Friends.UserId=Users.id OR Friends.FriendId=Users.id " +
                            "WHERE (Friends.UserId="+this.id+" OR Friends.FriendId="+this.id+") AND Users.id!="+this.id+" AND Friends.status='ACCEPTED' ";
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
                var query = "SELECT *, Users.id AS id, Friends.id as friendshipId FROM " + sequelize.models.User.tableName +
                            " INNER JOIN " + sequelize.models.Friend.tableName + " ON Friends.FriendId=Users.id" +
                            "WHERE Friends.FriendId="+this.id+" AND Users.id!="+this.id+" AND status='PENDING'";
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
            getFriendPendingRequestUsers: function() {
                var pagination = nbPerPage && offset;
                var query = "SELECT *, Users.id AS id, Friends.id as friendshipId FROM " + sequelize.models.User.tableName +
                            " INNER JOIN " + sequelize.models.Friend.tableName + " ON Friends.UserId=Users.id" +
                            "WHERE Friends.UserId="+this.id+" AND Users.id!="+this.id+" AND Friends.status='PENDING'";
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