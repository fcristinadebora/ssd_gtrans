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