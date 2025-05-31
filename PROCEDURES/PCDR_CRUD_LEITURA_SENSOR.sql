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

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE ou DELETE.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_LEITURA_SENSOR;
/