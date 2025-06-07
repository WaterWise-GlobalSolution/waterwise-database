-- ============================================================================
-- FUNÇÃO CORRIGIDA: CALCULAR TAXA DE DEGRADAÇÃO DO SOLO
-- ============================================================================
CREATE OR REPLACE FUNCTION CALCULAR_TAXA_DEGRADACAO_SOLO(
    p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
) RETURN VARCHAR2
IS
    v_nivel_atual           NUMBER(1);
    v_umidade_media         NUMBER(5,2);
    v_temperatura_media     NUMBER(4,1);
    v_precipitacao_total    NUMBER(8,2);
    v_dias_monitoramento    NUMBER;
    v_taxa_degradacao       NUMBER(8,4);
    v_tendencia            VARCHAR2(50);
    v_classificacao        VARCHAR2(100);
    
    -- Cursor para dados dos últimos 30 dias (CORRIGIDO)
    CURSOR c_dados_solo IS
        SELECT 
            AVG(ls.umidade_solo) as umidade_avg,
            AVG(ls.temperatura_ar) as temperatura_avg,
            SUM(ls.precipitacao_mm) as precipitacao_total,
            ROUND(SYSDATE - MIN(CAST(ls.timestamp_leitura AS DATE))) as dias_monitoramento
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        WHERE si.id_propriedade = p_id_propriedade
        AND ls.timestamp_leitura >= SYSDATE - 30;

BEGIN
    -- Buscar nível atual de degradação
    SELECT nd.nivel_numerico
    INTO v_nivel_atual
    FROM GS_WW_PROPRIEDADE_RURAL pr
    JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
    WHERE pr.id_propriedade = p_id_propriedade;
    
    -- Buscar dados climáticos
    OPEN c_dados_solo;
    FETCH c_dados_solo INTO v_umidade_media, v_temperatura_media, v_precipitacao_total, v_dias_monitoramento;
    CLOSE c_dados_solo;
    
    -- Verificar se há dados suficientes
    IF v_dias_monitoramento < 7 OR v_umidade_media IS NULL THEN
        RETURN 'Dados insuficientes - Mínimo 7 dias de monitoramento';
    END IF;
    
    -- Cálculo da taxa de degradação (baseado em fatores de risco)
    -- Taxa base pelo nível atual (1=0.1%, 2=0.3%, 3=0.6%, 4=1.2%, 5=2.5% ao mês)
    CASE v_nivel_atual
        WHEN 1 THEN v_taxa_degradacao := 0.1;
        WHEN 2 THEN v_taxa_degradacao := 0.3;
        WHEN 3 THEN v_taxa_degradacao := 0.6;
        WHEN 4 THEN v_taxa_degradacao := 1.2;
        WHEN 5 THEN v_taxa_degradacao := 2.5;
        ELSE v_taxa_degradacao := 0.5;
    END CASE;
    
    -- Ajustes pela umidade (solo muito seco ou muito úmido acelera degradação)
    IF v_umidade_media < 20 OR v_umidade_media > 85 THEN
        v_taxa_degradacao := v_taxa_degradacao * 1.5; -- Aumenta 50%
    ELSIF v_umidade_media < 30 OR v_umidade_media > 75 THEN
        v_taxa_degradacao := v_taxa_degradacao * 1.2; -- Aumenta 20%
    ELSIF v_umidade_media BETWEEN 40 AND 60 THEN
        v_taxa_degradacao := v_taxa_degradacao * 0.8; -- Reduz 20% (condição ideal)
    END IF;
    
    -- Ajustes pela temperatura (temperaturas extremas aceleram degradação)
    IF v_temperatura_media > 35 OR v_temperatura_media < 5 THEN
        v_taxa_degradacao := v_taxa_degradacao * 1.4; -- Aumenta 40%
    ELSIF v_temperatura_media > 30 OR v_temperatura_media < 10 THEN
        v_taxa_degradacao := v_taxa_degradacao * 1.1; -- Aumenta 10%
    END IF;
    
    -- Ajustes pela precipitação (chuva excessiva ou falta acelera degradação)
    IF v_precipitacao_total > 200 THEN
        v_taxa_degradacao := v_taxa_degradacao * 1.3; -- Erosão por excesso
    ELSIF v_precipitacao_total < 30 THEN
        v_taxa_degradacao := v_taxa_degradacao * 1.4; -- Ressecamento
    ELSIF v_precipitacao_total BETWEEN 60 AND 120 THEN
        v_taxa_degradacao := v_taxa_degradacao * 0.9; -- Condição ideal
    END IF;
    
    -- Determinar tendência
    IF v_taxa_degradacao <= 0.2 THEN
        v_tendencia := 'ESTÁVEL/MELHORIA';
    ELSIF v_taxa_degradacao <= 0.5 THEN
        v_tendencia := 'DEGRADAÇÃO LENTA';
    ELSIF v_taxa_degradacao <= 1.0 THEN
        v_tendencia := 'DEGRADAÇÃO MODERADA';
    ELSIF v_taxa_degradacao <= 2.0 THEN
        v_tendencia := 'DEGRADAÇÃO ACELERADA';
    ELSE
        v_tendencia := 'DEGRADAÇÃO CRÍTICA';
    END IF;
    
    v_classificacao := v_tendencia || ' - ' || ROUND(v_taxa_degradacao, 2) || '%/mês';
    
    RETURN v_classificacao;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERRO - Propriedade não encontrada';
    WHEN OTHERS THEN
        RETURN 'ERRO - ' || SQLERRM;
END CALCULAR_TAXA_DEGRADACAO_SOLO;
/