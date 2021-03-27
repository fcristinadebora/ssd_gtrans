CREATE TRIGGER staging_area_emissoes_tr
    AFTER INSERT 
    ON staging_area_emissoes
    FOR EACH ROW
    EXECUTE PROCEDURE insert_update_cubo();