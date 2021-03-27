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