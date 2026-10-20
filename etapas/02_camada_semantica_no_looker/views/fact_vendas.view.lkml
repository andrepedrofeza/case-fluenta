# Fato de vendas. Grão: 1 linha por venda (venda_id).
#
# Regra única de receita (README, G2): receita líquida = valor_liquido de vendas
# aprovadas e não gratuitas. Toda medida de receita deste modelo parte dela.

view: fact_vendas {
  sql_table_name: analytics.fact_vendas ;;

  # ---------------------------------------------------------------------------
  # Chave e chaves estrangeiras (técnicas, ocultas)
  # ---------------------------------------------------------------------------

  dimension: venda_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.venda_id ;;
  }

  dimension: data_id {
    hidden: yes
    type: number
    sql: ${TABLE}.data_id ;;
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

  dimension: canal_id {
    hidden: yes
    type: number
    sql: ${TABLE}.canal_id ;;
  }

  # ---------------------------------------------------------------------------
  # Atributos da venda
  # ---------------------------------------------------------------------------

  dimension: status_pagamento {
    type: string
    description: "Status do pagamento: aprovado, reembolsado ou recusado. Só aprovadas contam como receita."
    sql: ${TABLE}.status_pagamento ;;
  }

  dimension: venda_gratuita {
    type: yesno
    description: "Venda com 100% de desconto (cortesia/promoção). Não gera receita e fica fora das taxas de pagamento."
    sql: ${TABLE}.venda_gratuita ;;
  }

  dimension: tem_desconto {
    type: yesno
    description: "Venda com desconto maior que zero. Vendas gratuitas também aparecem como 'sim' (desconto de 100%)."
    sql: ${desconto} > 0 ;;
  }

  # Valores por linha ficam ocultos: o uso correto é pelas medidas, que já aplicam a regra de receita
  dimension: valor_bruto {
    hidden: yes
    type: number
    sql: ${TABLE}.valor_bruto ;;
  }

  dimension: desconto {
    hidden: yes
    type: number
    sql: ${TABLE}.desconto ;;
  }

  dimension: valor_liquido {
    hidden: yes
    type: number
    sql: ${TABLE}.valor_liquido ;;
  }

  # ---------------------------------------------------------------------------
  # Medidas pedidas no case
  # ---------------------------------------------------------------------------

  measure: receita_liquida {
    type: sum
    description: "Soma do valor líquido (bruto - desconto) das vendas aprovadas e não gratuitas. Definição oficial de Receita."
    sql: ${valor_liquido} ;;
    filters: [status_pagamento: "aprovado", venda_gratuita: "no"]
    value_format_name: brl
    drill_fields: [detalhe_venda*]
  }

  measure: qtd_vendas {
    type: count
    description: "Total de vendas registradas, em qualquer status e incluindo gratuitas. Para vendas que geraram receita, use Qtd Vendas Válidas."
    drill_fields: [detalhe_venda*]
  }

  measure: qtd_vendas_validas {
    type: count
    description: "Vendas aprovadas e não gratuitas: o denominador do ticket médio e do % com desconto."
    filters: [status_pagamento: "aprovado", venda_gratuita: "no"]
    drill_fields: [detalhe_venda*]
  }

  measure: clientes_unicos {
    type: count_distinct
    description: "Clientes distintos com pelo menos uma venda aprovada e não gratuita (compra efetiva) no recorte."
    sql: ${cliente_id} ;;
    filters: [status_pagamento: "aprovado", venda_gratuita: "no"]
  }

  measure: ticket_medio {
    type: number
    description: "Receita líquida / vendas válidas (aprovadas e não gratuitas). Ticket por venda, não por cliente."
    sql: ${receita_liquida} / NULLIF(${qtd_vendas_validas}, 0) ;;
    value_format_name: brl
  }

  measure: taxa_reembolso {
    type: number
    description: "Vendas reembolsadas / vendas cobradas (aprovadas + reembolsadas), sem gratuitas. Recusadas não entram: só é reembolsado quem foi cobrado."
    sql: 1.0 * ${qtd_reembolsadas} / NULLIF(${qtd_cobradas}, 0) ;;
    value_format_name: percent_2
  }

  measure: pct_vendas_com_desconto {
    type: number
    description: "Vendas válidas com desconto > 0 / vendas válidas. Gratuitas ficam fora porque têm 100% de desconto e inflariam o indicador."
    sql: 1.0 * ${qtd_vendas_validas_com_desconto} / NULLIF(${qtd_vendas_validas}, 0) ;;
    value_format_name: percent_2
  }

  # ---------------------------------------------------------------------------
  # Medidas complementares
  # ---------------------------------------------------------------------------

  measure: taxa_recusa {
    type: number
    description: "Vendas recusadas / tentativas de pagamento (todas as vendas não gratuitas)."
    sql: 1.0 * ${qtd_recusadas} / NULLIF(${qtd_tentativas_pagamento}, 0) ;;
    value_format_name: percent_2
  }

  measure: receita_bruta {
    type: sum
    description: "Soma do valor bruto (preço antes do desconto) das vendas aprovadas e não gratuitas. Restrito a Financeiro e Diretoria."
    sql: ${valor_bruto} ;;
    filters: [status_pagamento: "aprovado", venda_gratuita: "no"]
    value_format_name: brl
    required_access_grants: [ver_financeiro]
  }

  measure: total_descontos {
    type: sum
    description: "Soma dos descontos concedidos nas vendas aprovadas e não gratuitas. Restrito a Financeiro e Diretoria."
    sql: ${desconto} ;;
    filters: [status_pagamento: "aprovado", venda_gratuita: "no"]
    value_format_name: brl
    required_access_grants: [ver_financeiro]
  }

  # ---------------------------------------------------------------------------
  # Medidas auxiliares (componentes das taxas, ocultas)
  # ---------------------------------------------------------------------------

  measure: qtd_reembolsadas {
    hidden: yes
    type: count
    filters: [status_pagamento: "reembolsado", venda_gratuita: "no"]
  }

  measure: qtd_cobradas {
    hidden: yes
    type: count
    filters: [status_pagamento: "aprovado,reembolsado", venda_gratuita: "no"]
  }

  measure: qtd_recusadas {
    hidden: yes
    type: count
    filters: [status_pagamento: "recusado", venda_gratuita: "no"]
  }

  measure: qtd_tentativas_pagamento {
    hidden: yes
    type: count
    filters: [venda_gratuita: "no"]
  }

  measure: qtd_vendas_validas_com_desconto {
    hidden: yes
    type: count
    filters: [status_pagamento: "aprovado", venda_gratuita: "no", tem_desconto: "yes"]
  }

  set: detalhe_venda {
    fields: [venda_id, status_pagamento, venda_gratuita, receita_liquida]
  }
}
