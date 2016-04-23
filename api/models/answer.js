/**
 * Created by Aurelien PRIEUR on 22/04/16 for api.
 */
"use strict";

module.exports = function(sequelize, DataTypes) {
        var answer = sequelize.define('Answer', {
            id: {
                type: DataTypes.INTEGER,
                autoIncrement: true,
                primaryKey: true
            },
            answer: DataTypes.BOOLEAN,
            createdAt: {
                type: DataTypes.DATE,
                defaultValue: sequelize.NOW
            }
        },{
        classMethods: {
            associate: function(models) {
                models.Answer.hasOne(models.Question, {foreignKey: 'fkQuestionId'});
                models.Answer.hasOne(models.User, {foreignKey: 'fkUserId'});
            }
        }
    });

    return answer;
};