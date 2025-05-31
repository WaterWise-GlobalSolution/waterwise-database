
/* 
Verificar Status dos Sensores
Controle de Fluxo: IF/ELSIF baseado em percentuais

Exemplo de saída:
=== STATUS DOS SENSORES WATERWISE ===
Total de Sensores: 25
Sensores Ativos: 22
Sensores Inativos: 3

Percentual Ativo: 88.0%

Status do Sistema:  BOM
Ação: Sistema funcionando bem, monitorar inativos

*/

DECLARE
    v_total_sensores        NUMBER;
    v_sensores_ativos       NUMBER;
    v_sensores_inativos     NUMBER;
    v_percentual_ativo      NUMBER;
    v_status_sistema        VARCHAR2(50);
    v_acao_necessaria       VARCHAR2(200);
BEGIN
    -- Contar total de sensores
    SELECT COUNT(*) 
    INTO v_total_sensores 
    FROM GS_WW_SENSOR_IOT;
    
    -- Contar sensores ativos (com leituras na última semana)
    SELECT COUNT(DISTINCT si.id_sensor)
    INTO v_sensores_ativos
    FROM GS_WW_SENSOR_IOT si
    JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
    WHERE ls.timestamp_leitura >= SYSDATE - 7; -- Última semana
    
    -- Calcular sensores inativos
    v_sensores_inativos := v_total_sensores - v_sensores_ativos;
    
    DBMS_OUTPUT.PUT_LINE('=== STATUS DOS SENSORES WATERWISE - ÚLTIMA SEMANA ===');
    DBMS_OUTPUT.PUT_LINE('Período de Análise: 7 dias');
    DBMS_OUTPUT.PUT_LINE('Total de Sensores: ' || v_total_sensores);
    DBMS_OUTPUT.PUT_LINE('Sensores Ativos (7 dias): ' || v_sensores_ativos);
    DBMS_OUTPUT.PUT_LINE('Sensores Inativos (7 dias): ' || v_sensores_inativos);
    DBMS_OUTPUT.PUT_LINE(' ');
    
    -- Verificar se há sensores cadastrados
    IF v_total_sensores = 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ CRÍTICO: Nenhum sensor cadastrado no sistema!');
        DBMS_OUTPUT.PUT_LINE('Ação: Instalar sensores imediatamente');
    ELSE
        -- Calcular percentual de sensores ativos
        v_percentual_ativo := (v_sensores_ativos * 100) / v_total_sensores;
        DBMS_OUTPUT.PUT_LINE('Percentual Ativo (7 dias): ' || ROUND(v_percentual_ativo, 1) || '%');
        DBMS_OUTPUT.PUT_LINE(' ');
        
        -- Determinar status do sistema usando IF/ELSIF/ELSE
        IF v_percentual_ativo >= 90 THEN
            v_status_sistema := '✅ EXCELENTE';
            v_acao_necessaria := 'Sistema funcionando perfeitamente na semana';
        ELSIF v_percentual_ativo >= 75 THEN
            v_status_sistema := 'BOM';
            v_acao_necessaria := 'Sistema funcionando bem, monitorar ' || v_sensores_inativos || ' sensores inativos';
        ELSIF v_percentual_ativo >= 50 THEN
            v_status_sistema := 'ATENÇÃO';
            v_acao_necessaria := 'Verificar e reparar ' || v_sensores_inativos || ' sensores inativos na semana';
        ELSIF v_percentual_ativo >= 25 THEN
            v_status_sistema := 'CRÍTICO';
            v_acao_necessaria := 'URGENTE: ' || v_sensores_inativos || ' sensores inativos na semana!';
        ELSE
            v_status_sistema := 'FALHA GERAL';
            v_acao_necessaria := 'EMERGÊNCIA: Sistema de monitoramento semanal falhou!';
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Status do Sistema: ' || v_status_sistema);
        DBMS_OUTPUT.PUT_LINE('Ação: ' || v_acao_necessaria);
    END IF;
    
END;
/