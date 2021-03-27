module.exports = app => {
  const getClientsList = (callback) => {
    console.log(Date(Date.now()).toString() + ' - Selecionando clientes...');
    app.portalDb.raw(`SELECT distinct(nmbasepri) AS database,
              null as name
            FROM tab_clientes
            WHERE status = '1'
                AND nmbasepri <> ''
                AND nmbasepri <> 'csv_prod'
                AND sistema = 'CSV'
            ORDER BY nmbasepri`)
      .then((result) => {
        console.log(Date(Date.now()).toString() + ' - Iniciando sincronização...')
        app.clientsList = result.rows

        callback();
      })
      .catch(err => console.log(err))
      .finally()
  }

  return { getClientsList }
}