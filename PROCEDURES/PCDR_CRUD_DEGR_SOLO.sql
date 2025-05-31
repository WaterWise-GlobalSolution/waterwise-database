-- ============================================================================
-- 3. PROCEDURE CRUD PARA NÍVEL DEGRADAÇÃO SOLO
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_NIVEL_DEGRADACAO_SOLO(
    v_operacao              IN VARCHAR2,
    v_id_nivel_degradacao   IN GS_WW_NIVEL_DEGRADACAO_SOLO.id_nivel_degradacao%TYPE,
    v_codigo_degradacao     IN GS_WW_NIVEL_DEGRADACAO_SOLO.codigo_degradacao%TYPE,
    v_descricao_degradacao  IN GS_WW_NIVEL_DEGRADACAO_SOLO.descricao_degradacao%TYPE,
    v_nivel_numerico        IN GS_WW_NIVEL_DEGRADACAO_SOLO.nivel_numerico%TYPE,
    v_acoes_corretivas      IN GS_WW_NIVEL_DEGRADACAO_SOLO.acoes_corretivas%TYPE
) IS
    v_mensagem VARCHAR2(255);
BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_NIVEL_DEGRADACAO_SOLO (
            codigo_degradacao, descricao_degradacao, nivel_numerico, acoes_corretivas
        ) VALUES (
            v_codigo_degradacao, v_descricao_degradacao, v_nivel_numerico, v_acoes_corretivas
        );
        v_mensagem := 'Nível de degradação inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_NIVEL_DEGRADACAO_SOLO
        SET codigo_degradacao = v_codigo_degradacao,
            descricao_degradacao = v_descricao_degradacao,
            nivel_numerico = v_nivel_numerico,
            acoes_corretivas = v_acoes_corretivas
        WHERE id_nivel_degradacao = v_id_nivel_degradacao;
        v_mensagem := 'Nível de degradação atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_NIVEL_DEGRADACAO_SOLO
        WHERE id_nivel_degradacao = v_id_nivel_degradacao;
        v_mensagem := 'Nível de degradação deletado com sucesso.';

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE ou DELETE.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_NIVEL_DEGRADACAO_SOLO;
/