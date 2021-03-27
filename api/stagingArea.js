module.exports = app => {
  const insert = (data, clientConnection) => {
    app.eventosClienteRodando++;
    app.db('staging_area_emissoes').insert(data)
    .catch((error) => {
      console.log(data.ds_cliente_base, error)
      process.exit()
    })
    .finally(() => {
      app.eventosClienteConcluidos++
      app.queriesConcluidas++
      clientConnection.destroy()
      app.sincronizarCliente()
    })
  }

  return { insert }
}
