-- ============================================================================
-- FUNÇÃO CORRIGIDA: CALCULAR CAPACIDADE DE ABSORÇÃO
-- ============================================================================
CREATE OR REPLACE FUNCTION CALCULAR_CAPACIDADE_ABSORCAO(
    p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
) RETURN VARCHAR2
IS
    v_area_hectares         NUMBER(10,2);
    v_nivel_degradacao      NUMBER(1);
    v_umidade_atual         NUMBER(5,2);
    v_precipitacao_recente  NUMBER(8,2);
    v_capacidade_base       NUMBER(10,2);
    v_capacidade_atual      NUMBER(10,2);
    v_reducao_percentual    NUMBER(5,2);
    v_status_absorcao      VARCHAR2(100);
    v_count_sensores       NUMBER;
    
    -- Cursor para dados recentes (últimas 6 horas) - CORRIGIDO
    CURSOR c_dados_recentes IS
        SELECT 
            AVG(ls.umidade_solo) as umidade_atual,
            SUM(ls.precipitacao_mm) as precipitacao_6h,
            COUNT(DISTINCT si.id_sensor) as num_sensores
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        WHERE si.id_propriedade = p_id_propriedade
        AND ls.timestamp_leitura >= SYSDATE - 0.25; -- 0.25 dias = 6 horas

BEGIN
    -- Buscar dados da propriedade
    SELECT pr.area_hectares, nd.nivel_numerico
    INTO v_area_hectares, v_nivel_degradacao
    FROM GS_WW_PROPRIEDADE_RURAL pr
    JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
    WHERE pr.id_propriedade = p_id_propriedade;
    
    -- Buscar dados dos sensores
    OPEN c_dados_recentes;
    FETCH c_dados_recentes INTO v_umidade_atual, v_precipitacao_recente, v_count_sensores;
    CLOSE c_dados_recentes;
    
    -- Verificar se há sensores funcionando
    IF v_count_sensores = 0 OR v_umidade_atual IS NULL THEN
        RETURN 'SEM DADOS - Sensores não detectados';
    END IF;
    
    -- Cálculo da capacidade base de absorção (litros por hectare)
    -- Solo excelente: 12000 L/ha, Solo crítico: 3000 L/ha
    CASE v_nivel_degradacao
        WHEN 1 THEN v_capacidade_base := 12000; -- Excelente
        WHEN 2 THEN v_capacidade_base := 9500;  -- Bom
        WHEN 3 THEN v_capacidade_base := 7000;  -- Moderado
        WHEN 4 THEN v_capacidade_base := 4500;  -- Ruim
        WHEN 5 THEN v_capacidade_base := 3000;  -- Crítico
        ELSE v_capacidade_base := 6000;         -- Default
    END CASE;
    
    -- Ajustar capacidade baseada na umidade atual do solo
    -- Solo saturado (>90%) = capacidade quase zero
    -- Solo seco (<30%) = capacidade máxima
    IF v_umidade_atual >= 90 THEN
        v_reducao_percentual := 95; -- Reduz 95%
    ELSIF v_umidade_atual >= 80 THEN
        v_reducao_percentual := 75; -- Reduz 75%
    ELSIF v_umidade_atual >= 70 THEN
        v_reducao_percentual := 50; -- Reduz 50%
    ELSIF v_umidade_atual >= 60 THEN
        v_reducao_percentual := 30; -- Reduz 30%
    ELSIF v_umidade_atual >= 50 THEN
        v_reducao_percentual := 15; -- Reduz 15%
    ELSIF v_umidade_atual >= 40 THEN
        v_reducao_percentual := 5;  -- Reduz 5%
    ELSE
        v_reducao_percentual := 0;  -- Capacidade máxima
    END IF;
    
    -- Calcular capacidade atual
    v_capacidade_atual := v_capacidade_base * (100 - v_reducao_percentual) / 100;
    
    -- Capacidade total da propriedade
    v_capacidade_atual := v_capacidade_atual * v_area_hectares;
    
    -- Determinar status baseado na capacidade disponível
    IF v_reducao_percentual >= 90 THEN
        v_status_absorcao := 'SATURADO - Risco Alto de Alagamento';
    ELSIF v_reducao_percentual >= 70 THEN
        v_status_absorcao := 'CAPACIDADE CRÍTICA - Monitoramento Urgente';
    ELSIF v_reducao_percentual >= 50 THEN
        v_status_absorcao := 'CAPACIDADE REDUZIDA - Atenção Necessária';
    ELSIF v_reducao_percentual >= 25 THEN
        v_status_absorcao := 'CAPACIDADE BOA - Funcionamento Normal';
    ELSE
        v_status_absorcao := 'CAPACIDADE EXCELENTE - Esponja Natural Ativa';
    END IF;
    
    -- Retornar resultado formatado
    RETURN v_status_absorcao || ' - ' || 
           ROUND(v_capacidade_atual/1000, 1) || 'k litros disponíveis (' ||
           (100 - v_reducao_percentual) || '% da capacidade)';
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERRO - Propriedade não encontrada';
    WHEN OTHERS THEN
        RETURN 'ERRO - ' || SQLERRM;
END CALCULAR_CAPACIDADE_ABSORCAO;
/