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