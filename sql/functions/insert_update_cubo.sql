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