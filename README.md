# Alimentador DW SSD GTRANS

Faz conexão na base de dados de cada cliente configurado, busca os documentos emitidos, erros e usuário e insere no DW

### Pré-requisitos

NodeJs V9+

### Configurando o projeto

* Rode o comando

```
npm i --no-dev
```

* Para criar a base de dados, execute o conteúdo do arquivo **sql/consolidado.sql**

* Renomeie o arquivo **example.connectionConfig.js** para **connectionConfig.js** e ajuste com suas variáveis de conexão da base de dados do DW


### Configurações

*  **Configurações de BD da lista de clientes:** o arquivo api/portal.js consulta na base de dados chamada de portal a lista de clientes, para ajustar as configurações de banco de dados, você pode editar o arquivo  **config/portalDb.js**

*  **Configurações de BD dos clientes:** Parte-se do pressuposto que todos os clientes estão no mesmo servidor, para ajustar as configurações de banco de dados, você pode editar o arquivo  **api/client.js** na função **getConnection**

### Rodando o programa

Esse programa foi desenvolvido para execução em command line, portanto, para executá-lo, basta rodar o seguinte comando, na raiz do projeto:

```
node index.js
```