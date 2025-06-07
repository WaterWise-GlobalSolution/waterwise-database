/*
CURSOR: Estado Geral do Solo

O que faz: Mostra como está a qualidade do solo por região do Brasil

Exemplo de saída:
REGIÃO: CENTRO
Estado: Solo em excelente estado de conservação
  Propriedades: 15
  Área Total: 2,450.8 hectares
  Umidade Média: 45.2%

*/

DECLARE

    CURSOR C_ESTADO_SOLO IS
        SELECT 
            CASE 
                WHEN pr.latitude > -15 THEN 'NORTE'
                WHEN pr.latitude > -25 THEN 'CENTRO'
                ELSE 'SUL'
            END AS regiao,
            nd.descricao_degradacao,
            COUNT(*) AS quantidade_propriedades,
            SUM(pr.area_hectares) AS area_total,
            AVG(CASE WHEN ls.umidade_solo IS NOT NULL THEN ls.umidade_solo END) AS umidade_media
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor 
            AND ls.timestamp_leitura >= SYSDATE - 1 -- Últimas 24 horas
        GROUP BY 
            CASE 
                WHEN pr.latitude > -15 THEN 'NORTE'
                WHEN pr.latitude > -25 THEN 'CENTRO'
                ELSE 'SUL'
            END,
            nd.descricao_degradacao,
            nd.nivel_numerico
        ORDER BY regiao, nd.nivel_numerico;

    v_solo              c_estado_solo%ROWTYPE;
    v_regiao_anterior   VARCHAR2(10) := '';

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ESTADO GERAL DO SOLO ===');
    DBMS_OUTPUT.PUT_LINE('Por região geográfica');
    DBMS_OUTPUT.PUT_LINE(' ');
    
    OPEN c_estado_solo;
    
    LOOP
        FETCH c_estado_solo INTO v_solo;
        EXIT WHEN c_estado_solo%NOTFOUND;
        
        IF v_solo.regiao != v_regiao_anterior THEN
            IF v_regiao_anterior != '' THEN
                DBMS_OUTPUT.PUT_LINE(' ');
            END IF;
            DBMS_OUTPUT.PUT_LINE('REGIÃO: ' || v_solo.regiao);
            DBMS_OUTPUT.PUT_LINE('==================');
            v_regiao_anterior := v_solo.regiao;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Estado: ' || v_solo.descricao_degradacao);
        DBMS_OUTPUT.PUT_LINE('  Propriedades: ' || v_solo.quantidade_propriedades);
        DBMS_OUTPUT.PUT_LINE('  Área Total: ' || ROUND(v_solo.area_total, 1) || ' hectares');
        
        IF v_solo.umidade_media IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  Umidade Média: ' || ROUND(v_solo.umidade_media, 1) || '%');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
    
    CLOSE c_estado_solo;
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_estado_solo%ISOPEN THEN
            CLOSE c_estado_solo;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/