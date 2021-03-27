CREATE OR REPLACE FUNCTION public.insert_update_tipos_servico(IN p_descricao character varying DEFAULT NULL)
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
		FROM tipos_servico
		WHERE descricao = p_descricao;
		
	IF v_id IS NULL THEN
		INSERT INTO tipos_servico (descricao) VALUES (p_descricao)
			RETURNING id INTO v_id;
	END IF;

    UPDATE cubo_emissoes SET id_tipo_servico = v_id
		WHERE id_tipo_servico IN (SELECT id FROM tipos_servico WHERE descricao = p_descricao AND id <> v_id);
	
	DELETE FROM tipos_servico WHERE descricao = p_descricao AND id <> v_id;
	
	RETURN v_id;
END
$BODY$;