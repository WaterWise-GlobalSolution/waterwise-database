CREATE OR REPLACE PACKAGE PKG_WATERWISE IS

-- ============================================================================
-- 1. PROCEDURES CRUD
-- ============================================================================

    -- Procedure CRUD para Tipo Sensor
    PROCEDURE CRUD_TIPO_SENSOR(
        v_operacao         IN VARCHAR2,
        v_id_tipo_sensor   IN OUT NOCOPY GS_WW_TIPO_SENSOR.id_tipo_sensor%TYPE, -- Modificado
        v_nome_tipo        IN GS_WW_TIPO_SENSOR.nome_tipo%TYPE DEFAULT NULL,
        v_descricao        IN GS_WW_TIPO_SENSOR.descricao%TYPE DEFAULT NULL,
        v_unidade_medida   IN GS_WW_TIPO_SENSOR.unidade_medida%TYPE DEFAULT NULL,
        v_valor_min        IN GS_WW_TIPO_SENSOR.valor_min%TYPE DEFAULT NULL,
        v_valor_max        IN GS_WW_TIPO_SENSOR.valor_max%TYPE DEFAULT NULL
    );

    -- Procedure CRUD para Nível Severidade
    PROCEDURE CRUD_NIVEL_SEVERIDADE(
        v_operacao              IN VARCHAR2,
        v_id_nivel_severidade   IN OUT NOCOPY GS_WW_NIVEL_SEVERIDADE.id_nivel_severidade%TYPE, -- Modificado
        v_codigo_severidade     IN GS_WW_NIVEL_SEVERIDADE.codigo_severidade%TYPE DEFAULT NULL,
        v_descricao_severidade  IN GS_WW_NIVEL_SEVERIDADE.descricao_severidade%TYPE DEFAULT NULL,
        v_acoes_recomendadas    IN GS_WW_NIVEL_SEVERIDADE.acoes_recomendadas%TYPE DEFAULT NULL
    );

    -- Procedure CRUD para Nível Degradação Solo
    PROCEDURE CRUD_NIVEL_DEGRADACAO_SOLO(
        v_operacao              IN VARCHAR2,
        v_id_nivel_degradacao   IN OUT NOCOPY GS_WW_NIVEL_DEGRADACAO_SOLO.id_nivel_degradacao%TYPE, -- Modificado
        v_codigo_degradacao     IN GS_WW_NIVEL_DEGRADACAO_SOLO.codigo_degradacao%TYPE DEFAULT NULL,
        v_descricao_degradacao  IN GS_WW_NIVEL_DEGRADACAO_SOLO.descricao_degradacao%TYPE DEFAULT NULL,
        v_nivel_numerico        IN GS_WW_NIVEL_DEGRADACAO_SOLO.nivel_numerico%TYPE DEFAULT NULL,
        v_acoes_corretivas      IN GS_WW_NIVEL_DEGRADACAO_SOLO.acoes_corretivas%TYPE DEFAULT NULL
    );

    -- Procedure CRUD para Produtor Rural
    PROCEDURE CRUD_PRODUTOR_RURAL(
        v_operacao       IN VARCHAR2,
        v_id_produtor    IN OUT NOCOPY GS_WW_PRODUTOR_RURAL.id_produtor%TYPE, -- Modificado
        v_nome_completo  IN GS_WW_PRODUTOR_RURAL.nome_completo%TYPE DEFAULT NULL,
        v_cpf_cnpj       IN GS_WW_PRODUTOR_RURAL.cpf_cnpj%TYPE DEFAULT NULL,
        v_email          IN GS_WW_PRODUTOR_RURAL.email%TYPE DEFAULT NULL,
        v_telefone       IN GS_WW_PRODUTOR_RURAL.telefone%TYPE DEFAULT NULL,
        v_senha          IN GS_WW_PRODUTOR_RURAL.senha%TYPE DEFAULT NULL,
        v_data_cadastro  IN GS_WW_PRODUTOR_RURAL.data_cadastro%TYPE DEFAULT SYSDATE
    );

    -- Procedure CRUD para Propriedade Rural
    PROCEDURE CRUD_PROPRIEDADE_RURAL(
        v_operacao             IN VARCHAR2,
        v_id_propriedade       IN OUT NOCOPY GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE, -- Modificado
        v_id_produtor          IN GS_WW_PROPRIEDADE_RURAL.id_produtor%TYPE DEFAULT NULL,
        v_id_nivel_degradacao  IN GS_WW_PROPRIEDADE_RURAL.id_nivel_degradacao%TYPE DEFAULT NULL,
        v_nome_propriedade     IN GS_WW_PROPRIEDADE_RURAL.nome_propriedade%TYPE DEFAULT NULL,
        v_latitude             IN GS_WW_PROPRIEDADE_RURAL.latitude%TYPE DEFAULT NULL,
        v_longitude            IN GS_WW_PROPRIEDADE_RURAL.longitude%TYPE DEFAULT NULL,
        v_area_hectares        IN GS_WW_PROPRIEDADE_RURAL.area_hectares%TYPE DEFAULT NULL
    );

    -- Procedure CRUD para Sensor IoT
    PROCEDURE CRUD_SENSOR_IOT(
        v_operacao           IN VARCHAR2,
        v_id_sensor          IN OUT NOCOPY GS_WW_SENSOR_IOT.id_sensor%TYPE, -- Modificado
        v_id_propriedade     IN GS_WW_SENSOR_IOT.id_propriedade%TYPE DEFAULT NULL,
        v_id_tipo_sensor     IN GS_WW_SENSOR_IOT.id_tipo_sensor%TYPE DEFAULT NULL,
        v_modelo_dispositivo IN GS_WW_SENSOR_IOT.modelo_dispositivo%TYPE DEFAULT NULL
    );

    -- Procedure CRUD para Leitura Sensor
    PROCEDURE CRUD_LEITURA_SENSOR(
        v_operacao          IN VARCHAR2,
        v_id_leitura        IN OUT NOCOPY GS_WW_LEITURA_SENSOR.id_leitura%TYPE, -- Modificado
        v_id_sensor         IN GS_WW_LEITURA_SENSOR.id_sensor%TYPE DEFAULT NULL,
        v_timestamp_leitura IN GS_WW_LEITURA_SENSOR.timestamp_leitura%TYPE DEFAULT CURRENT_TIMESTAMP, -- Adicionado DEFAULT
        v_umidade_solo      IN GS_WW_LEITURA_SENSOR.umidade_solo%TYPE DEFAULT NULL,
        v_temperatura_ar    IN GS_WW_LEITURA_SENSOR.temperatura_ar%TYPE DEFAULT NULL,
        v_precipitacao_mm   IN GS_WW_LEITURA_SENSOR.precipitacao_mm%TYPE DEFAULT NULL
    );

    -- Procedure CRUD para Alerta
    PROCEDURE CRUD_ALERTA(
        v_operacao             IN VARCHAR2,
        v_id_alerta            IN OUT NOCOPY GS_WW_ALERTA.id_alerta%TYPE, -- Modificado
        v_id_produtor          IN GS_WW_ALERTA.id_produtor%TYPE DEFAULT NULL,
        v_id_leitura           IN GS_WW_ALERTA.id_leitura%TYPE DEFAULT NULL,
        v_id_nivel_severidade  IN GS_WW_ALERTA.id_nivel_severidade%TYPE DEFAULT NULL,
        v_timestamp_alerta     IN GS_WW_ALERTA.timestamp_alerta%TYPE DEFAULT CURRENT_TIMESTAMP, -- Adicionado DEFAULT
        v_descricao_alerta     IN GS_WW_ALERTA.descricao_alerta%TYPE DEFAULT NULL
    );

-- ============================================================================
-- 2. FUNÇÕES DE CÁLCULO
-- ============================================================================

    FUNCTION CALCULAR_RISCO_ALAGAMENTO(
        p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
    ) RETURN VARCHAR2;

    FUNCTION CALCULAR_TAXA_DEGRADACAO_SOLO(
        p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
    ) RETURN VARCHAR2;

    FUNCTION CALCULAR_CAPACIDADE_ABSORCAO(
        p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
    ) RETURN VARCHAR2;

-- ============================================================================
-- 3. PROCEDURES DE ANÁLISE E RELATÓRIOS
-- ============================================================================

    PROCEDURE ANALISAR_ALERTAS_DIARIOS;
    PROCEDURE VERIFICAR_RISCO_ENCHENTE(p_id_propriedade IN NUMBER DEFAULT NULL); -- Default NULL para analisar todas se desejado, ou adaptar lógica
    PROCEDURE STATUS_SENSORES;
    PROCEDURE RESUMO_DIARIO_SISTEMA;
    PROCEDURE LISTAR_ALERTAS_RECENTES;
    PROCEDURE ESTADO_GERAL_SOLO;
    PROCEDURE PROPRIEDADES_RISCO_ENCHENTE;

-- ============================================================================
-- 4. PROCEDURES DE RELATÓRIOS EXECUTIVOS
-- ============================================================================

    PROCEDURE DASHBOARD_METRICAS;
    PROCEDURE MELHORES_PRODUTORES;
    PROCEDURE RISCO_POR_REGIAO;
    PROCEDURE SEVERIDADE_ALERTAS;
    PROCEDURE MONITORAMENTO_TEMPO_REAL;
    PROCEDURE PRODUTIVIDADE_POR_REGIAO;
    PROCEDURE TENDENCIAS_CLIMATICAS(p_dias_analise IN NUMBER DEFAULT 30);

-- ============================================================================
-- 5. PROCEDURES UTILITÁRIAS
-- ============================================================================

    PROCEDURE INICIALIZAR_SISTEMA;
    PROCEDURE VALIDAR_INTEGRIDADE_DADOS;
    PROCEDURE RELATORIO_PROPRIEDADE(p_id_propriedade IN NUMBER);
    PROCEDURE BACKUP_DADOS_CRITICOS;

END PKG_WATERWISE;
/


CREATE OR REPLACE PACKAGE BODY PKG_WATERWISE IS

