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
    descricao VARCHAR(1)
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
    dt_sincronizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    st_cancelamento VARCHAR(1)
);

CREATE OR REPLACE FUNCTION insert_cubo (IN p_id_staging_area INTEGER)
	RETURNS INTEGER
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_cliente INTEGER;
	v_id_documento INTEGER;
	v_id_tipo_documento INTEGER;
	v_id_motivo_cancelamento INTEGER;
    v_id_responsavel_cancelamento INTEGER;
	v_id_usuario INTEGER;
	v_id_cubo INTEGER;
	v_reg RECORD;
BEGIN
	SELECT * INTO v_reg
		FROM staging_area_emissoes
		WHERE id = p_id_staging_area;
	
	SELECT * INTO v_id_cliente FROM insert_update_clientes(v_reg.ds_cliente, v_reg.ds_cliente_base);
	SELECT * INTO v_id_documento FROM insert_update_documentos(v_reg.ds_chave, v_reg.nr_sequencial);
	SELECT * INTO v_id_tipo_documento FROM insert_update_tipos_documento(v_reg.ds_tipodocto);
	SELECT * INTO v_id_usuario FROM insert_update_usuarios(v_reg.cd_usuario);
    SELECT * INTO v_id_motivo_cancelamento FROM insert_update_motivos_cancelamento(v_reg.ds_justcanc);
    SELECT * INTO v_id_responsavel_cancelamento FROM insert_update_responsaveis_cancelamento(v_reg.st_cancelamento);

    INSERT INTO cubo_emissoes (
            id_cliente,
            id_documento,
            id_tipo_documento,
            dt_emissao,
            id_usuario,
            id_motivo_cancelamento,
            dt_cancelamento,
            id_responsavel_cancelamento
        ) VALUES (
            v_id_cliente,
            v_id_documento,
            v_id_tipo_documento,
            v_reg.dt_record,
            v_id_usuario,
            v_id_motivo_cancelamento,
            v_reg.dt_cancelamento,
            v_id_responsavel_cancelamento
        )
        RETURNING id INTO v_id_cubo;
	
	RETURN v_id_cubo;
END
$BODY$;

CREATE OR REPLACE FUNCTION public.insert_update_clientes(IN p_nome character varying DEFAULT NULL, IN p_nome_database character varying DEFAULT NULL)
    RETURNS integer    
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id INTEGER;
BEGIN
	v_id = NULL;
	
	SELECT id INTO v_id
		FROM clientes
		WHERE nome_database = p_nome_database ORDER BY id ASC LIMIT 1;
		
	IF v_id IS NULL THEN
		INSERT INTO clientes (nome, nome_database) VALUES (p_nome, p_nome_database)
			RETURNING id INTO v_id;
	END IF;
	
	UPDATE cubo_emissoes SET id_cliente = v_id
		WHERE id_cliente IN (SELECT id FROM clientes WHERE nome_database = p_nome_database AND id <> v_id);
	
	DELETE FROM clientes WHERE nome_database = p_nome_database AND id <> v_id;

	RETURN v_id;
END
$BODY$;

CREATE OR REPLACE FUNCTION insert_update_cubo ()
	RETURNS TRIGGER
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_cubo INTEGER;
	v_id_cliente INTEGER;
	v_id_documento INTEGER;
	v_reg RECORD;
BEGIN
	SELECT * INTO v_reg
		FROM staging_area_emissoes
		WHERE id = NEW.id;

	v_id_cubo = NULL;
	SELECT cubo.id INTO v_id_cubo FROM cubo_emissoes cubo
		INNER JOIN  documentos docto ON docto.id = cubo.id_documento
			AND docto.nr_sequencial = v_reg.nr_sequencial AND docto.chave = v_reg.ds_chave;

	IF(v_id_cubo IS NULL) THEN
		SELECT * INTO v_id_cubo FROM insert_cubo(NEW.id);
	ELSE
		PERFORM update_cubo(NEW.id, v_id_cubo);
	END IF;

	IF(v_id_cubo IS NOT NULL) THEN
		DELETE FROM staging_area_emissoes WHERE id = NEW.id;
	END IF;

	RETURN NEW;
END
$BODY$;

CREATE OR REPLACE FUNCTION public.insert_update_documentos(IN p_chave character varying DEFAULT NULL, IN p_nr_sequencial INTEGER DEFAULT NULL)
    RETURNS integer    
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id INTEGER;
BEGIN
	v_id = NULL;
	
	SELECT id INTO v_id
		FROM documentos
		WHERE nr_sequencial = p_nr_sequencial AND chave = p_chave;
		
	IF v_id IS NULL THEN
		INSERT INTO documentos (nr_sequencial, chave) VALUES (p_nr_sequencial, p_chave)
			RETURNING id INTO v_id;
	END IF;
	
	RETURN v_id;
END
$BODY$;

