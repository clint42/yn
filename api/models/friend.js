/**
 * Created by Aurelien PRIEUR on 04/05/16 for api.
 */
"use strict";

module.exports = function(sequelize, DataTypes) {
    var friend = sequelize.define('Friend', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        status: {
            type: DataTypes.ENUM('PENDING', 'ACCEPTED', 'DENIED'),
            defaultValue: 'PENDING'
        }
    }, {
        classMethods: {
            associate: function(models) {

            }
        }
    });

    return friend;
};