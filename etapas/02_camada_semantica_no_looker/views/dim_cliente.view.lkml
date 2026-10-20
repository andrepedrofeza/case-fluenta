# Dimensão de clientes. Grão: 1 linha por cliente (cliente_id).
# O estado é a chave do access_filter regional (explores/vendas.explore.lkml).

view: dim_cliente {
  sql_table_name: analytics.dim_cliente ;;

  dimension: cliente_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.cliente_id ;;
  }

  dimension: canal_aquisicao_id {
    hidden: yes
    type: number
    sql: ${TABLE}.canal_aquisicao_id ;;
  }

  dimension: estado {
    type: string
    description: "UF do cliente no cadastro. Usada no filtro de acesso regional."
    sql: ${TABLE}.estado ;;
  }

  dimension_group: cadastro {
    type: time
    description: "Data de cadastro do cliente na plataforma."
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dt_cadastro ;;
  }

  dimension: faixa_etaria {
    type: string
    description: "Faixa etária declarada no cadastro (18-24, 25-34, 35-44, 45+). Não é recalculada na data da venda."
    sql: ${TABLE}.faixa_etaria ;;
  }

  dimension: objetivo {
    type: string
    description: "Objetivo declarado pelo aluno ao se cadastrar (ex.: Carreira, Viagem, Hobby)."
    sql: ${TABLE}.objetivo ;;
  }

  measure: qtd_clientes {
    type: count
    description: "Clientes cadastrados no recorte. Em explores com fato, o Looker usa symmetric aggregates para não inflar."
  }
}
