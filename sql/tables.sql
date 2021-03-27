CREATE TABLE clientes(
    id SERIAL NOT NULL PRIMARY KEY,
    nome VARCHAR(50),
    nome_database VARCHAR(50)
);

CREATE TABLE tipos_documento(
    id SERIAL NOT NULL PRIMARY KEY,
    nome VARCHAR(4)
);

CREATE TABLE documentos(
    id SERIAL NOT NULL PRIMARY KEY,
    nr_sequencial INTEGER,
    chave VARCHAR(50)
);

CREATE TABLE usuarios(
    id SERIAL NOT NULL PRIMARY KEY,
    codigo VARCHAR(20)
);

CREATE TABLE motivos_cancelamento(
    id SERIAL NOT NULL PRIMARY KEY,
    descricao VARCHAR(2000)
);

CREATE TABLE responsavel_cancelamento(
    id SERIAL NOT NULL PRIMARY KEY,
    descricao VARCHAR(2000)
);

CREATE TABLE tipos_servico(
	id SERIAL NOT NULL PRIMARY KEY,
	descricao VARCHAR(100)
);

CREATE TABLE cubo_emissoes(
    id SERIAL NOT NULL PRIMARY KEY,
    id_cliente INTEGER REFERENCES clientes,
    id_documento INTEGER REFERENCES documentos,
    id_tipo_documento INTEGER REFERENCES tipos_documento,
    dt_emissao TIMESTAMP,
    id_usuario INTEGER REFERENCES usuarios,
    id_motivo_cancelamento INTEGER REFERENCES motivos_cancelamento DEFAULT NULL,
    id_responsavel_cancelamento INTEGER REFERENCES responsavel_cancelamento,
    dt_cancelamento TIMESTAMP DEFAULT NULL,
    dt_sincronizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_tipo_servico INTEGER REFERENCES tipos_servico
);

CREATE TABLE staging_area_emissoes(
    id SERIAL NOT NULL PRIMARY KEY,
    nr_sequencial INTEGER,
    ds_chave VARCHAR(50),
    ds_justcanc VARCHAR(2000),
    dt_record TIMESTAMP,
    dt_cancelamento TIMESTAMP,
    ds_tipodocto VARCHAR(4),
    ds_cliente VARCHAR(50),
    ds_cliente_base VARCHAR(50),    
    cd_usuario VARCHAR(20),
    st_cancelamento VARCHAR(1),
    ds_tiposervico VARCHAR(100)
);