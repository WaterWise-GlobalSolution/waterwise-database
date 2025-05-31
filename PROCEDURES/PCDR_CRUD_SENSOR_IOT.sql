-- ============================================================================
-- 6. PROCEDURE CRUD PARA SENSOR IOT
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_SENSOR_IOT(
    v_operacao           IN VARCHAR2,
    v_id_sensor          IN GS_WW_SENSOR_IOT.id_sensor%TYPE,
    v_id_propriedade     IN GS_WW_SENSOR_IOT.id_propriedade%TYPE,
    v_id_tipo_sensor     IN GS_WW_SENSOR_IOT.id_tipo_sensor%TYPE,
    v_modelo_dispositivo IN GS_WW_SENSOR_IOT.modelo_dispositivo%TYPE
) IS
    v_mensagem VARCHAR2(255);
    -- Variáveis para o SELECT
    v_result_propriedade  GS_WW_SENSOR_IOT.id_propriedade%TYPE;
    v_result_tipo         GS_WW_SENSOR_IOT.id_tipo_sensor%TYPE;
    v_result_modelo       GS_WW_SENSOR_IOT.modelo_dispositivo%TYPE;
    v_result_data         GS_WW_SENSOR_IOT.data_instalacao%TYPE;

BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_SENSOR_IOT (
            id_propriedade, id_tipo_sensor, modelo_dispositivo, data_instalacao
        ) VALUES (
            v_id_propriedade, v_id_tipo_sensor, v_modelo_dispositivo, SYSDATE
        );
        v_mensagem := 'Sensor IoT inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_SENSOR_IOT
        SET id_propriedade = v_id_propriedade,
            id_tipo_sensor = v_id_tipo_sensor,
            modelo_dispositivo = v_modelo_dispositivo
        WHERE id_sensor = v_id_sensor;
        v_mensagem := 'Sensor IoT atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_SENSOR_IOT
        WHERE id_sensor = v_id_sensor;
        v_mensagem := 'Sensor IoT deletado com sucesso.';

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT id_propriedade, id_tipo_sensor, modelo_dispositivo, data_instalacao
            INTO v_result_propriedade, v_result_tipo, v_result_modelo, v_result_data
            FROM GS_WW_SENSOR_IOT
            WHERE id_sensor = v_id_sensor;

            DBMS_OUTPUT.PUT_LINE('ID Propriedade: ' || v_result_propriedade);
            DBMS_OUTPUT.PUT_LINE('ID Tipo Sensor: ' || v_result_tipo);
            DBMS_OUTPUT.PUT_LINE('Modelo: ' || v_result_modelo);
            DBMS_OUTPUT.PUT_LINE('Data Instalação: ' || v_result_data);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Sensor IoT não encontrado com o ID especificado.');
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
END CRUD_SENSOR_IOT;
/