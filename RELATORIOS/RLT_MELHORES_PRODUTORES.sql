/*
Relatório de Eficiência - Produtores Exemplares
JOINs: 7 tabelas | Agregações: Score de eficiência 0-150

Ranking: Melhores produtores por práticas sustentáveis
Score: Baseado em solo, sensores, alertas
Uso: Reconhecimento e benchmark de melhores práticas
*/

SELECT 
    prod.nome_completo AS produtor,
    prod.email,
    COUNT(DISTINCT pr.id_propriedade) AS total_propriedades,
    ROUND(SUM(pr.area_hectares), 1) AS area_total_hectares,
    COUNT(DISTINCT si.id_sensor) AS sensores_instalados,
    
    -- Análise de alertas (últimos 90 dias)
    COUNT(a.id_alerta) AS total_alertas_90d,
    COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) AS alertas_criticos_90d,
    ROUND(COUNT(a.id_alerta) / 90.0, 2) AS media_alertas_por_dia,
    
    -- Qualidade do solo
    ROUND(AVG(nd.nivel_numerico), 2) AS nivel_medio_degradacao,
    COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) AS propriedades_solo_bom,
    ROUND((COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 100.0) / COUNT(DISTINCT pr.id_propriedade), 1) AS percentual_solo_bom,
    
    -- Performance dos sensores
    COUNT(ls.id_leitura) AS total_leituras_30d,
    ROUND(COUNT(ls.id_leitura) / GREATEST(COUNT(DISTINCT si.id_sensor), 1), 1) AS leituras_por_sensor,
    ROUND(COUNT(ls.id_leitura) / 30.0, 1) AS leituras_por_dia,
    
    -- Condições ambientais médias
    ROUND(AVG(ls.umidade_solo), 1) AS umidade_media_propriedades,
    ROUND(AVG(ls.temperatura_ar), 1) AS temperatura_media_propriedades,
    ROUND(SUM(ls.precipitacao_mm), 1) AS precipitacao_total_30d,
    
    -- Cálculo de score de eficiência (0-100)
    ROUND(
        -- Pontos positivos
        100 +
        (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + -- Solo bom
        (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) + -- Atividade sensores
        (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -- Cobertura sensores
        
        -- Pontos negativos
        - (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -- Alertas críticos
        - (COUNT(a.id_alerta) * 2) -- Total alertas
        - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10) -- Solo degradado
    , 1) AS score_eficiencia,
    
    -- Capacidade de absorção total do produtor
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
        ) / 1000000, 2
    ) AS capacidade_absorcao_milhoes_litros,
    
    -- Tempo médio de instalação dos sensores
    ROUND(AVG(SYSDATE - si.data_instalacao), 0) AS dias_medio_monitoramento,
    
    -- Classificação final do produtor
    CASE 
        WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + 
              (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
              (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
              (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
              (COUNT(a.id_alerta) * 2) -
              (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 120 THEN 'PRODUTOR EXEMPLAR'
        WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + 
              (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
              (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
              (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
              (COUNT(a.id_alerta) * 2) -
              (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 100 THEN 'PRODUTOR EFICIENTE'
        WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + 
              (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
              (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
              (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
              (COUNT(a.id_alerta) * 2) -
              (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 80 THEN 'PRODUTOR REGULAR'
        ELSE 'PRODUTOR NECESSITA MELHORIA'
    END AS classificacao_final

FROM GS_WW_PRODUTOR_RURAL prod
LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON prod.id_produtor = pr.id_produtor
LEFT JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
    AND ls.timestamp_leitura >= SYSDATE - 30 -- Últimos 30 dias
LEFT JOIN GS_WW_ALERTA a ON prod.id_produtor = a.id_produtor 
    AND a.timestamp_alerta >= SYSDATE - 90 -- Últimos 90 dias
LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade

GROUP BY 
    prod.id_produtor, prod.nome_completo, prod.email

ORDER BY 
    score_eficiencia DESC,
    alertas_criticos_90d ASC,
    area_total_hectares DESC;