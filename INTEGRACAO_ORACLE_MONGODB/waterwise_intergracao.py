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
    'user': 'RM553528',
    'password': '150592'
}

# Configurações MongoDB
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
        # Teste a conexão fazendo uma operação simples
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
        # Criar nova conexão para cada consulta
        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )

        df = pd.read_sql(query, connection)
        connection.close()
        return df

    except Exception as e:
        st.error(f"Erro na consulta Oracle: {e}")
        return pd.DataFrame()


def execute_oracle_procedure(procedure_name, **params):
    """Executar procedure da PKG_WATERWISE"""
    try:
        # Criar nova conexão para cada procedure
        connection = oracledb.connect(
            user=ORACLE_CONFIG['user'],
            password=ORACLE_CONFIG['password'],
            host=ORACLE_CONFIG['host'],
            port=ORACLE_CONFIG['port'],
            service_name=ORACLE_CONFIG['service']
        )

        cursor = connection.cursor()

        if params:
            param_str = ", ".join([f"{k} => :{k}" for k in params.keys()])
            sql = f"BEGIN PKG_WATERWISE.{procedure_name}({param_str}); END;"
            cursor.execute(sql, params)
        else:
            sql = f"BEGIN PKG_WATERWISE.{procedure_name}; END;"
            cursor.execute(sql)

        connection.commit()
        cursor.close()
        connection.close()
        return True

    except Exception as e:
        st.error(f"Erro ao executar {procedure_name}: {e}")
        return False


def get_dashboard_metrics():
    """Obter métricas do dashboard"""
    # Primeira tentativa: consulta completa
    query = """
        SELECT 
            COUNT(DISTINCT pr.id_propriedade) as PROPRIEDADES,
            COUNT(DISTINCT si.id_sensor) as SENSORES,
            COUNT(DISTINCT a.id_alerta) as ALERTAS_HOJE,
            ROUND(AVG(ls.umidade_solo), 1) as UMIDADE_MEDIA
        FROM GS_WW_PROPRIEDADE_RURAL pr
        LEFT JOIN GS_WW_SENSOR_IOT si ON pr.id_propriedade = si.id_propriedade
        LEFT JOIN GS_WW_LEITURA_SENSOR ls ON si.id_sensor = ls.id_sensor
            AND ls.timestamp_leitura >= TRUNC(SYSDATE)
        LEFT JOIN GS_WW_ALERTA a ON a.timestamp_alerta >= TRUNC(SYSDATE)
    """

    df = get_oracle_data(query)

    # Se a consulta complexa falhar, tenta uma simples
    if df.empty:
        st.warning("⚠️ Consulta complexa falhou, tentando consulta simples...")
        simple_query = """
            SELECT 
                COUNT(*) as PROPRIEDADES,
                0 as SENSORES,
                0 as ALERTAS_HOJE,
                0 as UMIDADE_MEDIA
            FROM GS_WW_PROPRIEDADE_RURAL
        """
        df = get_oracle_data(simple_query)

    return df


def get_propriedades():
    """Obter lista de propriedades"""
    query = """
        SELECT 
            pr.id_propriedade as ID,
            pr.nome_propriedade as PROPRIEDADE,
            prod.nome_completo as PRODUTOR,
            pr.area_hectares as AREA_HA,
            nd.descricao_degradacao as ESTADO_SOLO
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
    """
    df = get_oracle_data(query)

    # Se não houver dados, retorna DataFrame vazio mas sem erro
    if df.empty:
        st.info("📊 Conectado ao Oracle, mas nenhum alerta encontrado nos últimos 7 dias")

    return df


# ============================================================================
# FUNÇÕES MONGODB
# ============================================================================

def log_activity(activity_type, details, user="system"):
    """Registrar atividade no MongoDB"""
    db = connect_mongodb()
    if db is None:
        return False

    try:
        log_entry = {
            "timestamp": datetime.now(),
            "type": activity_type,
            "user": user,
            "details": details,
            "source": "streamlit_interface"
        }
        db.activity_logs.insert_one(log_entry)
        return True
    except Exception as e:
        st.error(f"Erro ao registrar log: {e}")
        return False


