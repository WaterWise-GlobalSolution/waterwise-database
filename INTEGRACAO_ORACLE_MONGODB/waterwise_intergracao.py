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

# ============================================================================
# CONFIGURAÇÕES
# ============================================================================

ORACLE_CONFIG = {
    'host': 'oracle.fiap.com.br',
    'port': 1521,
    'service': 'ORCL',
    'user': 'RM553528',  # Substitua pelo seu usuário Oracle
    'password': '150592'  # Substitua pela sua senha Oracle
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
        db.list_collection_names()
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
    return None


def test_oracle_connection():
    """Testar conexão Oracle com uma consulta simples"""
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
        cursor.close()
        connection.close()
        return result is not None
    except Exception as e:
        st.error(f"Erro ao testar conexão Oracle: {e}")
        return False


def get_oracle_data(query):
    """Executar consulta Oracle"""
    try:
        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )
        df = pd.read_sql(query, connection)  # Usar read_sql para pandas mais recentes
        connection.close()
        return df
    except Exception as e:
        st.error(f"Erro na consulta Oracle: {e}")
        return pd.DataFrame()


def execute_oracle_procedure(procedure_name_full, **params):
    """Executar procedure da PKG_WATERWISE.
       procedure_name_full deve ser 'NOME_PACOTE.NOME_PROCEDURE'
    """
    try:
        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )
        cursor = connection.cursor()

        # Constrói a chamada da procedure dinamicamente
        # Os parâmetros no dicionário 'params' devem corresponder aos nomes na procedure PL/SQL
        param_bindings = [f"{k} => :{k}" for k in params.keys()]
        sql = f"BEGIN {procedure_name_full} ({', '.join(param_bindings)}); END;"

        # Prepara os parâmetros para o cursor.execute
        # Para parâmetros IN OUT que são apenas OUT no contexto de INSERT (ID gerado),
        # o Python os trata como IN. O valor de retorno é manipulado dentro do PL/SQL.
        # Se precisássemos do ID de volta no Python, a abordagem seria diferente (callproc ou bloco PL/SQL com OUT binds).

        # Filtrar parâmetros None que não são IDs para INSERT, se a procedure PL/SQL os tiver como DEFAULT NULL
        # No nosso caso, a procedure PL/SQL já trata NVL para updates.
        # Para IDs em INSERT, passamos None e a procedure PL/SQL usa RETURNING INTO no parâmetro IN OUT.

        cursor.execute(sql, params)

        connection.commit()
        cursor.close()
        connection.close()
        # st.success(f"Procedure {procedure_name_full} executada com sucesso.") # Sucesso é tratado no chamador
        return True
    except Exception as e:
        st.error(f"Erro ao executar {procedure_name_full}: {e}")
        return False


