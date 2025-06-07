DECLARE
    v_id_propriedade   NUMBER := 6; -- Altere para testar outras propriedades
    v_umidade_media    NUMBER;
    v_precipitacao_max NUMBER;
    v_nome_propriedade VARCHAR2(100);
    v_nome_produtor    VARCHAR2(100);
    v_telefone         VARCHAR2(15);
    v_email_produtor   VARCHAR2(100);
    v_data_cadastro    DATE;
    v_nivel_risco      VARCHAR2(20);
    v_acao_recomendada VARCHAR2(200);
    v_conta_ativa      VARCHAR2(20);
BEGIN
-- Buscar dados da propriedade e produtor
    SELECT
        pr.nome_propriedade,
        prod.nome_completo, 
        prod.telefone,
        prod.email,
        prod.data_cadastro,
        CASE
            WHEN prod.senha IS NOT NULL
                 AND LENGTH(prod.senha) >= 6 THEN 
                'ATIVA'
            ELSE
                'INATIVA'
        END AS conta_status
    INTO
        v_nome_propriedade,
        v_nome_produtor,
        v_telefone,
        v_email_produtor,
        v_data_cadastro,
        v_conta_ativa
    FROM
             gs_ww_propriedade_rural pr
        JOIN gs_ww_produtor_rural prod ON pr.id_produtor = prod.id_produtor
    WHERE
        pr.id_propriedade = v_id_propriedade;

-- Buscar dados do sensor e leituras recentes para a propriedade
    SELECT
        AVG(ls.umidade_solo),
        MAX(ls.precipitacao_mm)
    INTO
        v_umidade_media,
        v_precipitacao_max
    FROM
        gs_ww_leitura_sensor ls
        JOIN gs_ww_sensor_iot si ON ls.id_sensor = si.id_sensor
    WHERE
            si.id_propriedade = v_id_propriedade
        AND ls.timestamp_leitura >= SYSDATE - ( 1 / 24 ); -- Última hora

    dbms_output.put_line('=== VERIFICAÇÃO DE RISCO DE ENCHENTE ===');
    dbms_output.put_line('Propriedade: ' || v_nome_propriedade);
    dbms_output.put_line('Produtor: ' || v_nome_produtor);
    dbms_output.put_line('Email Produtor: ' || v_email_produtor);
    dbms_output.put_line('Data Cadastro Produtor: ' || TO_CHAR(v_data_cadastro, 'DD/MM/YYYY'));
    dbms_output.put_line('Status Conta: ' || v_conta_ativa);
    dbms_output.put_line(' ');

    IF v_umidade_media IS NULL THEN
        dbms_output.put_line('Sem dados de leitura recentes para esta propriedade.');
        v_nivel_risco := 'DESCONHECIDO';
        v_acao_recomendada := 'Verificar sensores da propriedade.';
    ELSE
        dbms_output.put_line('Umidade Média (última hora): ' || ROUND(v_umidade_media, 1) || '%');
        dbms_output.put_line('Precipitação Máxima (última hora): ' || ROUND(nvl(v_precipitacao_max, 0), 1) || 'mm');
        dbms_output.put_line(' ');

        IF v_umidade_media > 90
        OR nvl(v_precipitacao_max, 0) > 50 THEN
            v_nivel_risco := 'EMERGÊNCIA';
            v_acao_recomendada := 'Evacuar área imediatamente! Contatar autoridades!';
        ELSIF v_umidade_media > 80
        OR nvl(v_precipitacao_max, 0) > 35 THEN
            v_nivel_risco := 'CRÍTICO';
            v_acao_recomendada := 'Preparar evacuação e drenar área';
        ELSIF v_umidade_media > 70
        OR nvl(v_precipitacao_max, 0) > 25 THEN
            v_nivel_risco := 'ALTO';
            v_acao_recomendada := 'Monitorar de perto e preparar drenagem';
        ELSIF v_umidade_media > 50
        OR nvl(v_precipitacao_max, 0) > 15 THEN
            v_nivel_risco := 'MÉDIO';
            v_acao_recomendada := 'Continuar monitoramento normal';
        ELSE
            v_nivel_risco := 'BAIXO';
            v_acao_recomendada := 'Situação normal, sem ações necessárias';
        END IF;

        dbms_output.put_line('🚨 NÍVEL DE RISCO: ' || v_nivel_risco);
        dbms_output.put_line('📞 Contato: ' || v_telefone);
        dbms_output.put_line('✅ Ação Recomendada: ' || v_acao_recomendada);

    -- Verificação adicional de segurança
        IF
            v_conta_ativa = 'INATIVA'
            AND v_nivel_risco IN ( 'CRÍTICO', 'EMERGÊNCIA' )
        THEN
            dbms_output.put_line(' ');
            dbms_output.put_line('🔒 ALERTA DE SEGURANÇA: Conta inativa em situação crítica!');
            dbms_output.put_line('  Contatar produtor ' || v_nome_produtor || ' (' || v_email_produtor || ') URGENTE!');
        END IF;

    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Propriedade com ID ' || v_id_propriedade || ' não encontrada ou sem dados recentes.');
    WHEN OTHERS THEN
        dbms_output.put_line('Erro ao verificar risco de enchente: ' || SQLERRM);
END;
/