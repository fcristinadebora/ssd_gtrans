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