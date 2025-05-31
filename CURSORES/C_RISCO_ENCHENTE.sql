/*
CURSOR: Propriedades com Risco de Enchente

Mostra propriedades que podem alagar nas próximas horas

Exemplo de saída:
RISCO: CRÍTICO
Propriedade: Fazenda São João
Produtor: João Silva
Telefone: (11)99876-5432
Umidade Solo: 87.3%
Chuva Máxima: 65.2mm
Estado do Solo: Solo com degradação moderada

*/

DECLARE

    CURSOR C_RISCO_ENCHENTE IS
        SELECT 
            pr.nome_propriedade,
            prod.nome_completo AS produtor,
            prod.telefone,
            AVG(ls.umidade_solo) AS umidade_media,
            MAX(ls.precipitacao_mm) AS chuva_maxima,
            nd.descricao_degradacao AS estado_solo,
            CASE 
                WHEN AVG(ls.umidade_solo) > 85 AND MAX(ls.precipitacao_mm) > 50 THEN 'CRÍTICO'
                WHEN AVG(ls.umidade_solo) > 70 OR MAX(ls.precipitacao_mm) > 30 THEN 'ALTO'
                WHEN AVG(ls.umidade_solo) > 50 OR MAX(ls.precipitacao_mm) > 15 THEN 'MÉDIO'
                ELSE 'BAIXO'
            END AS nivel_risco
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
        WHERE ls.timestamp_leitura >= SYSDATE - 1 -- Últimas 24 horas
        GROUP BY pr.nome_propriedade, prod.nome_completo, prod.telefone, nd.descricao_degradacao
        HAVING AVG(ls.umidade_solo) > 50 OR MAX(ls.precipitacao_mm) > 10
        ORDER BY 
            CASE 
                WHEN AVG(ls.umidade_solo) > 85 AND MAX(ls.precipitacao_mm) > 50 THEN 1
                WHEN AVG(ls.umidade_solo) > 70 OR MAX(ls.precipitacao_mm) > 30 THEN 2
                WHEN AVG(ls.umidade_solo) > 50 OR MAX(ls.precipitacao_mm) > 15 THEN 3
                ELSE 4
            END;

    v_propriedade       c_risco_enchente%ROWTYPE;
    v_contador_critico  NUMBER := 0;
    v_contador_alto     NUMBER := 0;
    v_contador_medio    NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PROPRIEDADES COM RISCO DE ENCHENTE ===');
    DBMS_OUTPUT.PUT_LINE('Análise das últimas 24 horas');
    DBMS_OUTPUT.PUT_LINE(' ');
    

    OPEN c_risco_enchente;
    
    LOOP
        FETCH c_risco_enchente INTO v_propriedade;
        EXIT WHEN c_risco_enchente%NOTFOUND;
        
        IF v_propriedade.nivel_risco = 'CRÍTICO' THEN
            v_contador_critico := v_contador_critico + 1;
        ELSIF v_propriedade.nivel_risco = 'ALTO' THEN
            v_contador_alto := v_contador_alto + 1;
        ELSIF v_propriedade.nivel_risco = 'MÉDIO' THEN
            v_contador_medio := v_contador_medio + 1;
        END IF;
        

        DBMS_OUTPUT.PUT_LINE('RISCO: ' || v_propriedade.nivel_risco);
        DBMS_OUTPUT.PUT_LINE('Propriedade: ' || v_propriedade.nome_propriedade);
        DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_propriedade.produtor);
        DBMS_OUTPUT.PUT_LINE('Telefone: ' || v_propriedade.telefone);
        DBMS_OUTPUT.PUT_LINE('Umidade Solo: ' || ROUND(v_propriedade.umidade_media, 1) || '%');
        DBMS_OUTPUT.PUT_LINE('Chuva Máxima: ' || ROUND(v_propriedade.chuva_maxima, 1) || 'mm');
        DBMS_OUTPUT.PUT_LINE('Estado do Solo: ' || v_propriedade.estado_solo);
        DBMS_OUTPUT.PUT_LINE('----------------------------');
    END LOOP;
    
    CLOSE c_risco_enchente;
    

    DBMS_OUTPUT.PUT_LINE('=== RESUMO ===');
    DBMS_OUTPUT.PUT_LINE('CRÍTICO: ' || v_contador_critico || ' propriedades');
    DBMS_OUTPUT.PUT_LINE('ALTO: ' || v_contador_alto || ' propriedades');
    DBMS_OUTPUT.PUT_LINE('MÉDIO: ' || v_contador_medio || ' propriedades');
    DBMS_OUTPUT.PUT_LINE('TOTAL: ' || (v_contador_critico + v_contador_alto + v_contador_medio) || ' propriedades em risco');
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_risco_enchente%ISOPEN THEN
            CLOSE c_risco_enchente;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/