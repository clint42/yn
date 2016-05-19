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
            associate: function (models) {
                models.Question.belongsToMany(models.User, {
                    as: {singular: 'UserAsked', plural: 'UsersAsked'},
                    through: models.UserAsked,
                    onUpdate: 'CASCADE'
                });
                models.Question.belongsTo(models.User, {as: 'Owner', onDelete: 'CASCADE', onUpdate: 'CASCADE'});
            }
        },
        instanceMethods: {
            getAnswers: function() {
                var query = "SELECT * FROM UserAskeds WHERE QuestionId = " + this.id;
                return new Promise(function(resolve, reject) {
                    sequelize.query(query, {type: sequelize.QueryTypes.SELECT, model: sequelize.models.UserAsked}).then(function(answers) {
                        resolve(answers);
                    }).catch(function(err) {
                        reject(err);
                    });
                });
            }
        }
    });
    return question;
};