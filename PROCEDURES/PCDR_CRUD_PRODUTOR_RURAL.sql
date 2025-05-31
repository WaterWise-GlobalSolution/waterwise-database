-- ============================================================================
-- 4. PROCEDURE CRUD PARA PRODUTOR RURAL
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_PRODUTOR_RURAL(
    v_operacao       IN VARCHAR2,
    v_id_produtor    IN GS_WW_PRODUTOR_RURAL.id_produtor%TYPE,
    v_nome_completo  IN GS_WW_PRODUTOR_RURAL.nome_completo%TYPE,
    v_cpf_cnpj       IN GS_WW_PRODUTOR_RURAL.cpf_cnpj%TYPE,
    v_email          IN GS_WW_PRODUTOR_RURAL.email%TYPE,
    v_telefone       IN GS_WW_PRODUTOR_RURAL.telefone%TYPE
) IS
    v_mensagem VARCHAR2(255);
    -- Variáveis para o SELECT
    v_result_nome      GS_WW_PRODUTOR_RURAL.nome_completo%TYPE;
    v_result_cpf       GS_WW_PRODUTOR_RURAL.cpf_cnpj%TYPE;
    v_result_email     GS_WW_PRODUTOR_RURAL.email%TYPE;
    v_result_telefone  GS_WW_PRODUTOR_RURAL.telefone%TYPE;
    v_result_data      GS_WW_PRODUTOR_RURAL.data_cadastro%TYPE;

BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_PRODUTOR_RURAL (
            nome_completo, cpf_cnpj, email, telefone, data_cadastro
        ) VALUES (
            v_nome_completo, v_cpf_cnpj, v_email, v_telefone, SYSDATE
        );
        v_mensagem := 'Produtor rural inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_PRODUTOR_RURAL
        SET nome_completo = v_nome_completo,
            cpf_cnpj = v_cpf_cnpj,
            email = v_email,
            telefone = v_telefone
        WHERE id_produtor = v_id_produtor;
        v_mensagem := 'Produtor rural atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_PRODUTOR_RURAL
        WHERE id_produtor = v_id_produtor;
        v_mensagem := 'Produtor rural deletado com sucesso.';

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT nome_completo, cpf_cnpj, email, telefone, data_cadastro
            INTO v_result_nome, v_result_cpf, v_result_email, v_result_telefone, v_result_data
            FROM GS_WW_PRODUTOR_RURAL
            WHERE id_produtor = v_id_produtor;

            DBMS_OUTPUT.PUT_LINE('Nome: ' || v_result_nome);
            DBMS_OUTPUT.PUT_LINE('CPF/CNPJ: ' || v_result_cpf);
            DBMS_OUTPUT.PUT_LINE('Email: ' || v_result_email);
            DBMS_OUTPUT.PUT_LINE('Telefone: ' || v_result_telefone);
            DBMS_OUTPUT.PUT_LINE('Data Cadastro: ' || v_result_data);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Produtor rural não encontrado com o ID especificado.');
        END;

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE, DELETE ou SELECT.');
    END IF;

    IF v_operacao != 'SELECT' THEN
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_PRODUTOR_RURAL;
/