/*
Relatório Executivo - Propriedades em Risco por Região
JOINs: 6 tabelas | Agregações: 15+ métricas

Regional: Norte, Nordeste, Centro-Sul, Sul
Métricas: Score de risco, capacidade de absorção, degradação do solo
Uso: Planejamento estratégico e alocação de recursos

*/

SELECT 
    -- Classificação por região baseada em latitude
    CASE 
        WHEN pr.latitude > -10 THEN 'REGIÃO NORTE'
        WHEN pr.latitude > -20 THEN 'REGIÃO NORDESTE'
        WHEN pr.latitude > -30 THEN 'REGIÃO CENTRO-SUL'
        ELSE 'REGIÃO SUL'
    END AS regiao_geografica,
    
    -- Estatísticas gerais por região
    COUNT(DISTINCT pr.id_propriedade) AS total_propriedades,
    COUNT(DISTINCT prod.id_produtor) AS total_produtores,
    ROUND(SUM(pr.area_hectares), 1) AS area_total_hectares,
    ROUND(AVG(pr.area_hectares), 1) AS area_media_hectares,
    
    -- Análise de sensores por região
    COUNT(DISTINCT si.id_sensor) AS sensores_instalados,
    ROUND(COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade), 2) AS sensores_por_propriedade,
    
    -- Dados climáticos consolidados (últimas 24h)
    ROUND(AVG(ls.umidade_solo), 1) AS umidade_media_regiao,
    ROUND(MIN(ls.umidade_solo), 1) AS umidade_minima,
    ROUND(MAX(ls.umidade_solo), 1) AS umidade_maxima,
    ROUND(AVG(ls.temperatura_ar), 1) AS temperatura_media,
    ROUND(SUM(ls.precipitacao_mm), 1) AS precipitacao_total_24h,
    ROUND(MAX(ls.precipitacao_mm), 1) AS precipitacao_maxima_pontual,
    
    -- Análise de degradação do solo
    ROUND(AVG(nd.nivel_numerico), 2) AS nivel_degradacao_medio,
    COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) AS propriedades_solo_degradado,
    ROUND((COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 100.0) / COUNT(DISTINCT pr.id_propriedade), 1) AS percentual_solo_degradado,
    
    -- Análise de alertas (últimos 7 dias)
    COUNT(DISTINCT a.id_alerta) AS total_alertas_7d,
    COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) AS alertas_criticos_7d,
    
    -- Cálculo de risco consolidado por região
    ROUND(
        (AVG(ls.umidade_solo) * 0.4 + 
         AVG(nd.nivel_numerico) * 20 * 0.3 + 
         (SUM(ls.precipitacao_mm) / 10) * 0.3), 1
    ) AS score_risco_regional,
    
    -- Classificação final do risco
    CASE 
        WHEN (AVG(ls.umidade_solo) * 0.4 + AVG(nd.nivel_numerico) * 20 * 0.3 + (SUM(ls.precipitacao_mm) / 10) * 0.3) >= 80 THEN 'CRÍTICO'
        WHEN (AVG(ls.umidade_solo) * 0.4 + AVG(nd.nivel_numerico) * 20 * 0.3 + (SUM(ls.precipitacao_mm) / 10) * 0.3) >= 60 THEN 'ALTO'
        WHEN (AVG(ls.umidade_solo) * 0.4 + AVG(nd.nivel_numerico) * 20 * 0.3 + (SUM(ls.precipitacao_mm) / 10) * 0.3) >= 40 THEN 'MÉDIO'
        ELSE 'BAIXO'
    END AS classificacao_risco_regional,
    
    -- Capacidade de absorção estimada (litros)
    ROUND(
        SUM(
            CASE nd.nivel_numerico
                WHEN 1 THEN pr.area_hectares * 12000
                WHEN 2 THEN pr.area_hectares * 9500
                WHEN 3 THEN pr.area_hectares * 7000
                WHEN 4 THEN pr.area_hectares * 4500
                WHEN 5 THEN pr.area_hectares * 3000
                ELSE pr.area_hectares * 6000
            END
        ) / 1000000, 1
    ) AS capacidade_absorcao_milhoes_litros

FROM GS_WW_PROPRIEDADE_RURAL pr
JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor 
    AND ls.timestamp_leitura >= SYSDATE - 1 -- Últimas 24 horas
LEFT JOIN GS_WW_ALERTA a ON prod.id_produtor = a.id_produtor 
    AND a.timestamp_alerta >= SYSDATE - 7 -- Últimos 7 dias
LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade

GROUP BY 
    CASE 
        WHEN pr.latitude > -10 THEN 'REGIÃO NORTE'
        WHEN pr.latitude > -20 THEN 'REGIÃO NORDESTE'
        WHEN pr.latitude > -30 THEN 'REGIÃO CENTRO-SUL'
        ELSE 'REGIÃO SUL'
    END

ORDER BY score_risco_regional DESC, total_propriedades DESC;