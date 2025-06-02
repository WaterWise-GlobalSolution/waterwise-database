CREATE OR REPLACE PACKAGE PKG_WATERWISE_SLIM IS

-- ============================================================================
-- 1. PROCEDURES CRUD
-- ============================================================================
    PROCEDURE CRUD_TIPO_SENSOR(
        v_operacao         IN VARCHAR2,
        v_id_tipo_sensor   IN OUT NOCOPY GS_WW_TIPO_SENSOR.id_tipo_sensor%TYPE,
        v_nome_tipo        IN GS_WW_TIPO_SENSOR.nome_tipo%TYPE DEFAULT NULL,
        v_descricao        IN GS_WW_TIPO_SENSOR.descricao%TYPE DEFAULT NULL,
        v_unidade_medida   IN GS_WW_TIPO_SENSOR.unidade_medida%TYPE DEFAULT NULL,
        v_valor_min        IN GS_WW_TIPO_SENSOR.valor_min%TYPE DEFAULT NULL,
        v_valor_max        IN GS_WW_TIPO_SENSOR.valor_max%TYPE DEFAULT NULL
    );

    PROCEDURE CRUD_NIVEL_SEVERIDADE(
        v_operacao              IN VARCHAR2,
        v_id_nivel_severidade   IN OUT NOCOPY GS_WW_NIVEL_SEVERIDADE.id_nivel_severidade%TYPE,
        v_codigo_severidade     IN GS_WW_NIVEL_SEVERIDADE.codigo_severidade%TYPE DEFAULT NULL,
        v_descricao_severidade  IN GS_WW_NIVEL_SEVERIDADE.descricao_severidade%TYPE DEFAULT NULL,
        v_acoes_recomendadas    IN GS_WW_NIVEL_SEVERIDADE.acoes_recomendadas%TYPE DEFAULT NULL
    );

    PROCEDURE CRUD_NIVEL_DEGRADACAO_SOLO(
        v_operacao              IN VARCHAR2,
        v_id_nivel_degradacao   IN OUT NOCOPY GS_WW_NIVEL_DEGRADACAO_SOLO.id_nivel_degradacao%TYPE,
        v_codigo_degradacao     IN GS_WW_NIVEL_DEGRADACAO_SOLO.codigo_degradacao%TYPE DEFAULT NULL,
        v_descricao_degradacao  IN GS_WW_NIVEL_DEGRADACAO_SOLO.descricao_degradacao%TYPE DEFAULT NULL,
        v_nivel_numerico        IN GS_WW_NIVEL_DEGRADACAO_SOLO.nivel_numerico%TYPE DEFAULT NULL,
        v_acoes_corretivas      IN GS_WW_NIVEL_DEGRADACAO_SOLO.acoes_corretivas%TYPE DEFAULT NULL
    );

    PROCEDURE CRUD_PRODUTOR_RURAL(
        v_operacao       IN VARCHAR2,
        v_id_produtor    IN OUT NOCOPY GS_WW_PRODUTOR_RURAL.id_produtor%TYPE,
        v_nome_completo  IN GS_WW_PRODUTOR_RURAL.nome_completo%TYPE DEFAULT NULL,
        v_cpf_cnpj       IN GS_WW_PRODUTOR_RURAL.cpf_cnpj%TYPE DEFAULT NULL,
        v_email          IN GS_WW_PRODUTOR_RURAL.email%TYPE DEFAULT NULL,
        v_telefone       IN GS_WW_PRODUTOR_RURAL.telefone%TYPE DEFAULT NULL,
        v_senha          IN GS_WW_PRODUTOR_RURAL.senha%TYPE DEFAULT NULL,
        v_data_cadastro  IN GS_WW_PRODUTOR_RURAL.data_cadastro%TYPE DEFAULT SYSDATE
    );

    PROCEDURE CRUD_PROPRIEDADE_RURAL(
        v_operacao             IN VARCHAR2,
        v_id_propriedade       IN OUT NOCOPY GS_WW_PROPRIEDADE_RURAL.id_propriedade%TYPE,
        v_id_produtor          IN GS_WW_PROPRIEDADE_RURAL.id_produtor%TYPE DEFAULT NULL,
        v_id_nivel_degradacao  IN GS_WW_PROPRIEDADE_RURAL.id_nivel_degradacao%TYPE DEFAULT NULL,
        v_nome_propriedade     IN GS_WW_PROPRIEDADE_RURAL.nome_propriedade%TYPE DEFAULT NULL,
        v_latitude             IN GS_WW_PROPRIEDADE_RURAL.latitude%TYPE DEFAULT NULL,
        v_longitude            IN GS_WW_PROPRIEDADE_RURAL.longitude%TYPE DEFAULT NULL,
        v_area_hectares        IN GS_WW_PROPRIEDADE_RURAL.area_hectares%TYPE DEFAULT NULL
    );

    PROCEDURE CRUD_SENSOR_IOT(
        v_operacao           IN VARCHAR2,
        v_id_sensor          IN OUT NOCOPY GS_WW_SENSOR_IOT.id_sensor%TYPE,
        v_id_propriedade     IN GS_WW_SENSOR_IOT.id_propriedade%TYPE DEFAULT NULL,
        v_id_tipo_sensor     IN GS_WW_SENSOR_IOT.id_tipo_sensor%TYPE DEFAULT NULL,
        v_modelo_dispositivo IN GS_WW_SENSOR_IOT.modelo_dispositivo%TYPE DEFAULT NULL
    );

    PROCEDURE CRUD_LEITURA_SENSOR(
        v_operacao          IN VARCHAR2,
        v_id_leitura        IN OUT NOCOPY GS_WW_LEITURA_SENSOR.id_leitura%TYPE,
        v_id_sensor         IN GS_WW_LEITURA_SENSOR.id_sensor%TYPE DEFAULT NULL,
        v_timestamp_leitura IN GS_WW_LEITURA_SENSOR.timestamp_leitura%TYPE DEFAULT CURRENT_TIMESTAMP,
        v_umidade_solo      IN GS_WW_LEITURA_SENSOR.umidade_solo%TYPE DEFAULT NULL,
        v_temperatura_ar    IN GS_WW_LEITURA_SENSOR.temperatura_ar%TYPE DEFAULT NULL,
        v_precipitacao_mm   IN GS_WW_LEITURA_SENSOR.precipitacao_mm%TYPE DEFAULT NULL
    );

    PROCEDURE CRUD_ALERTA(
        v_operacao             IN VARCHAR2,
        v_id_alerta            IN OUT NOCOPY GS_WW_ALERTA.id_alerta%TYPE,
        v_id_produtor          IN GS_WW_ALERTA.id_produtor%TYPE DEFAULT NULL,
        v_id_leitura           IN GS_WW_ALERTA.id_leitura%TYPE DEFAULT NULL,
        v_id_nivel_severidade  IN GS_WW_ALERTA.id_nivel_severidade%TYPE DEFAULT NULL,
        v_timestamp_alerta     IN GS_WW_ALERTA.timestamp_alerta%TYPE DEFAULT CURRENT_TIMESTAMP,
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
    PROCEDURE VERIFICAR_RISCO_ENCHENTE(p_id_propriedade IN NUMBER DEFAULT NULL);
    PROCEDURE ESTADO_GERAL_SOLO;
    PROCEDURE DASHBOARD_METRICAS;
    PROCEDURE MELHORES_PRODUTORES;
    PROCEDURE RISCO_POR_REGIAO;
    PROCEDURE RELATORIO_PROPRIEDADE(p_id_propriedade IN NUMBER);

-- ============================================================================
-- 4. PROCEDURES UTILITÁRIAS
-- ============================================================================
    PROCEDURE INICIALIZAR_SISTEMA;
    PROCEDURE VALIDAR_INTEGRIDADE_DADOS;

END PKG_WATERWISE_SLIM;
/

CREATE OR REPLACE PACKAGE BODY PKG_WATERWISE_SLIM IS

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
            IF v_nome_tipo IS NULL THEN 
                 RAISE_APPLICATION_ERROR(-20001, 'Nome do tipo de sensor é obrigatório para INSERT.');
            END IF;
            INSERT INTO GS_WW_TIPO_SENSOR (nome_tipo, descricao, unidade_medida, valor_min, valor_max)
            VALUES (v_nome_tipo, v_descricao, v_unidade_medida, v_valor_min, v_valor_max)
            RETURNING id_tipo_sensor INTO v_id_tipo_sensor; 
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
            RETURNING id_nivel_severidade INTO v_id_nivel_severidade; 
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
            RETURNING id_nivel_degradacao INTO v_id_nivel_degradacao; 
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
            RETURNING id_produtor INTO v_id_produtor; 
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
            RETURNING id_propriedade INTO v_id_propriedade; 
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
            RETURNING id_sensor INTO v_id_sensor; 
            v_mensagem := 'Sensor IoT inserido com ID: ' || v_id_sensor;

        ELSIF UPPER(v_operacao) = 'UPDATE' THEN
            IF v_id_sensor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do sensor é obrigatório para UPDATE.');
            END IF;
            UPDATE GS_WW_SENSOR_IOT
            SET id_propriedade = NVL(v_id_propriedade, id_propriedade),
                id_tipo_sensor = NVL(v_id_tipo_sensor, id_tipo_sensor),
                modelo_dispositivo = NVL(v_modelo_dispositivo, modelo_dispositivo)
            WHERE id_sensor = v_id_sensor;
            IF SQL%NOTFOUND THEN
                 RAISE_APPLICATION_ERROR(-20004, 'Sensor com ID ' || v_id_sensor || ' não encontrado para UPDATE.');
            END IF;
            v_mensagem := 'Sensor IoT atualizado com ID: ' || v_id_sensor;

        ELSIF UPPER(v_operacao) = 'DELETE' THEN
            IF v_id_sensor IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID do sensor é obrigatório para DELETE.');
            END IF;
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
            RETURNING id_leitura INTO v_id_leitura; 
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
        v_id_leitura           IN GS_WW_ALERTA.id_leitura%TYPE DEFAULT NULL, 
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
            RETURNING id_alerta INTO v_id_alerta; 
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
-- 3. IMPLEMENTAÇÃO DAS PROCEDURES DE ANÁLISE E RELATÓRIOS
-- ============================================================================
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
            HAVING AVG(ls.umidade_solo) IS NOT NULL; 

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
                  (CASE WHEN COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) * 7.5) END) -
                  (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10), 1) AS score_eficiencia,
            CASE WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                       (CASE WHEN COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) * 7.5) END) -
                       (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 120 THEN 'PRODUTOR EXEMPLAR'
                 WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                       (CASE WHEN COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) * 7.5) END) -
                       (COUNT(CASE WHEN ns.codigo_severidade = 'CRITICO' THEN 1 END) * 15) - (COUNT(a.id_alerta) * 2) - (COUNT(CASE WHEN nd.nivel_numerico >= 4 THEN 1 END) * 10)) >= 100 THEN 'PRODUTOR EFICIENTE'
                 WHEN (100 + (COUNT(CASE WHEN nd.nivel_numerico <= 2 THEN 1 END) * 10) + (CASE WHEN COUNT(ls.id_leitura) / GREATEST(30.0,1) >= 5 THEN 20 ELSE (COUNT(ls.id_leitura) / GREATEST(30.0,1) * 4) END) +
                       (CASE WHEN COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) >= 2 THEN 15 ELSE (COUNT(DISTINCT si.id_sensor) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) * 7.5) END) -
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
            ROUND((NVL(AVG(ls.umidade_solo),0) * 0.4 + NVL(AVG(nd.nivel_numerico),0) * 20 * 0.3 + (NVL(SUM(ls.precipitacao_mm),0) / GREATEST(COUNT(DISTINCT pr.id_propriedade),1) / 10) * 0.3), 1) AS score_risco_regional, 
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
        JOIN GS_WW_PRODUTOR_RURAL prod_alerta ON a.id_produtor = prod_alerta.id_produtor 
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

