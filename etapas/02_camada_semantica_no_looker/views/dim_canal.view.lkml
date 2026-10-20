# Dimensão de canais de aquisição. Grão: 1 linha por canal (canal_id).
# Usada duas vezes no explore de vendas (role-playing): canal da venda e canal de aquisição do cliente.

view: dim_canal {
  sql_table_name: analytics.dim_canal ;;

  dimension: canal_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.canal_id ;;
  }

  dimension: grupo_canal {
    type: string
    description: "Agrupamento de canais para leitura executiva (ex.: Social Pago reúne instagram e facebook)."
    sql: ${TABLE}.grupo_canal ;;
  }

  dimension: source {
    type: string
    description: "Origem do tráfego (utm_source), ex.: google, instagram, newsletter."
    sql: ${TABLE}.source ;;
  }

  dimension: medium {
    type: string
    description: "Meio do tráfego (utm_medium), ex.: cpc, organic, paid_social."
    sql: ${TABLE}.medium ;;
  }

  dimension: source_medium {
    type: string
    description: "Combinação source / medium, no padrão do Google Analytics."
    sql: ${source} || ' / ' || ${medium} ;;
  }
}