CREATE OR REPLACE FUNCTION public.insert_update_motivos_cancelamento(IN p_descricao character varying DEFAULT NULL)
    RETURNS integer    
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id INTEGER;
BEGIN
    IF(p_descricao IS NULL) THEN
        RETURN NULL;
    END IF;
    
	v_id = NULL;
	
	SELECT id INTO v_id
		FROM motivos_cancelamento
		WHERE descricao = p_descricao ORDER BY id ASC LIMIT 1;
		
	IF v_id IS NULL THEN
		INSERT INTO motivos_cancelamento (descricao) VALUES (p_descricao)
			RETURNING id INTO v_id;
	END IF;

	UPDATE cubo_emissoes SET id_motivo_cancelamento = v_id
		WHERE id_motivo_cancelamento IN (
			SELECT id
			FROM motivos_cancelamento
			WHERE descricao = p_descricao
				AND id <> v_id);
	
	DELETE FROM motivos_cancelamento WHERE descricao = p_descricao AND id <> v_id;
	
	RETURN v_id;
END
$BODY$;

CREATE OR REPLACE FUNCTION public.insert_update_tipos_documento(IN p_nome character varying DEFAULT NULL)
    RETURNS integer    
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id INTEGER;
BEGIN
	v_id = NULL;
	
	SELECT id INTO v_id
		FROM tipos_documento
		WHERE nome = p_nome;
		
	IF v_id IS NULL THEN
		INSERT INTO tipos_documento (nome) VALUES (p_nome)
			RETURNING id INTO v_id;
	END IF;
	
	RETURN v_id;
END
$BODY$;

CREATE OR REPLACE FUNCTION public.insert_update_responsaveis_cancelamento(IN p_descricao character varying DEFAULT NULL)
    RETURNS integer    
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id INTEGER;
BEGIN
    IF(p_descricao IS NULL) THEN
        RETURN NULL;
    END IF;
    
	v_id = NULL;
	
	SELECT id INTO v_id
		FROM responsavel_cancelamento
		WHERE descricao = p_descricao ORDER BY id ASC LIMIT 1;
		
	IF v_id IS NULL THEN
		INSERT INTO responsavel_cancelamento (descricao) VALUES (p_descricao)
			RETURNING id INTO v_id;
	END IF;

	UPDATE cubo_emissoes SET id_responsavel_cancelamento = v_id
		WHERE id_responsavel_cancelamento IN (
			SELECT id
			FROM responsavel_cancelamento
			WHERE descricao = p_descricao
				AND id <> v_id);
	
	DELETE FROM responsavel_cancelamento WHERE descricao = p_descricao AND id <> v_id;
	
	RETURN v_id;
END
$BODY$;

CREATE OR REPLACE FUNCTION public.insert_update_usuarios(IN p_codigo character varying DEFAULT NULL)
    RETURNS integer    
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id INTEGER;
BEGIN
    IF(p_codigo IS NULL) THEN
        RETURN NULL;
    END IF;
    
	v_id = NULL;
	
	SELECT id INTO v_id
		FROM usuarios
		WHERE codigo = p_codigo;
		
	IF v_id IS NULL THEN
		INSERT INTO usuarios (codigo) VALUES (p_codigo)
			RETURNING id INTO v_id;
	END IF;
	
	RETURN v_id;
END
$BODY$;

CREATE OR REPLACE FUNCTION update_cubo (IN p_id_staging_area INTEGER, IN p_id_cubo INTEGER)
	RETURNS INTEGER
	LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	v_id_cliente INTEGER;
	v_id_documento INTEGER;
	v_id_tipo_documento INTEGER;
	v_id_motivo_cancelamento INTEGER;
	v_id_responsavel_cancelamento INTEGER;
	v_id_usuario INTEGER;
	v_id_cubo INTEGER;
	v_reg RECORD;
BEGIN
	SELECT * INTO v_reg
		FROM staging_area_emissoes
		WHERE id = p_id_staging_area;
	
	SELECT * INTO v_id_cliente FROM insert_update_clientes(v_reg.ds_cliente, v_reg.ds_cliente_base);
	SELECT * INTO v_id_documento FROM insert_update_documentos(v_reg.ds_chave, v_reg.nr_sequencial);
	SELECT * INTO v_id_tipo_documento FROM insert_update_tipos_documento(v_reg.ds_tipodocto);
	SELECT * INTO v_id_usuario FROM insert_update_usuarios(v_reg.cd_usuario);
    SELECT * INTO v_id_motivo_cancelamento FROM insert_update_motivos_cancelamento(v_reg.ds_justcanc);
	SELECT * INTO v_id_responsavel_cancelamento FROM insert_update_responsaveis_cancelamento(v_reg.st_cancelamento);

    UPDATE cubo_emissoes SET
            id_cliente = v_id_cliente,
            id_documento = v_id_documento,
            id_tipo_documento = v_id_tipo_documento,
            dt_emissao = v_reg.dt_record,
            id_usuario = v_id_usuario,
            id_motivo_cancelamento = v_id_motivo_cancelamento,
            dt_cancelamento = v_reg.dt_cancelamento,
			id_responsavel_cancelamento = v_id_responsavel_cancelamento
        WHERE id = p_id_cubo;
	
	RETURN p_id_cubo;
END
$BODY$;

CREATE TRIGGER staging_area_emissoes_tr
    AFTER INSERT 
    ON staging_area_emissoes
    FOR EACH ROW
    EXECUTE PROCEDURE insert_update_cubo();