/*
TRIGGER: VALIDAÇÃO DE DADOS DE LEITURA DOS SENSORES
Função: Valida dados de leitura antes de inserir no banco

Validações:
Umidade: 0% a 100%
Temperatura: -50°C a 70°C
Precipitação: 0mm a 1000mm
Timestamp: Não pode ser futuro
Dados suspeitos: Impede todos valores zerados

*/

CREATE OR REPLACE TRIGGER TRG_VALIDAR_DADOS_SENSOR
    BEFORE INSERT OR UPDATE ON GS_WW_LEITURA_SENSOR
    FOR EACH ROW
DECLARE
    v_tipo_sensor      GS_WW_TIPO_SENSOR.nome_tipo%TYPE;
    v_valor_min        GS_WW_TIPO_SENSOR.valor_min%TYPE;
    v_valor_max        GS_WW_TIPO_SENSOR.valor_max%TYPE;
    v_erro_validacao   VARCHAR2(200);
BEGIN
    -- Buscar informações do tipo de sensor
    SELECT ts.nome_tipo, ts.valor_min, ts.valor_max
    INTO v_tipo_sensor, v_valor_min, v_valor_max
    FROM GS_WW_TIPO_SENSOR ts
    JOIN GS_WW_SENSOR_IOT si ON ts.id_tipo_sensor = si.id_tipo_sensor
    WHERE si.id_sensor = :NEW.id_sensor;
    
    -- Validações específicas por tipo de medição
    
    -- 1. Validar umidade do solo (0-100%)
    IF :NEW.umidade_solo IS NOT NULL THEN
        IF :NEW.umidade_solo < 0 OR :NEW.umidade_solo > 100 THEN
            v_erro_validacao := 'Umidade do solo deve estar entre 0% e 100%';
            RAISE_APPLICATION_ERROR(-20001, v_erro_validacao);
        END IF;
    END IF;
    
    -- 2. Validar temperatura (-50°C a 70°C)
    IF :NEW.temperatura_ar IS NOT NULL THEN
        IF :NEW.temperatura_ar < -50 OR :NEW.temperatura_ar > 70 THEN
            v_erro_validacao := 'Temperatura deve estar entre -50°C e 70°C';
            RAISE_APPLICATION_ERROR(-20002, v_erro_validacao);
        END IF;
    END IF;
    
    -- 3. Validar precipitação (0-1000mm)
    IF :NEW.precipitacao_mm IS NOT NULL THEN
        IF :NEW.precipitacao_mm < 0 OR :NEW.precipitacao_mm > 1000 THEN
            v_erro_validacao := 'Precipitação deve estar entre 0mm e 1000mm';
            RAISE_APPLICATION_ERROR(-20003, v_erro_validacao);
        END IF;
    END IF;
    
    -- 4. Validar timestamp (não pode ser futuro)
    IF :NEW.timestamp_leitura > CURRENT_TIMESTAMP + INTERVAL '1' HOUR THEN
        v_erro_validacao := 'Timestamp da leitura não pode ser no futuro';
        RAISE_APPLICATION_ERROR(-20004, v_erro_validacao);
    END IF;
    
    -- 5. Validar se há valores extremos suspeitos (possível falha do sensor)
    IF (:NEW.umidade_solo = 0 AND :NEW.temperatura_ar = 0 AND :NEW.precipitacao_mm = 0) THEN
        v_erro_validacao := 'Leitura suspeita - todos os valores zerados (possível falha do sensor)';
        RAISE_APPLICATION_ERROR(-20005, v_erro_validacao);
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'Sensor não encontrado ou não configurado');
    WHEN OTHERS THEN
        RAISE;
END TRG_VALIDAR_DADOS_SENSOR;
/