-- Verificar estrutura das tabelas com prefixo GS_WW_
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    NULLABLE,
    COLUMN_ID
FROM USER_TAB_COLUMNS 
WHERE TABLE_NAME LIKE 'GS_WW_%'
ORDER BY TABLE_NAME, COLUMN_ID;

-- Verificar constraints com prefixo GS_WW_
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    SEARCH_CONDITION,
    R_CONSTRAINT_NAME,
    STATUS
FROM USER_CONSTRAINTS 
WHERE TABLE_NAME LIKE 'GS_WW_%'
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;

-- Verificar dados inseridos (contagem por tabela)
SELECT 'GS_WW_TIPO_SENSOR' as TABELA, COUNT(*) as REGISTROS FROM GS_WW_TIPO_SENSOR
UNION ALL
SELECT 'GS_WW_NIVEL_SEVERIDADE', COUNT(*) FROM GS_WW_NIVEL_SEVERIDADE
UNION ALL
SELECT 'GS_WW_NIVEL_DEGRADACAO_SOLO', COUNT(*) FROM GS_WW_NIVEL_DEGRADACAO_SOLO
UNION ALL
SELECT 'GS_WW_PRODUTOR_RURAL', COUNT(*) FROM GS_WW_PRODUTOR_RURAL
UNION ALL
SELECT 'GS_WW_PROPRIEDADE_RURAL', COUNT(*) FROM GS_WW_PROPRIEDADE_RURAL
UNION ALL
SELECT 'GS_WW_SENSOR_IOT', COUNT(*) FROM GS_WW_SENSOR_IOT
UNION ALL
SELECT 'GS_WW_LEITURA_SENSOR', COUNT(*) FROM GS_WW_LEITURA_SENSOR
UNION ALL
SELECT 'GS_WW_AREA_RISCO_URBANA', COUNT(*) FROM GS_WW_AREA_RISCO_URBANA
UNION ALL
SELECT 'GS_WW_ALERTA', COUNT(*) FROM GS_WW_ALERTA
UNION ALL
SELECT 'GS_WW_CAMPANHA_CONSCIENTIZACAO', COUNT(*) FROM GS_WW_CAMPANHA_CONSCIENTIZACAO
ORDER BY TABELA;

-- Query de teste de relacionamentos completos
SELECT 
    p.NOME_COMPLETO as PRODUTOR,
    pr.NOME_PROPRIEDADE,
    pr.AREA_HECTARES,
    nds.CODIGO_DEGRADACAO as NIVEL_SOLO,
    nds.CAPACIDADE_ABSORCAO_PERCENTUAL as ABSORCAO_PERCENTUAL,
    nds.COR_INDICADORA,
    COUNT(DISTINCT s.ID_SENSOR) as QTD_SENSORES,
    COUNT(DISTINCT ls.ID_LEITURA) as QTD_LEITURAS,
    ROUND(AVG(ls.UMIDADE_SOLO), 2) as UMIDADE_MEDIA,
    ROUND(AVG(ls.TEMPERATURA_AR), 2) as TEMPERATURA_MEDIA
FROM GS_WW_PRODUTOR_RURAL p
JOIN GS_WW_PROPRIEDADE_RURAL pr ON p.ID_PRODUTOR = pr.ID_PRODUTOR
JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nds ON pr.ID_NIVEL_DEGRADACAO = nds.ID_NIVEL_DEGRADACAO
LEFT JOIN GS_WW_SENSOR_IOT s ON pr.ID_PROPRIEDADE = s.ID_PROPRIEDADE
LEFT JOIN GS_WW_LEITURA_SENSOR ls ON s.ID_SENSOR = ls.ID_SENSOR
GROUP BY p.NOME_COMPLETO, pr.NOME_PROPRIEDADE, pr.AREA_HECTARES, 
         nds.CODIGO_DEGRADACAO, nds.CAPACIDADE_ABSORCAO_PERCENTUAL, nds.COR_INDICADORA
ORDER BY nds.NIVEL_NUMERICO, pr.AREA_HECTARES DESC;

-- Relat�rio de Alertas com Severidade
SELECT 
    a.ID_ALERTA,
    aru.NOME_AREA || ', ' || aru.CIDADE as LOCAL,
    ns.CODIGO_SEVERIDADE,
    ns.DESCRICAO_SEVERIDADE,
    ns.COR_REPRESENTACAO,
    ns.PRIORIDADE_NUMERICA,
    a.DESCRICAO_ALERTA,
    a.STATUS_ALERTA,
    TO_CHAR(a.TIMESTAMP_ALERTA, 'DD/MM/YYYY HH24:MI') as DATA_ALERTA,
    aru.POPULACAO_AFETADA,
    a.USUARIO_CRIACAO
