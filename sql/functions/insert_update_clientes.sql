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

	RETURN v_id;
END
$BODY$;