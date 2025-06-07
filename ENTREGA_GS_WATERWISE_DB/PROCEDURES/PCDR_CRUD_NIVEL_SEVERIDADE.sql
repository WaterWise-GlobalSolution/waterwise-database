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

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE ou DELETE.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_NIVEL_SEVERIDADE;
/