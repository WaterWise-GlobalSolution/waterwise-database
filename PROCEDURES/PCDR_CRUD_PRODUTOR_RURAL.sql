-- ============================================================================
-- 4. PROCEDURE CRUD PARA PRODUTOR RURAL
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_PRODUTOR_RURAL(
    v_operacao       IN VARCHAR2,
    v_id_produtor    IN GS_WW_PRODUTOR_RURAL.id_produtor%TYPE DEFAULT NULL,
    v_nome_completo  IN GS_WW_PRODUTOR_RURAL.nome_completo%TYPE DEFAULT NULL,
    v_cpf_cnpj       IN GS_WW_PRODUTOR_RURAL.cpf_cnpj%TYPE DEFAULT NULL,
    v_email          IN GS_WW_PRODUTOR_RURAL.email%TYPE DEFAULT NULL,
    v_telefone       IN GS_WW_PRODUTOR_RURAL.telefone%TYPE DEFAULT NULL,
    v_senha          IN GS_WW_PRODUTOR_RURAL.senha%TYPE DEFAULT NULL,
    v_data_cadastro  IN GS_WW_PRODUTOR_RURAL.data_cadastro%TYPE DEFAULT SYSDATE
) IS
    v_mensagem VARCHAR2(255);
BEGIN
    IF v_operacao = 'INSERT' THEN
        -- Validar campos obrigatórios para INSERT
        IF v_nome_completo IS NULL OR v_cpf_cnpj IS NULL OR v_email IS NULL OR v_senha IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Campos obrigatórios: nome, CPF/CNPJ, email e senha');
        END IF;
        
        INSERT INTO GS_WW_PRODUTOR_RURAL (
            nome_completo, cpf_cnpj, email, telefone, senha, data_cadastro
        ) VALUES (
            v_nome_completo, v_cpf_cnpj, v_email, v_telefone, v_senha, 
            NVL(v_data_cadastro, SYSDATE)
        );
        v_mensagem := 'Produtor rural inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        -- Validar ID obrigatório para UPDATE
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
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Produtor não encontrado para atualização');
        END IF;
        
        v_mensagem := 'Produtor rural atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        IF v_id_produtor IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'ID do produtor é obrigatório para DELETE');
        END IF;
        
        DELETE FROM GS_WW_PRODUTOR_RURAL
        WHERE id_produtor = v_id_produtor;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Produtor não encontrado para exclusão');
        END IF;
        
        v_mensagem := 'Produtor rural deletado com sucesso.';

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE ou DELETE.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_PRODUTOR_RURAL;
/