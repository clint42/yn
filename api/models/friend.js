/**
 * Created by Aurelien PRIEUR on 22/04/16 for api.
 */
"use strict";

module.exports = function(sequelize, DataTypes) {
    var friend = sequelize.define('Friend', {
        id: {
            autoIncrement: true,
            type: DataTypes.INTEGER,
            primaryKey: true
        },
        requestStatus: DataTypes.ENUM('SENT', 'REFUSED', 'ACCEPTED'),
        createdAt: {
            type: DataTypes.DATETIME,
            defaultValue: sequelize.NOW
        }
    },
    {
        classMethods: {
            associate: function(models) {
                models.Friend.hasOne(models.User, { foreignKey: 'userId1' });
                models.Friend.hasOne(models.User, { foreignKey: 'userId2' });
            }
        }
    });

    return friend;
};