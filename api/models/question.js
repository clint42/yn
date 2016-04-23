/**
 * Created by Aurelien PRIEUR on 22/04/16 for api.
 */
"use strict";

module.exports = function(sequelize, DataTypes) {
    var question = sequelize.define('Question', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        title: DataTypes.STRING,
        question: {
            type: DataTypes.STRING,
            allowNull: true
        },
        imageUrl: {
            type: DataTypes.STRING,
            allowNull: true
        },
        status: DataTypes.ENUM('OPEN', 'CLOSED'),
        createdAt: {
            defaultValue: sequelize.NOW,
            type: DataTypes.DATE
        }
    },
    {
        classMethods: {
            associate: function(models) {
                /*models.Question.belongsTo(models.User, { foreignKey: 'userId' });*/
                /*models.Question.hasMany(models.User, {foreignKey: 'userAsked'});*/
            }
        }
    });
    return question;
};