def save_report(report_type, content, metadata):
    """Salvar relatório no MongoDB"""
    db = connect_mongodb()
    if db is None:
        return None

    try:
        report = {
            "timestamp": datetime.now(),
            "type": report_type,
            "content": content,
            "metadata": metadata,
            "status": "generated"
        }
        result = db.reports.insert_one(report)
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar relatório: {e}")
        return None


def save_image(image_name, image_data, metadata):
    """Salvar imagem no MongoDB"""
    db = connect_mongodb()
    if db is None:
        return None

    try:
        image_b64 = base64.b64encode(image_data).decode()

        image_doc = {
            "timestamp": datetime.now(),
            "filename": image_name,
            "metadata": metadata,
            "image_data": image_b64,
            "size_bytes": len(image_data)
        }
        result = db.images.insert_one(image_doc)
        return str(result.inserted_id)
    except Exception as e:
        st.error(f"Erro ao salvar imagem: {e}")
        return None


def get_recent_logs(limit=50):
    """Obter logs recentes"""
    db = connect_mongodb()
    if db is None:
        return []

    try:
        logs = list(db.activity_logs.find()
                    .sort("timestamp", -1)
                    .limit(limit))
        return logs
    except Exception as e:
        st.error(f"Erro ao obter logs: {e}")
        return []


def get_reports(limit=20):
    """Obter relatórios"""
    db = connect_mongodb()
    if db is None:
        return []

    try:
        reports = list(db.reports.find()
                       .sort("timestamp", -1)
                       .limit(limit))
        return reports
    except Exception as e:
        st.error(f"Erro ao obter relatórios: {e}")
        return []


# ============================================================================
# INTERFACE STREAMLIT
# ============================================================================

def main():
    """Função principal"""
    st.set_page_config(
        page_title="WaterWise - Sistema Integrado",
        page_icon="🌊",
        layout="wide"
    )

    # Título principal
    st.title("🌊 WaterWise - Sistema Integrado")
    st.markdown("**Oracle + MongoDB** | Monitoramento Agrícola Sustentável")

    # Sidebar
    st.sidebar.title("Navegação")

    # Testar conexões
    with st.sidebar:
        st.subheader("📡 Status Conexões")

        # Oracle
        if test_oracle_connection():
            st.success("🟢 Oracle: Conectado")
        else:
            st.error("🔴 Oracle: Desconectado")

        # MongoDB
        mongo_db = connect_mongodb()
        if mongo_db is not None:
            st.success("🟢 MongoDB: Conectado")
        else:
            st.error("🔴 MongoDB: Desconectado")

        st.markdown("---")

    # Menu de navegação
    menu = st.sidebar.selectbox(
        "Selecione a página:",
        [
            "🏠 Dashboard",
            "📊 Dados Oracle",
            "📝 Logs MongoDB",
            "📋 Relatórios",
            "🖼️ Upload Imagens",
            "⚙️ Operações CRUD"
        ]
    )

    # Roteamento de páginas
    if menu == "🏠 Dashboard":
        dashboard_page()
    elif menu == "📊 Dados Oracle":
        oracle_page()
    elif menu == "📝 Logs MongoDB":
        logs_page()
    elif menu == "📋 Relatórios":
        reports_page()
    elif menu == "🖼️ Upload Imagens":
        images_page()
    elif menu == "⚙️ Operações CRUD":
        crud_page()


# ============================================================================
# PÁGINAS DA INTERFACE
# ============================================================================

