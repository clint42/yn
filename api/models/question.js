/**
 * Created by Aurelien PRIEUR on 16/05/16 for api.
 */

"use strict";

module.exports = function(sequelize, DataTypes) {
    var question = sequelize.define('Question', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        title: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        question: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        imageUrl: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        status: {
            type: DataTypes.ENUM('OPEN', 'CLOSED'),
            defaultValue: 'OPEN'
        }
    }, {
        classMethods: {
            associate: function(models) {
                models.Question.belongsTo(models.User, {as: 'OwnerId', onDelete: 'CASCADE', onUpdate: 'CASCADE'});
                models.Question.belongsToMany(models.User, {as: 'UsersAsked', through: models.UserAsked, onUpdate: 'CASCADE'});
            }
        }
    });
    return question;
};