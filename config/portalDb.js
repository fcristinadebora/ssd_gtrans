const config = {
    client: 'postgresql',
    connection: {
        host: 'host',
        database: 'database',
        user:     'user',
        port:     '5432',
        password: 'password'
    },
    pool: {
      min: 2,
      max: 10
    }
}

const knex = require('knex')(config)

module.exports = knex