def dashboard_page():
    """Página do dashboard"""
    st.header("🏠 Dashboard Principal")

    # Métricas principais
    metrics_df = get_dashboard_metrics()

    if not metrics_df.empty:
        # Debug: mostrar colunas disponíveis
        st.write("DEBUG - Colunas disponíveis:", metrics_df.columns.tolist())

        row = metrics_df.iloc[0]

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            # Tenta diferentes variações de nome da coluna
            propriedades = 0
            for col_name in ['PROPRIEDADES', 'propriedades', 'Propriedades']:
                if col_name in metrics_df.columns:
                    propriedades = int(row[col_name] or 0)
                    break
            st.metric("🏡 Propriedades", propriedades)

        with col2:
            sensores = 0
            for col_name in ['SENSORES', 'sensores', 'Sensores']:
                if col_name in metrics_df.columns:
                    sensores = int(row[col_name] or 0)
                    break
            st.metric("📡 Sensores", sensores)

        with col3:
            alertas = 0
            for col_name in ['ALERTAS_HOJE', 'alertas_hoje', 'Alertas_Hoje']:
                if col_name in metrics_df.columns:
                    alertas = int(row[col_name] or 0)
                    break
            st.metric("⚠️ Alertas Hoje", alertas)

        with col4:
            umidade = 0
            for col_name in ['UMIDADE_MEDIA', 'umidade_media', 'Umidade_Media']:
                if col_name in metrics_df.columns:
                    umidade = float(row[col_name] or 0)
                    break
            st.metric("💧 Umidade Média", f"{umidade:.1f}%")
    else:
        st.warning("⚠️ Não foi possível obter métricas do dashboard")

        # Métricas padrão quando não há dados
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("🏡 Propriedades", 0)
        with col2:
            st.metric("📡 Sensores", 0)
        with col3:
            st.metric("⚠️ Alertas Hoje", 0)
        with col4:
            st.metric("💧 Umidade Média", "0.0%")

    # Gráfico de alertas por severidade
    st.subheader("📈 Alertas por Severidade (Últimos 7 dias)")

    alertas_df = get_alertas_severidade()

    if not alertas_df.empty:
        # Debug: mostrar colunas disponíveis
        st.write("DEBUG - Colunas alertas:", alertas_df.columns.tolist())

        # Encontrar nomes corretos das colunas
        col_severidade = find_column_name(alertas_df, ['CODIGO_SEVERIDADE', 'codigo_severidade', 'Codigo_Severidade'])
        col_total = find_column_name(alertas_df, ['TOTAL', 'total', 'Total'])

        if col_severidade and col_total:
            fig = px.bar(
                alertas_df,
                x=col_severidade,
                y=col_total,
                title="Distribuição de Alertas",
                color=col_severidade
            )
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.error(f"❌ Colunas não encontradas. Disponíveis: {alertas_df.columns.tolist()}")
    else:
        st.info("📊 Nenhum alerta nos últimos 7 dias")

    # Log da visualização
    log_activity("dashboard_view", {
        "timestamp": datetime.now().isoformat()
    })


def oracle_page():
    """Página de dados Oracle"""
    st.header("📊 Dados Oracle")

    tab1, tab2, tab3 = st.tabs(["🏡 Propriedades", "🔧 Procedures", "📈 Consultas"])

    with tab1:
        st.subheader("Propriedades Cadastradas")

        propriedades_df = get_propriedades()

        if not propriedades_df.empty:
            st.dataframe(propriedades_df, use_container_width=True)

            # Gráfico por estado do solo
            if 'ESTADO_SOLO' in propriedades_df.columns:
                fig = px.pie(
                    propriedades_df,
                    names='ESTADO_SOLO',
                    title="Distribuição por Estado do Solo"
                )
                st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("📄 Nenhuma propriedade cadastrada")

    with tab2:
        st.subheader("Executar Procedures PKG_WATERWISE")

        procedure = st.selectbox(
            "Selecione a procedure:",
            [
                "INICIALIZAR_SISTEMA",
                "VALIDAR_INTEGRIDADE_DADOS",
                "STATUS_SENSORES",
                "ANALISAR_ALERTAS_DIARIOS",
                "DASHBOARD_METRICAS"
            ]
        )

        if st.button("🚀 Executar Procedure"):
            with st.spinner(f"Executando {procedure}..."):
                if execute_oracle_procedure(procedure):
                    st.success(f"✅ {procedure} executada com sucesso!")

                    # Log da execução
                    log_activity("procedure_executed", {
                        "procedure": procedure,
                        "timestamp": datetime.now().isoformat()
                    })
                else:
                    st.error(f"❌ Erro ao executar {procedure}")

    with tab3:
        st.subheader("Consulta Personalizada")

        query = st.text_area(
            "Digite sua consulta SQL:",
            value="SELECT COUNT(*) FROM GS_WW_PROPRIEDADE_RURAL",
            height=100
        )

        if st.button("🔍 Executar Consulta"):
            result_df = get_oracle_data(query)

            if not result_df.empty:
                st.dataframe(result_df, use_container_width=True)
            else:
                st.warning("⚠️ Consulta não retornou dados")


