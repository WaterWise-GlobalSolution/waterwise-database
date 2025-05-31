/*
Analisar Alertas do Dia
Controle de Fluxo: IF aninhados para classificar o dia

Exemplo de saída:
=== ANÁLISE DE ALERTAS DE HOJE ===
Data: 30/05/2024

Total de Alertas: 7
Alertas Críticos: 2
Alertas Automáticos: 5
Primeiro Alerta: 08:15
Último Alerta: 14:30

Situação: ️ DIA CRÍTICO
Recomendação: Monitoramento intensivo necessário

️ ATENÇÃO ESPECIAL: 2 alertas críticos hoje!
Verificar propriedades em risco imediatamente

*/

DECLARE
    v_alertas_hoje          NUMBER;
    v_alertas_criticos      NUMBER;
    v_alertas_automaticos   NUMBER;
    v_primeiro_alerta       TIMESTAMP;
    v_ultimo_alerta         TIMESTAMP;
    v_situacao_dia          VARCHAR2(50);
    v_recomendacao          VARCHAR2(200);
BEGIN

    SELECT 
        COUNT(*),
        COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END),
        COUNT(CASE WHEN a.descricao_alerta LIKE 'ALERTA AUTOMÁTICO:%' THEN 1 END),
        MIN(a.timestamp_alerta),
        MAX(a.timestamp_alerta)
    INTO 
        v_alertas_hoje,
        v_alertas_criticos,
        v_alertas_automaticos,
        v_primeiro_alerta,
        v_ultimo_alerta
    FROM GS_WW_ALERTA a
    LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
    WHERE a.timestamp_alerta >= TRUNC(SYSDATE); -- Hoje
    
    DBMS_OUTPUT.PUT_LINE('=== ANÁLISE DE ALERTAS DE HOJE ===');
    DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE(' ');
    

    IF v_alertas_hoje = 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ DIA TRANQUILO: Nenhum alerta hoje');
        DBMS_OUTPUT.PUT_LINE('Sistema funcionando normalmente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total de Alertas: ' || v_alertas_hoje);
        DBMS_OUTPUT.PUT_LINE('Alertas Críticos: ' || v_alertas_criticos);
        DBMS_OUTPUT.PUT_LINE('Alertas Automáticos: ' || v_alertas_automaticos);
        DBMS_OUTPUT.PUT_LINE('Primeiro Alerta: ' || TO_CHAR(v_primeiro_alerta, 'HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('Último Alerta: ' || TO_CHAR(v_ultimo_alerta, 'HH24:MI'));
        DBMS_OUTPUT.PUT_LINE(' ');
        

        IF v_alertas_criticos >= 5 THEN
            v_situacao_dia := '🚨 DIA DE EMERGÊNCIA';
            v_recomendacao := 'Ativar protocolo de emergência geral!';
        ELSIF v_alertas_criticos >= 2 THEN
            v_situacao_dia := '⚠️ DIA CRÍTICO';
            v_recomendacao := 'Monitoramento intensivo necessário';
        ELSIF v_alertas_hoje >= 10 THEN
            v_situacao_dia := '🟨 DIA AGITADO';
            v_recomendacao := 'Verificar causas dos múltiplos alertas';
        ELSIF v_alertas_automaticos = v_alertas_hoje THEN
            v_situacao_dia := '🤖 DIA AUTOMATIZADO';
            v_recomendacao := 'Sistema inteligente funcionando bem';
        ELSE
            v_situacao_dia := '📊 DIA NORMAL';
            v_recomendacao := 'Acompanhar alertas conforme necessário';
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Situação: ' || v_situacao_dia);
        DBMS_OUTPUT.PUT_LINE('Recomendação: ' || v_recomendacao);
        

        IF v_alertas_criticos > 0 THEN
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE('⚠️ ATENÇÃO ESPECIAL: ' || v_alertas_criticos || ' alertas críticos hoje!');
            DBMS_OUTPUT.PUT_LINE('Verificar propriedades em risco imediatamente');
        END IF;
    END IF;
    
END;
/