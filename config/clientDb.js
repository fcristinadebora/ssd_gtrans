const knex = require('knex')

module.exports = app => {

    const db = config => knex(config)
    
    return { db }
}