def logs_page():
    """Página de logs MongoDB"""
    st.header("📝 Logs MongoDB")

    col1, col2 = st.columns([3, 1])

    with col1:
        st.subheader("Logs Recentes")

    with col2:
        if st.button("🔄 Atualizar"):
            st.rerun()

    # Obter logs
    logs = get_recent_logs(50)

    if logs:
        st.write(f"📋 Exibindo {len(logs)} logs mais recentes")

        for log in logs:
            with st.expander(f"{log['type']} - {log['timestamp'].strftime('%d/%m/%Y %H:%M:%S')}"):
                st.json({
                    "Tipo": log['type'],
                    "Usuário": log['user'],
                    "Timestamp": log['timestamp'].isoformat(),
                    "Detalhes": log['details'],
                    "Origem": log['source']
                })
    else:
        st.info("📝 Nenhum log encontrado")

    # Adicionar log de teste
    st.subheader("Adicionar Log de Teste")

    col1, col2 = st.columns(2)

    with col1:
        log_type = st.text_input("Tipo do Log", value="test_log")

    with col2:
        log_user = st.text_input("Usuário", value="admin")

    log_message = st.text_area("Mensagem", value="Log de teste criado via interface")

    if st.button("📝 Adicionar Log"):
        if log_activity(log_type, {"message": log_message}, log_user):
            st.success("✅ Log adicionado com sucesso!")
            st.rerun()


def reports_page():
    """Página de relatórios"""
    st.header("📋 Relatórios MongoDB")

    tab1, tab2 = st.tabs(["📄 Criar Relatório", "📚 Visualizar Relatórios"])

    with tab1:
        st.subheader("Criar Novo Relatório")

        report_type = st.selectbox(
            "Tipo de Relatório:",
            ["Análise Mensal", "Relatório de Incidentes", "Avaliação de Solo", "Relatório Customizado"]
        )

        content = st.text_area("Conteúdo do Relatório:", height=200)

        col1, col2 = st.columns(2)

        with col1:
            author = st.text_input("Autor:", value="Admin")

        with col2:
            tags = st.text_input("Tags (separadas por vírgula):", value="mensal,análise")

        if st.button("💾 Salvar Relatório"):
            if content:
                metadata = {
                    "author": author,
                    "tags": [tag.strip() for tag in tags.split(",")],
                    "word_count": len(content.split())
                }

                report_id = save_report(report_type, content, metadata)

                if report_id:
                    st.success(f"✅ Relatório salvo! ID: {report_id}")

                    # Log da criação
                    log_activity("report_created", {
                        "report_id": report_id,
                        "type": report_type
                    })
            else:
                st.error("❌ Conteúdo é obrigatório!")

    with tab2:
        st.subheader("Relatórios Salvos")

        reports = get_reports(10)

        if reports:
            for report in reports:
                with st.expander(f"{report['type']} - {report['timestamp'].strftime('%d/%m/%Y %H:%M')}"):
                    st.write("**Conteúdo:**")
                    st.write(report['content'])
                    st.write("**Metadados:**")
                    st.json(report['metadata'])
        else:
            st.info("📄 Nenhum relatório encontrado")