-- ============================================================================
-- 4. IMPLEMENTAÇÃO DAS PROCEDURES UTILITÁRIAS
-- ============================================================================
    PROCEDURE INICIALIZAR_SISTEMA IS
        v_id_temp NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== INICIALIZANDO SISTEMA WATERWISE ===');
        BEGIN
            PKG_WATERWISE_SLIM.CRUD_TIPO_SENSOR('INSERT', v_id_temp, 'Sensor de Umidade do Solo', 'Sensor capacitivo para medição da umidade do solo', '%', 0, 100);
            PKG_WATERWISE_SLIM.CRUD_TIPO_SENSOR('INSERT', v_id_temp, 'Sensor de Temperatura', 'Sensor digital para medição da temperatura ambiente', '°C', -40, 85);
            PKG_WATERWISE_SLIM.CRUD_TIPO_SENSOR('INSERT', v_id_temp, 'Sensor de Precipitação', 'Pluviômetro digital para medição de chuva', 'mm', 0, 500);
        EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Tipos de sensores já existem ou erro: ' || SQLERRM); END;
        BEGIN
            PKG_WATERWISE_SLIM.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'BAIXO', 'Situação sob controle, monitoramento rotineiro', 'Continuar monitoramento regular. Verificar tendências.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'MEDIO', 'Situação requer atenção, monitoramento intensificado', 'Aumentar frequência de monitoramento. Verificar causas.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'ALTO', 'Situação preocupante, ação necessária', 'Ação corretiva imediata. Contatar responsável técnico.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_SEVERIDADE('INSERT', v_id_temp, 'CRITICO', 'Situação crítica, ação imediata necessária', 'Intervenção imediata. Contatar especialista. Implementar medidas corretivas urgentes.');
        EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Níveis de severidade já existem ou erro: ' || SQLERRM); END;
        BEGIN
            PKG_WATERWISE_SLIM.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'EXCELENTE', 'Solo em excelente estado de conservação', 1, 'Manter práticas atuais. Monitoramento preventivo.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'BOM', 'Solo em bom estado, pequenos sinais de desgaste', 2, 'Aplicar cobertura vegetal. Reduzir pisoteio.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'MODERADO', 'Degradação moderada, perda média de fertilidade', 3, 'Análise de solo. Correção química. Rotação de culturas.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'RUIM', 'Degradação avançada, perda significativa de fertilidade', 4, 'Recuperação intensiva. Análise detalhada. Plantio de recuperação.');
            PKG_WATERWISE_SLIM.CRUD_NIVEL_DEGRADACAO_SOLO('INSERT', v_id_temp, 'CRITICO', 'Degradação crítica, solo quase improdutivo', 5, 'Recuperação emergencial. Projeto técnico especializado.');
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

END PKG_WATERWISE_SLIM;
/