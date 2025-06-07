# ============================================================================
# WATERWISE - INTEGRAÇÃO ORACLE + MONGODB COM STREAMLIT
# ============================================================================

import streamlit as st
import pandas as pd
import plotly.express as px
from datetime import datetime
import json
import base64
import oracledb
import pymongo
from pymongo import MongoClient
from io import BytesIO

# ============================================================================
# CONFIGURAÇÕES
# ============================================================================

ORACLE_CONFIG = {
    'host': 'oracle.fiap.com.br',
    'port': 1521,
    'service': 'ORCL',
    'user': 'RM553528',
    'password': '150592'  
}

MONGO_CONFIG = {
    'host': 'localhost',
    'port': 27017,
    'database': 'waterwise'
}


# ============================================================================
# FUNÇÕES DE CONEXÃO
# ============================================================================

@st.cache_resource
def connect_mongodb():
    """Conectar ao MongoDB"""
    try:
        client = MongoClient(MONGO_CONFIG['host'], MONGO_CONFIG['port'])
        db = client[MONGO_CONFIG['database']]
        db.list_collection_names()  # Tenta listar coleções para verificar a conexão
        return db
    except Exception as e:
        st.error(f"Erro ao conectar MongoDB: {e}")
        return None


# ============================================================================
# FUNÇÕES ORACLE
# ============================================================================

def find_column_name(df, possible_names):
    """Encontra o nome correto da coluna independente do caso"""
    for name in possible_names:
        if name in df.columns:
            return name
    # Se nenhum dos nomes exatos for encontrado, tentar correspondência insensível a maiúsculas/minúsculas
    df_columns_lower = {col.lower(): col for col in df.columns}
    for name in possible_names:
        if name.lower() in df_columns_lower:
            return df_columns_lower[name.lower()]
    return None


def test_oracle_connection():
    """Testar conexão Oracle com uma consulta simples"""
    connection = None
    cursor = None
    try:
        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )
        cursor = connection.cursor()
        cursor.execute("SELECT 1 FROM DUAL")
        result = cursor.fetchone()
        return result is not None
    except Exception as e:
        st.error(f"Erro ao testar conexão Oracle: {e}")
        return False
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


def get_oracle_data(query):
    """Executar consulta Oracle"""
    connection = None
    try:
        # Remove ponto e vírgula do final da query, se houver
        cleaned_query = query.strip()
        if cleaned_query.endswith(';'):
            cleaned_query = cleaned_query[:-1]

        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )
        df = pd.read_sql(cleaned_query, connection)
        return df
    except Exception as e:
        st.error(f"Erro na consulta Oracle: {e}")
        return pd.DataFrame()
    finally:
        if connection:
            connection.close()


def execute_oracle_procedure(procedure_name_full, **params):
    """
    Executar procedure da PKG_WATERWISE e capturar DBMS_OUTPUT.
    procedure_name_full deve ser 'NOME_PACOTE.NOME_PROCEDURE'
    Retorna: (bool_sucesso, lista_de_strings_saida_ou_erro)
    """
    output_lines = []
    connection = None
    cursor = None
    try:
        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )
        cursor = connection.cursor()

        # Habilitar DBMS_OUTPUT
        cursor.callproc("DBMS_OUTPUT.ENABLE", (1000000,))  # Buffer de 1MB

        # Constrói a chamada da procedure dinamicamente
        param_bindings = [f"{k} => :{k}" for k in params.keys()]
        if param_bindings:
            sql = f"BEGIN {procedure_name_full} ({', '.join(param_bindings)}); END;"
        else:
            sql = f"BEGIN {procedure_name_full}; END;"

        # Executar a procedure
        cursor.execute(sql, params)

        # Coletar linhas do DBMS_OUTPUT
        line_var = cursor.var(str, size=32767)
        status_var = cursor.var(int)

        while True:
            cursor.callproc("DBMS_OUTPUT.GET_LINE", (line_var, status_var))
            current_status = status_var.getvalue()
            if current_status == 0:
                retrieved_line = line_var.getvalue()
                if retrieved_line is not None:
                    output_lines.append(retrieved_line)
            else:
                break

        connection.commit()
        return True, output_lines

    except Exception as e:
        # Garante que a mensagem de erro do Python seja sempre retornada
        error_message_for_display = f"PYTHON EXCEPTION: Erro ao executar {procedure_name_full} - Detalhes: {str(e)}"
        # Se output_lines já tiver algo (ex: erro durante get_line), pode ser útil adicionar,
        # mas para clareza, vamos focar no erro Python que interrompeu o fluxo.
        # Se o erro Python for a causa primária, output_lines pode estar vazia.
        return False, [error_message_for_display]  # Retorna uma lista contendo a string do erro
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


def get_dashboard_metrics():
    """Obter métricas do dashboard"""
    query = """
        SELECT 
            (SELECT COUNT(*) FROM GS_WW_PROPRIEDADE_RURAL) as PROPRIEDADES,
            (SELECT COUNT(*) FROM GS_WW_SENSOR_IOT s JOIN GS_WW_LEITURA_SENSOR ls ON s.id_sensor = ls.id_sensor WHERE ls.timestamp_leitura >= SYSDATE - 1) as SENSORES_ATIVOS,
            (SELECT COUNT(*) FROM GS_WW_ALERTA WHERE timestamp_alerta >= TRUNC(SYSDATE) AND id_nivel_severidade = (SELECT id_nivel_severidade FROM GS_WW_NIVEL_SEVERIDADE WHERE codigo_severidade = 'CRITICO')) as ALERTAS_CRITICOS_HOJE,
            (SELECT ROUND(AVG(umidade_solo), 1) FROM GS_WW_LEITURA_SENSOR WHERE timestamp_leitura >= TRUNC(SYSDATE)) as UMIDADE_MEDIA_HOJE
        FROM DUAL
    """  # Ajustado SENSORES para ATIVOS e ALERTAS para CRITICOS HOJE
    df = get_oracle_data(query)
    if not df.empty:
        df = df.fillna(0)
    return df


