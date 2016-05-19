/**
 * Created by Aurelien PRIEUR on 17/05/16 for api.
 */
"use strict";

module.exports = function(sequelize, DataTypes) {
    var device = sequelize.define('Device', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        token: {
            type: DataTypes.STRING,
            allowNull: false,
            //TODO: Reset unique to true
            //unique: true
        },
        deviceOS: {
            type: DataTypes.ENUM('IOS', 'ANDROID', 'WP'),
            defaultValue: 'IOS'
        },
        badgeValue: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
            allowNull: false
        }
    }, {
        classMethods: {
            associate: function(models) {
                models.Device.belongsTo(models.User, {onDelete: 'CASCADE', onUpdate: 'CASCADE'});
            }
        }
    });

    return device;
};