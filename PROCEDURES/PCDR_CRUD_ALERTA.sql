-- ============================================================================
-- 8. PROCEDURE CRUD PARA TABELA ALERTA (SEM SELECT)
-- ============================================================================
CREATE OR REPLACE PROCEDURE CRUD_ALERTA(
    v_operacao             IN VARCHAR2,
    v_id_alerta            IN GS_WW_ALERTA.id_alerta%TYPE,
    v_id_produtor          IN GS_WW_ALERTA.id_produtor%TYPE,
    v_id_leitura           IN GS_WW_ALERTA.id_leitura%TYPE,
    v_id_nivel_severidade  IN GS_WW_ALERTA.id_nivel_severidade%TYPE,
    v_descricao_alerta     IN GS_WW_ALERTA.descricao_alerta%TYPE
) IS
    v_mensagem VARCHAR2(255);
BEGIN
    IF v_operacao = 'INSERT' THEN
        INSERT INTO GS_WW_ALERTA (
            id_produtor, 
            id_leitura, 
            id_nivel_severidade, 
            timestamp_alerta, 
            descricao_alerta
        ) VALUES (
            v_id_produtor, 
            v_id_leitura, 
            v_id_nivel_severidade, 
            CURRENT_TIMESTAMP, 
            v_descricao_alerta
        );
        v_mensagem := 'Alerta inserido com sucesso.';

    ELSIF v_operacao = 'UPDATE' THEN
        UPDATE GS_WW_ALERTA
        SET id_produtor = v_id_produtor,
            id_leitura = v_id_leitura,
            id_nivel_severidade = v_id_nivel_severidade,
            descricao_alerta = v_descricao_alerta
        WHERE id_alerta = v_id_alerta;
        v_mensagem := 'Alerta atualizado com sucesso.';

    ELSIF v_operacao = 'DELETE' THEN
        DELETE FROM GS_WW_ALERTA
        WHERE id_alerta = v_id_alerta;
        v_mensagem := 'Alerta deletado com sucesso.';

    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE ou DELETE.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_mensagem);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_ALERTA;
/