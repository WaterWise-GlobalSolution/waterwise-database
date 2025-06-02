DECLARE
  v_id_produtor_criado GS_WW_PRODUTOR_RURAL.id_produtor%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- INICIANDO CREATE (INSERÇÃO) ---');
  PKG_WATERWISE.CRUD_PRODUTOR_RURAL(
      v_operacao       => 'INSERT',
      v_id_produtor    => v_id_produtor_criado, 
      v_nome_completo  => 'Carlos Chaves Teste',
      v_cpf_cnpj       => '101.202.303-04',
      v_email          => 'carlos.chaves@teste.com',
      v_telefone       => '(11) 91234-5678',
      v_senha          => 'senhaProd1',
      v_data_cadastro  => SYSDATE
  );
  DBMS_OUTPUT.PUT_LINE('Produtor Rural inserido com ID: ' || v_id_produtor_criado);
  DBMS_OUTPUT.PUT_LINE('--- CREATE (INSERÇÃO) CONCLUÍDO ---');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no CREATE: ' || SQLERRM);
    ROLLBACK;
END;
/

---------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM GS_WW_PRODUTOR_RURAL ORDER BY id_produtor DESC;

---------------------------------------------------------------------------------------------------------------------------------------
DECLARE
  v_id_produtor_para_atualizar GS_WW_PRODUTOR_RURAL.id_produtor%TYPE := 20; 
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- INICIANDO UPDATE (ATUALIZAÇÃO) PARA O PRODUTOR ID: ' || v_id_produtor_para_atualizar || ' ---');
  IF v_id_produtor_para_atualizar IS NULL THEN
     DBMS_OUTPUT.PUT_LINE('ERRO: ID do produtor para atualizar não foi fornecido.');
     RETURN;
  END IF;

  PKG_WATERWISE.CRUD_PRODUTOR_RURAL(
      v_operacao       => 'UPDATE',
      v_id_produtor    => v_id_produtor_para_atualizar,
      v_nome_completo  => 'Carlos Chaves Teste (Nome Atualizado)',
      v_email          => 'carlos.chaves.novo@teste.com',
      v_telefone       => '(11) 98765-4321'
      -- Campos não fornecidos no UPDATE (como cpf_cnpj, senha, data_cadastro)
      -- permanecerão com seus valores atuais, conforme a lógica NVL na procedure.
  );
  DBMS_OUTPUT.PUT_LINE('Produtor Rural ID: ' || v_id_produtor_para_atualizar || ' atualizado.');
  DBMS_OUTPUT.PUT_LINE('--- UPDATE (ATUALIZAÇÃO) CONCLUÍDO ---');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no UPDATE: ' || SQLERRM);
    ROLLBACK;
END;
/
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE
  v_id_produtor_para_deletar GS_WW_PRODUTOR_RURAL.id_produtor%TYPE := 20; 
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- INICIANDO DELETE (EXCLUSÃO) PARA O PRODUTOR ID: ' || v_id_produtor_para_deletar || ' ---');
  IF v_id_produtor_para_deletar IS NULL THEN
     DBMS_OUTPUT.PUT_LINE('ERRO: ID do produtor para deletar não foi fornecido.');
     RETURN;
  END IF;

  PKG_WATERWISE.CRUD_PRODUTOR_RURAL(
      v_operacao       => 'DELETE',
      v_id_produtor    => v_id_produtor_para_deletar
  );
  DBMS_OUTPUT.PUT_LINE('Produtor Rural ID: ' || v_id_produtor_para_deletar || ' excluído.');
  DBMS_OUTPUT.PUT_LINE('--- DELETE (EXCLUSÃO) CONCLUÍDO ---');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no DELETE: ' || SQLERRM);
    ROLLBACK;
END;
/