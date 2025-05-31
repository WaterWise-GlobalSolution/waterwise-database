-- ============================================================================
-- 7. PROCEDURE CRUD PARA LEITURA SENSOR
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_LEITURA_SENSOR(
    v_operacao          IN VARCHAR2,
    v_id_leitura        IN GS_WW_LEITURA_SENSOR.id_leitura%TYPE,
    v_id_sensor         IN GS_WW_LEITURA_SENSOR.id_sensor%TYPE,
    v_umidade_solo      IN GS_WW_LEITURA_SENSOR.umidade_solo%TYPE,
    v_temperatura_ar    IN GS_WW_LEITURA_SENSOR.temperatura_ar%TYPE,
    v_precipitacao_mm   IN GS_WW_LEITURA_SENSOR.precipitacao_mm%TYPE
) IS
    v_mensagem VARCHAR2(255);
    -- Variáveis para o SELECT
    v_result_sensor      GS_WW_LEITURA_SENSOR.id_sensor%TYPE;
    v_result_timestamp   GS_WW_LEITURA_SENSOR.timestamp_leitura%TYPE;
    v_result_umidade     GS_WW_LEITURA_SENSOR.umidade_solo%TYPE;
    v_result_temperatura GS_WW_LEITURA_SENSOR.temperatura_ar%TYPE;
    v_result_precipitacao GS_WW_LEITURA_SENSOR.precipitacao_mm%TYPE;

BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_LEITURA_SENSOR (
            id_sensor, timestamp_leitura, umidade_solo, temperatura_ar, precipitacao_mm
        ) VALUES (
            v_id_sensor, CURRENT_TIMESTAMP, v_umidade_solo, v_temperatura_ar, v_precipitacao_mm
        );
        v_mensagem := 'Leitura de sensor inserida com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_LEITURA_SENSOR
        SET id_sensor = v_id_sensor,
            umidade_solo = v_umidade_solo,
            temperatura_ar = v_temperatura_ar,
            precipitacao_mm = v_precipitacao_mm
        WHERE id_leitura = v_id_leitura;
        v_mensagem := 'Leitura de sensor atualizada com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_LEITURA_SENSOR
        WHERE id_leitura = v_id_leitura;
        v_mensagem := 'Leitura de sensor deletada com sucesso.';

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT id_sensor, timestamp_leitura, umidade_solo, temperatura_ar, precipitacao_mm
            INTO v_result_sensor, v_result_timestamp, v_result_umidade, v_result_temperatura, v_result_precipitacao
            FROM GS_WW_LEITURA_SENSOR
            WHERE id_leitura = v_id_leitura;

            DBMS_OUTPUT.PUT_LINE('ID Sensor: ' || v_result_sensor);
            DBMS_OUTPUT.PUT_LINE('Timestamp: ' || v_result_timestamp);
            DBMS_OUTPUT.PUT_LINE('Umidade Solo: ' || v_result_umidade || '%');
            DBMS_OUTPUT.PUT_LINE('Temperatura: ' || v_result_temperatura || '°C');
            DBMS_OUTPUT.PUT_LINE('Precipitação: ' || v_result_precipitacao || 'mm');

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Leitura de sensor não encontrada com o ID especificado.');
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
END CRUD_LEITURA_SENSOR;
/