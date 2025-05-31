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