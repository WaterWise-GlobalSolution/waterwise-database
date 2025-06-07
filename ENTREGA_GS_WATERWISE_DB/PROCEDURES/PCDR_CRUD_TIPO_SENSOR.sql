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

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE ou DELETE.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_TIPO_SENSOR;
/