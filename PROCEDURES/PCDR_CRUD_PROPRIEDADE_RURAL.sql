-- ============================================================================
-- 5. PROCEDURE CRUD PARA PROPRIEDADE RURAL
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_PROPRIEDADE_RURAL(
    v_operacao             IN VARCHAR2,
    v_id_propriedade       IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE,
    v_id_produtor          IN GS_WW_PROPRIEDADE_RURAL.id_produtor%TYPE,
    v_id_nivel_degradacao  IN GS_WW_PROPRIEDADE_RURAL.id_nivel_degradacao%TYPE,
    v_nome_propriedade     IN GS_WW_PROPRIEDADE_RURAL.nome_propriedade%TYPE,
    v_latitude             IN GS_WW_PROPRIEDADE_RURAL.latitude%TYPE,
    v_longitude            IN GS_WW_PROPRIEDADE_RURAL.longitude%TYPE,
    v_area_hectares        IN GS_WW_PROPRIEDADE_RURAL.area_hectares%TYPE
) IS
    v_mensagem VARCHAR2(255);
    -- Variáveis para o SELECT
    v_result_produtor     GS_WW_PROPRIEDADE_RURAL.id_produtor%TYPE;
    v_result_degradacao   GS_WW_PROPRIEDADE_RURAL.id_nivel_degradacao%TYPE;
    v_result_nome         GS_WW_PROPRIEDADE_RURAL.nome_propriedade%TYPE;
    v_result_latitude     GS_WW_PROPRIEDADE_RURAL.latitude%TYPE;
    v_result_longitude    GS_WW_PROPRIEDADE_RURAL.longitude%TYPE;
    v_result_area         GS_WW_PROPRIEDADE_RURAL.area_hectares%TYPE;
    v_result_data         GS_WW_PROPRIEDADE_RURAL.data_cadastro%TYPE;

BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_PROPRIEDADE_RURAL (
            id_produtor, id_nivel_degradacao, nome_propriedade, 
            latitude, longitude, area_hectares, data_cadastro
        ) VALUES (
            v_id_produtor, v_id_nivel_degradacao, v_nome_propriedade,
            v_latitude, v_longitude, v_area_hectares, SYSDATE
        );
        v_mensagem := 'Propriedade rural inserida com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_PROPRIEDADE_RURAL
        SET id_produtor = v_id_produtor,
            id_nivel_degradacao = v_id_nivel_degradacao,
            nome_propriedade = v_nome_propriedade,
            latitude = v_latitude,
            longitude = v_longitude,
            area_hectares = v_area_hectares
        WHERE id_propriedade = v_id_propriedade;
        v_mensagem := 'Propriedade rural atualizada com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_PROPRIEDADE_RURAL
        WHERE id_propriedade = v_id_propriedade;
        v_mensagem := 'Propriedade rural deletada com sucesso.';

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT id_produtor, id_nivel_degradacao, nome_propriedade, 
                   latitude, longitude, area_hectares, data_cadastro
            INTO v_result_produtor, v_result_degradacao, v_result_nome, 
                 v_result_latitude, v_result_longitude, v_result_area, v_result_data
            FROM GS_WW_PROPRIEDADE_RURAL
            WHERE id_propriedade = v_id_propriedade;

            DBMS_OUTPUT.PUT_LINE('ID Produtor: ' || v_result_produtor);
            DBMS_OUTPUT.PUT_LINE('ID Degradação: ' || v_result_degradacao);
            DBMS_OUTPUT.PUT_LINE('Nome: ' || v_result_nome);
            DBMS_OUTPUT.PUT_LINE('Latitude: ' || v_result_latitude);
            DBMS_OUTPUT.PUT_LINE('Longitude: ' || v_result_longitude);
            DBMS_OUTPUT.PUT_LINE('Área (ha): ' || v_result_area);
            DBMS_OUTPUT.PUT_LINE('Data Cadastro: ' || v_result_data);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Propriedade rural não encontrada com o ID especificado.');
        END;

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE, DELETE ou SELECT.');
    END IF;

    IF v_operacao != 'SELECT' THEN
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_PROPRIEDADE_RURAL;
/