FROM GS_WW_ALERTA a
JOIN GS_WW_AREA_RISCO_URBANA aru ON a.ID_AREA_RISCO = aru.ID_AREA_RISCO
JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.ID_NIVEL_SEVERIDADE = ns.ID_NIVEL_SEVERIDADE
ORDER BY ns.PRIORIDADE_NUMERICA DESC, a.TIMESTAMP_ALERTA DESC;

-- Relat�rio de Sensores por Tipo
SELECT 
    ts.NOME_TIPO,
    ts.UNIDADE_MEDIDA,
    ts.VALOR_MIN,
    ts.VALOR_MAX,
    COUNT(DISTINCT s.ID_SENSOR) as QTD_SENSORES,
    COUNT(DISTINCT CASE WHEN s.STATUS_OPERACIONAL = 'A' THEN s.ID_SENSOR END) as SENSORES_ATIVOS,
    ROUND(AVG(s.BATERIA_NIVEL), 2) as BATERIA_MEDIA,
    COUNT(DISTINCT ls.ID_LEITURA) as TOTAL_LEITURAS
FROM GS_WW_TIPO_SENSOR ts
LEFT JOIN GS_WW_SENSOR_IOT s ON ts.ID_TIPO_SENSOR = s.ID_TIPO_SENSOR
LEFT JOIN GS_WW_LEITURA_SENSOR ls ON s.ID_SENSOR = ls.ID_SENSOR
GROUP BY ts.NOME_TIPO, ts.UNIDADE_MEDIDA, ts.VALOR_MIN, ts.VALOR_MAX
ORDER BY QTD_SENSORES DESC;

-- Dashboard Executivo WaterWise
SELECT 
    'TOTAL_PRODUTORES' as METRICA,
    COUNT(*) as VALOR,
    'produtores cadastrados' as DESCRICAO
FROM GS_WW_PRODUTOR_RURAL WHERE STATUS_ATIVO = 'S'
UNION ALL
SELECT 
    'TOTAL_PROPRIEDADES',
    COUNT(*),
    'propriedades monitoradas'
FROM GS_WW_PROPRIEDADE_RURAL
UNION ALL
SELECT 
    'TOTAL_HECTARES',
    ROUND(SUM(AREA_HECTARES), 0),
    'hectares sob monitoramento'
FROM GS_WW_PROPRIEDADE_RURAL
UNION ALL
SELECT 
    'SENSORES_ATIVOS',
    COUNT(*),
    'sensores IoT operacionais'
FROM GS_WW_SENSOR_IOT WHERE STATUS_OPERACIONAL = 'A'
UNION ALL
SELECT 
    'ALERTAS_ATIVOS',
    COUNT(*),
    'alertas de enchente ativos'
FROM GS_WW_ALERTA WHERE STATUS_ALERTA = 'ATIVO'
UNION ALL
SELECT 
    'LEITURAS_HOJE',
    COUNT(*),
    'leituras nas �ltimas 24h'
FROM GS_WW_LEITURA_SENSOR 
WHERE TIMESTAMP_LEITURA >= CURRENT_TIMESTAMP - INTERVAL '1' DAY
UNION ALL
SELECT 
    'AREAS_RISCO',
    COUNT(*),
    '�reas urbanas monitoradas'
FROM GS_WW_AREA_RISCO_URBANA WHERE STATUS_ATIVO = 'S'
UNION ALL
SELECT 
    'CAMPANHAS_ATIVAS',
    COUNT(*),
    'campanhas de conscientiza��o ativas'
FROM GS_WW_CAMPANHA_CONSCIENTIZACAO WHERE STATUS_CAMPANHA = 'ATIVA';

-- An�lise de Risco por Regi�o
SELECT 
    aru.CIDADE,
    COUNT(DISTINCT aru.ID_AREA_RISCO) as AREAS_MONITORADAS,
    SUM(aru.POPULACAO_AFETADA) as POPULACAO_TOTAL_RISCO,
    ROUND(AVG(aru.NIVEL_RISCO), 2) as RISCO_MEDIO,
    COUNT(DISTINCT a.ID_ALERTA) as TOTAL_ALERTAS,
    COUNT(DISTINCT CASE WHEN a.STATUS_ALERTA = 'ATIVO' THEN a.ID_ALERTA END) as ALERTAS_ATIVOS,
    COUNT(DISTINCT pr.ID_PROPRIEDADE) as PROPRIEDADES_PROXIMAS
FROM GS_WW_AREA_RISCO_URBANA aru
LEFT JOIN GS_WW_ALERTA a ON aru.ID_AREA_RISCO = a.ID_AREA_RISCO
LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON 
    SQRT(POWER((pr.LATITUDE - aru.LATITUDE_CENTRO) * 111.32, 2) + 
         POWER((pr.LONGITUDE - aru.LONGITUDE_CENTRO) * 111.32, 2)) <= 10
WHERE aru.STATUS_ATIVO = 'S'
GROUP BY aru.CIDADE
ORDER BY RISCO_MEDIO DESC, POPULACAO_TOTAL_RISCO DESC;

COMMIT;