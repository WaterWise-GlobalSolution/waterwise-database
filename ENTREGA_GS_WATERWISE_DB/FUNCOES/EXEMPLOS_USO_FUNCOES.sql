-- ============================================================================
-- EXEMPLOS DE USO DAS FUNÇÕES
-- ============================================================================

-- Exemplo 1: Verificar risco de alagamento da propriedade 1

SELECT CALCULAR_RISCO_ALAGAMENTO(1) AS nivel_risco_alagamento FROM DUAL;


-- Exemplo 2: Verificar taxa de degradação do solo da propriedade 2

SELECT CALCULAR_TAXA_DEGRADACAO_SOLO(2) AS taxa_degradacao FROM DUAL;


-- Exemplo 3: Verificar capacidade de absorção da propriedade 3

SELECT CALCULAR_CAPACIDADE_ABSORCAO(3) AS capacidade_absorcao FROM DUAL;


-- Exemplo 4: Relatório completo de uma propriedade

SELECT 
    pr.nome_propriedade,
    prod.nome_completo AS produtor,
    CALCULAR_RISCO_ALAGAMENTO(pr.id_propriedade) AS risco_alagamento,
    CALCULAR_TAXA_DEGRADACAO_SOLO(pr.id_propriedade) AS degradacao_solo,
    CALCULAR_CAPACIDADE_ABSORCAO(pr.id_propriedade) AS capacidade_absorcao
FROM GS_WW_PROPRIEDADE_RURAL pr
JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
WHERE pr.id_propriedade = 1;


-- Exemplo 5: Dashboard de todas as propriedades

SELECT 
    pr.id_propriedade,
    pr.nome_propriedade,
    pr.area_hectares,
    CALCULAR_RISCO_ALAGAMENTO(pr.id_propriedade) AS risco,
    CALCULAR_TAXA_DEGRADACAO_SOLO(pr.id_propriedade) AS degradacao,
    CALCULAR_CAPACIDADE_ABSORCAO(pr.id_propriedade) AS absorcao
FROM GS_WW_PROPRIEDADE_RURAL pr
ORDER BY pr.id_propriedade;