-- ============================================================================
-- 1. IMPLEMENTAÇÃO DAS PROCEDURES CRUD
-- ============================================================================

    PROCEDURE CRUD_TIPO_SENSOR(
        v_operacao         IN VARCHAR2,
        v_id_tipo_sensor   IN OUT NOCOPY GS_WW_TIPO_SENSOR.id_tipo_sensor%TYPE,
        v_nome_tipo        IN GS_WW_TIPO_SENSOR.nome_tipo%TYPE DEFAULT NULL,
        v_descricao        IN GS_WW_TIPO_SENSOR.descricao%TYPE DEFAULT NULL,
        v_unidade_medida   IN GS_WW_TIPO_SENSOR.unidade_medida%TYPE DEFAULT NULL,
        v_valor_min        IN GS_WW_TIPO_SENSOR.valor_min%TYPE DEFAULT NULL,
        v_valor_max        IN GS_WW_TIPO_SENSOR.valor_max%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_nome_tipo IS NULL THEN -- Adicionando validação básica
                 RAISE_APPLICATION_ERROR(-20001, 'Nome do tipo de sensor é obrigatório para INSERT.');
            END IF;
            INSERT INTO GS_WW_TIPO_SENSOR (nome_tipo, descricao, unidade_medida, valor_min, valor_max)
            VALUES (v_nome_tipo, v_descricao, v_unidade_medida, v_valor_min, v_valor_max)
            RETURNING id_tipo_sensor INTO v_id_tipo_sensor; -- Modificado
            v_mensagem := 'Tipo de sensor inserido com ID: ' || v_id_tipo_sensor;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_tipo_sensor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do tipo de sensor é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_TIPO_SENSOR
            SET nome_tipo = NVL(v_nome_tipo, nome_tipo),
                descricao = NVL(v_descricao, descricao),
                unidade_medida = NVL(v_unidade_medida, unidade_medida),
                valor_min = NVL(v_valor_min, valor_min),
                valor_max = NVL(v_valor_max, valor_max)
            WHERE id_tipo_sensor = v_id_tipo_sensor;
            v_mensagem := 'Tipo de sensor atualizado com ID: ' || v_id_tipo_sensor;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_tipo_sensor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do tipo de sensor é obrigatório para DELETE.');
            END IF;
            DELETE FROM GS_WW_TIPO_SENSOR WHERE id_tipo_sensor = v_id_tipo_sensor;
            v_mensagem := 'Tipo de sensor deletado com ID: ' || v_id_tipo_sensor;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Tipo Sensor inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_TIPO_SENSOR (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_TIPO_SENSOR;

    PROCEDURE CRUD_NIVEL_SEVERIDADE(
        v_operacao              IN VARCHAR2,
        v_id_nivel_severidade   IN OUT NOCOPY GS_WW_NIVEL_SEVERIDADE.id_nivel_severidade%TYPE,
        v_codigo_severidade     IN GS_WW_NIVEL_SEVERIDADE.codigo_severidade%TYPE DEFAULT NULL,
        v_descricao_severidade  IN GS_WW_NIVEL_SEVERIDADE.descricao_severidade%TYPE DEFAULT NULL,
        v_acoes_recomendadas    IN GS_WW_NIVEL_SEVERIDADE.acoes_recomendadas%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_codigo_severidade IS NULL OR v_descricao_severidade IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001, 'Código e Descrição da severidade são obrigatórios para INSERT.');
            END IF;
            INSERT INTO GS_WW_NIVEL_SEVERIDADE (codigo_severidade, descricao_severidade, acoes_recomendadas)
            VALUES (v_codigo_severidade, v_descricao_severidade, v_acoes_recomendadas)
            RETURNING id_nivel_severidade INTO v_id_nivel_severidade; -- Modificado
            v_mensagem := 'Nível de severidade inserido com ID: ' || v_id_nivel_severidade;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_nivel_severidade IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do nível de severidade é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_NIVEL_SEVERIDADE
            SET codigo_severidade = NVL(v_codigo_severidade, codigo_severidade),
                descricao_severidade = NVL(v_descricao_severidade, descricao_severidade),
                acoes_recomendadas = NVL(v_acoes_recomendadas, acoes_recomendadas)
            WHERE id_nivel_severidade = v_id_nivel_severidade;
            v_mensagem := 'Nível de severidade atualizado com ID: ' || v_id_nivel_severidade;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_nivel_severidade IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do nível de severidade é obrigatório para DELETE.');
            END IF;
            DELETE FROM GS_WW_NIVEL_SEVERIDADE WHERE id_nivel_severidade = v_id_nivel_severidade;
            v_mensagem := 'Nível de severidade deletado com ID: ' || v_id_nivel_severidade;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Nível Severidade inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_NIVEL_SEVERIDADE (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_NIVEL_SEVERIDADE;

    PROCEDURE CRUD_NIVEL_DEGRADACAO_SOLO(
        v_operacao              IN VARCHAR2,
        v_id_nivel_degradacao   IN OUT NOCOPY GS_WW_NIVEL_DEGRADACAO_SOLO.id_nivel_degradacao%TYPE,
        v_codigo_degradacao     IN GS_WW_NIVEL_DEGRADACAO_SOLO.codigo_degradacao%TYPE DEFAULT NULL,
        v_descricao_degradacao  IN GS_WW_NIVEL_DEGRADACAO_SOLO.descricao_degradacao%TYPE DEFAULT NULL,
        v_nivel_numerico        IN GS_WW_NIVEL_DEGRADACAO_SOLO.nivel_numerico%TYPE DEFAULT NULL,
        v_acoes_corretivas      IN GS_WW_NIVEL_DEGRADACAO_SOLO.acoes_corretivas%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_codigo_degradacao IS NULL OR v_descricao_degradacao IS NULL OR v_nivel_numerico IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001, 'Código, Descrição e Nível Numérico da degradação são obrigatórios para INSERT.');
            END IF;
            INSERT INTO GS_WW_NIVEL_DEGRADACAO_SOLO (codigo_degradacao, descricao_degradacao, nivel_numerico, acoes_corretivas)
            VALUES (v_codigo_degradacao, v_descricao_degradacao, v_nivel_numerico, v_acoes_corretivas)
            RETURNING id_nivel_degradacao INTO v_id_nivel_degradacao; -- Modificado
            v_mensagem := 'Nível de degradação inserido com ID: ' || v_id_nivel_degradacao;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_nivel_degradacao IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do nível de degradação é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_NIVEL_DEGRADACAO_SOLO
            SET codigo_degradacao = NVL(v_codigo_degradacao, codigo_degradacao),
                descricao_degradacao = NVL(v_descricao_degradacao, descricao_degradacao),
                nivel_numerico = NVL(v_nivel_numerico, nivel_numerico),
                acoes_corretivas = NVL(v_acoes_corretivas, acoes_corretivas)
            WHERE id_nivel_degradacao = v_id_nivel_degradacao;
            v_mensagem := 'Nível de degradação atualizado com ID: ' || v_id_nivel_degradacao;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_nivel_degradacao IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do nível de degradação é obrigatório para DELETE.');
            END IF;
            DELETE FROM GS_WW_NIVEL_DEGRADACAO_SOLO WHERE id_nivel_degradacao = v_id_nivel_degradacao;
            v_mensagem := 'Nível de degradação deletado com ID: ' || v_id_nivel_degradacao;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Nível Degradação Solo inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_NIVEL_DEGRADACAO_SOLO (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_NIVEL_DEGRADACAO_SOLO;

    PROCEDURE CRUD_PRODUTOR_RURAL(
        v_operacao       IN VARCHAR2,
        v_id_produtor    IN OUT NOCOPY GS_WW_PRODUTOR_RURAL.id_produtor%TYPE,
        v_nome_completo  IN GS_WW_PRODUTOR_RURAL.nome_completo%TYPE DEFAULT NULL,
        v_cpf_cnpj       IN GS_WW_PRODUTOR_RURAL.cpf_cnpj%TYPE DEFAULT NULL,
        v_email          IN GS_WW_PRODUTOR_RURAL.email%TYPE DEFAULT NULL,
        v_telefone       IN GS_WW_PRODUTOR_RURAL.telefone%TYPE DEFAULT NULL,
        v_senha          IN GS_WW_PRODUTOR_RURAL.senha%TYPE DEFAULT NULL,
        v_data_cadastro  IN GS_WW_PRODUTOR_RURAL.data_cadastro%TYPE DEFAULT SYSDATE
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_nome_completo IS NULL OR v_cpf_cnpj IS NULL OR v_email IS NULL OR v_senha IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'Campos obrigatórios para Produtor (INSERT): nome, CPF/CNPJ, email e senha');
            END IF;
            INSERT INTO GS_WW_PRODUTOR_RURAL (nome_completo, cpf_cnpj, email, telefone, senha, data_cadastro)
            VALUES (v_nome_completo, v_cpf_cnpj, v_email, v_telefone, v_senha, NVL(v_data_cadastro, SYSDATE))
            RETURNING id_produtor INTO v_id_produtor; -- Modificado
            v_mensagem := 'Produtor rural inserido com ID: ' || v_id_produtor;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_produtor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do produtor é obrigatório para UPDATE');
            END IF;
            UPDATE GS_WW_PRODUTOR_RURAL
            SET nome_completo = NVL(v_nome_completo, nome_completo),
                cpf_cnpj = NVL(v_cpf_cnpj, cpf_cnpj),
                email = NVL(v_email, email),
                telefone = NVL(v_telefone, telefone),
                senha = NVL(v_senha, senha),
                data_cadastro = NVL(v_data_cadastro, data_cadastro)
            WHERE id_produtor = v_id_produtor;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Produtor com ID ' || v_id_produtor || ' não encontrado para UPDATE.');
            END IF;
            v_mensagem := 'Produtor rural atualizado com ID: ' || v_id_produtor;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_produtor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do produtor é obrigatório para DELETE');
            END IF;
            -- Adicionar lógica para deletar dependências ANTES de deletar o produtor.
            -- Ex: Deletar alertas associados, e potencialmente propriedades (ou impedir delete se existirem propriedades)
            -- DELETE FROM GS_WW_ALERTA WHERE id_produtor = v_id_produtor;
            -- ... verificar outras tabelas ...
            DELETE FROM GS_WW_PRODUTOR_RURAL WHERE id_produtor = v_id_produtor;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Produtor com ID ' || v_id_produtor || ' não encontrado para DELETE.');
            END IF;
            v_mensagem := 'Produtor rural deletado com ID: ' || v_id_produtor;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Produtor Rural inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_PRODUTOR_RURAL (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_PRODUTOR_RURAL;

    PROCEDURE CRUD_PROPRIEDADE_RURAL(
        v_operacao             IN VARCHAR2,
        v_id_propriedade       IN OUT NOCOPY GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE,
        v_id_produtor          IN GS_WW_PROPRIEDADE_RURAL.id_produtor%TYPE DEFAULT NULL,
        v_id_nivel_degradacao  IN GS_WW_PROPRIEDADE_RURAL.id_nivel_degradacao%TYPE DEFAULT NULL,
        v_nome_propriedade     IN GS_WW_PROPRIEDADE_RURAL.nome_propriedade%TYPE DEFAULT NULL,
        v_latitude             IN GS_WW_PROPRIEDADE_RURAL.latitude%TYPE DEFAULT NULL,
        v_longitude            IN GS_WW_PROPRIEDADE_RURAL.longitude%TYPE DEFAULT NULL,
        v_area_hectares        IN GS_WW_PROPRIEDADE_RURAL.area_hectares%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_id_produtor IS NULL OR v_id_nivel_degradacao IS NULL OR v_nome_propriedade IS NULL OR
               v_latitude IS NULL OR v_longitude IS NULL OR v_area_hectares IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001, 'Todos os campos (exceto ID da propriedade) são obrigatórios para INSERT de Propriedade.');
            END IF;
            INSERT INTO GS_WW_PROPRIEDADE_RURAL (id_produtor, id_nivel_degradacao, nome_propriedade, latitude, longitude, area_hectares, data_cadastro)
            VALUES (v_id_produtor, v_id_nivel_degradacao, v_nome_propriedade, v_latitude, v_longitude, v_area_hectares, SYSDATE)
            RETURNING id_propriedade INTO v_id_propriedade; -- Modificado
            v_mensagem := 'Propriedade rural inserida com ID: ' || v_id_propriedade;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_propriedade IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID da propriedade é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_PROPRIEDADE_RURAL
            SET id_produtor = NVL(v_id_produtor, id_produtor),
                id_nivel_degradacao = NVL(v_id_nivel_degradacao, id_nivel_degradacao),
                nome_propriedade = NVL(v_nome_propriedade, nome_propriedade),
                latitude = NVL(v_latitude, latitude),
                longitude = NVL(v_longitude, longitude),
                area_hectares = NVL(v_area_hectares, area_hectares)
            WHERE id_propriedade = v_id_propriedade;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Propriedade com ID ' || v_id_propriedade || ' não encontrada para UPDATE.');
            END IF;
            v_mensagem := 'Propriedade rural atualizada com ID: ' || v_id_propriedade;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_propriedade IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID da propriedade é obrigatório para DELETE.');
            END IF;
            -- Adicionar lógica para deletar dependências (sensores, etc.)
            DELETE FROM GS_WW_PROPRIEDADE_RURAL WHERE id_propriedade = v_id_propriedade;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Propriedade com ID ' || v_id_propriedade || ' não encontrada para DELETE.');
            END IF;
            v_mensagem := 'Propriedade rural deletada com ID: ' || v_id_propriedade;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Propriedade Rural inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_PROPRIEDADE_RURAL (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_PROPRIEDADE_RURAL;

    PROCEDURE CRUD_SENSOR_IOT(
        v_operacao           IN VARCHAR2,
        v_id_sensor          IN OUT NOCOPY GS_WW_SENSOR_IOT.id_sensor%TYPE,
        v_id_propriedade     IN GS_WW_SENSOR_IOT.id_propriedade%TYPE DEFAULT NULL,
        v_id_tipo_sensor     IN GS_WW_SENSOR_IOT.id_tipo_sensor%TYPE DEFAULT NULL,
        v_modelo_dispositivo IN GS_WW_SENSOR_IOT.modelo_dispositivo%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_id_propriedade IS NULL OR v_id_tipo_sensor IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001, 'ID da Propriedade e ID do Tipo de Sensor são obrigatórios para INSERT de Sensor IoT.');
            END IF;
            INSERT INTO GS_WW_SENSOR_IOT (id_propriedade, id_tipo_sensor, modelo_dispositivo, data_instalacao)
            VALUES (v_id_propriedade, v_id_tipo_sensor, v_modelo_dispositivo, SYSDATE)
            RETURNING id_sensor INTO v_id_sensor; -- Modificado
            v_mensagem := 'Sensor IoT inserido com ID: ' || v_id_sensor;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_sensor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do sensor é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_SENSOR_IOT
            SET id_propriedade = NVL(v_id_propriedade, id_propriedade),
                id_tipo_sensor = NVL(v_id_tipo_sensor, id_tipo_sensor),
                modelo_dispositivo = NVL(v_modelo_dispositivo, modelo_dispositivo)
                -- data_instalacao geralmente não se atualiza, a menos que seja uma reinstalação.
            WHERE id_sensor = v_id_sensor;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Sensor com ID ' || v_id_sensor || ' não encontrado para UPDATE.');
            END IF;
            v_mensagem := 'Sensor IoT atualizado com ID: ' || v_id_sensor;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_sensor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do sensor é obrigatório para DELETE.');
            END IF;
            -- Adicionar lógica para deletar leituras associadas
            DELETE FROM GS_WW_SENSOR_IOT WHERE id_sensor = v_id_sensor;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Sensor com ID ' || v_id_sensor || ' não encontrado para DELETE.');
            END IF;
            v_mensagem := 'Sensor IoT deletado com ID: ' || v_id_sensor;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Sensor IoT inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_SENSOR_IOT (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_SENSOR_IOT;

    PROCEDURE CRUD_LEITURA_SENSOR(
        v_operacao          IN VARCHAR2,
        v_id_leitura        IN OUT NOCOPY GS_WW_LEITURA_SENSOR.id_leitura%TYPE,
        v_id_sensor         IN GS_WW_LEITURA_SENSOR.id_sensor%TYPE DEFAULT NULL,
        v_timestamp_leitura IN GS_WW_LEITURA_SENSOR.timestamp_leitura%TYPE DEFAULT CURRENT_TIMESTAMP,
        v_umidade_solo      IN GS_WW_LEITURA_SENSOR.umidade_solo%TYPE DEFAULT NULL,
        v_temperatura_ar    IN GS_WW_LEITURA_SENSOR.temperatura_ar%TYPE DEFAULT NULL,
        v_precipitacao_mm   IN GS_WW_LEITURA_SENSOR.precipitacao_mm%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_id_sensor IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001, 'ID do Sensor é obrigatório para INSERT de Leitura.');
            END IF;
            INSERT INTO GS_WW_LEITURA_SENSOR (id_sensor, timestamp_leitura, umidade_solo, temperatura_ar, precipitacao_mm)
            VALUES (v_id_sensor, NVL(v_timestamp_leitura, CURRENT_TIMESTAMP), v_umidade_solo, v_temperatura_ar, v_precipitacao_mm)
            RETURNING id_leitura INTO v_id_leitura; -- Modificado
            v_mensagem := 'Leitura de sensor inserida com ID: ' || v_id_leitura;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_leitura IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID da leitura é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_LEITURA_SENSOR
            SET id_sensor = NVL(v_id_sensor, id_sensor),
                timestamp_leitura = NVL(v_timestamp_leitura, timestamp_leitura),
                umidade_solo = NVL(v_umidade_solo, umidade_solo),
                temperatura_ar = NVL(v_temperatura_ar, temperatura_ar),
                precipitacao_mm = NVL(v_precipitacao_mm, precipitacao_mm)
            WHERE id_leitura = v_id_leitura;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Leitura com ID ' || v_id_leitura || ' não encontrada para UPDATE.');
            END IF;
            v_mensagem := 'Leitura de sensor atualizada com ID: ' || v_id_leitura;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_leitura IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID da leitura é obrigatório para DELETE.');
            END IF;
            DELETE FROM GS_WW_LEITURA_SENSOR WHERE id_leitura = v_id_leitura;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Leitura com ID ' || v_id_leitura || ' não encontrada para DELETE.');
            END IF;
            v_mensagem := 'Leitura de sensor deletada com ID: ' || v_id_leitura;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Leitura Sensor inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_LEITURA_SENSOR (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_LEITURA_SENSOR;

    PROCEDURE CRUD_ALERTA(
        v_operacao             IN VARCHAR2,
        v_id_alerta            IN OUT NOCOPY GS_WW_ALERTA.id_alerta%TYPE,
        v_id_produtor          IN GS_WW_ALERTA.id_produtor%TYPE DEFAULT NULL,
        v_id_leitura           IN GS_WW_ALERTA.id_leitura%TYPE DEFAULT NULL, -- Modificado de GS_WW_LEITURA_SENSOR para GS_WW_ALERTA
        v_id_nivel_severidade  IN GS_WW_ALERTA.id_nivel_severidade%TYPE DEFAULT NULL,
        v_timestamp_alerta     IN GS_WW_ALERTA.timestamp_alerta%TYPE DEFAULT CURRENT_TIMESTAMP,
        v_descricao_alerta     IN GS_WW_ALERTA.descricao_alerta%TYPE DEFAULT NULL
    ) IS
        v_mensagem VARCHAR2(255);
    BEGIN
        IF UPPER(v_operacao) = 'INSERT' THEN
            IF v_id_produtor IS NULL OR v_id_nivel_severidade IS NULL OR v_descricao_alerta IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001, 'ID do Produtor, ID Nível Severidade e Descrição são obrigatórios para INSERT de Alerta.');
            END IF;
            INSERT INTO GS_WW_ALERTA (id_produtor, id_leitura, id_nivel_severidade, timestamp_alerta, descricao_alerta)
            VALUES (v_id_produtor, v_id_leitura, v_id_nivel_severidade, NVL(v_timestamp_alerta, CURRENT_TIMESTAMP), v_descricao_alerta)
            RETURNING id_alerta INTO v_id_alerta; -- Modificado
            v_mensagem := 'Alerta inserido com ID: ' || v_id_alerta;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_alerta IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do alerta é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_ALERTA
            SET id_produtor = NVL(v_id_produtor, id_produtor),
                id_leitura = NVL(v_id_leitura, id_leitura),
                id_nivel_severidade = NVL(v_id_nivel_severidade, id_nivel_severidade),
                timestamp_alerta = NVL(v_timestamp_alerta, timestamp_alerta),
                descricao_alerta = NVL(v_descricao_alerta, descricao_alerta)
            WHERE id_alerta = v_id_alerta;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Alerta com ID ' || v_id_alerta || ' não encontrado para UPDATE.');
            END IF;
            v_mensagem := 'Alerta atualizado com ID: ' || v_id_alerta;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_alerta IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do alerta é obrigatório para DELETE.');
            END IF;
            DELETE FROM GS_WW_ALERTA WHERE id_alerta = v_id_alerta;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Alerta com ID ' || v_id_alerta || ' não encontrado para DELETE.');
            END IF;
            v_mensagem := 'Alerta deletado com ID: ' || v_id_alerta;
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'Operação CRUD para Alerta inválida: ' || v_operacao);
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro em CRUD_ALERTA (' || v_operacao || '): ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END CRUD_ALERTA;

-- ============================================================================
-- 2. IMPLEMENTAÇÃO DAS FUNÇÕES
-- ============================================================================
    -- Colar aqui as implementações das funções:
    -- CALCULAR_RISCO_ALAGAMENTO, CALCULAR_TAXA_DEGRADACAO_SOLO, CALCULAR_CAPACIDADE_ABSORCAO
    -- (Conforme fornecido no arquivo PKG_WATERWISE_FINAL.sql original)
    FUNCTION CALCULAR_RISCO_ALAGAMENTO(
        p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
    ) RETURN VARCHAR2 IS
        v_precipitacao_media    NUMBER(8,2);
        v_umidade_solo_media    NUMBER(5,2);
        v_nivel_degradacao      NUMBER(1);
        v_area_hectares         NUMBER(10,2);
        v_score_risco          NUMBER(5,2);
        v_nivel_risco          VARCHAR2(20);
        v_count_leituras       NUMBER;
    BEGIN
        SELECT pr.area_hectares, nd.nivel_numerico
        INTO v_area_hectares, v_nivel_degradacao
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        WHERE pr.id_propriedade = p_id_propriedade;
        
        SELECT AVG(ls.precipitacao_mm), AVG(ls.umidade_solo), COUNT(*)
        INTO v_precipitacao_media, v_umidade_solo_media, v_count_leituras
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        WHERE si.id_propriedade = p_id_propriedade
        AND ls.timestamp_leitura >= SYSDATE - 1;
        
        IF v_count_leituras = 0 OR v_precipitacao_media IS NULL THEN
            RETURN 'INDETERMINADO - Dados insuficientes';
        END IF;
        v_score_risco := 0;
        IF v_precipitacao_media > 50 THEN v_score_risco := v_score_risco + 40;
        ELSIF v_precipitacao_media > 25 THEN v_score_risco := v_score_risco + 25;
        ELSIF v_precipitacao_media > 10 THEN v_score_risco := v_score_risco + 15;
        ELSE v_score_risco := v_score_risco + 5; END IF;
        v_score_risco := v_score_risco + (v_nivel_degradacao * 6);
        IF v_umidade_solo_media > 80 THEN v_score_risco := v_score_risco + 20;
        ELSIF v_umidade_solo_media > 60 THEN v_score_risco := v_score_risco + 15;
        ELSIF v_umidade_solo_media > 40 THEN v_score_risco := v_score_risco + 10;
        ELSE v_score_risco := v_score_risco + 5; END IF;
        IF v_area_hectares < 50 THEN v_score_risco := v_score_risco + 10;
        ELSIF v_area_hectares < 150 THEN v_score_risco := v_score_risco + 6;
        ELSE v_score_risco := v_score_risco + 3; END IF;
        IF v_score_risco >= 80 THEN v_nivel_risco := 'CRÍTICO';
        ELSIF v_score_risco >= 60 THEN v_nivel_risco := 'ALTO';
        ELSIF v_score_risco >= 40 THEN v_nivel_risco := 'MÉDIO';
        ELSIF v_score_risco >= 20 THEN v_nivel_risco := 'BAIXO';
        ELSE v_nivel_risco := 'MÍNIMO'; END IF;
        RETURN v_nivel_risco || ' (' || ROUND(v_score_risco, 1) || '%)';
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'ERRO - Propriedade não encontrada'; WHEN OTHERS THEN RETURN 'ERRO - ' || SQLERRM;
    END CALCULAR_RISCO_ALAGAMENTO;

    FUNCTION CALCULAR_TAXA_DEGRADACAO_SOLO(
        p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
    ) RETURN VARCHAR2 IS
        v_nivel_atual           NUMBER(1); v_umidade_media         NUMBER(5,2);
        v_temperatura_media     NUMBER(4,1); v_precipitacao_total    NUMBER(8,2);
        v_dias_monitoramento    NUMBER; v_taxa_degradacao       NUMBER(8,4);
        v_tendencia            VARCHAR2(50); v_classificacao        VARCHAR2(100);
    BEGIN
        SELECT nd.nivel_numerico INTO v_nivel_atual
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        WHERE pr.id_propriedade = p_id_propriedade;
        SELECT AVG(ls.umidade_solo), AVG(ls.temperatura_ar), SUM(ls.precipitacao_mm),
               ROUND(SYSDATE - MIN(CAST(ls.timestamp_leitura AS DATE)))
        INTO v_umidade_media, v_temperatura_media, v_precipitacao_total, v_dias_monitoramento
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        WHERE si.id_propriedade = p_id_propriedade AND ls.timestamp_leitura >= SYSDATE - 30;
        IF v_dias_monitoramento < 7 OR v_umidade_media IS NULL THEN RETURN 'Dados insuficientes - Mínimo 7 dias de monitoramento'; END IF;
        CASE v_nivel_atual
            WHEN 1 THEN v_taxa_degradacao := 0.1; WHEN 2 THEN v_taxa_degradacao := 0.3;
            WHEN 3 THEN v_taxa_degradacao := 0.6; WHEN 4 THEN v_taxa_degradacao := 1.2;
            WHEN 5 THEN v_taxa_degradacao := 2.5; ELSE v_taxa_degradacao := 0.5; END CASE;
        IF v_umidade_media < 20 OR v_umidade_media > 85 THEN v_taxa_degradacao := v_taxa_degradacao * 1.5;
        ELSIF v_umidade_media < 30 OR v_umidade_media > 75 THEN v_taxa_degradacao := v_taxa_degradacao * 1.2;
        ELSIF v_umidade_media BETWEEN 40 AND 60 THEN v_taxa_degradacao := v_taxa_degradacao * 0.8; END IF;
        IF v_temperatura_media > 35 OR v_temperatura_media < 5 THEN v_taxa_degradacao := v_taxa_degradacao * 1.4;
        ELSIF v_temperatura_media > 30 OR v_temperatura_media < 10 THEN v_taxa_degradacao := v_taxa_degradacao * 1.1; END IF;
        IF v_precipitacao_total > 200 THEN v_taxa_degradacao := v_taxa_degradacao * 1.3;
        ELSIF v_precipitacao_total < 30 THEN v_taxa_degradacao := v_taxa_degradacao * 1.4;
        ELSIF v_precipitacao_total BETWEEN 60 AND 120 THEN v_taxa_degradacao := v_taxa_degradacao * 0.9; END IF;
        IF v_taxa_degradacao <= 0.2 THEN v_tendencia := 'ESTÁVEL/MELHORIA';
        ELSIF v_taxa_degradacao <= 0.5 THEN v_tendencia := 'DEGRADAÇÃO LENTA';
        ELSIF v_taxa_degradacao <= 1.0 THEN v_tendencia := 'DEGRADAÇÃO MODERADA';
        ELSIF v_taxa_degradacao <= 2.0 THEN v_tendencia := 'DEGRADAÇÃO ACELERADA';
        ELSE v_tendencia := 'DEGRADAÇÃO CRÍTICA'; END IF;
        v_classificacao := v_tendencia || ' - ' || ROUND(v_taxa_degradacao, 2) || '%/mês';
        RETURN v_classificacao;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'ERRO - Propriedade não encontrada'; WHEN OTHERS THEN RETURN 'ERRO - ' || SQLERRM;
    END CALCULAR_TAXA_DEGRADACAO_SOLO;

    FUNCTION CALCULAR_CAPACIDADE_ABSORCAO(
        p_id_propriedade IN GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE
    ) RETURN VARCHAR2 IS
        v_area_hectares         NUMBER(10,2); v_nivel_degradacao      NUMBER(1);
        v_umidade_atual         NUMBER(5,2); v_precipitacao_recente  NUMBER(8,2);
        v_capacidade_base       NUMBER(10,2); v_capacidade_atual      NUMBER(10,2);
        v_reducao_percentual    NUMBER(5,2); v_status_absorcao      VARCHAR2(100);
        v_count_sensores       NUMBER;
    BEGIN
        SELECT pr.area_hectares, nd.nivel_numerico INTO v_area_hectares, v_nivel_degradacao
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        WHERE pr.id_propriedade = p_id_propriedade;
        SELECT AVG(ls.umidade_solo), SUM(ls.precipitacao_mm), COUNT(DISTINCT si.id_sensor)
        INTO v_umidade_atual, v_precipitacao_recente, v_count_sensores
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        WHERE si.id_propriedade = p_id_propriedade AND ls.timestamp_leitura >= SYSDATE - 0.25;
        IF v_count_sensores = 0 OR v_umidade_atual IS NULL THEN RETURN 'SEM DADOS - Sensores não detectados'; END IF;
        CASE v_nivel_degradacao
            WHEN 1 THEN v_capacidade_base := 12000; WHEN 2 THEN v_capacidade_base := 9500;
            WHEN 3 THEN v_capacidade_base := 7000;  WHEN 4 THEN v_capacidade_base := 4500;
            WHEN 5 THEN v_capacidade_base := 3000;  ELSE v_capacidade_base := 6000; END CASE;
        IF v_umidade_atual >= 90 THEN v_reducao_percentual := 95;
        ELSIF v_umidade_atual >= 80 THEN v_reducao_percentual := 75;
        ELSIF v_umidade_atual >= 70 THEN v_reducao_percentual := 50;
        ELSIF v_umidade_atual >= 60 THEN v_reducao_percentual := 30;
        ELSIF v_umidade_atual >= 50 THEN v_reducao_percentual := 15;
        ELSIF v_umidade_atual >= 40 THEN v_reducao_percentual := 5;
        ELSE v_reducao_percentual := 0; END IF;
        v_capacidade_atual := v_capacidade_base * (100 - v_reducao_percentual) / 100;
        v_capacidade_atual := v_capacidade_atual * v_area_hectares;
        IF v_reducao_percentual >= 90 THEN v_status_absorcao := 'SATURADO - Risco Alto de Alagamento';
        ELSIF v_reducao_percentual >= 70 THEN v_status_absorcao := 'CAPACIDADE CRÍTICA - Monitoramento Urgente';
        ELSIF v_reducao_percentual >= 50 THEN v_status_absorcao := 'CAPACIDADE REDUZIDA - Atenção Necessária';
        ELSIF v_reducao_percentual >= 25 THEN v_status_absorcao := 'CAPACIDADE BOA - Funcionamento Normal';
        ELSE v_status_absorcao := 'CAPACIDADE EXCELENTE - Esponja Natural Ativa'; END IF;
        RETURN v_status_absorcao || ' - ' || ROUND(v_capacidade_atual/1000, 1) || 'k litros disponíveis (' || (100 - v_reducao_percentual) || '% da capacidade)';
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'ERRO - Propriedade não encontrada'; WHEN OTHERS THEN RETURN 'ERRO - ' || SQLERRM;
    END CALCULAR_CAPACIDADE_ABSORCAO;

-- ============================================================================
-- 3. IMPLEMENTAÇÃO DAS PROCEDURES DE ANÁLISE (Conforme PKG_WATERWISE_FINAL.sql)
-- ============================================================================
    -- Colar aqui as implementações das procedures:
    -- ANALISAR_ALERTAS_DIARIOS, VERIFICAR_RISCO_ENCHENTE, STATUS_SENSORES,
    -- RESUMO_DIARIO_SISTEMA, LISTAR_ALERTAS_RECENTES, ESTADO_GERAL_SOLO,
    -- PROPRIEDADES_RISCO_ENCHENTE
    PROCEDURE ANALISAR_ALERTAS_DIARIOS IS
        v_alertas_hoje          NUMBER; v_alertas_criticos      NUMBER;
        v_alertas_automaticos   NUMBER; v_primeiro_alerta       TIMESTAMP;
        v_ultimo_alerta         TIMESTAMP; v_situacao_dia          VARCHAR2(50);
        v_recomendacao          VARCHAR2(200);
    BEGIN
        SELECT COUNT(*), COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END),
               COUNT(CASE WHEN a.descricao_alerta LIKE 'ALERTA AUTOMÁTICO:%' THEN 1 END),
               MIN(a.timestamp_alerta), MAX(a.timestamp_alerta)
        INTO v_alertas_hoje, v_alertas_criticos, v_alertas_automaticos, v_primeiro_alerta, v_ultimo_alerta
        FROM GS_WW_ALERTA a
        LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        WHERE a.timestamp_alerta >= TRUNC(SYSDATE);
        DBMS_OUTPUT.PUT_LINE('=== ANÁLISE DE ALERTAS DE HOJE ===');
        DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY')); DBMS_OUTPUT.PUT_LINE(' ');
        IF v_alertas_hoje = 0 THEN
            DBMS_OUTPUT.PUT_LINE('✅ DIA TRANQUILO: Nenhum alerta hoje');
            DBMS_OUTPUT.PUT_LINE('Sistema funcionando normalmente');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Total de Alertas: ' || v_alertas_hoje);
            DBMS_OUTPUT.PUT_LINE('Alertas Críticos: ' || v_alertas_criticos);
            DBMS_OUTPUT.PUT_LINE('Alertas Automáticos: ' || v_alertas_automaticos);
            DBMS_OUTPUT.PUT_LINE('Primeiro Alerta: ' || TO_CHAR(v_primeiro_alerta, 'HH24:MI'));
            DBMS_OUTPUT.PUT_LINE('Último Alerta: ' || TO_CHAR(v_ultimo_alerta, 'HH24:MI')); DBMS_OUTPUT.PUT_LINE(' ');
            IF v_alertas_criticos >= 5 THEN v_situacao_dia := '🚨 DIA DE EMERGÊNCIA'; v_recomendacao := 'Ativar protocolo de emergência geral!';
            ELSIF v_alertas_criticos >= 2 THEN v_situacao_dia := '⚠️ DIA CRÍTICO'; v_recomendacao := 'Monitoramento intensivo necessário';
            ELSIF v_alertas_hoje >= 10 THEN v_situacao_dia := '🟨 DIA AGITADO'; v_recomendacao := 'Verificar causas dos múltiplos alertas';
            ELSIF v_alertas_automaticos = v_alertas_hoje THEN v_situacao_dia := '🤖 DIA AUTOMATIZADO'; v_recomendacao := 'Sistema inteligente funcionando bem';
            ELSE v_situacao_dia := '📊 DIA NORMAL'; v_recomendacao := 'Acompanhar alertas conforme necessário'; END IF;
            DBMS_OUTPUT.PUT_LINE('Situação: ' || v_situacao_dia); DBMS_OUTPUT.PUT_LINE('Recomendação: ' || v_recomendacao);
            IF v_alertas_criticos > 0 THEN DBMS_OUTPUT.PUT_LINE(' ');
                DBMS_OUTPUT.PUT_LINE('⚠️ ATENÇÃO ESPECIAL: ' || v_alertas_criticos || ' alertas críticos hoje!');
                DBMS_OUTPUT.PUT_LINE('Verificar propriedades em risco imediatamente');
            END IF;
        END IF;
    END ANALISAR_ALERTAS_DIARIOS;

    PROCEDURE VERIFICAR_RISCO_ENCHENTE(p_id_propriedade IN NUMBER DEFAULT NULL) IS
        CURSOR c_propriedades_risco IS
            SELECT pr.id_propriedade, pr.nome_propriedade, prod.nome_completo, prod.telefone,
                   AVG(ls.umidade_solo) as umidade_media, MAX(ls.precipitacao_mm) as precipitacao_max
            FROM GS_WW_PROPRIEDADE_RURAL pr
            JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
            JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
            JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
            WHERE (pr.id_propriedade = p_id_propriedade OR p_id_propriedade IS NULL)
              AND ls.timestamp_leitura >= SYSDATE - 0.25 -- Últimas 6 horas
            GROUP BY pr.id_propriedade, pr.nome_propriedade, prod.nome_completo, prod.telefone
            HAVING AVG(ls.umidade_solo) IS NOT NULL; -- Considerar apenas propriedades com dados de umidade

        v_prop_rec c_propriedades_risco%ROWTYPE;
        v_nivel_risco VARCHAR2(20);
        v_acao_recomendada VARCHAR2(200);
        v_count_processed NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== VERIFICAÇÃO DE RISCO DE ENCHENTE ===');
        IF p_id_propriedade IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Propriedade Específica ID: ' || p_id_propriedade);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Todas as Propriedades com Dados Recentes (últimas 6h)');
        END IF;
        DBMS_OUTPUT.PUT_LINE(' ');

        FOR v_prop_rec IN c_propriedades_risco LOOP
            v_count_processed := v_count_processed + 1;
            DBMS_OUTPUT.PUT_LINE('Propriedade: ' || v_prop_rec.nome_propriedade || ' (ID: ' || v_prop_rec.id_propriedade || ')');
            DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_prop_rec.nome_completo);
            DBMS_OUTPUT.PUT_LINE('Umidade Média: ' || ROUND(v_prop_rec.umidade_media, 1) || '%');
            DBMS_OUTPUT.PUT_LINE('Precipitação Máxima: ' || ROUND(NVL(v_prop_rec.precipitacao_max, 0), 1) || 'mm');
            
            IF v_prop_rec.umidade_media > 90 AND NVL(v_prop_rec.precipitacao_max, 0) > 50 THEN
                v_nivel_risco := 'EMERGÊNCIA'; v_acao_recomendada := 'Evacuar áreas baixas IMEDIATAMENTE!';
            ELSIF v_prop_rec.umidade_media > 85 OR NVL(v_prop_rec.precipitacao_max, 0) > 40 THEN
                v_nivel_risco := 'CRÍTICO'; v_acao_recomendada := 'Preparar evacuação e drenar área';
            ELSIF v_prop_rec.umidade_media > 70 OR NVL(v_prop_rec.precipitacao_max, 0) > 25 THEN
                v_nivel_risco := 'ALTO'; v_acao_recomendada := 'Monitorar de perto e preparar drenagem';
            ELSIF v_prop_rec.umidade_media > 50 OR NVL(v_prop_rec.precipitacao_max, 0) > 15 THEN
                v_nivel_risco := 'MÉDIO'; v_acao_recomendada := 'Continuar monitoramento normal';
            ELSE
                v_nivel_risco := 'BAIXO'; v_acao_recomendada := 'Situação normal, sem ações necessárias';
            END IF;
            DBMS_OUTPUT.PUT_LINE('🚨 NÍVEL DE RISCO: ' || v_nivel_risco);
            DBMS_OUTPUT.PUT_LINE('📞 Contato: ' || v_prop_rec.telefone);
            DBMS_OUTPUT.PUT_LINE('✅ Ação Recomendada: ' || v_acao_recomendada);
            DBMS_OUTPUT.PUT_LINE('-----------------------------------');
        END LOOP;

        IF v_count_processed = 0 THEN
            IF p_id_propriedade IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('❌ ERRO: Sem dados dos sensores nas últimas 6 horas para a propriedade ID ' || p_id_propriedade || ' ou propriedade não encontrada.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Nenhuma propriedade com dados de sensor suficientes nas últimas 6 horas encontrada.');
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('❌ ERRO: ' || SQLERRM);
    END VERIFICAR_RISCO_ENCHENTE;

    PROCEDURE STATUS_SENSORES IS
        v_total_sensores NUMBER; v_sensores_ativos NUMBER; v_sensores_inativos NUMBER;
        v_percentual_ativo NUMBER; v_status_sistema VARCHAR2(50); v_acao_necessaria VARCHAR2(200);
    BEGIN
        SELECT COUNT(*) INTO v_total_sensores FROM GS_WW_SENSOR_IOT;
        SELECT COUNT(DISTINCT si.id_sensor) INTO v_sensores_ativos
        FROM GS_WW_SENSOR_IOT si JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
        WHERE ls.timestamp_leitura >= SYSDATE - 7;
        v_sensores_inativos := v_total_sensores - v_sensores_ativos;
        DBMS_OUTPUT.PUT_LINE('=== STATUS DOS SENSORES WATERWISE ===');
        DBMS_OUTPUT.PUT_LINE('Período de Análise: 7 dias');
        DBMS_OUTPUT.PUT_LINE('Total de Sensores: ' || v_total_sensores);
        DBMS_OUTPUT.PUT_LINE('Sensores Ativos: ' || v_sensores_ativos);
        DBMS_OUTPUT.PUT_LINE('Sensores Inativos: ' || v_sensores_inativos); DBMS_OUTPUT.PUT_LINE(' ');
        IF v_total_sensores = 0 THEN
            DBMS_OUTPUT.PUT_LINE('❌ CRÍTICO: Nenhum sensor cadastrado no sistema!');
            DBMS_OUTPUT.PUT_LINE('Ação: Instalar sensores imediatamente');
        ELSE
            v_percentual_ativo := (v_sensores_ativos * 100) / v_total_sensores;
            DBMS_OUTPUT.PUT_LINE('Percentual Ativo: ' || ROUND(v_percentual_ativo, 1) || '%'); DBMS_OUTPUT.PUT_LINE(' ');
            IF v_percentual_ativo >= 90 THEN v_status_sistema := '✅ EXCELENTE'; v_acao_necessaria := 'Sistema funcionando perfeitamente';
            ELSIF v_percentual_ativo >= 75 THEN v_status_sistema := 'BOM'; v_acao_necessaria := 'Sistema funcionando bem, monitorar ' || v_sensores_inativos || ' sensores inativos';
            ELSIF v_percentual_ativo >= 50 THEN v_status_sistema := 'ATENÇÃO'; v_acao_necessaria := 'Verificar e reparar ' || v_sensores_inativos || ' sensores inativos';
            ELSIF v_percentual_ativo >= 25 THEN v_status_sistema := 'CRÍTICO'; v_acao_necessaria := 'URGENTE: ' || v_sensores_inativos || ' sensores inativos!';
            ELSE v_status_sistema := 'FALHA GERAL'; v_acao_necessaria := 'EMERGÊNCIA: Sistema de monitoramento falhou!'; END IF;
            DBMS_OUTPUT.PUT_LINE('Status do Sistema: ' || v_status_sistema);
            DBMS_OUTPUT.PUT_LINE('Ação: ' || v_acao_necessaria);
        END IF;
    END STATUS_SENSORES;

    PROCEDURE RESUMO_DIARIO_SISTEMA IS
        CURSOR c_resumo_diario IS SELECT COUNT(DISTINCT pr.id_propriedade) AS total_propriedades,
            COUNT(DISTINCT si.id_sensor) AS total_sensores, COUNT(DISTINCT ls.id_leitura) AS leituras_hoje,
            COUNT(DISTINCT a.id_alerta) AS alertas_hoje, AVG(ls.umidade_solo) AS umidade_media_hoje,
            AVG(ls.temperatura_ar) AS temperatura_media_hoje, SUM(ls.precipitacao_mm) AS chuva_total_hoje
        FROM GS_WW_PROPRIEDADE_RURAL pr
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor AND ls.timestamp_leitura >= TRUNC(SYSDATE)
        LEFT JOIN GS_WW_ALERTA a ON pr.id_produtor = a.id_produtor AND a.timestamp_alerta >= TRUNC(SYSDATE); -- Ligando alerta ao produtor
        v_resumo c_resumo_diario%ROWTYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RESUMO DIÁRIO DO SISTEMA WATERWISE ===');
        DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY')); DBMS_OUTPUT.PUT_LINE(' ');
        OPEN c_resumo_diario; FETCH c_resumo_diario INTO v_resumo; CLOSE c_resumo_diario;
        DBMS_OUTPUT.PUT_LINE('MÉTRICAS DO SISTEMA:');
        DBMS_OUTPUT.PUT_LINE('Propriedades Monitoradas: ' || NVL(v_resumo.total_propriedades,0));
        DBMS_OUTPUT.PUT_LINE('Sensores Instalados: ' || NVL(v_resumo.total_sensores,0));
        DBMS_OUTPUT.PUT_LINE('Leituras Hoje: ' || NVL(v_resumo.leituras_hoje,0));
        DBMS_OUTPUT.PUT_LINE('Alertas Hoje: ' || NVL(v_resumo.alertas_hoje,0)); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('CONDIÇÕES AMBIENTAIS HOJE:');
        IF v_resumo.umidade_media_hoje IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Umidade Média do Solo: ' || ROUND(v_resumo.umidade_media_hoje, 1) || '%'); END IF;
        IF v_resumo.temperatura_media_hoje IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Temperatura Média: ' || ROUND(v_resumo.temperatura_media_hoje, 1) || '°C'); END IF;
        IF v_resumo.chuva_total_hoje IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Chuva Total: ' || ROUND(v_resumo.chuva_total_hoje, 1) || 'mm'); END IF; DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('STATUS GERAL:');
        IF NVL(v_resumo.alertas_hoje,0) = 0 THEN DBMS_OUTPUT.PUT_LINE('✅ Sistema tranquilo - Nenhum alerta hoje');
        ELSIF NVL(v_resumo.alertas_hoje,0) <= 5 THEN DBMS_OUTPUT.PUT_LINE('⚠️ Sistema em monitoramento - ' || v_resumo.alertas_hoje || ' alertas hoje');
        ELSE DBMS_OUTPUT.PUT_LINE('🚨 Sistema em alerta - ' || v_resumo.alertas_hoje || ' alertas hoje - Atenção necessária'); END IF;
        IF NVL(v_resumo.leituras_hoje,0) < NVL(v_resumo.total_sensores,1) * 0.5 THEN DBMS_OUTPUT.PUT_LINE('⚠️ Baixa atividade dos sensores - Verificar funcionamento'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END RESUMO_DIARIO_SISTEMA;

    PROCEDURE LISTAR_ALERTAS_RECENTES IS
        CURSOR c_alertas_recentes IS SELECT a.timestamp_alerta, a.descricao_alerta, ns.codigo_severidade,
            prod.nome_completo AS produtor, prod.telefone, pr.nome_propriedade,
            ROUND(EXTRACT(DAY FROM (SYSDATE - a.timestamp_alerta)) * 24 + EXTRACT(HOUR FROM (SYSDATE - a.timestamp_alerta)) + EXTRACT(MINUTE FROM (SYSDATE - a.timestamp_alerta)) / 60, 1) AS horas_atras
        FROM GS_WW_ALERTA a
        JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        JOIN GS_WW_PRODUTOR_RURAL prod ON a.id_produtor = prod.id_produtor
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON a.id_leitura = ls.id_leitura
        LEFT JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON si.id_propriedade = pr.id_propriedade
        WHERE a.timestamp_alerta >= SYSDATE - 2 ORDER BY a.timestamp_alerta DESC;
        v_total_alertas NUMBER := 0; v_alertas_criticos NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ALERTAS RECENTES ==='); DBMS_OUTPUT.PUT_LINE('Últimas 48 horas'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR rec IN c_alertas_recentes LOOP v_total_alertas := v_total_alertas + 1;
            IF rec.codigo_severidade = 'CRITICO' THEN v_alertas_criticos := v_alertas_criticos + 1; END IF;
            DBMS_OUTPUT.PUT_LINE('SEVERIDADE: ' || rec.codigo_severidade); DBMS_OUTPUT.PUT_LINE('Descrição: ' || rec.descricao_alerta);
            DBMS_OUTPUT.PUT_LINE('Produtor: ' || rec.produtor); DBMS_OUTPUT.PUT_LINE('Telefone: ' || rec.telefone);
            IF rec.nome_propriedade IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Propriedade: ' || rec.nome_propriedade); END IF;
            DBMS_OUTPUT.PUT_LINE('Quando: ' || TO_CHAR(rec.timestamp_alerta, 'DD/MM/YYYY HH24:MI'));
            DBMS_OUTPUT.PUT_LINE('Há: ' || rec.horas_atras || ' horas'); DBMS_OUTPUT.PUT_LINE('----------------------------');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('=== RESUMO DE ALERTAS ==='); DBMS_OUTPUT.PUT_LINE('Total de Alertas: ' || v_total_alertas);
        DBMS_OUTPUT.PUT_LINE('Alertas Críticos: ' || v_alertas_criticos);
        IF v_alertas_criticos > 0 THEN DBMS_OUTPUT.PUT_LINE('ATENÇÃO: ' || v_alertas_criticos || ' alertas críticos precisam de ação imediata!'); END IF;
        IF v_total_alertas = 0 THEN DBMS_OUTPUT.PUT_LINE('Nenhum alerta nas últimas 48 horas - Sistema tranquilo'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END LISTAR_ALERTAS_RECENTES;

    PROCEDURE ESTADO_GERAL_SOLO IS
        CURSOR c_estado_solo IS SELECT CASE WHEN pr.latitude > -15 THEN 'NORTE' WHEN pr.latitude > -25 THEN 'CENTRO' ELSE 'SUL' END AS regiao,
            nd.descricao_degradacao, COUNT(*) AS quantidade_propriedades, SUM(pr.area_hectares) AS area_total,
            AVG(CASE WHEN ls.umidade_solo IS NOT NULL THEN ls.umidade_solo END) AS umidade_media
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor AND ls.timestamp_leitura >= SYSDATE - 1
        GROUP BY CASE WHEN pr.latitude > -15 THEN 'NORTE' WHEN pr.latitude > -25 THEN 'CENTRO' ELSE 'SUL' END, nd.descricao_degradacao, nd.nivel_numerico
        ORDER BY regiao, nd.nivel_numerico;
        v_solo c_estado_solo%ROWTYPE; v_regiao_anterior VARCHAR2(10) := '';
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ESTADO GERAL DO SOLO ==='); DBMS_OUTPUT.PUT_LINE('Por região geográfica'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR v_solo IN c_estado_solo LOOP
            IF v_solo.regiao != v_regiao_anterior THEN IF v_regiao_anterior != '' THEN DBMS_OUTPUT.PUT_LINE(' '); END IF;
                DBMS_OUTPUT.PUT_LINE('REGIÃO: ' || v_solo.regiao); DBMS_OUTPUT.PUT_LINE('=================='); v_regiao_anterior := v_solo.regiao;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Estado: ' || v_solo.descricao_degradacao);
            DBMS_OUTPUT.PUT_LINE('  Propriedades: ' || v_solo.quantidade_propriedades);
            DBMS_OUTPUT.PUT_LINE('  Área Total: ' || ROUND(NVL(v_solo.area_total,0), 1) || ' hectares');
            IF v_solo.umidade_media IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('  Umidade Média: ' || ROUND(v_solo.umidade_media, 1) || '%'); END IF;
            DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END ESTADO_GERAL_SOLO;

    PROCEDURE PROPRIEDADES_RISCO_ENCHENTE IS
        CURSOR c_risco_enchente IS SELECT pr.nome_propriedade, prod.nome_completo AS produtor, prod.telefone,
            AVG(ls.umidade_solo) AS umidade_media, MAX(ls.precipitacao_mm) AS chuva_maxima, nd.descricao_degradacao AS estado_solo,
            CASE WHEN AVG(ls.umidade_solo) > 85 AND MAX(ls.precipitacao_mm) > 50 THEN 'CRÍTICO'
                 WHEN AVG(ls.umidade_solo) > 70 OR MAX(ls.precipitacao_mm) > 30 THEN 'ALTO'
                 WHEN AVG(ls.umidade_solo) > 50 OR MAX(ls.precipitacao_mm) > 15 THEN 'MÉDIO'
                 ELSE 'BAIXO' END AS nivel_risco
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade -- Mudado para LEFT JOIN
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor -- Mudado para LEFT JOIN
        WHERE ls.timestamp_leitura >= SYSDATE - 1 OR ls.id_sensor IS NULL -- Considerar propriedades mesmo sem leituras recentes para listagem
        GROUP BY pr.nome_propriedade, prod.nome_completo, prod.telefone, nd.descricao_degradacao
        HAVING AVG(ls.umidade_solo) > 50 OR MAX(ls.precipitacao_mm) > 10 OR COUNT(ls.id_sensor)=0 -- Inclui props sem dados recentes ou com risco
        ORDER BY CASE WHEN AVG(ls.umidade_solo) IS NULL THEN 5 -- Prioridade menor para sem dados recentes
                      WHEN AVG(ls.umidade_solo) > 85 AND MAX(ls.precipitacao_mm) > 50 THEN 1
                      WHEN AVG(ls.umidade_solo) > 70 OR MAX(ls.precipitacao_mm) > 30 THEN 2
                      WHEN AVG(ls.umidade_solo) > 50 OR MAX(ls.precipitacao_mm) > 15 THEN 3
                      ELSE 4 END;
        v_propriedade c_risco_enchente%ROWTYPE; v_contador_critico NUMBER := 0;
        v_contador_alto NUMBER := 0; v_contador_medio NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PROPRIEDADES COM RISCO DE ENCHENTE ===');
        DBMS_OUTPUT.PUT_LINE('Análise das últimas 24 horas'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR v_propriedade IN c_risco_enchente LOOP
            IF v_propriedade.nivel_risco = 'CRÍTICO' THEN v_contador_critico := v_contador_critico + 1;
            ELSIF v_propriedade.nivel_risco = 'ALTO' THEN v_contador_alto := v_contador_alto + 1;
            ELSIF v_propriedade.nivel_risco = 'MÉDIO' THEN v_contador_medio := v_contador_medio + 1; END IF;
            DBMS_OUTPUT.PUT_LINE('RISCO: ' || NVL(v_propriedade.nivel_risco, 'DADOS INSUFICIENTES'));
            DBMS_OUTPUT.PUT_LINE('Propriedade: ' || v_propriedade.nome_propriedade);
            DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_propriedade.produtor); DBMS_OUTPUT.PUT_LINE('Telefone: ' || v_propriedade.telefone);
            DBMS_OUTPUT.PUT_LINE('Umidade Solo: ' || ROUND(NVL(v_propriedade.umidade_media,0), 1) || '%');
            DBMS_OUTPUT.PUT_LINE('Chuva Máxima: ' || ROUND(NVL(v_propriedade.chuva_maxima,0), 1) || 'mm');
            DBMS_OUTPUT.PUT_LINE('Estado do Solo: ' || v_propriedade.estado_solo); DBMS_OUTPUT.PUT_LINE('----------------------------');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('=== RESUMO ==='); DBMS_OUTPUT.PUT_LINE('CRÍTICO: ' || v_contador_critico || ' propriedades');
        DBMS_OUTPUT.PUT_LINE('ALTO: ' || v_contador_alto || ' propriedades'); DBMS_OUTPUT.PUT_LINE('MÉDIO: ' || v_contador_medio || ' propriedades');
        DBMS_OUTPUT.PUT_LINE('TOTAL EM RISCO IDENTIFICADO: ' || (v_contador_critico + v_contador_alto + v_contador_medio) || ' propriedades');
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END PROPRIEDADES_RISCO_ENCHENTE;

-- ============================================================================
-- 4. IMPLEMENTAÇÃO DAS PROCEDURES DE RELATÓRIOS EXECUTIVOS (Conforme PKG_WATERWISE_FINAL.sql)
-- ============================================================================
    -- Colar aqui as implementações das procedures:
    -- DASHBOARD_METRICAS, MELHORES_PRODUTORES, RISCO_POR_REGIAO, SEVERIDADE_ALERTAS,
    -- MONITORAMENTO_TEMPO_REAL, PRODUTIVIDADE_POR_REGIAO, TENDENCIAS_CLIMATICAS
    PROCEDURE DASHBOARD_METRICAS IS
        v_total_propriedades NUMBER; v_area_total NUMBER; v_sensores_ativos NUMBER; v_alertas_criticos NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== DASHBOARD DE MÉTRICAS ESTRATÉGICAS ===');
        DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI')); DBMS_OUTPUT.PUT_LINE(' ');
        SELECT COUNT(DISTINCT pr.id_propriedade), ROUND(SUM(pr.area_hectares), 0) INTO v_total_propriedades, v_area_total FROM GS_WW_PROPRIEDADE_RURAL pr;
        SELECT COUNT(DISTINCT si.id_sensor) INTO v_sensores_ativos FROM GS_WW_SENSOR_IOT si
        JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor WHERE ls.timestamp_leitura >= SYSDATE - 1;
        SELECT COUNT(a.id_alerta) INTO v_alertas_criticos FROM GS_WW_ALERTA a
        JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        WHERE a.timestamp_alerta >= SYSDATE - 1 AND ns.codigo_severidade = 'CRITICO';
        DBMS_OUTPUT.PUT_LINE('MÉTRICAS GERAIS'); DBMS_OUTPUT.PUT_LINE('===============');
        DBMS_OUTPUT.PUT_LINE('Total de Propriedades: ' || NVL(v_total_propriedades,0) || ' propriedades');
        DBMS_OUTPUT.PUT_LINE('Área Total Monitorada: ' || NVL(v_area_total,0) || ' hectares');
        DBMS_OUTPUT.PUT_LINE('Sensores Ativos (24h): ' || NVL(v_sensores_ativos,0) || ' sensores');
        DBMS_OUTPUT.PUT_LINE('Alertas Críticos (24h): ' || NVL(v_alertas_criticos,0) || ' alertas'); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('STATUS DAS MÉTRICAS'); DBMS_OUTPUT.PUT_LINE('==================');
        IF NVL(v_total_propriedades,0) >= 50 THEN DBMS_OUTPUT.PUT_LINE('Propriedades: EXCELENTE'); ELSIF NVL(v_total_propriedades,0) >= 20 THEN DBMS_OUTPUT.PUT_LINE('Propriedades: BOM');
        ELSIF NVL(v_total_propriedades,0) >= 10 THEN DBMS_OUTPUT.PUT_LINE('Propriedades: REGULAR'); ELSE DBMS_OUTPUT.PUT_LINE('Propriedades: INSUFICIENTE'); END IF;
        IF NVL(v_sensores_ativos,0) >= 100 THEN DBMS_OUTPUT.PUT_LINE('Sensores: EXCELENTE'); ELSIF NVL(v_sensores_ativos,0) >= 50 THEN DBMS_OUTPUT.PUT_LINE('Sensores: BOM');
        ELSIF NVL(v_sensores_ativos,0) >= 20 THEN DBMS_OUTPUT.PUT_LINE('Sensores: REGULAR'); ELSE DBMS_OUTPUT.PUT_LINE('Sensores: INSUFICIENTE'); END IF;
        IF NVL(v_alertas_criticos,0) = 0 THEN DBMS_OUTPUT.PUT_LINE('Alertas Críticos: EXCELENTE'); ELSIF NVL(v_alertas_criticos,0) <= 2 THEN DBMS_OUTPUT.PUT_LINE('Alertas Críticos: BOM');
        ELSIF NVL(v_alertas_criticos,0) <= 5 THEN DBMS_OUTPUT.PUT_LINE('Alertas Críticos: ATENÇÃO'); ELSE DBMS_OUTPUT.PUT_LINE('Alertas Críticos: CRÍTICO'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END DASHBOARD_METRICAS;

    PROCEDURE MELHORES_PRODUTORES IS
        CURSOR c_melhores_produtores IS SELECT prod.nome_completo AS produtor, prod.email,
            COUNT(DISTINCT pr.id_propriedade) AS total_propriedades, ROUND(SUM(pr.area_hectares), 1) AS area_total_hectares,
            COUNT(DISTINCT si.id_sensor) AS sensores_instalados, COUNT(a.id_alerta) AS total_alertas_90d,
            COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) AS alertas_criticos_90d,
            ROUND(AVG(nd.nivel_numerico), 2) AS nivel_medio_degradacao, COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) AS propriedades_solo_bom,
            COUNT(ls.id_leitura) AS total_leituras_30d,
            ROUND(100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                  (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
                  (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10), 1) AS score_eficiencia,
            CASE WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                       (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
                       (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 120 THEN 'PRODUTOR EXEMPLAR'
                 WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                       (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
                       (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 100 THEN 'PRODUTOR EFICIENTE'
                 WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                       (CASE WHEN COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade) * 7.5) END) -
                       (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 80 THEN 'PRODUTOR REGULAR'
                 ELSE 'PRODUTOR NECESSITA MELHORIA' END AS classificacao_final
        FROM GS_WW_PRODUTOR_RURAL prod
        LEFT JOIN GS_WW_PROPRIEDADE_RURAL pr ON prod.id_produtor = pr.id_produtor
        LEFT JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor AND ls.timestamp_leitura >= SYSDATE - 30
        LEFT JOIN GS_WW_ALERTA a ON prod.id_produtor = a.id_produtor AND a.timestamp_alerta >= SYSDATE - 90
        LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        GROUP BY prod.id_produtor, prod.nome_completo, prod.email
        ORDER BY score_eficiencia DESC, alertas_criticos_90d ASC, area_total_hectares DESC;
        v_produtor c_melhores_produtores%ROWTYPE; v_posicao NUMBER := 1;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RANKING DOS MELHORES PRODUTORES ===');
        DBMS_OUTPUT.PUT_LINE('Baseado em práticas sustentáveis e eficiência'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR v_produtor IN c_melhores_produtores LOOP
            DBMS_OUTPUT.PUT_LINE(v_posicao || 'º LUGAR - ' || v_produtor.classificacao_final);
            DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_produtor.produtor); DBMS_OUTPUT.PUT_LINE('Email: ' || v_produtor.email);
            DBMS_OUTPUT.PUT_LINE('Score de Eficiência: ' || NVL(v_produtor.score_eficiencia,0));
            DBMS_OUTPUT.PUT_LINE('Propriedades: ' || NVL(v_produtor.total_propriedades,0));
            DBMS_OUTPUT.PUT_LINE('Área Total: ' || NVL(v_produtor.area_total_hectares,0) || ' hectares');
            DBMS_OUTPUT.PUT_LINE('Sensores: ' || NVL(v_produtor.sensores_instalados,0));
            DBMS_OUTPUT.PUT_LINE('Alertas Críticos (90d): ' || NVL(v_produtor.alertas_criticos_90d,0));
            DBMS_OUTPUT.PUT_LINE('Propriedades Solo Bom: ' || NVL(v_produtor.propriedades_solo_bom,0));
            DBMS_OUTPUT.PUT_LINE('Leituras (30d): ' || NVL(v_produtor.total_leituras_30d,0));
            DBMS_OUTPUT.PUT_LINE('==========================================');
            v_posicao := v_posicao + 1; EXIT WHEN v_posicao > 10;
        END LOOP;
        IF v_posicao = 1 THEN DBMS_OUTPUT.PUT_LINE('Nenhum produtor encontrado para o ranking.'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END MELHORES_PRODUTORES;

    PROCEDURE RISCO_POR_REGIAO IS
        CURSOR c_risco_regiao IS SELECT CASE WHEN pr.latitude > -10 THEN 'REGIÃO NORTE' WHEN pr.latitude > -20 THEN 'REGIÃO NORDESTE'
            WHEN pr.latitude > -30 THEN 'REGIÃO CENTRO-SUL' ELSE 'REGIÃO SUL' END AS regiao_geografica,
            COUNT(DISTINCT pr.id_propriedade) AS total_propriedades, COUNT(DISTINCT prod.id_produtor) AS total_produtores,
            ROUND(SUM(pr.area_hectares), 1) AS area_total_hectares, ROUND(AVG(pr.area_hectares), 1) AS area_media_hectares,
            COUNT(DISTINCT si.id_sensor) AS sensores_instalados, ROUND(AVG(ls.umidade_solo), 1) AS umidade_media_regiao,
            ROUND(AVG(ls.temperatura_ar), 1) AS temperatura_media, ROUND(SUM(ls.precipitacao_mm), 1) AS precipitacao_total_24h,
            ROUND(AVG(nd.nivel_numerico), 2) AS nivel_degradacao_medio, COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) AS propriedades_solo_degradado,
            COUNT(DISTINCT a.id_alerta) AS total_alertas_7d, COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) AS alertas_criticos_7d,
            ROUND((NVL(AVG(ls.umidade_solo),0) * 0.4 + NVL(AVG(nd.nivel_numerico),0) * 20 * 0.3 + (NVL(SUM(ls.precipitacao_mm),0) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) / 10) * 0.3), 1) AS score_risco_regional, -- Ajuste na precipitação para ser média por propriedade
            CASE WHEN (NVL(AVG(ls.umidade_solo),0) * 0.4 + NVL(AVG(nd.nivel_numerico),0) * 20 * 0.3 + (NVL(SUM(ls.precipitacao_mm),0) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) / 10) * 0.3) >= 80 THEN 'CRÍTICO'
                 WHEN (NVL(AVG(ls.umidade_solo),0) * 0.4 + NVL(AVG(nd.nivel_numerico),0) * 20 * 0.3 + (NVL(SUM(ls.precipitacao_mm),0) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) / 10) * 0.3) >= 60 THEN 'ALTO'
                 WHEN (NVL(AVG(ls.umidade_solo),0) * 0.4 + NVL(AVG(nd.nivel_numerico),0) * 20 * 0.3 + (NVL(SUM(ls.precipitacao_mm),0) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) / 10) * 0.3) >= 40 THEN 'MÉDIO'
                 ELSE 'BAIXO' END AS classificacao_risco_regional
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor AND ls.timestamp_leitura >= SYSDATE - 1
        LEFT JOIN GS_WW_ALERTA a ON prod.id_produtor = a.id_produtor AND a.timestamp_alerta >= SYSDATE - 7
        LEFT JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        GROUP BY CASE WHEN pr.latitude > -10 THEN 'REGIÃO NORTE' WHEN pr.latitude > -20 THEN 'REGIÃO NORDESTE'
                      WHEN pr.latitude > -30 THEN 'REGIÃO CENTRO-SUL' ELSE 'REGIÃO SUL' END
        ORDER BY score_risco_regional DESC, total_propriedades DESC;
        v_regiao c_risco_regiao%ROWTYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ANÁLISE DE RISCO POR REGIÃO ===');
        DBMS_OUTPUT.PUT_LINE('Relatório executivo de propriedades em risco'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR v_regiao IN c_risco_regiao LOOP
            DBMS_OUTPUT.PUT_LINE('REGIÃO: ' || v_regiao.regiao_geografica);
            DBMS_OUTPUT.PUT_LINE('Classificação de Risco: ' || v_regiao.classificacao_risco_regional);
            DBMS_OUTPUT.PUT_LINE('Score de Risco: ' || NVL(v_regiao.score_risco_regional,0)); DBMS_OUTPUT.PUT_LINE('-----------------------------------');
            DBMS_OUTPUT.PUT_LINE('Propriedades: ' || v_regiao.total_propriedades); DBMS_OUTPUT.PUT_LINE('Produtores: ' || v_regiao.total_produtores);
            DBMS_OUTPUT.PUT_LINE('Área Total: ' || NVL(v_regiao.area_total_hectares,0) || ' hectares'); DBMS_OUTPUT.PUT_LINE('Sensores: ' || NVL(v_regiao.sensores_instalados,0));
            IF v_regiao.umidade_media_regiao IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Umidade Média: ' || v_regiao.umidade_media_regiao || '%'); END IF;
            IF v_regiao.temperatura_media IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Temperatura Média: ' || v_regiao.temperatura_media || '°C'); END IF;
            IF v_regiao.precipitacao_total_24h IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Chuva (24h): ' || v_regiao.precipitacao_total_24h || 'mm'); END IF;
            DBMS_OUTPUT.PUT_LINE('Solo Degradado: ' || NVL(v_regiao.propriedades_solo_degradado,0) || ' propriedades');
            DBMS_OUTPUT.PUT_LINE('Alertas (7d): ' || NVL(v_regiao.total_alertas_7d,0));
            DBMS_OUTPUT.PUT_LINE('Alertas Críticos (7d): ' || NVL(v_regiao.alertas_criticos_7d,0));
            DBMS_OUTPUT.PUT_LINE('======================================='); DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END RISCO_POR_REGIAO;

    PROCEDURE SEVERIDADE_ALERTAS IS
        CURSOR c_severidade IS SELECT ns.id_nivel_severidade, ns.codigo_severidade, ns.descricao_severidade, ns.acoes_recomendadas,
            COUNT(a.id_alerta) AS total_alertas_historico, COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 30 THEN 1 END) AS alertas_30_dias,
            COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 7 THEN 1 END) AS alertas_7_dias, COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 1 THEN 1 END) AS alertas_24_horas,
            COUNT(DISTINCT a.id_produtor) AS produtores_alertados, MIN(a.timestamp_alerta) AS primeiro_alerta_tipo, MAX(a.timestamp_alerta) AS ultimo_alerta_tipo,
            ROUND((COUNT(a.id_alerta) * 100.0) / NULLIF((SELECT COUNT(*) FROM GS_WW_ALERTA), 0), 2) AS percentual_uso,
            CASE WHEN COUNT(a.id_alerta) = 0 THEN 'NUNCA USADO' WHEN COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 7 THEN 1 END) >= 5 THEN 'USO FREQUENTE'
                 WHEN COUNT(CASE WHEN a.timestamp_alerta >= SYSDATE - 30 THEN 1 END) >= 5 THEN 'USO REGULAR'
                 WHEN COUNT(a.id_alerta) >= 10 THEN 'USO OCASIONAL' ELSE 'USO RARO' END AS frequencia_uso,
            CASE WHEN ns.codigo_severidade = 'CRITICO' AND COUNT(a.id_alerta) = 0 THEN 'BOM - SEM EMERGÊNCIAS'
                 WHEN ns.codigo_severidade = 'CRITICO' AND COUNT(a.id_alerta) > 10 THEN 'PREOCUPANTE - MUITAS EMERGÊNCIAS'
                 WHEN COUNT(a.id_alerta) = 0 THEN 'NÃO UTILIZADO' ELSE 'EM USO NORMAL' END AS status_severidade
        FROM GS_WW_NIVEL_SEVERIDADE ns LEFT JOIN GS_WW_ALERTA a ON ns.id_nivel_severidade = a.id_nivel_severidade -- Mudado para LEFT JOIN
        GROUP BY ns.id_nivel_severidade, ns.codigo_severidade, ns.descricao_severidade, ns.acoes_recomendadas
        ORDER BY CASE ns.codigo_severidade WHEN 'CRITICO' THEN 1 WHEN 'ALTO' THEN 2 WHEN 'MEDIO' THEN 3 WHEN 'BAIXO' THEN 4 ELSE 5 END, total_alertas_historico DESC;
        v_severidade c_severidade%ROWTYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RELATÓRIO DE SEVERIDADE DOS ALERTAS ===');
        DBMS_OUTPUT.PUT_LINE('Análise de uso dos níveis de severidade'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR v_severidade IN c_severidade LOOP
            DBMS_OUTPUT.PUT_LINE('NÍVEL: ' || v_severidade.codigo_severidade); DBMS_OUTPUT.PUT_LINE('Descrição: ' || v_severidade.descricao_severidade);
            DBMS_OUTPUT.PUT_LINE('Status: ' || v_severidade.status_severidade); DBMS_OUTPUT.PUT_LINE('Frequência: ' || v_severidade.frequencia_uso);
            DBMS_OUTPUT.PUT_LINE('-----------------------------------');
            DBMS_OUTPUT.PUT_LINE('Total Histórico: ' || v_severidade.total_alertas_historico);
            DBMS_OUTPUT.PUT_LINE('Últimos 30 dias: ' || v_severidade.alertas_30_dias); DBMS_OUTPUT.PUT_LINE('Últimos 7 dias: ' || v_severidade.alertas_7_dias);
            DBMS_OUTPUT.PUT_LINE('Últimas 24h: ' || v_severidade.alertas_24_horas); DBMS_OUTPUT.PUT_LINE('Produtores Alertados: ' || v_severidade.produtores_alertados);
            DBMS_OUTPUT.PUT_LINE('Percentual de Uso: ' || NVL(v_severidade.percentual_uso, 0) || '%');
            IF v_severidade.primeiro_alerta_tipo IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('Primeiro Alerta: ' || TO_CHAR(v_severidade.primeiro_alerta_tipo, 'DD/MM/YYYY'));
                DBMS_OUTPUT.PUT_LINE('Último Alerta: ' || TO_CHAR(v_severidade.ultimo_alerta_tipo, 'DD/MM/YYYY'));
            END IF;
            DBMS_OUTPUT.PUT_LINE('Ações Recomendadas: ' || v_severidade.acoes_recomendadas);
            DBMS_OUTPUT.PUT_LINE('======================================='); DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END SEVERIDADE_ALERTAS;

    PROCEDURE MONITORAMENTO_TEMPO_REAL IS
        CURSOR c_monitoramento_real IS SELECT pr.nome_propriedade, prod.nome_completo AS produtor, prod.telefone,
            ls.timestamp_leitura, ls.umidade_solo, ls.temperatura_ar, ls.precipitacao_mm,
            CASE WHEN ls.umidade_solo > 90 OR ls.precipitacao_mm > 50 THEN 'CRÍTICO'
                 WHEN ls.umidade_solo > 80 OR ls.precipitacao_mm > 30 THEN 'ALTO'
                 WHEN ls.umidade_solo < 20 OR ls.temperatura_ar > 40 THEN 'ATENÇÃO'
                 ELSE 'NORMAL' END AS status_atual,
            ROUND(EXTRACT(DAY FROM (SYSDATE - ls.timestamp_leitura)) * 24 * 60 + EXTRACT(HOUR FROM (SYSDATE - ls.timestamp_leitura)) * 60 + EXTRACT(MINUTE FROM (SYSDATE - ls.timestamp_leitura)), 1) AS minutos_atras
        FROM GS_WW_LEITURA_SENSOR ls
        JOIN GS_WW_SENSOR_IOT si ON ls.id_sensor = si.id_sensor
        JOIN GS_WW_PROPRIEDADE_RURAL pr ON si.id_propriedade = pr.id_propriedade
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        WHERE ls.timestamp_leitura >= SYSDATE - 1/24 ORDER BY ls.timestamp_leitura DESC;
        v_contador_critico NUMBER := 0; v_contador_alto NUMBER := 0; v_contador_atencao NUMBER := 0; v_contador_normal NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== MONITORAMENTO EM TEMPO REAL ==='); DBMS_OUTPUT.PUT_LINE('Leituras da última hora');
        DBMS_OUTPUT.PUT_LINE('Atualizado: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS')); DBMS_OUTPUT.PUT_LINE(' ');
        FOR rec IN c_monitoramento_real LOOP
            CASE rec.status_atual WHEN 'CRÍTICO' THEN v_contador_critico := v_contador_critico + 1;
                                 WHEN 'ALTO' THEN v_contador_alto := v_contador_alto + 1;
                                 WHEN 'ATENÇÃO' THEN v_contador_atencao := v_contador_atencao + 1;
                                 ELSE v_contador_normal := v_contador_normal + 1; END CASE;
            IF rec.status_atual IN ('CRÍTICO', 'ALTO') THEN
                DBMS_OUTPUT.PUT_LINE('🚨 STATUS: ' || rec.status_atual); DBMS_OUTPUT.PUT_LINE('Propriedade: ' || rec.nome_propriedade);
                DBMS_OUTPUT.PUT_LINE('Produtor: ' || rec.produtor); DBMS_OUTPUT.PUT_LINE('Contato: ' || rec.telefone);
                DBMS_OUTPUT.PUT_LINE('Umidade: ' || rec.umidade_solo || '%'); DBMS_OUTPUT.PUT_LINE('Temperatura: ' || rec.temperatura_ar || '°C');
                DBMS_OUTPUT.PUT_LINE('Chuva: ' || rec.precipitacao_mm || 'mm'); DBMS_OUTPUT.PUT_LINE('Há: ' || rec.minutos_atras || ' minutos');
                DBMS_OUTPUT.PUT_LINE('----------------------------');
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' '); DBMS_OUTPUT.PUT_LINE('=== RESUMO DO MONITORAMENTO ===');
        DBMS_OUTPUT.PUT_LINE('🚨 Situações Críticas: ' || v_contador_critico); DBMS_OUTPUT.PUT_LINE('⚠️ Alto Risco: ' || v_contador_alto);
        DBMS_OUTPUT.PUT_LINE('📊 Atenção: ' || v_contador_atencao); DBMS_OUTPUT.PUT_LINE('✅ Normal: ' || v_contador_normal);
        DBMS_OUTPUT.PUT_LINE('TOTAL: ' || (v_contador_critico + v_contador_alto + v_contador_atencao + v_contador_normal) || ' leituras na última hora');
        IF v_contador_critico > 0 THEN DBMS_OUTPUT.PUT_LINE(' '); DBMS_OUTPUT.PUT_LINE('⚡ AÇÃO IMEDIATA NECESSÁRIA: ' || v_contador_critico || ' situações críticas detectadas!'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END MONITORAMENTO_TEMPO_REAL;

    PROCEDURE PRODUTIVIDADE_POR_REGIAO IS
        CURSOR c_produtividade IS SELECT CASE WHEN pr.latitude > -15 THEN 'NORTE' WHEN pr.latitude > -25 THEN 'CENTRO' ELSE 'SUL' END AS regiao,
            COUNT(DISTINCT pr.id_propriedade) AS total_propriedades, ROUND(SUM(pr.area_hectares), 1) AS area_total,
            ROUND(AVG(pr.area_hectares), 1) AS area_media, COUNT(DISTINCT si.id_sensor) AS total_sensores,
            ROUND(COUNT(DISTINCT si.id_sensor) / COUNT(DISTINCT pr.id_propriedade), 2) AS sensores_por_propriedade,
            COUNT(ls.id_leitura) AS leituras_mes, ROUND(COUNT(ls.id_leitura) / COUNT(DISTINCT pr.id_propriedade), 1) AS leituras_por_propriedade,
            COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) AS propriedades_solo_bom,
            ROUND((COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 100.0) / COUNT(DISTINCT pr.id_propriedade), 1) AS percentual_solo_bom,
            COUNT(DISTINCT a.id_alerta) AS alertas_mes, ROUND(AVG(ls.umidade_solo), 1) AS umidade_media,
            ROUND(AVG(ls.temperatura_ar), 1) AS temperatura_media,
            ROUND((COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 20) +
                  (CASE WHEN COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) >= 2 THEN 30 ELSE (COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) * 15) END) +
                  (CASE WHEN COUNT(ls.id_leitura) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) >= 50 THEN 25 ELSE (COUNT(ls.id_leitura) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) * 0.5) END) +
                  (25 - LEAST(COUNT(DISTINCT a.id_alerta), 25)), 1) AS indice_produtividade
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor AND ls.timestamp_leitura >= SYSDATE - 30
        LEFT JOIN GS_WW_ALERTA a ON prod.id_produtor = a.id_produtor AND a.timestamp_alerta >= SYSDATE - 30
        GROUP BY CASE WHEN pr.latitude > -15 THEN 'NORTE' WHEN pr.latitude > -25 THEN 'CENTRO' ELSE 'SUL' END
        ORDER BY indice_produtividade DESC;
        v_prod c_produtividade%ROWTYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RELATÓRIO DE PRODUTIVIDADE POR REGIÃO ===');
        DBMS_OUTPUT.PUT_LINE('Análise de eficiência e sustentabilidade'); DBMS_OUTPUT.PUT_LINE('Período: Últimos 30 dias'); DBMS_OUTPUT.PUT_LINE(' ');
        FOR v_prod IN c_produtividade LOOP
            DBMS_OUTPUT.PUT_LINE('REGIÃO: ' || v_prod.regiao);
            DBMS_OUTPUT.PUT_LINE('Índice de Produtividade: ' || NVL(v_prod.indice_produtividade,0) || '/100');
            IF NVL(v_prod.indice_produtividade,0) >= 80 THEN DBMS_OUTPUT.PUT_LINE('Classificação: 🏆 REGIÃO EXEMPLAR');
            ELSIF NVL(v_prod.indice_produtividade,0) >= 60 THEN DBMS_OUTPUT.PUT_LINE('Classificação: ✅ REGIÃO EFICIENTE');
            ELSIF NVL(v_prod.indice_produtividade,0) >= 40 THEN DBMS_OUTPUT.PUT_LINE('Classificação: ⚠️ REGIÃO EM DESENVOLVIMENTO');
            ELSE DBMS_OUTPUT.PUT_LINE('Classificação: 🔧 REGIÃO NECESSITA MELHORIA'); END IF;
            DBMS_OUTPUT.PUT_LINE('-----------------------------------');
            DBMS_OUTPUT.PUT_LINE('Propriedades: ' || NVL(v_prod.total_propriedades,0));
            DBMS_OUTPUT.PUT_LINE('Área Total: ' || NVL(v_prod.area_total,0) || ' hectares');
            DBMS_OUTPUT.PUT_LINE('Área Média: ' || NVL(v_prod.area_media,0) || ' hectares/propriedade');
            DBMS_OUTPUT.PUT_LINE('Sensores: ' || NVL(v_prod.total_sensores,0) || ' (' || NVL(v_prod.sensores_por_propriedade,0) || '/propriedade)');
            DBMS_OUTPUT.PUT_LINE('Leituras (30d): ' || NVL(v_prod.leituras_mes,0) || ' (' || NVL(v_prod.leituras_por_propriedade,0) || '/propriedade)');
            DBMS_OUTPUT.PUT_LINE('Solo Bom: ' || NVL(v_prod.propriedades_solo_bom,0) || ' (' || NVL(v_prod.percentual_solo_bom,0) || '%)');
            DBMS_OUTPUT.PUT_LINE('Alertas (30d): ' || NVL(v_prod.alertas_mes,0));
            IF v_prod.umidade_media IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Umidade Média: ' || v_prod.umidade_media || '%'); END IF;
            IF v_prod.temperatura_media IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('Temperatura Média: ' || v_prod.temperatura_media || '°C'); END IF;
            DBMS_OUTPUT.PUT_LINE('======================================='); DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END PRODUTIVIDADE_POR_REGIAO;

    PROCEDURE TENDENCIAS_CLIMATICAS(p_dias_analise IN NUMBER DEFAULT 30) IS
        CURSOR c_tendencias IS SELECT TRUNC(ls.timestamp_leitura) AS data_leitura, COUNT(ls.id_leitura) AS total_leituras,
            ROUND(AVG(ls.umidade_solo), 1) AS umidade_media_dia, ROUND(MIN(ls.umidade_solo), 1) AS umidade_minima, ROUND(MAX(ls.umidade_solo), 1) AS umidade_maxima,
            ROUND(AVG(ls.temperatura_ar), 1) AS temperatura_media_dia, ROUND(MIN(ls.temperatura_ar), 1) AS temperatura_minima, ROUND(MAX(ls.temperatura_ar), 1) AS temperatura_maxima,
            ROUND(SUM(ls.precipitacao_mm), 1) AS precipitacao_total_dia, ROUND(MAX(ls.precipitacao_mm), 1) AS precipitacao_maxima_pontual,
            COUNT(CASE WHEN ls.umidade_solo > 85 THEN 1 END) AS leituras_solo_saturado, COUNT(CASE WHEN ls.temperatura_ar > 35 THEN 1 END) AS leituras_calor_extremo,
            COUNT(CASE WHEN ls.precipitacao_mm > 50 THEN 1 END) AS eventos_chuva_intensa
        FROM GS_WW_LEITURA_SENSOR ls WHERE ls.timestamp_leitura >= SYSDATE - p_dias_analise
        GROUP BY TRUNC(ls.timestamp_leitura) ORDER BY data_leitura DESC;
        v_tend c_tendencias%ROWTYPE; v_total_dias NUMBER := 0; v_dias_risco NUMBER := 0;
        v_precipitacao_acumulada NUMBER := 0; v_temp_media_periodo NUMBER := 0; v_umidade_media_periodo NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ANÁLISE DE TENDÊNCIAS CLIMÁTICAS ===');
        DBMS_OUTPUT.PUT_LINE('Período de Análise: ' || p_dias_analise || ' dias');
        DBMS_OUTPUT.PUT_LINE('Data da Análise: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY')); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('TENDÊNCIAS DIÁRIAS:'); DBMS_OUTPUT.PUT_LINE('===================');
        FOR v_tend IN c_tendencias LOOP v_total_dias := v_total_dias + 1;
            v_precipitacao_acumulada := v_precipitacao_acumulada + NVL(v_tend.precipitacao_total_dia,0);
            v_temp_media_periodo := v_temp_media_periodo + NVL(v_tend.temperatura_media_dia,0);
            v_umidade_media_periodo := v_umidade_media_periodo + NVL(v_tend.umidade_media_dia,0);
            IF v_tend.leituras_solo_saturado > 0 OR v_tend.eventos_chuva_intensa > 0 OR v_tend.leituras_calor_extremo > 0 THEN
                v_dias_risco := v_dias_risco + 1;
                DBMS_OUTPUT.PUT_LINE('⚠️ DIA DE RISCO: ' || TO_CHAR(v_tend.data_leitura, 'DD/MM/YYYY'));
                DBMS_OUTPUT.PUT_LINE('   Umidade: ' || v_tend.umidade_minima || '-' || v_tend.umidade_maxima || '% (média: ' || v_tend.umidade_media_dia || '%)');
                DBMS_OUTPUT.PUT_LINE('   Temperatura: ' || v_tend.temperatura_minima || '-' || v_tend.temperatura_maxima || '°C (média: ' || v_tend.temperatura_media_dia || '°C)');
                DBMS_OUTPUT.PUT_LINE('   Chuva: ' || v_tend.precipitacao_total_dia || 'mm (máx pontual: ' || v_tend.precipitacao_maxima_pontual || 'mm)');
                IF v_tend.leituras_solo_saturado > 0 THEN DBMS_OUTPUT.PUT_LINE('   🚨 Solo saturado em ' || v_tend.leituras_solo_saturado || ' leituras'); END IF;
                IF v_tend.eventos_chuva_intensa > 0 THEN DBMS_OUTPUT.PUT_LINE('   🌧️ ' || v_tend.eventos_chuva_intensa || ' eventos de chuva intensa'); END IF;
                IF v_tend.leituras_calor_extremo > 0 THEN DBMS_OUTPUT.PUT_LINE('   🔥 ' || v_tend.leituras_calor_extremo || ' leituras de calor extremo'); END IF;
                DBMS_OUTPUT.PUT_LINE(' ');
            END IF;
            EXIT WHEN c_tendencias%ROWCOUNT >= 10;
        END LOOP;
        IF v_total_dias > 0 THEN v_temp_media_periodo := v_temp_media_periodo / v_total_dias; v_umidade_media_periodo := v_umidade_media_periodo / v_total_dias; END IF;
        DBMS_OUTPUT.PUT_LINE('RESUMO DO PERÍODO (' || p_dias_analise || ' DIAS):'); DBMS_OUTPUT.PUT_LINE('=====================================');
        DBMS_OUTPUT.PUT_LINE('Dias com Dados: ' || v_total_dias);
        DBMS_OUTPUT.PUT_LINE('Dias de Risco: ' || v_dias_risco || ' (' || ROUND((v_dias_risco * 100.0) / GREATEST(v_total_dias, 1), 1) || '%)');
        DBMS_OUTPUT.PUT_LINE('Precipitação Acumulada: ' || ROUND(v_precipitacao_acumulada, 1) || 'mm');
        DBMS_OUTPUT.PUT_LINE('Temperatura Média: ' || ROUND(v_temp_media_periodo, 1) || '°C');
        DBMS_OUTPUT.PUT_LINE('Umidade Média: ' || ROUND(v_umidade_media_periodo, 1) || '%');
        DBMS_OUTPUT.PUT_LINE(' '); DBMS_OUTPUT.PUT_LINE('AVALIAÇÃO GERAL:');
        IF v_dias_risco = 0 THEN DBMS_OUTPUT.PUT_LINE('✅ PERÍODO ESTÁVEL - Nenhum dia de risco identificado');
        ELSIF (v_dias_risco * 100.0) / GREATEST(v_total_dias, 1) <= 10 THEN DBMS_OUTPUT.PUT_LINE('⚠️ PERÍODO NORMAL - Poucos dias de risco');
        ELSIF (v_dias_risco * 100.0) / GREATEST(v_total_dias, 1) <= 30 THEN DBMS_OUTPUT.PUT_LINE('🟨 PERÍODO INSTÁVEL - Vários dias de risco');
        ELSE DBMS_OUTPUT.PUT_LINE('🚨 PERÍODO CRÍTICO - Muitos dias de risco'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END TENDENCIAS_CLIMATICAS;

-- ============================================================================
-- 5. IMPLEMENTAÇÃO DAS PROCEDURES UTILITÁRIAS (Conforme PKG_WATERWISE_FINAL.sql)
-- ============================================================================

    PROCEDURE INICIALIZAR_SISTEMA IS
        v_id_temp NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== INICIALIZANDO SISTEMA WATERWISE ===');
        BEGIN
            PKG_WATERWISE.CRUD_TIPO_SENSOR('INSERT', v_id_temp, 'Sensor de Umidade do Solo', 'Sensor capacitivo para medição da umidade do solo', '%', 0, 100);
            PKG_WATERWISE.CRUD_TIPO_SENSOR('INSERT', v_id_temp, 'Sensor de Temperatura', 'Sensor digital para medição da temperatura ambiente', '°C', -40, 85);
            PKG_WATERWISE.CRUD_TIPO_SENSOR('INSERT', v_id_temp, 'Sensor de Precipitação', 'Pluviômetro digital para medição de chuva', 'mm', 0, 500);
        EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Tipos de sensores já existem ou erro: ' || SQLERRM); END;
        BEGIN
            PKG_WATERWISE.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'BAIXO', 'Situação sob controle, monitoramento rotineiro', 'Continuar monitoramento regular. Verificar tendências.');
            PKG_WATERWISE.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'MEDIO', 'Situação requer atenção, monitoramento intensificado', 'Aumentar frequência de monitoramento. Verificar causas.');
            PKG_WATERWISE.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'ALTO', 'Situação preocupante, ação necessária', 'Ação corretiva imediata. Contatar responsável técnico.');
            PKG_WATERWISE.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'CRITICO', 'Situação crítica, ação imediata necessária', 'Intervenção imediata. Contatar especialista. Implementar medidas corretivas urgentes.');
        EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Níveis de severidade já existem ou erro: ' || SQLERRM); END;
        BEGIN
            PKG_WATERWISE.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'EXCELENTE', 'Solo em excelente estado de conservação', 1, 'Manter práticas atuais. Monitoramento preventivo.');
            PKG_WATERWISE.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'BOM', 'Solo em bom estado, pequenos sinais de desgaste', 2, 'Aplicar cobertura vegetal. Reduzir pisoteio.');
            PKG_WATERWISE.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'MODERADO', 'Degradação moderada, perda média de fertilidade', 3, 'Análise de solo. Correção química. Rotação de culturas.');
            PKG_WATERWISE.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'RUIM', 'Degradação avançada, perda significativa de fertilidade', 4, 'Recuperação intensiva. Análise detalhada. Plantio de recuperação.');
            PKG_WATERWISE.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'CRITICO', 'Degradação crítica, solo quase improdutivo', 5, 'Recuperação emergencial. Projeto técnico especializado.');
        EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Níveis de degradação já existem ou erro: ' || SQLERRM); END;
        DBMS_OUTPUT.PUT_LINE('✅ Sistema WaterWise inicializado com sucesso!');
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro na inicialização: ' || SQLERRM); ROLLBACK;
    END INICIALIZAR_SISTEMA;

    PROCEDURE VALIDAR_INTEGRIDADE_DADOS IS
        v_produtores_sem_propriedade NUMBER; v_propriedades_sem_sensor NUMBER;
        v_sensores_sem_leitura NUMBER; v_alertas_sem_nivel NUMBER; v_total_problemas NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== VALIDAÇÃO DE INTEGRIDADE DOS DADOS ===');
        DBMS_OUTPUT.PUT_LINE('Verificando consistência do banco de dados'); DBMS_OUTPUT.PUT_LINE(' ');
        SELECT COUNT(*) INTO v_produtores_sem_propriedade FROM GS_WW_PRODUTOR_RURAL prod WHERE NOT EXISTS (SELECT 1 FROM GS_WW_PROPRIEDADE_RURAL pr WHERE pr.id_produtor = prod.id_produtor);
        SELECT COUNT(*) INTO v_propriedades_sem_sensor FROM GS_WW_PROPRIEDADE_RURAL pr WHERE NOT EXISTS (SELECT 1 FROM GS_WW_SENSOR_IOT si WHERE si.id_propriedade = pr.id_propriedade);
        SELECT COUNT(*) INTO v_sensores_sem_leitura FROM GS_WW_SENSOR_IOT si WHERE NOT EXISTS (SELECT 1 FROM GS_WW_LEITURA_SENSOR ls WHERE ls.id_sensor = si.id_sensor AND ls.timestamp_leitura >= SYSDATE - 7);
        SELECT COUNT(*) INTO v_alertas_sem_nivel FROM GS_WW_ALERTA a WHERE NOT EXISTS (SELECT 1 FROM GS_WW_NIVEL_SEVERIDADE ns WHERE ns.id_nivel_severidade = a.id_nivel_severidade);
        DBMS_OUTPUT.PUT_LINE('RESULTADOS DA VALIDAÇÃO:'); DBMS_OUTPUT.PUT_LINE('=======================');
        IF v_produtores_sem_propriedade > 0 THEN DBMS_OUTPUT.PUT_LINE('⚠️ ' || v_produtores_sem_propriedade || ' produtores sem propriedades cadastradas'); v_total_problemas := v_total_problemas + 1; END IF;
        IF v_propriedades_sem_sensor > 0 THEN DBMS_OUTPUT.PUT_LINE('⚠️ ' || v_propriedades_sem_sensor || ' propriedades sem sensores instalados'); v_total_problemas := v_total_problemas + 1; END IF;
        IF v_sensores_sem_leitura > 0 THEN DBMS_OUTPUT.PUT_LINE('⚠️ ' || v_sensores_sem_leitura || ' sensores sem leituras na última semana'); v_total_problemas := v_total_problemas + 1; END IF;
        IF v_alertas_sem_nivel > 0 THEN DBMS_OUTPUT.PUT_LINE('❌ ' || v_alertas_sem_nivel || ' alertas com referências inválidas'); v_total_problemas := v_total_problemas + 1; END IF;
        DBMS_OUTPUT.PUT_LINE(' ');
        IF v_total_problemas = 0 THEN DBMS_OUTPUT.PUT_LINE('✅ INTEGRIDADE OK - Nenhum problema encontrado'); DBMS_OUTPUT.PUT_LINE('Base de dados consistente e funcional');
        ELSE DBMS_OUTPUT.PUT_LINE('🔧 AÇÃO NECESSÁRIA - ' || v_total_problemas || ' tipos de problemas encontrados'); DBMS_OUTPUT.PUT_LINE('Revisar dados e corrigir inconsistências'); END IF;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro na validação: ' || SQLERRM);
    END VALIDAR_INTEGRIDADE_DADOS;

    PROCEDURE RELATORIO_PROPRIEDADE(p_id_propriedade IN NUMBER) IS
        v_nome_propriedade VARCHAR2(100); v_nome_produtor VARCHAR2(100); v_email_produtor VARCHAR2(100);
        v_telefone_produtor VARCHAR2(15); v_area_hectares NUMBER(10,2); v_latitude NUMBER(10,8);
        v_longitude NUMBER(11,8); v_descricao_degradacao VARCHAR2(200); v_data_cadastro DATE;
        v_total_sensores NUMBER; v_sensores_ativos NUMBER; v_total_alertas NUMBER; v_alertas_criticos NUMBER;
        v_risco_alagamento VARCHAR2(200); v_taxa_degradacao VARCHAR2(200); v_capacidade_absorcao VARCHAR2(200);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RELATÓRIO COMPLETO DA PROPRIEDADE ===');
        DBMS_OUTPUT.PUT_LINE('ID da Propriedade: ' || p_id_propriedade);
        DBMS_OUTPUT.PUT_LINE('Data do Relatório: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI')); DBMS_OUTPUT.PUT_LINE(' ');
        SELECT pr.nome_propriedade, prod.nome_completo, prod.email, prod.telefone, pr.area_hectares, pr.latitude, pr.longitude,
               nd.descricao_degradacao, pr.data_cadastro
        INTO v_nome_propriedade, v_nome_produtor, v_email_produtor, v_telefone_produtor, v_area_hectares, v_latitude, v_longitude,
             v_descricao_degradacao, v_data_cadastro
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        WHERE pr.id_propriedade = p_id_propriedade;
        SELECT COUNT(*), COUNT(CASE WHEN EXISTS (SELECT 1 FROM GS_WW_LEITURA_SENSOR ls WHERE ls.id_sensor = si.id_sensor AND ls.timestamp_leitura >= SYSDATE - 7) THEN 1 END)
        INTO v_total_sensores, v_sensores_ativos FROM GS_WW_SENSOR_IOT si WHERE si.id_propriedade = p_id_propriedade;
        SELECT COUNT(*), COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) INTO v_total_alertas, v_alertas_criticos
        FROM GS_WW_ALERTA a
        JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        JOIN GS_WW_PRODUTOR_RURAL prod_alerta ON a.id_produtor = prod_alerta.id_produtor -- Garantir que o alerta é do produtor da propriedade
        JOIN GS_WW_PROPRIEDADE_RURAL pr_alerta ON prod_alerta.id_produtor = pr_alerta.id_produtor 
        WHERE pr_alerta.id_propriedade = p_id_propriedade AND a.timestamp_alerta >= SYSDATE - 30;
        
        v_risco_alagamento := CALCULAR_RISCO_ALAGAMENTO(p_id_propriedade);
        v_taxa_degradacao := CALCULAR_TAXA_DEGRADACAO_SOLO(p_id_propriedade);
        v_capacidade_absorcao := CALCULAR_CAPACIDADE_ABSORCAO(p_id_propriedade);
        DBMS_OUTPUT.PUT_LINE('INFORMAÇÕES GERAIS'); DBMS_OUTPUT.PUT_LINE('==================');
        DBMS_OUTPUT.PUT_LINE('Nome: ' || v_nome_propriedade); DBMS_OUTPUT.PUT_LINE('Produtor: ' || v_nome_produtor);
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_email_produtor); DBMS_OUTPUT.PUT_LINE('Telefone: ' || v_telefone_produtor);
        DBMS_OUTPUT.PUT_LINE('Área: ' || v_area_hectares || ' hectares');
        DBMS_OUTPUT.PUT_LINE('Coordenadas: ' || v_latitude || ', ' || v_longitude);
        DBMS_OUTPUT.PUT_LINE('Estado do Solo: ' || v_descricao_degradacao); DBMS_OUTPUT.PUT_LINE('Cadastro: ' || TO_CHAR(v_data_cadastro, 'DD/MM/YYYY')); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('MONITORAMENTO'); DBMS_OUTPUT.PUT_LINE('=============');
        DBMS_OUTPUT.PUT_LINE('Total de Sensores: ' || v_total_sensores); DBMS_OUTPUT.PUT_LINE('Sensores Ativos (7 dias): ' || v_sensores_ativos);
        DBMS_OUTPUT.PUT_LINE('Total Alertas (30 dias): ' || v_total_alertas); DBMS_OUTPUT.PUT_LINE('Alertas Críticos (30 dias): ' || v_alertas_criticos); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('ANÁLISES ESPECIALIZADAS'); DBMS_OUTPUT.PUT_LINE('=======================');
        DBMS_OUTPUT.PUT_LINE('Risco de Alagamento: ' || v_risco_alagamento); DBMS_OUTPUT.PUT_LINE('Taxa de Degradação: ' || v_taxa_degradacao);
        DBMS_OUTPUT.PUT_LINE('Capacidade de Absorção: ' || v_capacidade_absorcao);
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('❌ ERRO: Propriedade não encontrada (ID: ' || p_id_propriedade || ')');
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('❌ ERRO em RELATORIO_PROPRIEDADE: ' || SQLERRM);
    END RELATORIO_PROPRIEDADE;

    PROCEDURE BACKUP_DADOS_CRITICOS IS
        v_total_produtores NUMBER; v_total_propriedades NUMBER; v_total_sensores NUMBER;
        v_total_leituras NUMBER; v_total_alertas NUMBER; v_data_backup VARCHAR2(20);
    BEGIN
        v_data_backup := TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS');
        DBMS_OUTPUT.PUT_LINE('=== BACKUP DE DADOS CRÍTICOS ===');
        DBMS_OUTPUT.PUT_LINE('Timestamp: ' || v_data_backup); DBMS_OUTPUT.PUT_LINE(' ');
        SELECT COUNT(*) INTO v_total_produtores FROM GS_WW_PRODUTOR_RURAL; SELECT COUNT(*) INTO v_total_propriedades FROM GS_WW_PROPRIEDADE_RURAL;
        SELECT COUNT(*) INTO v_total_sensores FROM GS_WW_SENSOR_IOT; SELECT COUNT(*) INTO v_total_leituras FROM GS_WW_LEITURA_SENSOR;
        SELECT COUNT(*) INTO v_total_alertas FROM GS_WW_ALERTA;
        DBMS_OUTPUT.PUT_LINE('ESTATÍSTICAS DO BACKUP:'); DBMS_OUTPUT.PUT_LINE('========================');
        DBMS_OUTPUT.PUT_LINE('Produtores: ' || v_total_produtores || ' registros'); DBMS_OUTPUT.PUT_LINE('Propriedades: ' || v_total_propriedades || ' registros');
        DBMS_OUTPUT.PUT_LINE('Sensores: ' || v_total_sensores || ' registros'); DBMS_OUTPUT.PUT_LINE('Leituras: ' || v_total_leituras || ' registros');
        DBMS_OUTPUT.PUT_LINE('Alertas: ' || v_total_alertas || ' registros'); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('INSTRUÇÕES PARA BACKUP COMPLETO:'); DBMS_OUTPUT.PUT_LINE('=================================');
        DBMS_OUTPUT.PUT_LINE('1. Execute EXPDP para backup completo:'); DBMS_OUTPUT.PUT_LINE('   expdp SEU_USUARIO/SUA_SENHA@SEU_SERVICE_NAME DIRECTORY=DATA_PUMP_DIR DUMPFILE=waterwise_backup_' || v_data_backup || '.dmp LOGFILE=waterwise_backup_' || v_data_backup || '.log SCHEMAS=SEU_SCHEMA_WATERWISE');
        DBMS_OUTPUT.PUT_LINE(' '); DBMS_OUTPUT.PUT_LINE('2. Tabelas críticas para backup individual (se necessário):');
        DBMS_OUTPUT.PUT_LINE('   - GS_WW_PRODUTOR_RURAL'); DBMS_OUTPUT.PUT_LINE('   - GS_WW_PROPRIEDADE_RURAL');
        DBMS_OUTPUT.PUT_LINE('   - GS_WW_SENSOR_IOT'); DBMS_OUTPUT.PUT_LINE('   - GS_WW_LEITURA_SENSOR (últimos 90 dias)');
        DBMS_OUTPUT.PUT_LINE('   - GS_WW_ALERTA (últimos 180 dias)'); DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('✅ Relatório de backup concluído');
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro no backup: ' || SQLERRM);
    END BACKUP_DADOS_CRITICOS;

END PKG_WATERWISE;
/
