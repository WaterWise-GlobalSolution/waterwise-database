-- ============================================================================
-- 8. PROCEDURE CRUD PARA TABELA ALERTA - VERSÃO COMPLETA
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
    -- Variáveis para o SELECT
    v_result_produtor     GS_WW_ALERTA.id_produtor%TYPE;
    v_result_leitura      GS_WW_ALERTA.id_leitura%TYPE;
    v_result_severidade   GS_WW_ALERTA.id_nivel_severidade%TYPE;
    v_result_timestamp    GS_WW_ALERTA.timestamp_alerta%TYPE;
    v_result_descricao    GS_WW_ALERTA.descricao_alerta%TYPE;

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

    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT id_produtor, 
                   id_leitura, 
                   id_nivel_severidade, 
                   timestamp_alerta, 
                   descricao_alerta
            INTO v_result_produtor, 
                 v_result_leitura, 
                 v_result_severidade, 
                 v_result_timestamp, 
                 v_result_descricao
            FROM GS_WW_ALERTA
            WHERE id_alerta = v_id_alerta;

            DBMS_OUTPUT.PUT_LINE('ID Produtor: ' || v_result_produtor);
            DBMS_OUTPUT.PUT_LINE('ID Leitura: ' || v_result_leitura);
            DBMS_OUTPUT.PUT_LINE('ID Severidade: ' || v_result_severidade);
            DBMS_OUTPUT.PUT_LINE('Timestamp: ' || v_result_timestamp);
            DBMS_OUTPUT.PUT_LINE('Descrição: ' || v_result_descricao);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Alerta não encontrado com o ID especificado.');
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
END CRUD_ALERTA;
/