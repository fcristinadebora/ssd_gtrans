const connectionConfig = require('../connectionConfig')

const config = {
    client: 'postgresql',
    connection: connectionConfig,
    pool: {
      min: 2,
      max: 10
    }
}

const knex = require('knex')(config)

module.exports = knex