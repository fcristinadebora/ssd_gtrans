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