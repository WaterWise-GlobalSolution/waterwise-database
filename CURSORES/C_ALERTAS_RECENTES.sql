/*
CURSOR: Alertas Recentes

Lista todos os alertas das últimas 48 horas

Exemplo de saída:
SEVERIDADE: CRITICO
Descrição: Solo saturado - Alto risco de alagamento
Produtor: Maria Costa
Telefone: (11)98765-4321
Propriedade: Sítio Santa Maria
Quando: 30/05/2024 08:15
Há: 6.2 horas

*/

DECLARE
    -- Cursor para mostrar alertas das últimas 48 horas
    CURSOR C_ALERTAS_RECENTES IS
        SELECT 
            a.timestamp_alerta,
            a.descricao_alerta,
            ns.codigo_severidade,
            prod.nome_completo AS produtor,
            prod.telefone,
            pr.nome_propriedade,
            ROUND((SYSDATE - a.timestamp_alerta) * 24, 1) AS horas_atras
        FROM GS_WW_ALERTA a
        JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        JOIN GS_WW_PRODUTOR_RURAL prod ON a.id_produtor = prod.id_produtor
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON a.id_leitura = ls.id_leitura
        LEFT JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON si.id_propriedade = pr.id_propriedade
        WHERE a.timestamp_alerta >= SYSDATE - 2 -- Últimas 48 horas
        ORDER BY a.timestamp_alerta DESC;

    v_alerta            c_alertas_recentes%ROWTYPE;
    v_total_alertas     NUMBER := 0;
    v_alertas_criticos  NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ALERTAS RECENTES ===');
    DBMS_OUTPUT.PUT_LINE('Últimas 48 horas');
    DBMS_OUTPUT.PUT_LINE(' ');
    
    OPEN c_alertas_recentes;
    
    LOOP
        FETCH c_alertas_recentes INTO v_alerta;
        EXIT WHEN c_alertas_recentes%NOTFOUND;
        
        v_total_alertas := v_total_alertas + 1;
        
        -- Contar alertas críticos
        IF v_alerta.codigo_severidade = 'CRITICO' THEN
            v_alertas_criticos := v_alertas_criticos + 1;
        END IF;
        
        -- Mostrar informações do alerta
        DBMS_OUTPUT.PUT_LINE('SEVERIDADE: ' || v_alerta.codigo_severidade);
        DBMS_OUTPUT.PUT_LINE('Descrição: ' || v_alerta.descricao_alerta);
        DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_alerta.produtor);
        DBMS_OUTPUT.PUT_LINE('Telefone: ' || v_alerta.telefone);
        
        IF v_alerta.nome_propriedade IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Propriedade: ' || v_alerta.nome_propriedade);
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Quando: ' || TO_CHAR(v_alerta.timestamp_alerta, 'DD/MM/YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('Há: ' || v_alerta.horas_atras || ' horas');
        DBMS_OUTPUT.PUT_LINE('----------------------------');
    END LOOP;
    
    CLOSE c_alertas_recentes;
    
    -- Resumo
    DBMS_OUTPUT.PUT_LINE('=== RESUMO DE ALERTAS ===');
    DBMS_OUTPUT.PUT_LINE('Total de Alertas: ' || v_total_alertas);
    DBMS_OUTPUT.PUT_LINE('Alertas Críticos: ' || v_alertas_criticos);
    
    IF v_alertas_criticos > 0 THEN
        DBMS_OUTPUT.PUT_LINE('ATENÇÃO: ' || v_alertas_criticos || ' alertas críticos precisam de ação imediata!');
    END IF;
    
    IF v_total_alertas = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum alerta nas últimas 48 horas - Sistema tranquilo');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_alertas_recentes%ISOPEN THEN
            CLOSE c_alertas_recentes;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/
