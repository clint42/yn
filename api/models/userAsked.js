/**
 * Created by gregoirelafitte on 5/17/16.
 */

"use strict";

module.exports = function(sequelize, DataTypes) {
    var userAsked = sequelize.define('UserAsked', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        status: {
            type: DataTypes.ENUM('OPEN', 'CLOSED'),
            defaultValue: 'OPEN'
        },
        answer: {
            type: DataTypes.ENUM('NONE', 'YES', 'NO'),
            defaultValue: 'NONE'
        }
    }, {
        classMethods: {
            associate: function(models) {

            }
        }
    });
    return userAsked;
};