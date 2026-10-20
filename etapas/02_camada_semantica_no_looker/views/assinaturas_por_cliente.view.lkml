# HIPOTÉTICO (item 2.4): PDT que pré-agrega a fact_assinaturas_diaria no grão de cliente.
# Com 1 linha por cliente, o join no explore de vendas volta a ser many_to_one e a receita
# não infla. A PDT é reconstruída pelo mesmo datagroup do modelo (1x por carga do DW).

view: assinaturas_por_cliente {
  derived_table: {
    sql:
      SELECT
        cliente_id,
        MIN(data) AS primeiro_dia_assinante,
        MAX(data) AS ultimo_dia_assinante,
        COUNT(*) AS dias_assinante,
        MAX(data) = CURRENT_DATE() AS assinante_ativo_hoje
      FROM analytics.fact_assinaturas_diaria
      WHERE status_assinatura = 'ativa'
      GROUP BY cliente_id ;;
    datagroup_trigger: fluenta_diario
  }

  dimension: cliente_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.cliente_id ;;
  }

  dimension_group: primeiro_dia_assinante {
    type: time
    description: "Primeiro dia com assinatura ativa."
    timeframes: [date, month, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.primeiro_dia_assinante ;;
  }

  dimension: dias_assinante {
    type: number
    description: "Dias com assinatura ativa no histórico do cliente."
    sql: ${TABLE}.dias_assinante ;;
  }

  dimension: assinante_ativo_hoje {
    type: yesno
    description: "Cliente com assinatura ativa na data de hoje."
    sql: ${TABLE}.assinante_ativo_hoje ;;
  }
}
