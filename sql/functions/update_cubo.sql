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
	v_id_tipo_servico INTEGER;
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
	SELECT * INTO v_id_tipo_servico FROM insert_update_tipos_servico(v_reg.ds_tiposervico);

    UPDATE cubo_emissoes SET
            id_cliente = v_id_cliente,
            id_documento = v_id_documento,
            id_tipo_documento = v_id_tipo_documento,
            dt_emissao = v_reg.dt_record,
            id_usuario = v_id_usuario,
            id_motivo_cancelamento = v_id_motivo_cancelamento,
            dt_cancelamento = v_reg.dt_cancelamento,
			id_responsavel_cancelamento = v_id_responsavel_cancelamento,
			id_tipo_servico = v_id_tipo_servico
        WHERE id = p_id_cubo;
	
	RETURN p_id_cubo;
END
$BODY$;