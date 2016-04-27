/**
 * Created by Aurelien PRIEUR on 22/04/16 for api.
 */
"use strict";

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
        createdAt: {
            defaultValue: sequelize.NOW,
            type: DataTypes.DATE
        }
        },
        {
        classMethods: {
            associate: function(models) {
                models.User.hasMany(models.Friend, { foreignKey: { name: 'userId1', allowNull: false }, onDelete: 'CASCADE' });
                models.User.hasMany(models.Question, { foreignKey: { name: 'userId', allowNull: true }, onDelete: 'CASCADE'})
            }
        }
    });

    return user;
};


