
-- Insert 1: Sensor de Umidade do Solo
BEGIN
    CRUD_TIPO_SENSOR(
        v_operacao => 'INSERT',
        v_id_tipo_sensor => NULL, 
        v_nome_tipo => 'Sensor de Umidade do Solo',
        v_descricao => 'Sensor capacitivo para medição da umidade do solo',
        v_unidade_medida => '%',
        v_valor_min => 0,
        v_valor_max => 100
    );
END;
/

-- Insert 2: Sensor de Temperatura
BEGIN
    CRUD_TIPO_SENSOR(
        v_operacao => 'INSERT',
        v_id_tipo_sensor => NULL, 
        v_nome_tipo => 'Sensor de Temperatura',
        v_descricao => 'Sensor digital para medição da temperatura ambiente',
        v_unidade_medida => '°C',
        v_valor_min => -40,
        v_valor_max => 85
    );
END;
/


-- Insert 1: Nível Baixo
BEGIN
    CRUD_NIVEL_SEVERIDADE(
        v_operacao => 'INSERT',
        v_id_nivel_severidade => NULL,
        v_codigo_severidade => 'BAIXO',
        v_descricao_severidade => 'Situação sob controle, monitoramento rotineiro',
        v_acoes_recomendadas => 'Continuar monitoramento regular. Verificar tendências.'
    );
END;
/

-- Insert 2: Nível Crítico
BEGIN
    CRUD_NIVEL_SEVERIDADE(
        v_operacao => 'INSERT',
        v_id_nivel_severidade => NULL, 
        v_codigo_severidade => 'CRITICO',
        v_descricao_severidade => 'Situação crítica, ação imediata necessária',
        v_acoes_recomendadas => 'Intervenção imediata. Contatar especialista. Implementar medidas corretivas urgentes.'
    );
END;
/


-- Insert 1: Degradação Leve
BEGIN
    CRUD_NIVEL_DEGRADACAO_SOLO(
        v_operacao => 'INSERT',
        v_id_nivel_degradacao => NULL, 
        v_codigo_degradacao => 'LEVE',
        v_descricao_degradacao => 'Degradação leve do solo, sinais iniciais de desgaste',
        v_nivel_numerico => 1,
        v_acoes_corretivas => 'Aplicar cobertura vegetal. Reduzir pisoteio. Monitorar erosão.'
    );
END;
/

-- Insert 2: Degradação Severa
BEGIN
    CRUD_NIVEL_DEGRADACAO_SOLO(
        v_operacao => 'INSERT',
        v_id_nivel_degradacao => NULL, 
        v_codigo_degradacao => 'SEVERA',
        v_descricao_degradacao => 'Degradação severa com perda significativa de fertilidade',
        v_nivel_numerico => 4,
        v_acoes_corretivas => 'Recuperação intensiva. Análise de solo. Correção química. Plantio de recuperação.'
    );
END;
/


-- Insert 1: João Silva
BEGIN
    CRUD_PRODUTOR_RURAL(
        v_operacao => 'INSERT',
        v_id_produtor => NULL,
        v_nome_completo => 'João Silva Santos',
        v_cpf_cnpj => '12345678901',
        v_email => 'joao.silva@email.com',
        v_telefone => '(11) 98765-4321'
    );
END;
/

-- Insert 2: Maria Oliveira (CNPJ)
BEGIN
    CRUD_PRODUTOR_RURAL(
        v_operacao => 'INSERT',
        v_id_produtor => NULL,
        v_nome_completo => 'Maria Oliveira Agropecuária LTDA',
        v_cpf_cnpj => '12345678000195',
        v_email => 'maria.oliveira@agropecuaria.com.br',
        v_telefone => '(19) 3456-7890'
    );
END;
/


-- Insert 1: Fazenda São José
BEGIN
    CRUD_PROPRIEDADE_RURAL(
        v_operacao => 'INSERT',
        v_id_propriedade => NULL, 
        v_id_produtor => 1,
        v_id_nivel_degradacao => 1, 
        v_nome_propriedade => 'Fazenda São José',
        v_latitude => -23.5505,
        v_longitude => -46.6333,
        v_area_hectares => 150.5
    );
END;
/

-- Insert 2: Sítio Esperança
BEGIN
    CRUD_PROPRIEDADE_RURAL(
        v_operacao => 'INSERT',
        v_id_propriedade => NULL, 
        v_id_produtor => 2, 
        v_id_nivel_degradacao => 2,
        v_nome_propriedade => 'Sítio Esperança',
        v_latitude => -22.9068,
        v_longitude => -43.1729,
        v_area_hectares => 75.0
    );
END;
/


-- Insert 1: Sensor DHT22
BEGIN
    CRUD_SENSOR_IOT(
        v_operacao => 'INSERT',
        v_id_sensor => NULL, 
        v_id_propriedade => 1, 
        v_id_tipo_sensor => 1,
        v_modelo_dispositivo => 'DHT22-001'
    );
END;
/

-- Insert 2: Sensor DS18B20
BEGIN
    CRUD_SENSOR_IOT(
        v_operacao => 'INSERT',
        v_id_sensor => NULL,
        v_id_propriedade => 2, 
        v_id_tipo_sensor => 2, 
        v_modelo_dispositivo => 'DS18B20-002'
    );
END;
/


-- Insert 1: Leitura do Sensor DHT22
BEGIN
    CRUD_LEITURA_SENSOR(
        v_operacao => 'INSERT',
        v_id_leitura => NULL, 
        v_id_sensor => 1, 
        v_umidade_solo => 65.5,
        v_temperatura_ar => 24.8,
        v_precipitacao_mm => 2.3
    );
END;
/

-- Insert 2: Leitura do Sensor DS18B20
BEGIN
    CRUD_LEITURA_SENSOR(
        v_operacao => 'INSERT',
        v_id_leitura => NULL, 
        v_id_sensor => 2, 
        v_umidade_solo => 45.2,
        v_temperatura_ar => 28.1,
        v_precipitacao_mm => 0.0
    );
END;
/


-- Insert 1: Alerta de Umidade Baixa
BEGIN
    CRUD_ALERTA(
        v_operacao => 'INSERT',
        v_id_alerta => NULL, 
        v_id_produtor => 1,
        v_id_leitura => 2, 
        v_id_nivel_severidade => 2,
        v_descricao_alerta => 'Umidade do solo abaixo do nível crítico (45.2%). Necessária irrigação imediata.'
    );
END;
/

-- Insert 2: Alerta de Monitoramento
BEGIN
    CRUD_ALERTA(
        v_operacao => 'INSERT',
        v_id_alerta => NULL, 
        v_id_produtor => 2,
        v_id_leitura => 1,
        v_id_nivel_severidade => 1, 
        v_descricao_alerta => 'Condições dentro do esperado. Continuar monitoramento regular da propriedade.'
    );
END;
/