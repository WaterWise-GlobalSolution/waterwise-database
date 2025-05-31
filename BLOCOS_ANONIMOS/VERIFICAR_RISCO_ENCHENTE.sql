/*
Verificar Risco de Enchente por Propriedade
Controle de Fluxo: IF/ELSIF/ELSE para classificar risco

Exemplo de saída:
=== VERIFICAÇÃO DE RISCO DE ENCHENTE ===
Propriedade: Fazenda São João
Produtor: João Silva

Umidade Média: 87.3%
Precipitação Máxima: 45.2mm

NÍVEL DE RISCO: CRÍTICO
Contato: (11)99876-5432
Ação Recomendada: Preparar evacuação e drenar área

*/

DECLARE
    v_id_propriedade    NUMBER := 1; -- Altere para testar outras propriedades
    v_umidade_media     NUMBER;
    v_precipitacao_max  NUMBER;
    v_nome_propriedade  VARCHAR2(100);
    v_nome_produtor     VARCHAR2(100);
    v_telefone         VARCHAR2(15);
    v_nivel_risco      VARCHAR2(20);
    v_acao_recomendada VARCHAR2(200);
BEGIN
    -- Buscar dados da propriedade
    SELECT 
        pr.nome_propriedade,
        prod.nome_completo,
        prod.telefone
    INTO 
        v_nome_propriedade,
        v_nome_produtor,
        v_telefone
    FROM GS_WW_PROPRIEDADE_RURAL pr
    JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
    WHERE pr.id_propriedade = v_id_propriedade;
    
    SELECT 
        AVG(ls.umidade_solo),
        MAX(ls.precipitacao_mm)
    INTO 
        v_umidade_media,
        v_precipitacao_max
    FROM GS_WW_LEITURA_SENSOR ls
    JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
    WHERE si.id_propriedade = v_id_propriedade
    AND ls.timestamp_leitura >= SYSDATE - 0.25; -- 6 horas
    
    DBMS_OUTPUT.PUT_LINE('=== VERIFICAÇÃO DE RISCO DE ENCHENTE ===');
    DBMS_OUTPUT.PUT_LINE('Propriedade: ' || v_nome_propriedade);
    DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_nome_produtor);
    DBMS_OUTPUT.PUT_LINE(' ');
    

    IF v_umidade_media IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERRO: Sem dados dos sensores nas últimas 6 horas');
        DBMS_OUTPUT.PUT_LINE('Ação: Verificar funcionamento dos sensores');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Umidade Média: ' || ROUND(v_umidade_media, 1) || '%');
        DBMS_OUTPUT.PUT_LINE('Precipitação Máxima: ' || ROUND(NVL(v_precipitacao_max, 0), 1) || 'mm');
        DBMS_OUTPUT.PUT_LINE(' ');
        

        IF v_umidade_media > 90 AND NVL(v_precipitacao_max, 0) > 50 THEN
            v_nivel_risco := 'EMERGÊNCIA';
            v_acao_recomendada := 'Evacuar áreas baixas IMEDIATAMENTE!';
        ELSIF v_umidade_media > 85 OR NVL(v_precipitacao_max, 0) > 40 THEN
            v_nivel_risco := 'CRÍTICO';
            v_acao_recomendada := 'Preparar evacuação e drenar área';
        ELSIF v_umidade_media > 70 OR NVL(v_precipitacao_max, 0) > 25 THEN
            v_nivel_risco := 'ALTO';
            v_acao_recomendada := 'Monitorar de perto e preparar drenagem';
        ELSIF v_umidade_media > 50 OR NVL(v_precipitacao_max, 0) > 15 THEN
            v_nivel_risco := 'MÉDIO';
            v_acao_recomendada := 'Continuar monitoramento normal';
        ELSE
            v_nivel_risco := 'BAIXO';
            v_acao_recomendada := 'Situação normal, sem ações necessárias';
        END IF;
        

        DBMS_OUTPUT.PUT_LINE('🚨 NÍVEL DE RISCO: ' || v_nivel_risco);
        DBMS_OUTPUT.PUT_LINE('📞 Contato: ' || v_telefone);
        DBMS_OUTPUT.PUT_LINE('✅ Ação Recomendada: ' || v_acao_recomendada);
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERRO: Propriedade não encontrada (ID: ' || v_id_propriedade || ')');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERRO: ' || SQLERRM);
END;
/