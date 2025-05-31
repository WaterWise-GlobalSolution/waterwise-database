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
            -- CORREÇÃO AQUI: Converter para NUMBER de dias antes de multiplicar por 24
            ROUND((CAST(SYSDATE AS DATE) - CAST(a.timestamp_alerta AS DATE)) * 24, 1) AS horas_atras
        FROM GS_WW_ALERTA a
        JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        JOIN GS_WW_PRODUTOR_RURAL prod ON a.id_produtor = prod.id_produtor
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON a.id_leitura = ls.id_leitura
        LEFT JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON si.id_propriedade = pr.id_propriedade
        WHERE a.timestamp_alerta >= SYSDATE - 2 -- Últimas 48 horas
        ORDER BY a.timestamp_alerta DESC;

    v_alerta            C_ALERTAS_RECENTES%ROWTYPE;
    v_total_alertas     NUMBER := 0;
    v_alertas_criticos  NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ALERTAS RECENTES (ÚLTIMAS 48H) ===');
    DBMS_OUTPUT.PUT_LINE(' ');

    OPEN C_ALERTAS_RECENTES;

    LOOP
        FETCH C_ALERTAS_RECENTES INTO v_alerta;
        EXIT WHEN C_ALERTAS_RECENTES%NOTFOUND;

        v_total_alertas := v_total_alertas + 1;
        IF v_alerta.codigo_severidade = 'CRITICO' THEN
            v_alertas_criticos := v_alertas_criticos + 1;
        END IF;

        -- Exibir informações do alerta
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

    CLOSE C_ALERTAS_RECENTES;

    -- Resumo
    DBMS_OUTPUT.PUT_LINE('=== RESUMO DE ALERTAS ===');
    DBMS_OUTPUT.PUT_LINE('Total de Alertas: ' || v_total_alertas);
    DBMS_OUTPUT.PUT_LINE('Alertas Críticos: ' || v_alertas_criticos);

    IF v_alertas_criticos > 0 THEN
        DBMS_OUTPUT.PUT_LINE('ATENÇÃO: ' || v_alertas_criticos || ' alertas críticos nas últimas 48h. Ações urgentes podem ser necessárias!');
    ELSIF v_total_alertas = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum alerta registrado nas últimas 48 horas. Situação tranquila.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Monitoramento normal. Alertas de baixa/média severidade.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório de alertas recentes: ' || SQLERRM);
END;
/