def images_page():
    """Página de upload de imagens"""
    st.header("🖼️ Upload de Imagens")

    st.subheader("Enviar Imagem da Propriedade")

    # Upload de arquivo
    uploaded_file = st.file_uploader(
        "Escolha uma imagem:",
        type=['png', 'jpg', 'jpeg', 'gif']
    )

    if uploaded_file is not None:
        # Exibir preview
        st.image(uploaded_file, caption=uploaded_file.name, width=300)

        # Metadados
        col1, col2 = st.columns(2)

        with col1:
            property_id = st.number_input("ID da Propriedade:", min_value=1, value=1)
            image_type = st.selectbox("Tipo:", ["Visão Geral", "Solo", "Cultivo", "Sensor", "Problema"])

        with col2:
            description = st.text_area("Descrição:", height=100)
            coordinates = st.text_input("Coordenadas GPS (lat,lng):", placeholder="-23.5505,-46.6333")

        if st.button("💾 Salvar Imagem"):
            metadata = {
                "property_id": property_id,
                "image_type": image_type,
                "description": description,
                "coordinates": coordinates if coordinates else None,
                "file_size": len(uploaded_file.getvalue())
            }

            image_id = save_image(uploaded_file.name, uploaded_file.getvalue(), metadata)

            if image_id:
                st.success(f"✅ Imagem salva! ID: {image_id}")

                # Log do upload
                log_activity("image_uploaded", {
                    "image_id": image_id,
                    "filename": uploaded_file.name,
                    "property_id": property_id
                })


def crud_page():
    """Página de operações CRUD"""
    st.header("⚙️ Operações CRUD")

    operation = st.selectbox(
        "Operação:",
        [
            "Inserir Produtor Rural",
            "Inserir Propriedade Rural",
            "Inserir Sensor IoT",
            "Inserir Leitura Sensor",
            "Inserir Alerta"
        ]
    )

    if operation == "Inserir Produtor Rural":
        st.subheader("👨‍🌾 Novo Produtor Rural")

        with st.form("produtor_form"):
            col1, col2 = st.columns(2)

            with col1:
                nome = st.text_input("Nome Completo*")
                cpf_cnpj = st.text_input("CPF/CNPJ*")

            with col2:
                email = st.text_input("Email*")
                telefone = st.text_input("Telefone*")

            submitted = st.form_submit_button("💾 Inserir")

            if submitted and all([nome, cpf_cnpj, email, telefone]):
                params = {
                    "v_operacao": "INSERT",
                    "v_id_produtor": None,
                    "v_nome_completo": nome,
                    "v_cpf_cnpj": cpf_cnpj,
                    "v_email": email,
                    "v_telefone": telefone
                }

                if execute_oracle_procedure("CRUD_PRODUTOR_RURAL", **params):
                    st.success("✅ Produtor inserido com sucesso!")

                    # Log da inserção
                    log_activity("produtor_inserted", {
                        "nome": nome,
                        "cpf_cnpj": cpf_cnpj[:3] + "***"
                    })

    elif operation == "Inserir Leitura Sensor":
        st.subheader("📊 Nova Leitura de Sensor")

        with st.form("leitura_form"):
            col1, col2 = st.columns(2)

            with col1:
                id_sensor = st.number_input("ID Sensor*", min_value=1, value=1)
                umidade = st.number_input("Umidade (%)", min_value=0.0, max_value=100.0, value=65.5)

            with col2:
                temperatura = st.number_input("Temperatura (°C)", min_value=-50.0, max_value=70.0, value=25.0)
                precipitacao = st.number_input("Precipitação (mm)", min_value=0.0, value=0.0)

            submitted = st.form_submit_button("💾 Inserir")

            if submitted:
                params = {
                    "v_operacao": "INSERT",
                    "v_id_leitura": None,
                    "v_id_sensor": id_sensor,
                    "v_umidade_solo": umidade,
                    "v_temperatura_ar": temperatura,
                    "v_precipitacao_mm": precipitacao
                }

                if execute_oracle_procedure("CRUD_LEITURA_SENSOR", **params):
                    st.success("✅ Leitura inserida com sucesso!")

                    # Log da inserção
                    log_activity("leitura_inserted", {
                        "sensor_id": id_sensor,
                        "umidade": umidade,
                        "temperatura": temperatura
                    })

    # Adicionar outros formulários CRUD conforme necessário...
    st.info("💡 Outros formulários CRUD podem ser adicionados conforme necessário")


# ============================================================================
# EXECUÇÃO PRINCIPAL
# ============================================================================

if __name__ == "__main__":
    main()