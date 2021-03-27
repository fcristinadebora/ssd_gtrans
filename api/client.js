module.exports = app => {
  const getConnection = database => {
    const config = {
      client: 'postgresql',
      connection: {
        host: 'host',
        database: database,
        user: 'user',
        password: 'password'
      }
    }

    return app.config.clientDb.db(config)
  }

  const getCtes = (client, callback) => {
    var connection = getConnection(client.database)

    connection.raw(`SELECT s.nr_sequencial,
          s.ds_chavecte,
          s.ds_justcanc,
          s.dt_record,
          s.dt_cancelamento,
          u.cd_usuario,
          s.st_cancelamento,
          CASE
            WHEN r.tp_servico = 0 THEN 'normal'
            WHEN r.tp_servico = 1 THEN 'subcontratação'
            WHEN r.tp_servico = 2 THEN 'redespacho'
            WHEN r.tp_servico = 3 THEN 'redespacho intermediário'
          END as ds_tiposervico
        FROM statuscte s 
        INNER JOIN receitafrota r ON r.nr_lancamento = s.nr_lancreceitafrota
        INNER JOIN usuario u ON u.cd_usuario = r.cd_usuario
        WHERE
	        date(s.dt_record) >= (current_date - interval '8 days')
	        --date(s.dt_record) >= '2019-10-01'
      `)
      .then((result) => {
        var ctes = result.rows.map(row => {
          if (typeof row.dt_cancelamento === 'string' && row.dt_cancelamento.length <= '14') {
            row.dt_cancelamento = null
          }

          row.ds_cliente = client.name
          row.ds_cliente_base = client.database
          row.ds_tipodocto = 'cte'
          row.ds_chave = row.ds_chavecte
          delete row.ds_chavecte

          return row
        })

        console.log('[CTE-s] inserindo ' + client.database)
        return callback(ctes, connection)
      })
      .catch(err => {
        console.log('[CTE-s] Erro na base ' + client.database + ': ' + err)
        connection.destroy()
        app.eventosClienteConcluidos++
        app.queriesConcluidas++
      })
      .finally()
  }

  const getMdfes = (client, callback) => {
    var connection = getConnection(client.database)

    connection.raw(`SELECT nr_sequencial, ds_chavemdfe, ds_justcanc, dt_record, dt_cancelamento, st_cancelamento, cd_usuario
      FROM statusmdfe
      WHERE
        date(dt_record) >= (current_date - interval '8 days')
        --date(dt_record) >= '2019-10-01'	 
      `)
      .then((result) => {
        var mdfes = result.rows.map(row => {
          if (typeof row.dt_cancelamento === 'string' && row.dt_cancelamento.length <= '14') {
            row.dt_cancelamento = null
          }

          row.ds_cliente = client.name
          row.ds_cliente_base = client.database
          row.ds_tipodocto = 'mdfe'
          row.ds_chave = row.ds_chavemdfe
          delete row.ds_chavemdfe

          return row
        })

        console.log('[MDFE-s] inserindo ' + client.database)
        return callback(mdfes, connection)
      })
      .catch(err => {
        console.log('[MDFE-s] Erro na base ' + client.database + ': ' + err)
        connection.destroy()
        app.eventosClienteConcluidos++
        app.queriesConcluidas++
      })
  }

  return { getCtes, getMdfes }
}
