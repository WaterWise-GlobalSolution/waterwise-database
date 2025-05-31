/*
CURSOR: Resumo Diário do Sistema

O que faz: Métricas gerais do sistema no dia atual

Exemplo de saída:
MÉTRICAS DO SISTEMA:
Propriedades Monitoradas: 25
Sensores Instalados: 48
Leituras Hoje: 156
Alertas Hoje: 3

CONDIÇÕES AMBIENTAIS HOJE:
Umidade Média do Solo: 42.5%
Temperatura Média: 24.8°C
Chuva Total: 12.3mm

STATUS GERAL:
⚠️ Sistema em monitoramento - 3 alertas hoje

*/

DECLARE

    CURSOR C_RESUMO_DIARIO IS
        SELECT 
            COUNT(DISTINCT pr.id_propriedade) AS total_propriedades,
            COUNT(DISTINCT si.id_sensor) AS total_sensores,
            COUNT(DISTINCT ls.id_leitura) AS leituras_hoje,
            COUNT(DISTINCT a.id_alerta) AS alertas_hoje,
            AVG(ls.umidade_solo) AS umidade_media_hoje,
            AVG(ls.temperatura_ar) AS temperatura_media_hoje,
            SUM(ls.precipitacao_mm) AS chuva_total_hoje
        FROM GS_WW_PROPRIEDADE_RURAL pr
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
            AND ls.timestamp_leitura >= TRUNC(SYSDATE) -- Hoje
        LEFT JOIN GS_WW_ALERTA a ON ls.id_leitura = a.id_leitura
            AND a.timestamp_alerta >= TRUNC(SYSDATE); -- Hoje

    v_resumo            c_resumo_diario%ROWTYPE;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RESUMO DIÁRIO DO SISTEMA WATERWISE ===');
    DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE(' ');
    
    OPEN c_resumo_diario;
    FETCH c_resumo_diario INTO v_resumo;
    CLOSE c_resumo_diario;
    
    DBMS_OUTPUT.PUT_LINE('MÉTRICAS DO SISTEMA:');
    DBMS_OUTPUT.PUT_LINE('Propriedades Monitoradas: ' || v_resumo.total_propriedades);
    DBMS_OUTPUT.PUT_LINE('Sensores Instalados: ' || v_resumo.total_sensores);
    DBMS_OUTPUT.PUT_LINE('Leituras Hoje: ' || v_resumo.leituras_hoje);
    DBMS_OUTPUT.PUT_LINE('Alertas Hoje: ' || v_resumo.alertas_hoje);
    DBMS_OUTPUT.PUT_LINE(' ');
    
    DBMS_OUTPUT.PUT_LINE('CONDIÇÕES AMBIENTAIS HOJE:');
    IF v_resumo.umidade_media_hoje IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Umidade Média do Solo: ' || ROUND(v_resumo.umidade_media_hoje, 1) || '%');
    END IF;
    
    IF v_resumo.temperatura_media_hoje IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Temperatura Média: ' || ROUND(v_resumo.temperatura_media_hoje, 1) || '°C');
    END IF;
    
    IF v_resumo.chuva_total_hoje IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Chuva Total: ' || ROUND(v_resumo.chuva_total_hoje, 1) || 'mm');
    END IF;
    DBMS_OUTPUT.PUT_LINE(' ');
    
    DBMS_OUTPUT.PUT_LINE('STATUS GERAL:');
    IF v_resumo.alertas_hoje = 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Sistema tranquilo - Nenhum alerta hoje');
    ELSIF v_resumo.alertas_hoje <= 5 THEN
        DBMS_OUTPUT.PUT_LINE('⚠️ Sistema em monitoramento - ' || v_resumo.alertas_hoje || ' alertas hoje');
    ELSE
        DBMS_OUTPUT.PUT_LINE('🚨 Sistema em alerta - ' || v_resumo.alertas_hoje || ' alertas hoje - Atenção necessária');
    END IF;
    
    IF v_resumo.leituras_hoje < v_resumo.total_sensores * 0.5 THEN
        DBMS_OUTPUT.PUT_LINE('⚠️ Baixa atividade dos sensores - Verificar funcionamento');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_resumo_diario%ISOPEN THEN
            CLOSE c_resumo_diario;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/