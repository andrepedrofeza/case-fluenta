# HIPOTÉTICO (item 2.4): tabela não existe na base fornecida.
# Grão: 1 linha por cliente por dia com assinatura. Juntá-la a fact_vendas via dim_cliente
# multiplicaria cada venda pelo nº de dias de assinatura do cliente (fan-out).

view: fact_assinaturas_diaria {
  sql_table_name: analytics.fact_assinaturas_diaria ;;

  # Chave composta: sem PK única o Looker não consegue aplicar symmetric aggregates
  dimension: pk_cliente_dia {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.cliente_id AS STRING), '|', CAST(${TABLE}.data AS STRING)) ;;
  }

  dimension: cliente_id {
    hidden: yes
    type: number
    sql: ${TABLE}.cliente_id ;;
  }

  dimension: produto_id {
    hidden: yes
    type: number
    sql: ${TABLE}.produto_id ;;
  }

  dimension_group: snapshot {
    type: time
    description: "Dia da foto da assinatura."
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.data ;;
  }

  dimension: status_assinatura {
    type: string
    description: "Situação da assinatura no dia: ativa, trial ou cancelada."
    sql: ${TABLE}.status_assinatura ;;
  }

  dimension: valor_mrr {
    hidden: yes
    type: number
    sql: ${TABLE}.valor_mrr ;;
  }

  measure: assinantes_ativos {
    type: count_distinct
    description: "Clientes distintos com assinatura ativa no período. Contagem distinta, então não soma dias."
    sql: ${cliente_id} ;;
    filters: [status_assinatura: "ativa"]
  }

  # MRR é semiaditivo no tempo: somar 30 fotos diárias daria 30x o MRR do mês.
  # A leitura correta é por dia; em séries mensais, use o MRR médio diário.
  measure: mrr_medio_diario {
    type: number
    description: "MRR somado por dia e dividido pelo nº de dias do recorte. Evita somar fotos diárias (semiaditivo)."
    sql: SUM(${valor_mrr}) / NULLIF(COUNT(DISTINCT ${snapshot_date}), 0) ;;
    value_format_name: brl
  }
}
