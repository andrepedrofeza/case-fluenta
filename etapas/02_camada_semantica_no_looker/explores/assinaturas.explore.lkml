# HIPOTÉTICO (item 2.4): explore próprio para a fact_assinaturas_diaria, que não existe na base
# fornecida. Grão diferente (cliente x dia) pede explore separado em vez de join no de vendas.

explore: assinaturas {
  view_name: fact_assinaturas_diaria
  label: "Assinaturas (diário)"
  description: "Foto diária das assinaturas por cliente. Para cruzar com vendas, use o resumo por cliente no explore Vendas."

  access_filter: {
    field: dim_cliente.estado
    user_attribute: estados_permitidos
  }

  join: dim_cliente {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_assinaturas_diaria.cliente_id} = ${dim_cliente.cliente_id} ;;
  }

  join: dim_produto {
    view_label: "Plano"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_assinaturas_diaria.produto_id} = ${dim_produto.produto_id} ;;
  }
}
