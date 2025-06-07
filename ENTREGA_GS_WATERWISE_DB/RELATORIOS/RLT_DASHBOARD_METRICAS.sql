/*
Dashboard Consolidado - Métricas Estratégicas
JOINs: UNION ALL | Agregações: KPIs principais

Métricas: Propriedades, sensores, alertas, capacidade
Status: Excelente/Bom/Regular/Crítico para cada KPI
Uso: Reuniões executivas e tomada de decisão

*/

SELECT
    'MÉTRICAS GERAIS' AS categoria,
    'Total de Propriedades Monitoradas' AS metrica,
    COUNT(DISTINCT pr.id_propriedade) AS valor_numerico,
    'propriedades' AS unidade,
    CASE
        WHEN COUNT(DISTINCT pr.id_propriedade) >= 50 THEN 'EXCELENTE'
        WHEN COUNT(DISTINCT pr.id_propriedade) >= 20 THEN 'BOM'
        WHEN COUNT(DISTINCT pr.id_propriedade) >= 10 THEN 'REGULAR'
        ELSE 'INSUFICIENTE'
    END AS status_metrica
FROM GS_WW_PROPRIEDADE_RURAL pr

UNION ALL

SELECT
    'MÉTRICAS GERAIS',
    'Área Total Monitorada',
    ROUND(SUM(pr.area_hectares), 0),
    'hectares',
    CASE
        WHEN SUM(pr.area_hectares) >= 10000 THEN 'EXCELENTE'
        WHEN SUM(pr.area_hectares) >= 5000 THEN 'BOM'
        WHEN SUM(pr.area_hectares) >= 1000 THEN 'REGULAR'
        ELSE 'INSUFICIENTE'
    END
FROM GS_WW_PROPRIEDADE_RURAL pr

UNION ALL

SELECT
    'MÉTRICAS DE MONIT.',
    'Total de Sensores Instalados',
    COUNT(DISTINCT si.id_sensor),
    'sensores',
    CASE
        WHEN COUNT(DISTINCT si.id_sensor) >= 100 THEN 'EXCELENTE'
        WHEN COUNT(DISTINCT si.id_sensor) >= 50 THEN 'BOM'
        WHEN COUNT(DISTINCT si.id_sensor) >= 20 THEN 'REGULAR'
        ELSE 'INSUFICIENTE'
    END
FROM GS_WW_SENSOR_IOT si

UNION ALL

SELECT
    'MÉTRICAS DE MONIT.',
    'Total de Leituras Últimos 30 Dias',
    COUNT(ls.id_leitura),
    'leituras',
    CASE
        WHEN COUNT(ls.id_leitura) >= 10000 THEN 'EXCELENTE'
        WHEN COUNT(ls.id_leitura) >= 5000 THEN 'BOM'
        WHEN COUNT(ls.id_leitura) >= 1000 THEN 'REGULAR'
        ELSE 'INSUFICIENTE'
    END
FROM GS_WW_LEITURA_SENSOR ls
WHERE ls.timestamp_leitura >= SYSDATE - 30

UNION ALL

SELECT
    'MÉTRICAS DE ALERTAS',
    'Alertas Críticos Últimos 7 Dias',
    COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END),
    'alertas',
    CASE
        WHEN COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) = 0 THEN 'EXCELENTE'
        WHEN COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) <= 3 THEN 'BOM'
        WHEN COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) <= 10 THEN 'REGULAR'
        ELSE 'CRÍTICO'
    END
FROM GS_WW_ALERTA a
JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
WHERE a.timestamp_alerta >= SYSDATE - 7

UNION ALL

SELECT
    'MÉTRICAS DE QUALIDADE',
    'Capacidade de Absorção Estimada',
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
        ) / 1000000000, 2),
    'bilhões de litros',
    CASE
        WHEN SUM(CASE nd.nivel_numerico WHEN 1 THEN pr.area_hectares * 12000 ELSE pr.area_hectares * 6000 END) >= 1000000000 THEN 'EXCELENTE'
        WHEN SUM(CASE nd.nivel_numerico WHEN 1 THEN pr.area_hectares * 12000 ELSE pr.area_hectares * 6000 END) >= 500000000 THEN 'BOM'
        ELSE 'REGULAR'
    END
FROM GS_WW_PROPRIEDADE_RURAL pr
JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao

UNION ALL

SELECT
    'QUALIDADE SOLO',
    'Propriedades com Solo Degradado',
    COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END),
    'propriedades',
    CASE
        WHEN (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 100.0 / COUNT(*)) <= 10 THEN 'EXCELENTE'
        WHEN (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 100.0 / COUNT(*)) <= 25 THEN 'BOM'
        WHEN (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 100.0 / COUNT(*)) <= 50 THEN 'REGULAR'
        ELSE 'CRÍTICO'
    END
FROM GS_WW_PROPRIEDADE_RURAL pr
JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao;