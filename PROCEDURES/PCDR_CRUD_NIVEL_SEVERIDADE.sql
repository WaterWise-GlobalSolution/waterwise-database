-- ============================================================================
-- 2. PROCEDURE CRUD PARA NÍVEL SEVERIDADE
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_NIVEL_SEVERIDADE(
    v_operacao              IN VARCHAR2,
    v_id_nivel_severidade   IN GS_WW_NIVEL_SEVERIDADE.id_nivel_severidade%TYPE,
    v_codigo_severidade     IN GS_WW_NIVEL_SEVERIDADE.codigo_severidade%TYPE,
    v_descricao_severidade  IN GS_WW_NIVEL_SEVERIDADE.descricao_severidade%TYPE,
    v_acoes_recomendadas    IN GS_WW_NIVEL_SEVERIDADE.acoes_recomendadas%TYPE
) IS
    v_mensagem VARCHAR2(255);
    -- Variáveis para o SELECT
    v_result_codigo      GS_WW_NIVEL_SEVERIDADE.codigo_severidade%TYPE;
    v_result_descricao   GS_WW_NIVEL_SEVERIDADE.descricao_severidade%TYPE;
    v_result_acoes       GS_WW_NIVEL_SEVERIDADE.acoes_recomendadas%TYPE;

BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_NIVEL_SEVERIDADE (
            codigo_severidade, descricao_severidade, acoes_recomendadas
        ) VALUES (
            v_codigo_severidade, v_descricao_severidade, v_acoes_recomendadas
        );
        v_mensagem := 'Nível de severidade inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_NIVEL_SEVERIDADE
        SET codigo_severidade = v_codigo_severidade,
            descricao_severidade = v_descricao_severidade,
            acoes_recomendadas = v_acoes_recomendadas
        WHERE id_nivel_severidade = v_id_nivel_severidade;
        v_mensagem := 'Nível de severidade atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_NIVEL_SEVERIDADE
        WHERE id_nivel_severidade = v_id_nivel_severidade;
        v_mensagem := 'Nível de severidade deletado com sucesso.';

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT codigo_severidade, descricao_severidade, acoes_recomendadas
            INTO v_result_codigo, v_result_descricao, v_result_acoes
            FROM GS_WW_NIVEL_SEVERIDADE
            WHERE id_nivel_severidade = v_id_nivel_severidade;

            DBMS_OUTPUT.PUT_LINE('Código: ' || v_result_codigo);
            DBMS_OUTPUT.PUT_LINE('Descrição: ' || v_result_descricao);
            DBMS_OUTPUT.PUT_LINE('Ações: ' || v_result_acoes);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Nível de severidade não encontrado com o ID especificado.');
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
END CRUD_NIVEL_SEVERIDADE;
/