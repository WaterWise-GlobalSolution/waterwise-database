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
    -- CORREÇÃO AQUI: Adicionado NULLIF para o divisor
    ROUND((COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 100.0) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0), 1) AS percent_solo_bom,

    -- Score de Eficiência (exemplo de cálculo)
    -- Base: 100 pontos
    -- +10 pontos por propriedade com solo bom (Nível 1 ou 2)
    -- +20 pontos se mais de 5 leituras/sensor/mês
    -- +15 pontos se mais de 2 sensores/propriedade
    -- -15 pontos por alerta crítico nos últimos 90 dias
    -- -2 pontos por alerta geral nos últimos 90 dias
    -- -10 pontos por propriedade com solo degradado (Nível 4 ou 5)
    (
        100 +
        (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) +
        (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
        -- CORREÇÃO AQUI: Adicionado NULLIF para o divisor
        (CASE WHEN COUNT(DISTINCT pr.id_propriedade) > 0 AND COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) * 7.5) END) -
        (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
        (COUNT(a.id_alerta) * 2) -
        (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)
    ) AS score_eficiencia,

    -- Classificação Final
    CASE
        WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) +
              (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
              -- CORREÇÃO AQUI: Adicionado NULLIF para o divisor
              (CASE WHEN COUNT(DISTINCT pr.id_propriedade) > 0 AND COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) * 7.5) END) -
              (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
              (COUNT(a.id_alerta) * 2) -
              (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 120 THEN 'PRODUTOR EXEMPLAR'
        WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) +
              (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
              -- CORREÇÃO AQUI: Adicionado NULLIF para o divisor
              (CASE WHEN COUNT(DISTINCT pr.id_propriedade) > 0 AND COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) * 7.5) END) -
              (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
              (COUNT(a.id_alerta) * 2) -
              (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 80 THEN 'PRODUTOR EFICIENTE'
        WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) +
              (CASE WHEN COUNT(ls.id_leitura) / 30.0 >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / 30.0 * 4) END) +
              -- CORREÇÃO AQUI: Adicionado NULLIF para o divisor
              (CASE WHEN COUNT(DISTINCT pr.id_propriedade) > 0 AND COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / NULLIF(COUNT(DISTINCT pr.id_propriedade), 0) * 7.5) END) -
              (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) -
              (COUNT(a.id_alerta) * 2) -
              (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 40 THEN 'PRODUTOR REGULAR'
        ELSE 'PRODUTOR NECESSITA MELHORIA'
    END AS classificacao_final

FROM GS_WW_PRODUTOR_RURAL prod
LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON prod.id_produtor = pr.id_produtor
LEFT JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor AND ls.timestamp_leitura >= SYSDATE - 90
LEFT JOIN GS_WW_ALERTA a ON a.id_produtor = prod.id_produtor AND a.timestamp_alerta >= SYSDATE - 90
LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
GROUP BY
    prod.id_produtor,
    prod.nome_completo,
    prod.email
ORDER BY score_eficiencia DESC;