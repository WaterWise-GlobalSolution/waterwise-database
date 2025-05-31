-- ============================================================================
-- 1. PROCEDURE CRUD PARA TIPO SENSOR
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_TIPO_SENSOR(
    v_operacao         IN VARCHAR2,
    v_id_tipo_sensor   IN GS_WW_TIPO_SENSOR.id_tipo_sensor%TYPE,
    v_nome_tipo        IN GS_WW_TIPO_SENSOR.nome_tipo%TYPE,
    v_descricao        IN GS_WW_TIPO_SENSOR.descricao%TYPE,
    v_unidade_medida   IN GS_WW_TIPO_SENSOR.unidade_medida%TYPE,
    v_valor_min        IN GS_WW_TIPO_SENSOR.valor_min%TYPE,
    v_valor_max        IN GS_WW_TIPO_SENSOR.valor_max%TYPE
) IS
    v_mensagem VARCHAR2(255);
    -- Variáveis para o SELECT
    v_result_nome       GS_WW_TIPO_SENSOR.nome_tipo%TYPE;
    v_result_descricao  GS_WW_TIPO_SENSOR.descricao%TYPE;
    v_result_unidade    GS_WW_TIPO_SENSOR.unidade_medida%TYPE;
    v_result_min        GS_WW_TIPO_SENSOR.valor_min%TYPE;
    v_result_max        GS_WW_TIPO_SENSOR.valor_max%TYPE;

BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_TIPO_SENSOR (
            nome_tipo, descricao, unidade_medida, valor_min, valor_max
        ) VALUES (
            v_nome_tipo, v_descricao, v_unidade_medida, v_valor_min, v_valor_max
        );
        v_mensagem := 'Tipo de sensor inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_TIPO_SENSOR
        SET nome_tipo = v_nome_tipo,
            descricao = v_descricao,
            unidade_medida = v_unidade_medida,
            valor_min = v_valor_min,
            valor_max = v_valor_max
        WHERE id_tipo_sensor = v_id_tipo_sensor;
        v_mensagem := 'Tipo de sensor atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_TIPO_SENSOR
        WHERE id_tipo_sensor = v_id_tipo_sensor;
        v_mensagem := 'Tipo de sensor deletado com sucesso.';

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT nome_tipo, descricao, unidade_medida, valor_min, valor_max
            INTO v_result_nome, v_result_descricao, v_result_unidade, v_result_min, v_result_max
            FROM GS_WW_TIPO_SENSOR
            WHERE id_tipo_sensor = v_id_tipo_sensor;

            DBMS_OUTPUT.PUT_LINE('Nome: ' || v_result_nome);
            DBMS_OUTPUT.PUT_LINE('Descrição: ' || v_result_descricao);
            DBMS_OUTPUT.PUT_LINE('Unidade: ' || v_result_unidade);
            DBMS_OUTPUT.PUT_LINE('Valor Mín: ' || v_result_min);
            DBMS_OUTPUT.PUT_LINE('Valor Máx: ' || v_result_max);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Tipo de sensor não encontrado com o ID especificado.');
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
END CRUD_TIPO_SENSOR;
/