def get_dashboard_metrics():
    """Obter métricas do dashboard"""
    query = """
        SELECT 
            (SELECT COUNT(*) FROM GS_WW_PROPRIEDADE_RURAL) as PROPRIEDADES,
            (SELECT COUNT(*) FROM GS_WW_SENSOR_IOT) as SENSORES,
            (SELECT COUNT(*) FROM GS_WW_ALERTA WHERE timestamp_alerta >= TRUNC(SYSDATE)) as ALERTAS_HOJE,
            (SELECT ROUND(AVG(umidade_solo), 1) FROM GS_WW_LEITURA_SENSOR WHERE timestamp_leitura >= TRUNC(SYSDATE)) as UMIDADE_MEDIA
        FROM DUAL
    """
    df = get_oracle_data(query)
    if not df.empty:
        df = df.fillna(0)  # Preencher com 0 se alguma métrica for NULL
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
        WHERE a.timestamp_alerta >= SYSDATE - 7 -- Alertas dos últimos 7 dias
        GROUP BY ns.codigo_severidade
        ORDER BY CASE ns.codigo_severidade WHEN 'CRITICO' THEN 1 WHEN 'ALTO' THEN 2 WHEN 'MEDIO' THEN 3 ELSE 4 END
    """
    df = get_oracle_data(query)
    if df.empty:
        st.info("📊 Nenhum alerta encontrado nos últimos 7 dias.")
    return df


# ... (demais funções MongoDB e de interface permanecem as mesmas até crud_page) ...
# Vou omitir as funções de MongoDB e as páginas que não mudam para economizar espaço
# As funções main(), dashboard_page(), oracle_page() (exceto a lista de procedures),
# logs_page(), reports_page(), images_page() seriam mantidas como na sua última versão.

# Funções MongoDB (mantidas como na sua versão anterior)
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


def save_report(report_type, content, metadata):
    db = connect_mongodb()
    if db is None: return None
    try:
        result = db.reports.insert_one(
            {"timestamp": datetime.now(), "type": report_type, "content": content, "metadata": metadata,
             "status": "generated"})
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar relatório: {e}"); return None


def save_image(image_name, image_data, metadata):
    db = connect_mongodb()
    if db is None: return None
    try:
        image_b64 = base64.b64encode(image_data).decode()
        result = db.images.insert_one(
            {"timestamp": datetime.now(), "filename": image_name, "metadata": metadata, "image_data": image_b64,
             "size_bytes": len(image_data)})
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar imagem: {e}"); return None


def get_recent_logs(limit=50):
    db = connect_mongodb()
    if db is None: return []
    try:
        return list(db.activity_logs.find().sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter logs: {e}"); return []


def get_reports(limit=20):
    db = connect_mongodb()
    if db is None: return []
    try:
        return list(db.reports.find().sort("timestamp", pymongo.DESCENDING).limit(limit))
    except Exception as e:
        st.error(f"Erro ao obter relatórios: {e}"); return []


# ============================================================================
# PÁGINAS DA INTERFACE (CRUD PAGE ATUALIZADA, OUTRAS MANTIDAS)
# ============================================================================
def crud_page():
    """Página de operações CRUD para Produtor Rural e Propriedade Rural"""
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
                            "v_operacao": "INSERT",
                            "v_id_produtor": None,  # Será IN OUT, mas passamos None para INSERT
                            "v_nome_completo": nome_prod,
                            "v_cpf_cnpj": cpf_cnpj_prod,
                            "v_email": email_prod,
                            "v_telefone": telefone_prod if telefone_prod else None,
                            "v_senha": senha_prod,
                            "v_data_cadastro": datetime.now()  # A procedure PLSQL usa DEFAULT SYSDATE
                        }
                        if execute_oracle_procedure("PKG_WATERWISE.CRUD_PRODUTOR_RURAL", **params):
                            st.success(f"✅ Produtor '{nome_prod}' inserido com sucesso!")
                            log_activity("oracle_crud",
                                         {"entity": "ProdutorRural", "operation": "INSERT", "name": nome_prod})

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
                            "v_operacao": "UPDATE",
                            "v_id_produtor": id_prod_upd,
                            "v_nome_completo": nome_prod_upd if nome_prod_upd else None,
                            "v_cpf_cnpj": cpf_cnpj_prod_upd if cpf_cnpj_prod_upd else None,
                            "v_email": email_prod_upd if email_prod_upd else None,
                            "v_telefone": telefone_prod_upd if telefone_prod_upd else None,
                            "v_senha": senha_prod_upd if senha_prod_upd else None,
                            "v_data_cadastro": None  # Não atualizamos data de cadastro geralmente
                        }
                        # Remover chaves com valor None para que a procedure use NVL corretamente com o valor existente
                        params_clean = {k: v for k, v in params.items() if
                                        v is not None or k == "v_id_produtor" or k == "v_operacao"}

                        if execute_oracle_procedure("PKG_WATERWISE.CRUD_PRODUTOR_RURAL", **params_clean):
                            st.success(f"✅ Produtor ID {id_prod_upd} atualizado!")
                            log_activity("oracle_crud",
                                         {"entity": "ProdutorRural", "operation": "UPDATE", "id": id_prod_upd})

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
                        if execute_oracle_procedure("PKG_WATERWISE.CRUD_PRODUTOR_RURAL", **params):
                            st.success(
                                f"✅ Produtor ID {id_prod_del} deletado (e dados dependentes, se configurado na procedure)!")
                            log_activity("oracle_crud",
                                         {"entity": "ProdutorRural", "operation": "DELETE", "id": id_prod_del})

    elif entity == "Propriedade Rural":
        st.subheader("🏡 Gerenciar Propriedades Rurais")
        operation_prop = st.selectbox("Operação para Propriedade Rural:",
                                      ["Inserir Nova", "Atualizar Existente", "Deletar"])

        # Para selects de ID_PRODUTOR e ID_NIVEL_DEGRADACAO
        produtores_df = get_oracle_data(
            "SELECT ID_PRODUTOR, NOME_COMPLETO || ' (' || CPF_CNPJ || ')' AS PRODUTOR_INFO FROM GS_WW_PRODUTOR_RURAL ORDER BY NOME_COMPLETO")
        niveis_degradacao_df = get_oracle_data(
            "SELECT ID_NIVEL_DEGRADACAO, CODIGO_DEGRADACAO || ' - ' || DESCRICAO_DEGRADACAO AS NIVEL_INFO FROM GS_WW_NIVEL_DEGRADACAO_SOLO ORDER BY NIVEL_NUMERICO")

        produtores_map = {}
        if not produtores_df.empty:
            produtores_map = pd.Series(produtores_df.ID_PRODUTOR.values, index=produtores_df.PRODUTOR_INFO).to_dict()

        niveis_map = {}
        if not niveis_degradacao_df.empty:
            niveis_map = pd.Series(niveis_degradacao_df.ID_NIVEL_DEGRADACAO.values,
                                   index=niveis_degradacao_df.NIVEL_INFO).to_dict()

        if operation_prop == "Inserir Nova":
            with st.form("new_propriedade_form"):
                st.markdown("**Dados da Nova Propriedade:**")
                id_prod_prop = st.selectbox("Produtor Responsável*", options=list(produtores_map.keys()),
                                            format_func=lambda x: x) if produtores_map else st.text_input(
                    "ID do Produtor* (manual se lista vazia)")
                id_nivel_deg_prop = st.selectbox("Nível de Degradação do Solo*", options=list(niveis_map.keys()),
                                                 format_func=lambda x: x) if niveis_map else st.text_input(
                    "ID Nível Degradação* (manual)")

                nome_prop = st.text_input("Nome da Propriedade*")
                cols_geo = st.columns(2)
                with cols_geo[0]:
                    latitude_prop = st.number_input("Latitude*", format="%.7f")
                with cols_geo[1]:
                    longitude_prop = st.number_input("Longitude*", format="%.7f")
                area_prop = st.number_input("Área (Hectares)*", min_value=0.01, format="%.2f")

                submitted = st.form_submit_button("💾 Inserir Propriedade")
                if submitted:
                    id_prod_selected = produtores_map.get(id_prod_prop) if produtores_map else (
                        int(id_prod_prop) if id_prod_prop else None)
                    id_nivel_selected = niveis_map.get(id_nivel_deg_prop) if niveis_map else (
                        int(id_nivel_deg_prop) if id_nivel_deg_prop else None)

                    if not all([id_prod_selected, id_nivel_selected, nome_prop, latitude_prop is not None,
                                longitude_prop is not None, area_prop]):
                        st.error("❌ Preencha todos os campos obrigatórios (*).")
                    else:
                        params = {
                            "v_operacao": "INSERT",
                            "v_id_propriedade": None,  # Será IN OUT
                            "v_id_produtor": id_prod_selected,
                            "v_id_nivel_degradacao": id_nivel_selected,
                            "v_nome_propriedade": nome_prop,
                            "v_latitude": latitude_prop,
                            "v_longitude": longitude_prop,
                            "v_area_hectares": area_prop
                        }
                        if execute_oracle_procedure("PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL", **params):
                            st.success(f"✅ Propriedade '{nome_prop}' inserida!")
                            log_activity("oracle_crud",
                                         {"entity": "PropriedadeRural", "operation": "INSERT", "name": nome_prop})

        elif operation_prop == "Atualizar Existente":
            with st.form("update_propriedade_form"):
                st.markdown("**Atualizar Dados da Propriedade:**")
                id_prop_upd = st.number_input("ID da Propriedade a Atualizar*", min_value=1, step=1)
                st.markdown("*Deixe campos em branco/não selecionados para não alterá-los.*")

                id_prod_prop_upd = st.selectbox("Novo Produtor Responsável",
                                                options=[None] + list(produtores_map.keys()), format_func=lambda
                        x: x if x else "Não alterar") if produtores_map else st.number_input(
                    "Novo ID Produtor (opcional)", value=None)
                id_nivel_deg_prop_upd = st.selectbox("Novo Nível de Degradação",
                                                     options=[None] + list(niveis_map.keys()), format_func=lambda
                        x: x if x else "Não alterar") if niveis_map else st.number_input(
                    "Novo ID Nível Degradação (opcional)", value=None)

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
                            id_prod_prop_upd) if produtores_map and id_prod_prop_upd else (
                            int(id_prod_prop_upd) if isinstance(id_prod_prop_upd,
                                                                str) and id_prod_prop_upd.isdigit() else id_prod_prop_upd)
                        id_nivel_selected_upd = niveis_map.get(
                            id_nivel_deg_prop_upd) if niveis_map and id_nivel_deg_prop_upd else (
                            int(id_nivel_deg_prop_upd) if isinstance(id_nivel_deg_prop_upd,
                                                                     str) and id_nivel_deg_prop_upd.isdigit() else id_nivel_deg_prop_upd)

                        params = {
                            "v_operacao": "UPDATE",
                            "v_id_propriedade": id_prop_upd,
                            "v_id_produtor": id_prod_selected_upd,
                            "v_id_nivel_degradacao": id_nivel_selected_upd,
                            "v_nome_propriedade": nome_prop_upd if nome_prop_upd else None,
                            "v_latitude": latitude_prop_upd,
                            "v_longitude": longitude_prop_upd,
                            "v_area_hectares": area_prop_upd
                        }
                        params_clean = {k: v for k, v in params.items() if
                                        v is not None or k == "v_id_propriedade" or k == "v_operacao"}

                        if execute_oracle_procedure("PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL", **params_clean):
                            st.success(f"✅ Propriedade ID {id_prop_upd} atualizada!")
                            log_activity("oracle_crud",
                                         {"entity": "PropriedadeRural", "operation": "UPDATE", "id": id_prop_upd})

        elif operation_prop == "Deletar":
            with st.form("delete_propriedade_form"):
                st.markdown("**Deletar Propriedade Rural:**")
                id_prop_del = st.number_input("ID da Propriedade a Deletar*", min_value=1, step=1)
                confirm_delete_prop = st.checkbox(
                    f"Confirmo que desejo deletar a propriedade ID {id_prop_del}. Esta ação não pode ser desfeita e pode afetar sensores e leituras associados.")

                submitted = st.form_submit_button("🗑️ Deletar Propriedade")
                if submitted:
                    if not id_prop_del:
                        st.error("❌ ID da Propriedade é obrigatório para deleção.")
                    elif not confirm_delete_prop:
                        st.warning("⚠️ Confirme a deleção marcando a caixa de seleção.")
                    else:
                        params = {"v_operacao": "DELETE", "v_id_propriedade": id_prop_del}
                        if execute_oracle_procedure("PKG_WATERWISE.CRUD_PROPRIEDADE_RURAL", **params):
                            st.success(
                                f"✅ Propriedade ID {id_prop_del} deletada (e dados dependentes, conforme configurado na procedure)!")
                            log_activity("oracle_crud",
                                         {"entity": "PropriedadeRural", "operation": "DELETE", "id": id_prop_del})

    # Adicionar CRUD para Sensor IoT, Leitura Sensor, Alerta etc. se necessário,
    # seguindo o mesmo padrão.
    st.markdown("---")
    st.info("💡 CRUD para Sensor IoT, Leitura de Sensor e Alertas podem ser adicionados aqui seguindo o mesmo padrão.")


# Definição das outras páginas (main, dashboard_page, oracle_page, logs_page, reports_page, images_page)
# Elas seriam mantidas conforme a sua última versão do script, com pequenos ajustes se necessário
# para nomes de colunas ou chamadas de função.
# Por exemplo, na oracle_page, a lista de procedures para execução manual pode ser atualizada.

def main():
    """Função principal"""
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
            st.error("🔴 MongoDB: Desconectado")  # connect_mongodb já mostra erro, mas para consistência
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
        crud_page()  # Renomeado para Gerenciar Dados


def dashboard_page():
    st.header("🏠 Dashboard Principal")
    metrics_df = get_dashboard_metrics()
    if not metrics_df.empty:
        row = metrics_df.iloc[0]
        col1, col2, col3, col4 = st.columns(4)
        col1.metric("🏡 Propriedades", int(row.get('PROPRIEDADES', 0)))
        col2.metric("📡 Sensores", int(row.get('SENSORES', 0)))
        col3.metric("⚠️ Alertas Hoje", int(row.get('ALERTAS_HOJE', 0)))
        col4.metric("💧 Umidade Média", f"{float(row.get('UMIDADE_MEDIA', 0.0)):.1f}%")
    else:
        st.warning("⚠️ Não foi possível obter métricas do dashboard.")
        # ... (métricas padrão)

    st.subheader("📈 Alertas por Severidade (Últimos 7 dias)")
    alertas_df = get_alertas_severidade()
    if not alertas_df.empty:
        col_severidade = find_column_name(alertas_df, ['CODIGO_SEVERIDADE'])
        col_total = find_column_name(alertas_df, ['TOTAL'])
        if col_severidade and col_total:
            fig = px.bar(alertas_df, x=col_severidade, y=col_total, title="Distribuição de Alertas",
                         color=col_severidade, labels={col_severidade: "Severidade", col_total: "Total"},
                         text_auto=True)
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.error(f"Colunas esperadas não encontradas no DataFrame de alertas: {alertas_df.columns.tolist()}")
    log_activity("dashboard_view", {"timestamp": datetime.now().isoformat()})


def oracle_page():
    st.header("📊 Dados Oracle")
    tab1, tab2, tab3 = st.tabs(["🏡 Propriedades Detalhadas", "🔧 Executar Procedures PKG", "📈 Consultas SQL"])

    with tab1:
        st.subheader("Visão Geral das Propriedades com Métricas Calculadas")
        propriedades_df = get_propriedades_com_metricas()  # Função atualizada
        if not propriedades_df.empty:
            st.dataframe(propriedades_df, use_container_width=True, hide_index=True)
            col_estado_solo = find_column_name(propriedades_df, ["ESTADO SOLO REGISTRADO"])
            if col_estado_solo and col_estado_solo in propriedades_df.columns:
                contagem_estado_solo = propriedades_df[col_estado_solo].value_counts().reset_index()
                # contagem_estado_solo.columns = [col_estado_solo, 'count'] # já vem com nomes corretos
                fig_pie = px.pie(contagem_estado_solo, names=col_estado_solo, values='count',
                                 title="Distribuição por Estado do Solo", hole=0.3)
                st.plotly_chart(fig_pie, use_container_width=True)
        else:
            st.info("📄 Nenhuma propriedade cadastrada ou dados insuficientes.")

    with tab2:
        st.subheader("Executar Procedures do Pacote PKG_WATERWISE")
        # Lista de procedures que fazem sentido para execução manual (sem parâmetros complexos ou com defaults)
        available_pkg_procedures = [
            "PKG_WATERWISE.INICIALIZAR_SISTEMA",
            "PKG_WATERWISE.VALIDAR_INTEGRIDADE_DADOS",
            "PKG_WATERWISE.ANALISAR_ALERTAS_DIARIOS",
            "PKG_WATERWISE.STATUS_SENSORES",
            "PKG_WATERWISE.RESUMO_DIARIO_SISTEMA",
            "PKG_WATERWISE.LISTAR_ALERTAS_RECENTES",
            "PKG_WATERWISE.ESTADO_GERAL_SOLO",
            "PKG_WATERWISE.PROPRIEDADES_RISCO_ENCHENTE",
            "PKG_WATERWISE.DASHBOARD_METRICAS",
            "PKG_WATERWISE.MELHORES_PRODUTORES",
            "PKG_WATERWISE.RISCO_POR_REGIAO",
            "PKG_WATERWISE.SEVERIDADE_ALERTAS",
            "PKG_WATERWISE.MONITORAMENTO_TEMPO_REAL",
            "PKG_WATERWISE.PRODUTIVIDADE_POR_REGIAO",
            "PKG_WATERWISE.BACKUP_DADOS_CRITICOS"
            # Adicionar outras como PKG_WATERWISE.TENDENCIAS_CLIMATICAS (precisaria de input para p_dias)
            # PKG_WATERWISE.VERIFICAR_RISCO_ENCHENTE e PKG_WATERWISE.RELATORIO_PROPRIEDADE precisam de ID
        ]
        procedure_to_run = st.selectbox("Selecione a procedure da PKG_WATERWISE:", available_pkg_procedures)

        params_proc = {}
        if procedure_to_run == "PKG_WATERWISE.TENDENCIAS_CLIMATICAS":  # Exemplo de procedure com param
            dias_tend = st.number_input("Dias para análise de tendência (p_dias_analise):", min_value=1, value=30,
                                        step=1)
            params_proc['p_dias_analise'] = dias_tend
        # Adicionar inputs para VERIFICAR_RISCO_ENCHENTE e RELATORIO_PROPRIEDADE se selecionadas

        if st.button(f"🚀 Executar {procedure_to_run}"):
            st.info(
                f"A saída da procedure '{procedure_to_run}' será exibida no console do servidor Oracle (DBMS_OUTPUT).")
            if execute_oracle_procedure(procedure_to_run, **params_proc):
                st.success(f"✅ Chamada para {procedure_to_run} enviada com sucesso!")
                log_activity("oracle_procedure_called", {"procedure": procedure_to_run, "params": params_proc})

    with tab3:  # Consulta SQL Personalizada (mantida)
        st.subheader("Consulta SQL Personalizada")
        default_query = "SELECT pr.id_propriedade, pr.nome_propriedade, prod.nome_completo AS produtor \nFROM GS_WW_PROPRIEDADE_RURAL pr \nJOIN GS_WW_PRODUTOR_RURAL prod ON pr.id_produtor = prod.id_produtor \nWHERE ROWNUM <= 5;"
        query = st.text_area("Digite sua consulta SQL:", value=default_query, height=150)
        if st.button("🔍 Executar Consulta"):
            with st.spinner("Executando consulta..."):
                result_df = get_oracle_data(query)
            if not result_df.empty:
                st.dataframe(result_df, use_container_width=True, hide_index=True)
                log_activity("custom_query_executed", {"query_executed": query[:200]})
            else:
                st.warning("⚠️ A consulta não retornou dados ou falhou.")


# As funções logs_page, reports_page, images_page podem ser mantidas como na sua última versão.
# Vou adicionar versões simplificadas para manter o foco no CRUD.

def logs_page():
    st.header("📝 Logs de Atividade (MongoDB)")
    if st.button("🔄 Atualizar Logs"): st.rerun()
    logs = get_recent_logs(50)
    if logs:
        st.write(f"📋 Exibindo os {len(logs)} logs mais recentes.")
        logs_df = pd.DataFrame(logs)
        if not logs_df.empty:
            logs_df['timestamp_fmt'] = pd.to_datetime(logs_df['timestamp']).dt.strftime('%d/%m/%Y %H:%M:%S')
            display_cols = ['timestamp_fmt', 'type', 'user', 'details', 'source']
            logs_df_display = logs_df[display_cols].rename(
                columns={'timestamp_fmt': 'Data/Hora', 'type': 'Tipo', 'user': 'Usuário', 'details': 'Detalhes',
                         'source': 'Origem'})
            st.dataframe(logs_df_display, hide_index=True, use_container_width=True)
    else:
        st.info("📝 Nenhum log encontrado.")


def reports_page():
    st.header("📋 Relatórios (MongoDB)")
    st.info("Funcionalidade de relatórios a ser implementada ou mantida da versão anterior.")


def images_page():
    st.header("🖼️ Upload Imagens (MongoDB)")
    st.info("Funcionalidade de upload de imagens a ser implementada ou mantida da versão anterior.")


# ============================================================================
# EXECUÇÃO PRINCIPAL
# ============================================================================

if __name__ == "__main__":
    main()