def get_propriedades_com_metricas():
    """Obter lista de propriedades com métricas calculadas pela PKG_WATERWISE"""
    query = """
        SELECT 
            pr.id_propriedade as "ID",
            pr.nome_propriedade as "NOME DA PROPRIEDADE",
            prod.nome_completo as "PRODUTOR",
            pr.area_hectares as "ÁREA (HA)", 
            nd.descricao_degradacao as "ESTADO SOLO REGISTRADO",
            PKG_WATERWISE.CALCULAR_RISCO_ALAGAMENTO(pr.id_propriedade) AS "RISCO ALAGAMENTO",
            PKG_WATERWISE.CALCULAR_TAXA_DEGRADACAO_SOLO(pr.id_propriedade) AS "TAXA DEGRADAÇÃO",
            PKG_WATERWISE.CALCULAR_CAPACIDADE_ABSORCAO(pr.id_propriedade) AS "CAPACIDADE ABSORÇÃO"
        FROM GS_WW_PROPRIEDADE_RURAL pr
        JOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor
        JOIN GS_WW_NIVEL_DEGRADACAO_SOLO nd ON pr.id_nivel_degradacao = nd.id_nivel_degradacao
        ORDER BY pr.nome_propriedade
    """
    return get_oracle_data(query)


def get_alertas_severidade():
    """Obter alertas por severidade"""
    query = """
        SELECT ns.codigo_severidade as CODIGO_SEVERIDADE, COUNT(a.id_alerta) as TOTAL
        FROM GS_WW_ALERTA a
        JOIN GS_WW_NIVEL_SEVERIDADE ns ON a.id_nivel_severidade = ns.id_nivel_severidade
        WHERE a.timestamp_alerta >= SYSDATE - 7 
        GROUP BY ns.codigo_severidade
        ORDER BY CASE ns.codigo_severidade WHEN 'CRITICO' THEN 1 WHEN 'ALTO' THEN 2 WHEN 'MEDIO' THEN 3 ELSE 4 END
    """
    df = get_oracle_data(query)
    # Não exibir info se vazio aqui, o chamador decide
    return df


# ============================================================================
# FUNÇÕES MONGODB (Mantidas como no original)
# ============================================================================
def log_activity(activity_type, details, user="system"):
    db = connect_mongodb()
    if db is None: return False
    try:
        db.activity_logs.insert_one(
            {"timestamp": datetime.now(), "type": activity_type, "user": user, "details": details,
             "source": "streamlit_interface"})
        return True
    except Exception as e:
        st.error(f"Erro ao registrar log: {e}");
        return False


def save_report(report_type, content, metadata):  # Não implementado na UI, mas função existe
    db = connect_mongodb()
    if db is None: return None
    try:
        result = db.reports.insert_one(
            {"timestamp": datetime.now(), "type": report_type, "content": content, "metadata": metadata,
             "status": "generated"})
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar relatório: {e}");
        return None


def save_image(image_name, image_data, metadata):  # Não implementado na UI, mas função existe
    db = connect_mongodb()
    if db is None: return None
    try:
        image_b64 = base64.b64encode(image_data).decode()
        result = db.images.insert_one(
            {"timestamp": datetime.now(), "filename": image_name, "metadata": metadata, "image_data": image_b64,
             "size_bytes": len(image_data)})
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar imagem: {e}");
        return None


