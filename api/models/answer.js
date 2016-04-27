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
                models.Answer.belongsTo(models.Question, {foreignKey: 'questionId'});
                models.Answer.belongsTo(models.User, {foreignKey: 'userId'});
            }
        }
    });

    return answer;
};