const express = require('express')
const app = express()
const db = require('./config/db')
const portalDb = require('./config/portalDb')
const consign = require('consign')

consign()
    .then('./api')
    .then('./config/clientDb.js')
    .into(app)

app.db = db
app.portalDb = portalDb

app.queriesRodando = 0;
app.queriesConcluidas = 0;
app.eventosClienteRodando = 0;
app.eventosClienteConcluidos = 0;
app.currentIndex = -1;

const inicio = new Date();

app.sincronizarCliente = () => {
    if(app.eventosClienteRodando == app.eventosClienteConcluidos){
        app.currentIndex++
        
        if(app.currentIndex >= app.clientsList.length){
            console.log("Aguardando execução de todas as queries...")
            if(app.queriesConcluidas >= app.queriesRodando){
                const final = new Date();
                console.log('Integração concluída, ' + app.clientsList.length + ' clientes sincronizados');
                console.log('Iniciado em: ' + inicio.toString() + " / Finalizado em: " + final.toString());
                console.log('Tempo total de execução: ' + ((final - inicio) / 1000))
                process.exit()
            }

            return false;
        }

        console.log("Sincronizando cliente " + app.clientsList[app.currentIndex].database)
        
        app.api.client.getCtes(app.clientsList[app.currentIndex], app.api.stagingArea.insert)
        app.api.client.getMdfes(app.clientsList[app.currentIndex], app.api.stagingArea.insert)
        app.queriesRodando = app.queriesRodando + 2
    }
}

app.api.portal.getClientsList(app.sincronizarCliente)