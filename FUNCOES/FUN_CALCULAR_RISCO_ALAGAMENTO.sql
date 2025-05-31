-- ============================================================================
-- FUNÇÃO CORRIGIDA: CALCULAR RISCO DE ALAGAMENTO  
-- ============================================================================
CREATE OR REPLACE FUNCTION CALCULAR_RISCO_ALAGAMENTO(
    p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
) RETURN VARCHAR2
IS
    v_precipitacao_media    NUMBER(8,2);
    v_umidade_solo_media    NUMBER(5,2);
    v_nivel_degradacao      NUMBER(1);
    v_area_hectares         NUMBER(10,2);
    v_score_risco          NUMBER(5,2);
    v_nivel_risco          VARCHAR2(20);
    v_count_leituras       NUMBER;
    
    -- Cursor para buscar dados das últimas 24 horas (CORRIGIDO)
    CURSOR c_dados_propriedade IS
        SELECT 
            AVG(ls.precipitacao_mm) as precipitacao_avg,
            AVG(ls.umidade_solo) as umidade_avg,
            COUNT(*) as total_leituras
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        WHERE si.id_propriedade = p_id_propriedade
        AND ls.timestamp_leitura >= SYSDATE - 1; -- 1 dia = 24 horas

BEGIN
    -- Buscar dados da propriedade
    SELECT pr.area_hectares, nd.nivel_numerico
    INTO v_area_hectares, v_nivel_degradacao
    FROM GS_WW_PROPRIEDADE_RURAL pr
    JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
    WHERE pr.id_propriedade = p_id_propriedade;
    
    -- Buscar dados dos sensores
    OPEN c_dados_propriedade;
    FETCH c_dados_propriedade INTO v_precipitacao_media, v_umidade_solo_media, v_count_leituras;
    CLOSE c_dados_propriedade;
    
    -- Se não há leituras suficientes, retorna risco indeterminado
    IF v_count_leituras = 0 OR v_precipitacao_media IS NULL THEN
        RETURN 'INDETERMINADO - Dados insuficientes';
    END IF;
    
    -- Cálculo do score de risco (0-100)
    -- Fatores: precipitação (40%), degradação do solo (30%), umidade (20%), área (10%)
    v_score_risco := 0;
    
    -- Fator precipitação (0-40 pontos)
    IF v_precipitacao_media > 50 THEN
        v_score_risco := v_score_risco + 40;
    ELSIF v_precipitacao_media > 25 THEN
        v_score_risco := v_score_risco + 25;
    ELSIF v_precipitacao_media > 10 THEN
        v_score_risco := v_score_risco + 15;
    ELSE
        v_score_risco := v_score_risco + 5;
    END IF;
    
    -- Fator degradação do solo (0-30 pontos) - mais degradado = maior risco
    v_score_risco := v_score_risco + (v_nivel_degradacao * 6);
    
    -- Fator umidade do solo (0-20 pontos) - solo saturado = maior risco
    IF v_umidade_solo_media > 80 THEN
        v_score_risco := v_score_risco + 20;
    ELSIF v_umidade_solo_media > 60 THEN
        v_score_risco := v_score_risco + 15;
    ELSIF v_umidade_solo_media > 40 THEN
        v_score_risco := v_score_risco + 10;
    ELSE
        v_score_risco := v_score_risco + 5;
    END IF;
    
    -- Fator área (0-10 pontos) - propriedades maiores têm mais capacidade de absorção
    IF v_area_hectares < 50 THEN
        v_score_risco := v_score_risco + 10;
    ELSIF v_area_hectares < 150 THEN
        v_score_risco := v_score_risco + 6;
    ELSE
        v_score_risco := v_score_risco + 3;
    END IF;
    
    -- Classificação do risco
    IF v_score_risco >= 80 THEN
        v_nivel_risco := 'CRÍTICO';
    ELSIF v_score_risco >= 60 THEN
        v_nivel_risco := 'ALTO';
    ELSIF v_score_risco >= 40 THEN
        v_nivel_risco := 'MÉDIO';
    ELSIF v_score_risco >= 20 THEN
        v_nivel_risco := 'BAIXO';
    ELSE
        v_nivel_risco := 'MÍNIMO';
    END IF;
    
    RETURN v_nivel_risco || ' (' || ROUND(v_score_risco, 1) || '%)';
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERRO - Propriedade não encontrada';
    WHEN OTHERS THEN
        RETURN 'ERRO - ' || SQLERRM;
END CALCULAR_RISCO_ALAGAMENTO;
/
