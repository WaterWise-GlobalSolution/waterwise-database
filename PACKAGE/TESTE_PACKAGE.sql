SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    -- Variáveis para armazenar IDs para testes sequenciais
    v_id_tipo_sensor_teste      GS_WW_TIPO_SENSOR.id_tipo_sensor%TYPE;
    v_id_nivel_severidade_teste GS_WW_NIVEL_SEVERIDADE.id_nivel_severidade%TYPE;
    v_id_nivel_degradacao_teste GS_WW_NIVEL_DEGRADACAO_SOLO.id_nivel_degradacao%TYPE;
    v_id_produtor_teste         GS_WW_PRODUTOR_RURAL.id_produtor%TYPE;
    v_id_propriedade_teste      GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE;
    v_id_sensor_iot_teste       GS_WW_SENSOR_IOT.id_sensor%TYPE;
    v_id_leitura_teste          GS_WW_LEITURA_SENSOR.id_leitura%TYPE;
    v_id_alerta_teste           GS_WW_ALERTA.id_alerta%TYPE;
    
    v_resultado_varchar VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO TESTES DA PKG_WATERWISE ===');

    -- 1. Inicializar o sistema (popula tabelas de lookup: Tipo Sensor, Nível Severidade, Nível Degradação)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 1. Testando INICIALIZAR_SISTEMA ---');
    PKG_WATERWISE.INICIALIZAR_SISTEMA;
    DBMS_OUTPUT.PUT_LINE('Sistema inicializado (lookup tables populadas).');

    -- Obter IDs de lookup para usar nos testes seguintes (assumindo que INICIALIZAR_SISTEMA os criou)
    BEGIN
        SELECT id_tipo_sensor INTO v_id_tipo_sensor_teste FROM GS_WW_TIPO_SENSOR WHERE nome_tipo = 'Sensor de Umidade do Solo' AND ROWNUM = 1;
        SELECT id_nivel_severidade INTO v_id_nivel_severidade_teste FROM GS_WW_NIVEL_SEVERIDADE WHERE codigo_severidade = 'MEDIO' AND ROWNUM = 1;
        SELECT id_nivel_degradacao INTO v_id_nivel_degradacao_teste FROM GS_WW_NIVEL_DEGRADACAO_SOLO WHERE codigo_degradacao = 'MODERADO' AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Dados de lookup não encontrados após INICIALIZAR_SISTEMA. Verifique a procedure.');
            RETURN;
    END;
    
    -- 2. Testar CRUD_PRODUTOR_RURAL
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 2. Testando CRUD_PRODUTOR_RURAL ---');
    v_id_produtor_teste := NULL; -- Importante para INSERT com parâmetro IN OUT
    PKG_WATERWISE.CRUD_PRODUTOR_RURAL(
        v_operacao       => 'INSERT',
        v_id_produtor    => v_id_produtor_teste, -- Receberá o ID gerado
        v_nome_completo  => 'João Testador da Silva',
        v_cpf_cnpj       => '123.456.789-00', -- Garanta que seja único para o teste
        v_email          => 'joao.teste@waterwise.com', -- Garanta que seja único
        v_telefone       => '(11)91234-5678',
        v_senha          => 'JoaoTeste@2025'
    );
    DBMS_OUTPUT.PUT_LINE('Produtor João Testador inserido com ID: ' || v_id_produtor_teste);

    PKG_WATERWISE.CRUD_PRODUTOR_RURAL(
        v_operacao       => 'UPDATE',
        v_id_produtor    => v_id_produtor_teste,
        v_nome_completo  => 'João Testador da Silva (Nome Atualizado)',
        v_email          => 'joao.teste.novo@waterwise.com'
        -- Demais campos (cpf_cnpj, telefone, senha) serão mantidos se NULL na chamada
    );
    DBMS_OUTPUT.PUT_LINE('Produtor ID ' || v_id_produtor_teste || ' atualizado.');

    -- 3. Testar CRUD_PROPRIEDADE_RURAL
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 3. Testando CRUD_PROPRIEDADE_RURAL ---');
    v_id_propriedade_teste := NULL; -- Importante para INSERT
    PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL(
        v_operacao             => 'INSERT',
        v_id_propriedade       => v_id_propriedade_teste, -- Receberá o ID
        v_id_produtor          => v_id_produtor_teste,
        v_id_nivel_degradacao  => v_id_nivel_degradacao_teste, 
        v_nome_propriedade     => 'Fazenda Teste Principal',
        v_latitude             => -23.12345,
        v_longitude            => -46.54321,
        v_area_hectares        => 150.75
    );
    DBMS_OUTPUT.PUT_LINE('Propriedade Fazenda Teste Principal inserida com ID: ' || v_id_propriedade_teste);

    -- 4. Testar CRUD_SENSOR_IOT
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 4. Testando CRUD_SENSOR_IOT ---');
    v_id_sensor_iot_teste := NULL; -- Importante para INSERT
    PKG_WATERWISE.CRUD_SENSOR_IOT(
        v_operacao           => 'INSERT',
        v_id_sensor          => v_id_sensor_iot_teste, -- Receberá o ID
        v_id_propriedade     => v_id_propriedade_teste,
        v_id_tipo_sensor     => v_id_tipo_sensor_teste, 
        v_modelo_dispositivo => 'SensorUmidadeModeloAlpha'
    );
    DBMS_OUTPUT.PUT_LINE('Sensor IoT SensorUmidadeModeloAlpha inserido com ID: ' || v_id_sensor_iot_teste);

    -- 5. Testar CRUD_LEITURA_SENSOR
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 5. Testando CRUD_LEITURA_SENSOR ---');
    v_id_leitura_teste := NULL; -- Importante para INSERT
    PKG_WATERWISE.CRUD_LEITURA_SENSOR(
        v_operacao          => 'INSERT',
        v_id_leitura        => v_id_leitura_teste, -- Receberá o ID
        v_id_sensor         => v_id_sensor_iot_teste,
        v_timestamp_leitura => SYSTIMESTAMP - INTERVAL '1' HOUR, -- Leitura de 1 hora atrás
        v_umidade_solo      => 75.5,
        v_temperatura_ar    => 25.2,
        v_precipitacao_mm   => 5.1
    );
    DBMS_OUTPUT.PUT_LINE('Leitura de Sensor (ID: '|| v_id_leitura_teste ||') inserida para o sensor ID ' || v_id_sensor_iot_teste);
    -- Inserir mais uma leitura para testar alertas e cálculos
    DECLARE v_id_leitura_critica NUMBER; BEGIN
        PKG_WATERWISE.CRUD_LEITURA_SENSOR('INSERT',v_id_leitura_critica,v_id_sensor_iot_teste,SYSTIMESTAMP - INTERVAL '30' MINUTE,92.0,23.0,55.0);
        DBMS_OUTPUT.PUT_LINE('Leitura de Sensor CRÍTICA (ID: '|| v_id_leitura_critica ||') inserida para o sensor ID ' || v_id_sensor_iot_teste);
    END;


    -- 6. Testar CRUD_ALERTA (Alerta Manual)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 6. Testando CRUD_ALERTA (Manual) ---');
    v_id_alerta_teste := NULL; -- Importante para INSERT
    PKG_WATERWISE.CRUD_ALERTA(
        v_operacao             => 'INSERT',
        v_id_alerta            => v_id_alerta_teste, -- Receberá o ID
        v_id_produtor          => v_id_produtor_teste,
        v_id_leitura           => v_id_leitura_teste, -- Associado à primeira leitura inserida
        v_id_nivel_severidade  => v_id_nivel_severidade_teste, 
        v_timestamp_alerta     => SYSTIMESTAMP,
        v_descricao_alerta     => 'Alerta manual de teste: Necessário verificar equipamento.'
    );
    DBMS_OUTPUT.PUT_LINE('Alerta manual inserido com ID: ' || v_id_alerta_teste);

    -- 7. Testar Funções de Cálculo
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 7. Testando Funções de Cálculo para Propriedade ID ' || v_id_propriedade_teste || ' ---');
    v_resultado_varchar := PKG_WATERWISE.CALCULAR_RISCO_ALAGAMENTO(p_id_propriedade => v_id_propriedade_teste);
    DBMS_OUTPUT.PUT_LINE('Risco Alagamento: ' || v_resultado_varchar);
    
    v_resultado_varchar := PKG_WATERWISE.CALCULAR_TAXA_DEGRADACAO_SOLO(p_id_propriedade => v_id_propriedade_teste);
    DBMS_OUTPUT.PUT_LINE('Taxa Degradação Solo: ' || v_resultado_varchar);
    
    v_resultado_varchar := PKG_WATERWISE.CALCULAR_CAPACIDADE_ABSORCAO(p_id_propriedade => v_id_propriedade_teste);
    DBMS_OUTPUT.PUT_LINE('Capacidade Absorção: ' || v_resultado_varchar);

    -- 8. Testar Procedures de Análise e Relatórios (uma seleção)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 8. Testando Procedures de Análise e Relatórios ---');
    PKG_WATERWISE.ANALISAR_ALERTAS_DIARIOS;
    DBMS_OUTPUT.PUT_LINE('---');
    PKG_WATERWISE.VERIFICAR_RISCO_ENCHENTE(p_id_propriedade => v_id_propriedade_teste);
    DBMS_OUTPUT.PUT_LINE('---');
    PKG_WATERWISE.STATUS_SENSORES;
    DBMS_OUTPUT.PUT_LINE('---');
    PKG_WATERWISE.PROPRIEDADES_RISCO_ENCHENTE;
    DBMS_OUTPUT.PUT_LINE('---');
    PKG_WATERWISE.DASHBOARD_METRICAS;
    DBMS_OUTPUT.PUT_LINE('---');
    PKG_WATERWISE.RELATORIO_PROPRIEDADE(p_id_propriedade => v_id_propriedade_teste);
    DBMS_OUTPUT.PUT_LINE('---');
    PKG_WATERWISE.RISCO_POR_REGIAO; -- Certifique-se que há dados para diferentes regiões
    
    -- 9. Testar operação DELETE (Exemplo para Produtor)
    -- CUIDADO: Deleções são permanentes e podem afetar a integridade referencial
    -- se não tratadas corretamente na procedure ou se houver dados dependentes não tratados.
    -- As procedures CRUD implementadas tentam tratar algumas dependências, mas revise-as.
    /*
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 9. Testando DELETE para Produtor ID ' || v_id_produtor_teste || ' ---');
    PKG_WATERWISE.CRUD_PRODUTOR_RURAL(
        v_operacao    => 'DELETE',
        v_id_produtor => v_id_produtor_teste
    );
    -- Verificar se o produtor e suas dependências (se configurado para cascata na procedure) foram removidos.
    */

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== TESTES PKG_WATERWISE CONCLUÍDOS ===');
    -- COMMIT; -- COMMIT já está dentro de cada procedure CRUD.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO GERAL NO BLOCO DE TESTE: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK; -- Garante rollback se algo falhar no bloco de teste principal.
END;
/