/*
Níveis de Severidade COM e SEM Alertas (RIGHT JOIN)
Objetivo: Verificar uso dos níveis de alerta
sql-- Exemplo de resultado:
CRÍTICO | Alertas: 45 | Uso: FREQUENTE | Status: PREOCUPANTE
BAIXO | Alertas: 0 | Uso: NUNCA USADO | Status: NÃO UTILIZADO
*/

SELECT 
    ns.id_nivel_severidade,
    ns.codigo_severidade,
    ns.descricao_severidade,
    ns.acoes_recomendadas,
    
    -- Agregações dos alertas (pode ser 0 se nunca foi usado)
    COUNT(a.id_alerta) AS total_alertas_historico,
    COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 30 THEN 1 END) AS alertas_30_dias,
    COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 7 THEN 1 END) AS alertas_7_dias,
    COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 1 THEN 1 END) AS alertas_24_horas,
    
    -- Produtores únicos que receberam este tipo de alerta
    COUNT(DISTINCT a.id_produtor) AS produtores_alertados,
    
    -- Período dos alertas
    MIN(a.timestamp_alerta) AS primeiro_alerta_tipo,
    MAX(a.timestamp_alerta) AS ultimo_alerta_tipo,
    
    -- Percentual de uso deste nível
    ROUND(
        (COUNT(a.id_alerta) * 100.0) / 
        NULLIF((SELECT COUNT(*) FROM GS_WW_ALERTA), 0), 2
    ) AS percentual_uso,
    
    -- Frequência de uso
    CASE 
        WHEN COUNT(a.id_alerta) = 0 THEN 'NUNCA USADO'
        WHEN COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 7 THEN 1 END) >= 5 THEN 'USO FREQUENTE'
        WHEN COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 30 THEN 1 END) >= 5 THEN 'USO REGULAR'
        WHEN COUNT(a.id_alerta) >= 10 THEN 'USO OCASIONAL'
        ELSE 'USO RARO'
    END AS frequencia_uso,
    
    -- Status da severidade no sistema
    CASE 
        WHEN ns.codigo_severidade = 'CRITICO' AND COUNT(a.id_alerta) = 0 THEN 'BOM - SEM EMERGÊNCIAS'
        WHEN ns.codigo_severidade = 'CRITICO' AND COUNT(a.id_alerta) > 10 THEN 'PREOCUPANTE - MUITAS EMERGÊNCIAS'
        WHEN COUNT(a.id_alerta) = 0 THEN 'NÃO UTILIZADO'
        ELSE 'EM USO NORMAL'
    END AS status_severidade

FROM GS_WW_ALERTA a
RIGHT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade

GROUP BY 
    ns.id_nivel_severidade, ns.codigo_severidade, 
    ns.descricao_severidade, ns.acoes_recomendadas

ORDER BY 
    CASE ns.codigo_severidade
        WHEN 'CRITICO' THEN 1
        WHEN 'ALTO' THEN 2
        WHEN 'MEDIO' THEN 3
        WHEN 'BAIXO' THEN 4
        ELSE 5
    END,
    total_alertas_historico DESC;