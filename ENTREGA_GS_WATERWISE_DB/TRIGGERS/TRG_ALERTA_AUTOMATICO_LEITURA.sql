/*
 TRG_ALERTA_AUTOMATICO_LEITURA

Função: Gera alertas automáticos baseados em leituras críticas dos sensores

Condições de Alerta:
Umidade < 15% → Risco de dessecamento (ALTO)
Umidade > 90% → Solo saturado - risco de alagamento (CRÍTICO)
Temperatura > 40°C → Estresse térmico (ALTO)
Temperatura < 0°C → Risco de geada (ALTO)
Precipitação > 80mm → Risco iminente de enchente (CRÍTICO)
Precipitação > 50mm → Chuva forte - monitoramento (ALTO)

*/

CREATE OR REPLACE TRIGGER TRG_ALERTA_AUTOMATICO_LEITURA
    AFTER INSERT ON GS_WW_LEITURA_SENSOR
    FOR EACH ROW
DECLARE
    v_id_propriedade    GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE;
    v_id_produtor       GS_WW_PRODUTOR_RURAL.id_produtor%TYPE;
    v_nome_propriedade  GS_WW_PROPRIEDADE_RURAL.nome_propriedade%TYPE;
    v_nivel_severidade  NUMBER(1);
    v_descricao_alerta  VARCHAR2(500);
    v_gerar_alerta     BOOLEAN := FALSE;
BEGIN
    -- Buscar dados da propriedade e produtor
    SELECT pr.id_propriedade, pr.id_produtor, pr.nome_propriedade
    INTO v_id_propriedade, v_id_produtor, v_nome_propriedade
    FROM GS_WW_PROPRIEDADE_RURAL pr
    JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
    WHERE si.id_sensor = :NEW.id_sensor;
    
    -- CONDIÇÕES CRÍTICAS PARA ALERTAS AUTOMÁTICOS
    
    -- 1. Umidade do solo crítica (muito baixa ou muito alta)
    IF :NEW.umidade_solo IS NOT NULL THEN
        IF :NEW.umidade_solo < 15 THEN
            v_gerar_alerta := TRUE;
            v_nivel_severidade := 3; -- ALTO
            v_descricao_alerta := 'ALERTA AUTOMÁTICO: Umidade do solo crítica (' || 
                                :NEW.umidade_solo || '%) - Risco de dessecamento em ' || v_nome_propriedade;
        ELSIF :NEW.umidade_solo > 90 THEN
            v_gerar_alerta := TRUE;
            v_nivel_severidade := 4; -- CRÍTICO
            v_descricao_alerta := 'ALERTA AUTOMÁTICO: Solo saturado (' || 
                                :NEW.umidade_solo || '%) - Alto risco de alagamento em ' || v_nome_propriedade;
        END IF;
    END IF;
    
    -- 2. Temperatura extrema
    IF :NEW.temperatura_ar IS NOT NULL AND NOT v_gerar_alerta THEN
        IF :NEW.temperatura_ar > 40 THEN
            v_gerar_alerta := TRUE;
            v_nivel_severidade := 3; -- ALTO
            v_descricao_alerta := 'ALERTA AUTOMÁTICO: Temperatura extrema (' || 
                                :NEW.temperatura_ar || '°C) - Estresse térmico em ' || v_nome_propriedade;
        ELSIF :NEW.temperatura_ar < 0 THEN
            v_gerar_alerta := TRUE;
            v_nivel_severidade := 3; -- ALTO
            v_descricao_alerta := 'ALERTA AUTOMÁTICO: Temperatura de congelamento (' || 
                                :NEW.temperatura_ar || '°C) - Risco de geada em ' || v_nome_propriedade;
        END IF;
    END IF;
    
    -- 3. Precipitação excessiva (enchente)
    IF :NEW.precipitacao_mm IS NOT NULL AND NOT v_gerar_alerta THEN
        IF :NEW.precipitacao_mm > 80 THEN
            v_gerar_alerta := TRUE;
            v_nivel_severidade := 4; -- CRÍTICO
            v_descricao_alerta := 'ALERTA AUTOMÁTICO: Precipitação intensa (' || 
                                :NEW.precipitacao_mm || 'mm) - Risco iminente de enchente em ' || v_nome_propriedade;
        ELSIF :NEW.precipitacao_mm > 50 THEN
            v_gerar_alerta := TRUE;
            v_nivel_severidade := 3; -- ALTO
            v_descricao_alerta := 'ALERTA AUTOMÁTICO: Chuva forte (' || 
                                :NEW.precipitacao_mm || 'mm) - Monitoramento de alagamento em ' || v_nome_propriedade;
        END IF;
    END IF;
    
    -- Gerar alerta se alguma condição crítica foi detectada
    IF v_gerar_alerta THEN
        INSERT INTO GS_WW_ALERTA (
            id_produtor, 
            id_leitura, 
            id_nivel_severidade, 
            timestamp_alerta, 
            descricao_alerta
        ) VALUES (
            v_id_produtor,
            :NEW.id_leitura,
            v_nivel_severidade,
            CURRENT_TIMESTAMP,
            v_descricao_alerta
        );
        
        -- Log para auditoria
        DBMS_OUTPUT.PUT_LINE('ALERTA GERADO: ' || v_descricao_alerta);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log do erro sem interromper a inserção da leitura
        DBMS_OUTPUT.PUT_LINE('Erro na geração de alerta automático: ' || SQLERRM);
END TRG_ALERTA_AUTOMATICO_LEITURA;
/