def get_recent_logs(limit=50):
    db = connect_mongodb()
    if db is None: return []
    try:
        return list(db.activity_logs.find().sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter logs: {e}");
        return []


def get_reports(limit=20):  # Não implementado na UI, mas função existe
    db = connect_mongodb()
    if db is None: return []
    try:
        return list(db.reports.find().sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter relatórios: {e}");
        return []

def log_activity(activity_type, details, user="system"):
    db = connect_mongodb()
    if db is None: return False
    try:
        db.activity_logs.insert_one(
            {"timestamp": datetime.now(), "type": activity_type, "user": user, "details": details,
             "source": "streamlit_interface"})
        return True
    except Exception as e:
        st.error(f"Erro ao registrar log: {e}"); return False

def save_report_to_mongo(report_type, content, metadata): # Nome corrigido/confirmado
    db = connect_mongodb()
    if db is None: return None
    try:
        result = db.reports.insert_one(
            {"timestamp": datetime.now(), "type": report_type, "content": content, "metadata": metadata,
             "status": "generated"})
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar relatório no MongoDB: {e}"); return None

def save_image_to_mongo(image_name, image_data, metadata): # Nome corrigido/confirmado
    db = connect_mongodb()
    if db is None: return None
    try:
        image_b64 = base64.b64encode(image_data).decode()
        result = db.images.insert_one(
            {"timestamp": datetime.now(), "filename": image_name, "metadata": metadata, "image_data": image_b64,
             "size_bytes": len(image_data)})
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar imagem no MongoDB: {e}"); return None

def get_recent_logs(limit=50):
    db = connect_mongodb()
    if db is None: return []
    try:
        return list(db.activity_logs.find().sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter logs: {e}"); return []

def get_mongo_reports(limit=20): # Nome corrigido/confirmado
    db = connect_mongodb()
    if db is None: return []
    try:
        # Exclui o campo 'content' da listagem inicial para performance
        return list(db.reports.find({}, {"content": 0}).sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter relatórios do MongoDB: {e}"); return []

def get_mongo_report_by_id(report_id_str): # Nome corrigido/confirmado
    db = connect_mongodb()
    if db is None: return None
    try:
        from bson.objectid import ObjectId # Importar ObjectId aqui ou no topo do arquivo
        # Validação básica do ID
        if not ObjectId.is_valid(report_id_str):
            st.error(f"ID de relatório inválido: {report_id_str}")
            return None
        return db.reports.find_one({"_id": ObjectId(report_id_str)})
    except Exception as e:
        st.error(f"Erro ao obter relatório por ID '{report_id_str}': {e}"); return None

def get_mongo_images(limit=5): # Nova função - Definição
    db = connect_mongodb()
    if db is None: return []
    try:
        # Retorna documentos sem o campo image_data para performance na listagem
        return list(db.images.find({}, {"image_data": 0}).sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter metadados de imagens do MongoDB: {e}"); return []

def get_mongo_image_data_by_id(image_id_str): # Nova função - Definição
    db = connect_mongodb()
    if db is None: return None
    try:
        from bson.objectid import ObjectId # Importar ObjectId aqui ou no topo do arquivo
        # Validação básica do ID
        if not ObjectId.is_valid(image_id_str):
            st.error(f"ID de imagem inválido: {image_id_str}")
            return None
        image_doc = db.images.find_one({"_id": ObjectId(image_id_str)}, {"image_data": 1})
        if image_doc and "image_data" in image_doc:
            return base64.b64decode(image_doc["image_data"])
        return None
    except Exception as e:
        st.error(f"Erro ao obter dados da imagem por ID '{image_id_str}': {e}"); return None


# ============================================================================
# PÁGINAS DA INTERFACE
# ============================================================================
def crud_page():
    st.header("⚙️ Gerenciamento de Dados (Oracle)")
    entity = st.radio("Selecione a Entidade:", ["Produtor Rural", "Propriedade Rural"], horizontal=True)
    st.markdown("---")

    if entity == "Produtor Rural":
        st.subheader("👨‍🌾 Gerenciar Produtores Rurais")
        operation = st.selectbox("Operação para Produtor Rural:", ["Inserir Novo", "Atualizar Existente", "Deletar"])

        if operation == "Inserir Novo":
            with st.form("new_produtor_form"):
                st.markdown("**Dados do Novo Produtor:**")
                nome_prod = st.text_input("Nome Completo*")
                cpf_cnpj_prod = st.text_input("CPF/CNPJ* (único)")
                email_prod = st.text_input("Email* (único)")
                telefone_prod = st.text_input("Telefone")
                senha_prod = st.text_input("Senha*", type="password")
                submitted = st.form_submit_button("💾 Inserir Produtor")

                if submitted:
                    if not all([nome_prod, cpf_cnpj_prod, email_prod, senha_prod]):
                        st.error("❌ Preencha todos os campos obrigatórios (*).")
                    else:
                        params = {
                            "v_operacao": "INSERT", "v_id_produtor": None,
                            "v_nome_completo": nome_prod, "v_cpf_cnpj": cpf_cnpj_prod,
                            "v_email": email_prod, "v_telefone": telefone_prod if telefone_prod else None,
                            "v_senha": senha_prod, "v_data_cadastro": datetime.now()
                        }
                        success, messages = execute_oracle_procedure("PKG_WATERWISE.CRUD_PRODUTOR_RURAL", **params)
                        if success:
                            st.success(f"✅ Produtor '{nome_prod}' inserido com sucesso!")
                            log_activity("oracle_crud",
                                         {"entity": "ProdutorRural", "operation": "INSERT", "name": nome_prod})
                            # Não exibir DBMS_OUTPUT aqui, pois CRUDs não devem usá-lo para sucesso
                        else:
                            st.error("❌ Falha ao inserir produtor.")
                            if messages:
                                st.text_area("Detalhes do Erro:", value="\n".join(messages), height=100,
                                             key=f"crud_error_prod_insert_{datetime.now().timestamp()}")

        elif operation == "Atualizar Existente":
            with st.form("update_produtor_form"):
                st.markdown("**Atualizar Dados do Produtor:**")
                id_prod_upd = st.number_input("ID do Produtor a Atualizar*", min_value=1, step=1)
                st.markdown("*Deixe campos em branco para não alterá-los.*")
                nome_prod_upd = st.text_input("Novo Nome Completo")
                cpf_cnpj_prod_upd = st.text_input("Novo CPF/CNPJ (único)")
                email_prod_upd = st.text_input("Novo Email (único)")
                telefone_prod_upd = st.text_input("Novo Telefone")
                senha_prod_upd = st.text_input("Nova Senha (opcional)", type="password")
                submitted = st.form_submit_button("🔄 Atualizar Produtor")

                if submitted:
                    if not id_prod_upd:
                        st.error("❌ ID do Produtor é obrigatório para atualização.")
                    else:
                        params = {
                            "v_operacao": "UPDATE", "v_id_produtor": id_prod_upd,
                            "v_nome_completo": nome_prod_upd if nome_prod_upd else None,
                            "v_cpf_cnpj": cpf_cnpj_prod_upd if cpf_cnpj_prod_upd else None,
                            "v_email": email_prod_upd if email_prod_upd else None,
                            "v_telefone": telefone_prod_upd if telefone_prod_upd else None,
                            "v_senha": senha_prod_upd if senha_prod_upd else None,
                            "v_data_cadastro": None
                        }
                        params_clean = {k: v for k, v in params.items() if
                                        v is not None or k in ["v_id_produtor", "v_operacao"]}
                        success, messages = execute_oracle_procedure("PKG_WATERWISE.CRUD_PRODUTOR_RURAL",
                                                                     **params_clean)
                        if success:
                            st.success(f"✅ Produtor ID {id_prod_upd} atualizado!")
                            log_activity("oracle_crud",
                                         {"entity": "ProdutorRural", "operation": "UPDATE", "id": id_prod_upd})
                        else:
                            st.error(f"❌ Falha ao atualizar produtor ID {id_prod_upd}.")
                            if messages:
                                st.text_area("Detalhes do Erro:", value="\n".join(messages), height=100,
                                             key=f"crud_error_prod_update_{datetime.now().timestamp()}")

        elif operation == "Deletar":
            with st.form("delete_produtor_form"):
                st.markdown("**Deletar Produtor:**")
                id_prod_del = st.number_input("ID do Produtor a Deletar*", min_value=1, step=1)
                confirm_delete = st.checkbox(
                    f"Confirmo que desejo deletar o produtor ID {id_prod_del}. Esta ação não pode ser desfeita e pode afetar dados relacionados.")
                submitted = st.form_submit_button("🗑️ Deletar Produtor")

                if submitted:
                    if not id_prod_del:
                        st.error("❌ ID do Produtor é obrigatório para deleção.")
                    elif not confirm_delete:
                        st.warning("⚠️ Confirme a deleção marcando a caixa de seleção.")
                    else:
                        params = {"v_operacao": "DELETE", "v_id_produtor": id_prod_del}
                        success, messages = execute_oracle_procedure("PKG_WATERWISE.CRUD_PRODUTOR_RURAL", **params)
                        if success:
                            st.success(f"✅ Produtor ID {id_prod_del} deletado!")
                            log_activity("oracle_crud",
                                         {"entity": "ProdutorRural", "operation": "DELETE", "id": id_prod_del})
                        else:
                            st.error(f"❌ Falha ao deletar produtor ID {id_prod_del}.")
                            if messages:
                                st.text_area("Detalhes do Erro:", value="\n".join(messages), height=100,
                                             key=f"crud_error_prod_delete_{datetime.now().timestamp()}")

    elif entity == "Propriedade Rural":
        st.subheader("🏡 Gerenciar Propriedades Rurais")
        operation_prop = st.selectbox("Operação para Propriedade Rural:",
                                      ["Inserir Nova", "Atualizar Existente", "Deletar"])

        produtores_df = get_oracle_data(
            "SELECT ID_PRODUTOR, NOME_COMPLETO || ' (ID: ' || ID_PRODUTOR || ')' AS PRODUTOR_INFO FROM GS_WW_PRODUTOR_RURAL ORDER BY NOME_COMPLETO")
        niveis_degradacao_df = get_oracle_data(
            "SELECT ID_NIVEL_DEGRADACAO, CODIGO_DEGRADACAO || ' - ' || DESCRICAO_DEGRADACAO AS NIVEL_INFO FROM GS_WW_NIVEL_DEGRADACAO_SOLO ORDER BY NIVEL_NUMERICO")

        produtores_map = {}
        if not produtores_df.empty:
            col_id_prod = find_column_name(produtores_df, ["ID_PRODUTOR", "ID_PRODUTOR"])
            col_info_prod = find_column_name(produtores_df, ["PRODUTOR_INFO", "PRODUTOR_INFO"])
            if col_id_prod and col_info_prod:
                produtores_map = pd.Series(produtores_df[col_id_prod].values,
                                           index=produtores_df[col_info_prod]).to_dict()

        niveis_map = {}
        if not niveis_degradacao_df.empty:
            col_id_nivel = find_column_name(niveis_degradacao_df, ["ID_NIVEL_DEGRADACAO", "ID_NIVEL_DEGRADACAO"])
            col_info_nivel = find_column_name(niveis_degradacao_df, ["NIVEL_INFO", "NIVEL_INFO"])
            if col_id_nivel and col_info_nivel:
                niveis_map = pd.Series(niveis_degradacao_df[col_id_nivel].values,
                                       index=niveis_degradacao_df[col_info_nivel]).to_dict()

        if operation_prop == "Inserir Nova":
            with st.form("new_propriedade_form"):
                st.markdown("**Dados da Nova Propriedade:**")
                id_prod_prop_key = st.selectbox("Produtor Responsável*", options=list(
                    produtores_map.keys())) if produtores_map else st.text_input("ID do Produtor* (manual)")
                id_nivel_deg_prop_key = st.selectbox("Nível de Degradação do Solo*",
                                                     options=list(niveis_map.keys())) if niveis_map else st.text_input(
                    "ID Nível Degradação* (manual)")
                nome_prop = st.text_input("Nome da Propriedade*")
                cols_geo = st.columns(2)
                with cols_geo[0]:
                    latitude_prop = st.number_input("Latitude*", format="%.7f", value=0.0)
                with cols_geo[1]:
                    longitude_prop = st.number_input("Longitude*", format="%.7f", value=0.0)
                area_prop = st.number_input("Área (Hectares)*", min_value=0.01, format="%.2f", value=1.0)
                submitted = st.form_submit_button("💾 Inserir Propriedade")

                if submitted:
                    id_prod_selected = produtores_map.get(id_prod_prop_key) if produtores_map else (
                        int(id_prod_prop_key) if id_prod_prop_key and id_prod_prop_key.isdigit() else None)
                    id_nivel_selected = niveis_map.get(id_nivel_deg_prop_key) if niveis_map else (
                        int(id_nivel_deg_prop_key) if id_nivel_deg_prop_key and id_nivel_deg_prop_key.isdigit() else None)

                    if not all([id_prod_selected, id_nivel_selected, nome_prop,
                                area_prop]):  # Latitude/Longitude podem ser 0
                        st.error("❌ Preencha todos os campos obrigatórios (*).")
                    else:
                        params = {
                            "v_operacao": "INSERT", "v_id_propriedade": None,
                            "v_id_produtor": id_prod_selected, "v_id_nivel_degradacao": id_nivel_selected,
                            "v_nome_propriedade": nome_prop, "v_latitude": latitude_prop,
                            "v_longitude": longitude_prop, "v_area_hectares": area_prop
                        }
                        success, messages = execute_oracle_procedure("PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL", **params)
                        if success:
                            st.success(f"✅ Propriedade '{nome_prop}' inserida!")
                            log_activity("oracle_crud",
                                         {"entity": "PropriedadeRural", "operation": "INSERT", "name": nome_prop})
                        else:
                            st.error(f"❌ Falha ao inserir propriedade '{nome_prop}'.")
                            if messages:
                                st.text_area("Detalhes do Erro:", value="\n".join(messages), height=100,
                                             key=f"crud_error_prop_insert_{datetime.now().timestamp()}")

        elif operation_prop == "Atualizar Existente":
            with st.form("update_propriedade_form"):
                st.markdown("**Atualizar Dados da Propriedade:**")
                id_prop_upd = st.number_input("ID da Propriedade a Atualizar*", min_value=1, step=1)
                st.markdown("*Deixe campos em branco/não selecionados para não alterá-los.*")
                id_prod_prop_upd_key = st.selectbox("Novo Produtor Responsável",
                                                    options=[None] + list(produtores_map.keys()), format_func=lambda
                        x: x if x else "Não alterar") if produtores_map else st.number_input(
                    "Novo ID Produtor (opcional)", value=None, step=1, min_value=1, format="%d")
                id_nivel_deg_prop_upd_key = st.selectbox("Novo Nível de Degradação",
                                                         options=[None] + list(niveis_map.keys()), format_func=lambda
                        x: x if x else "Não alterar") if niveis_map else st.number_input(
                    "Novo ID Nível Degradação (opcional)", value=None, step=1, min_value=1, format="%d")
                nome_prop_upd = st.text_input("Novo Nome da Propriedade")
                cols_geo_upd = st.columns(2)
                with cols_geo_upd[0]:
                    latitude_prop_upd = st.number_input("Nova Latitude", value=None, format="%.7f")
                with cols_geo_upd[1]:
                    longitude_prop_upd = st.number_input("Nova Longitude", value=None, format="%.7f")
                area_prop_upd = st.number_input("Nova Área (Hectares)", value=None, min_value=0.01, format="%.2f")
                submitted = st.form_submit_button("🔄 Atualizar Propriedade")

                if submitted:
                    if not id_prop_upd:
                        st.error("❌ ID da Propriedade é obrigatório para atualização.")
                    else:
                        id_prod_selected_upd = produtores_map.get(
                            id_prod_prop_upd_key) if produtores_map and id_prod_prop_upd_key else id_prod_prop_upd_key
                        id_nivel_selected_upd = niveis_map.get(
                            id_nivel_deg_prop_upd_key) if niveis_map and id_nivel_deg_prop_upd_key else id_nivel_deg_prop_upd_key

                        params = {
                            "v_operacao": "UPDATE", "v_id_propriedade": id_prop_upd,
                            "v_id_produtor": int(id_prod_selected_upd) if id_prod_selected_upd is not None else None,
                            "v_id_nivel_degradacao": int(
                                id_nivel_selected_upd) if id_nivel_selected_upd is not None else None,
                            "v_nome_propriedade": nome_prop_upd if nome_prop_upd else None,
                            "v_latitude": latitude_prop_upd, "v_longitude": longitude_prop_upd,
                            "v_area_hectares": area_prop_upd
                        }
                        params_clean = {k: v for k, v in params.items() if
                                        v is not None or k in ["v_id_propriedade", "v_operacao", "v_latitude",
                                                               "v_longitude",
                                                               "v_area_hectares"]}  # Lat/Long/Area podem ser 0 ou None explicitamente

                        success, messages = execute_oracle_procedure("PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL",
                                                                     **params_clean)
                        if success:
                            st.success(f"✅ Propriedade ID {id_prop_upd} atualizada!")
                            log_activity("oracle_crud",
                                         {"entity": "PropriedadeRural", "operation": "UPDATE", "id": id_prop_upd})
                        else:
                            st.error(f"❌ Falha ao atualizar propriedade ID {id_prop_upd}.")
                            if messages:
                                st.text_area("Detalhes do Erro:", value="\n".join(messages), height=100,
                                             key=f"crud_error_prop_update_{datetime.now().timestamp()}")

        elif operation_prop == "Deletar":
            with st.form("delete_propriedade_form"):
                st.markdown("**Deletar Propriedade Rural:**")
                id_prop_del = st.number_input("ID da Propriedade a Deletar*", min_value=1, step=1)
                confirm_delete_prop = st.checkbox(
                    f"Confirmo que desejo deletar a propriedade ID {id_prop_del}. Esta ação não pode ser desfeita.")
                submitted = st.form_submit_button("🗑️ Deletar Propriedade")

                if submitted:
                    if not id_prop_del:
                        st.error("❌ ID da Propriedade é obrigatório para deleção.")
                    elif not confirm_delete_prop:
                        st.warning("⚠️ Confirme a deleção marcando a caixa de seleção.")
                    else:
                        params = {"v_operacao": "DELETE", "v_id_propriedade": id_prop_del}
                        success, messages = execute_oracle_procedure("PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL", **params)
                        if success:
                            st.success(f"✅ Propriedade ID {id_prop_del} deletada!")
                            log_activity("oracle_crud",
                                         {"entity": "PropriedadeRural", "operation": "DELETE", "id": id_prop_del})
                        else:
                            st.error(f"❌ Falha ao deletar propriedade ID {id_prop_del}.")
                            if messages:
                                st.text_area("Detalhes do Erro:", value="\n".join(messages), height=100,
                                             key=f"crud_error_prop_delete_{datetime.now().timestamp()}")

    st.markdown("---")
    st.info("💡 CRUD para Sensor IoT, Leitura de Sensor e Alertas podem ser adicionados aqui seguindo o mesmo padrão.")


def main():
    st.set_page_config(page_title="WaterWise - Sistema Integrado", page_icon="🌊", layout="wide")
    st.title("🌊 WaterWise - Sistema Integrado")
    st.markdown("**Oracle + MongoDB** | Monitoramento Agrícola Sustentável")

    st.sidebar.title("Navegação")
    with st.sidebar:
        st.subheader("📡 Status Conexões")
        if test_oracle_connection():
            st.success("🟢 Oracle: Conectado")
        else:
            st.error("🔴 Oracle: Desconectado")
        if connect_mongodb() is not None:
            st.success("🟢 MongoDB: Conectado")
        else:
            st.error("🔴 MongoDB: Desconectado")
        st.markdown("---")

    menu_options = ["🏠 Dashboard", "📊 Dados Oracle", "📝 Logs MongoDB", "📋 Relatórios", "🖼️ Upload Imagens",
                    "⚙️ Gerenciar Dados"]
    query_params = st.query_params.to_dict()
    default_index = 0
    if "page" in query_params:
        try:
            default_index = menu_options.index(query_params["page"][0])
        except ValueError:
            default_index = 0

    selected_page = st.sidebar.selectbox("Selecione a página:", menu_options, index=default_index)
    if query_params.get("page", [""])[0] != selected_page: st.query_params["page"] = selected_page

    if selected_page == "🏠 Dashboard":
        dashboard_page()
    elif selected_page == "📊 Dados Oracle":
        oracle_page()
    elif selected_page == "📝 Logs MongoDB":
        logs_page()
    elif selected_page == "📋 Relatórios":
        reports_page()
    elif selected_page == "🖼️ Upload Imagens":
        images_page()
    elif selected_page == "⚙️ Gerenciar Dados":
        crud_page()


def dashboard_page():
    st.header("🏠 Dashboard Principal")
    metrics_df = get_dashboard_metrics()
    if not metrics_df.empty:
        row = metrics_df.iloc[0]
        col1, col2, col3, col4 = st.columns(4)
        col1.metric("🏡 Propriedades", int(row.get('PROPRIEDADES', 0)))
        col2.metric("📡 Sensores Ativos (24h)", int(row.get('SENSORES_ATIVOS', 0)))  # Atualizado
        col3.metric("⚠️ Alertas Críticos Hoje", int(row.get('ALERTAS_CRITICOS_HOJE', 0)))  # Atualizado
        col4.metric("💧 Umidade Média Hoje", f"{float(row.get('UMIDADE_MEDIA_HOJE', 0.0)):.1f}%")  # Atualizado
    else:
        st.warning("⚠️ Não foi possível obter métricas do dashboard.")

    st.subheader("📈 Alertas por Severidade (Últimos 7 dias)")
    alertas_df = get_alertas_severidade()
    if not alertas_df.empty:
        col_severidade = find_column_name(alertas_df, ['CODIGO_SEVERIDADE', 'CODIGO_SEVERIDADE'])
        col_total = find_column_name(alertas_df, ['TOTAL', 'TOTAL'])
        if col_severidade and col_total:
            fig = px.bar(alertas_df, x=col_severidade, y=col_total, title="Distribuição de Alertas",
                         color=col_severidade, labels={col_severidade: "Severidade", col_total: "Total"},
                         text_auto=True)
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.error(f"Colunas esperadas não encontradas no DataFrame de alertas: {alertas_df.columns.tolist()}")
    else:
        st.info("📊 Nenhum alerta encontrado nos últimos 7 dias para exibir no gráfico.")
    log_activity("dashboard_view", {"timestamp": datetime.now().isoformat()})


def oracle_page():
    st.header("📊 Dados Oracle")
    tab1, tab2, tab3 = st.tabs(["🏡 Propriedades Detalhadas", "🔧 Executar Procedures PKG", "📈 Consultas SQL"])

    with tab1:
        st.subheader("Visão Geral das Propriedades com Métricas Calculadas")
        propriedades_df = get_propriedades_com_metricas()
        if not propriedades_df.empty:
            st.dataframe(propriedades_df, use_container_width=True, hide_index=True)
            col_estado_solo = find_column_name(propriedades_df, ["ESTADO SOLO REGISTRADO", "ESTADO SOLO REGISTRADO"])
            if col_estado_solo and col_estado_solo in propriedades_df.columns:
                contagem_estado_solo = propriedades_df[col_estado_solo].value_counts().reset_index()
                if not contagem_estado_solo.empty and 'count' in contagem_estado_solo.columns:  # Verifica se a coluna 'count' existe
                    fig_pie = px.pie(contagem_estado_solo, names=col_estado_solo, values='count',
                                     title="Distribuição por Estado do Solo", hole=0.3)
                    st.plotly_chart(fig_pie, use_container_width=True)
                else:
                    st.warning(
                        "⚠️ Não foi possível gerar o gráfico de pizza do estado do solo (dados insuficientes ou coluna 'count' ausente).")
            else:
                st.warning(
                    f"⚠️ Coluna '{col_estado_solo or 'ESTADO SOLO REGISTRADO'}' não encontrada para o gráfico de pizza.")

        else:
            st.info("📄 Nenhuma propriedade cadastrada ou dados insuficientes.")

    with tab2:
        st.subheader("Executar Procedures do Pacote PKG_WATERWISE")
        available_pkg_procedures = [
            "PKG_WATERWISE.INICIALIZAR_SISTEMA", "PKG_WATERWISE.VALIDAR_INTEGRIDADE_DADOS",
            "PKG_WATERWISE.ANALISAR_ALERTAS_DIARIOS", "PKG_WATERWISE.ESTADO_GERAL_SOLO",
            "PKG_WATERWISE.DASHBOARD_METRICAS", "PKG_WATERWISE.MELHORES_PRODUTORES",
            "PKG_WATERWISE.RISCO_POR_REGIAO", "PKG_WATERWISE.VERIFICAR_RISCO_ENCHENTE",
            "PKG_WATERWISE.RELATORIO_PROPRIEDADE", "PKG_WATERWISE.TENDENCIAS_CLIMATICAS"
        ]
        procedure_to_run = st.selectbox("Selecione a procedure da PKG_WATERWISE:", available_pkg_procedures)
        params_proc = {}

        if procedure_to_run == "PKG_WATERWISE.TENDENCIAS_CLIMATICAS":
            dias_tend = st.number_input("Dias para análise de tendência (p_dias_analise):", min_value=1, value=30,
                                        step=1)
            params_proc['p_dias_analise'] = dias_tend
        elif procedure_to_run == "PKG_WATERWISE.VERIFICAR_RISCO_ENCHENTE":
            id_prop_risco = st.number_input("ID da Propriedade para verificar risco (opcional, deixe 0 para todas):",
                                            min_value=0, value=0, step=1, key="id_risco")
            if id_prop_risco > 0: params_proc['p_id_propriedade'] = id_prop_risco
        elif procedure_to_run == "PKG_WATERWISE.RELATORIO_PROPRIEDADE":
            id_prop_rel = st.number_input("ID da Propriedade para o relatório:", min_value=1, value=1, step=1,
                                          key="id_relatorio")
            params_proc['p_id_propriedade'] = id_prop_rel

        if st.button(f"🚀 Executar {procedure_to_run}"):
            with st.spinner(f"Executando {procedure_to_run}..."):
                success, result_data = execute_oracle_procedure(procedure_to_run, **params_proc)
            if success:
                st.success(f"✅ Chamada para {procedure_to_run} executada!")
                if result_data:
                    unique_key = f"output_{procedure_to_run.replace('.', '_')}_{datetime.now().timestamp()}"
                    st.text_area("Saída da Procedure (DBMS_OUTPUT):", value="\n".join(result_data), height=300,
                                 key=unique_key, help="Esta é a saída gerada pela procedure via DBMS_OUTPUT.")
                else:
                    st.info("ℹ️ A procedure foi executada, mas não produziu saída via DBMS_OUTPUT.")
                log_activity("oracle_procedure_called", {"procedure": procedure_to_run, "params": str(params_proc)})
            else:
                st.error("❌ Falha ao executar a procedure:")
                if result_data:
                    st.text_area("Detalhes do Erro:", value="\n".join(result_data), height=150,
                                 key=f"error_{procedure_to_run.replace('.', '_')}_{datetime.now().timestamp()}")

    with tab3:
        st.subheader("Consulta SQL Personalizada")
        default_query = "SELECT pr.id_propriedade, pr.nome_propriedade, prod.nome_completo AS produtor \nFROM GS_WW_PROPRIEDADE_RURAL pr \nJOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor \nWHERE ROWNUM <= 5"  # Removido ;
        query = st.text_area("Digite sua consulta SQL (sem ';'' no final):", value=default_query, height=150)
        if st.button("🔍 Executar Consulta"):
            with st.spinner("Executando consulta..."):
                result_df = get_oracle_data(query)
            if not result_df.empty:
                st.dataframe(result_df, use_container_width=True, hide_index=True)
                log_activity("custom_query_executed", {"query_executed": query[:200]})
            # else: st.warning("⚠️ A consulta não retornou dados ou falhou.") # get_oracle_data já mostra o erro


def logs_page():
    st.header("📝 Logs de Atividade (MongoDB)")
    if st.button("🔄 Atualizar Logs"): st.rerun()
    logs = get_recent_logs(50)
    if logs:
        st.write(f"📋 Exibindo os {len(logs)} logs mais recentes.")
        try:
            logs_df = pd.DataFrame(logs)
            if not logs_df.empty:
                if 'timestamp' in logs_df.columns:
                    logs_df['timestamp_fmt'] = pd.to_datetime(logs_df['timestamp']).dt.strftime('%d/%m/%Y %H:%M:%S')
                    display_cols_ordered = ['timestamp_fmt', 'type', 'user', 'details', 'source']
                    # Garante que apenas colunas existentes sejam selecionadas
                    actual_display_cols = [col for col in display_cols_ordered if
                                           col in logs_df.columns or col == 'timestamp_fmt']
                    logs_df_display = logs_df[actual_display_cols].rename(
                        columns={'timestamp_fmt': 'Data/Hora', 'type': 'Tipo', 'user': 'Usuário',
                                 'details': 'Detalhes', 'source': 'Origem'})
                    st.dataframe(logs_df_display, hide_index=True, use_container_width=True)
                else:
                    st.dataframe(logs_df, hide_index=True, use_container_width=True)  # Fallback se não houver timestamp
            else:
                st.info("📝 Nenhum log encontrado para exibir.")
        except Exception as e:
            st.error(f"Erro ao processar logs para exibição: {e}")
            st.json(logs)  # Exibe logs brutos em caso de erro no DataFrame
    else:
        st.info("📝 Nenhum log encontrado.")


def reports_page():
    st.header("📋 Relatórios Armazenados (MongoDB)")

    st.subheader("📄 Gerar Novo Relatório Simples")
    with st.form("new_report_form"):
        report_type = st.text_input("Tipo do Relatório (ex: AnaliseDiariaResumida, MedicaoEspecial)")
        report_content_json = st.text_area("Conteúdo do Relatório (em formato JSON)", height=150,
                                           value='{\n  "parametro_exemplo": "valor_exemplo",\n  "dados_coletados": []\n}')
        report_metadata_json = st.text_area("Metadados Adicionais (em formato JSON)", height=100,
                                            value='{\n  "gerado_por": "Interface Streamlit",\n  "id_propriedade_ref": null\n}')
        submitted_report = st.form_submit_button("💾 Salvar Relatório no MongoDB")

        if submitted_report:
            if not report_type or not report_content_json:
                st.error("❌ Tipo e Conteúdo do Relatório são obrigatórios.")
            else:
                try:
                    content = json.loads(report_content_json)
                    metadata = json.loads(report_metadata_json) if report_metadata_json else {}
                    # Usando a função save_report_to_mongo que foi definida anteriormente
                    report_id = save_report_to_mongo(report_type, content, metadata)
                    if report_id:
                        st.success(f"✅ Relatório '{report_type}' salvo com ID: {report_id}")
                        log_activity("mongo_report_saved", {"report_type": report_type, "report_id": report_id})
                        st.rerun()  # Atualiza a lista de relatórios
                    else:
                        st.error("❌ Falha ao salvar o relatório no MongoDB.")
                except json.JSONDecodeError:
                    st.error("❌ Erro ao decodificar JSON do Conteúdo ou Metadados. Verifique o formato.")
                except Exception as e:
                    st.error(f"Erro inesperado ao salvar relatório: {e}")

    st.markdown("---")
    st.subheader("📑 Relatórios Recentes")
    if st.button("🔄 Atualizar Lista de Relatórios"):
        st.rerun()

    # Usando a função get_mongo_reports que foi definida anteriormente
    reports = get_mongo_reports(limit=20)
    if reports:
        st.write(f"📋 Exibindo os {len(reports)} relatórios mais recentes.")
        for report in reports:
            report_id_str = str(report['_id'])
            # Assegura que timestamp é um objeto datetime antes de formatar
            timestamp_val = report.get('timestamp')
            if isinstance(timestamp_val, str):  # Tenta converter se for string
                try:
                    timestamp_val = pd.to_datetime(timestamp_val)
                except ValueError:  # Se a conversão falhar, use um placeholder
                    timestamp_val = None

            date_display = timestamp_val.strftime('%d/%m/%Y %H:%M') if timestamp_val and isinstance(timestamp_val,
                                                                                                    pd.Timestamp) else 'Data Desconhecida'

            with st.expander(f"**{report.get('type', 'N/A')}** ({date_display}) - ID: {report_id_str}"):
                st.json(report.get('metadata', {}))
                if st.button("Ver Conteúdo Completo", key=f"view_content_{report_id_str}"):
                    # Usando a função get_mongo_report_by_id que foi definida anteriormente
                    full_report = get_mongo_report_by_id(report_id_str)
                    if full_report and "content" in full_report:
                        st.json(full_report["content"])
                    else:
                        st.warning("Conteúdo não encontrado ou erro ao buscar.")
    else:
        st.info("📑 Nenhum relatório encontrado no MongoDB.")


def images_page():
    st.header("🖼️ Imagens (MongoDB)")

    st.subheader("📤 Fazer Upload de Nova Imagem")
    # Mover o file_uploader para fora do form para que seu estado persista melhor
    uploaded_file = st.file_uploader("Escolha uma imagem...", type=["jpg", "png", "jpeg", "gif"], key="img_uploader")

    with st.form("new_image_form", clear_on_submit=True):
        # O nome do arquivo pode ser pego de uploaded_file.name se uploaded_file não for None
        # No entanto, como está dentro de um form que pode ser submetido mesmo sem arquivo,
        # é melhor deixar o usuário preencher ou verificar uploaded_file antes de usar .name
        image_filename_default = uploaded_file.name if uploaded_file else ""
        image_filename = st.text_input("Nome do Arquivo (será usado no MongoDB)", value=image_filename_default,
                                       help="Padrão para o nome do arquivo original se um arquivo for selecionado.")

        image_metadata_json = st.text_area("Metadados da Imagem (em formato JSON)", height=100,
                                           value='{\n  "descricao": "",\n  "tags": [],\n  "id_propriedade_ref": null,\n  "id_sensor_ref": null\n}')

        submitted_image = st.form_submit_button("💾 Salvar Imagem no MongoDB")

        if submitted_image:
            if uploaded_file is not None:  # Verifica se um arquivo foi realmente selecionado
                if not image_filename:  # Usa o nome do arquivo original se não preenchido
                    image_filename = uploaded_file.name

                if not image_filename:  # Checa novamente se o nome está vazio
                    st.error("❌ Nome do arquivo é obrigatório.")
                else:
                    try:
                        image_data = uploaded_file.getvalue()
                        metadata = json.loads(image_metadata_json) if image_metadata_json else {}

                        # Usando a função save_image_to_mongo que foi definida anteriormente
                        image_id = save_image_to_mongo(image_filename, image_data, metadata)
                        if image_id:
                            st.success(f"✅ Imagem '{image_filename}' salva com ID: {image_id}")
                            log_activity("mongo_image_saved",
                                         {"filename": image_filename, "image_id": image_id, "size": len(image_data)})
                            # Para atualizar a lista de imagens abaixo, um st.rerun() seria útil,
                            # mas pode causar loop se não tratado com cuidado dentro de um form.
                            # clear_on_submit=True já ajuda a resetar o form.
                        else:
                            st.error("❌ Falha ao salvar a imagem no MongoDB.")
                    except json.JSONDecodeError:
                        st.error("❌ Erro ao decodificar JSON dos Metadados. Verifique o formato.")
                    except Exception as e:
                        st.error(f"Erro inesperado ao salvar imagem: {e}")
            else:
                st.warning("⚠️ Por favor, selecione um arquivo de imagem para fazer upload.")

    st.markdown("---")
    st.subheader("🎨 Imagens Recentes")
    if st.button("🔄 Atualizar Lista de Imagens"):
        st.rerun()

    # Usando a função get_mongo_images que foi definida anteriormente
    images = get_mongo_images(limit=5)
    if images:
        st.write(f"🖼️ Exibindo as {len(images)} imagens mais recentes.")
        for img_meta in images:
            img_id_str = str(img_meta['_id'])

            timestamp_val_img = img_meta.get('timestamp')
            if isinstance(timestamp_val_img, str):
                try:
                    timestamp_val_img = pd.to_datetime(timestamp_val_img)
                except ValueError:
                    timestamp_val_img = None

            date_display_img = timestamp_val_img.strftime('%d/%m/%Y %H:%M') if timestamp_val_img and isinstance(
                timestamp_val_img, pd.Timestamp) else ''

            with st.expander(f"**{img_meta.get('filename', 'Nome Desconhecido')}** ({date_display_img})"):
                st.json(img_meta.get('metadata', {}))
                st.write(f"Tamanho: {img_meta.get('size_bytes', 0) / 1024:.2f} KB")

                if st.button("🖼️ Exibir Imagem", key=f"view_img_{img_id_str}"):
                    with st.spinner("Carregando imagem..."):
                        # Usando a função get_mongo_image_data_by_id que foi definida anteriormente
                        img_data_bytes = get_mongo_image_data_by_id(img_id_str)
                    if img_data_bytes:
                        try:
                            st.image(BytesIO(img_data_bytes))
                        except Exception as e:
                            st.error(f"Não foi possível exibir a imagem. Erro: {e}")
                    else:
                        st.warning("Dados da imagem não encontrados ou erro ao buscar.")
    else:
        st.info("🖼️ Nenhuma imagem encontrada no MongoDB.")



# ============================================================================
# EXECUÇÃO PRINCIPAL
# ============================================================================

if __name__ == "__main__":
    main()