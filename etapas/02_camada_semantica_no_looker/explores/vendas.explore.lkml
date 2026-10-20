# Explore de vendas em estrela: a fato (1 linha por venda) é a base e toda dimensão
# entra como many_to_one. Nenhum join multiplica linhas da fato, então somas e contagens
# saem corretas sem depender de symmetric aggregates.

explore: vendas {
  view_name: fact_vendas
  label: "Vendas"
  description: "Vendas da Fluenta por data, cliente, produto e canal. Receita = aprovadas e não gratuitas."

  # Governança regional: cada usuário só enxerga clientes dos estados no seu user attribute
  # `estados_permitidos` (ex.: "PR,SC,RS" para o time Sul; "%" para quem vê tudo).
  access_filter: {
    field: dim_cliente.estado
    user_attribute: estados_permitidos
  }

  join: dim_data {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_vendas.data_id} = ${dim_data.data_id} ;;
  }

  join: dim_cliente {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_vendas.cliente_id} = ${dim_cliente.cliente_id} ;;
  }

  join: dim_produto {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_vendas.produto_id} = ${dim_produto.produto_id} ;;
  }

  # Role-playing: a mesma dim_canal entra duas vezes, com aliases que deixam o papel explícito
  join: dim_canal_venda {
    from: dim_canal
    view_label: "Canal da Venda"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_vendas.canal_id} = ${dim_canal_venda.canal_id} ;;
  }

  # Canal de aquisição do cliente (snowflake via dim_cliente)
  join: dim_canal_aquisicao {
    from: dim_canal
    view_label: "Canal de Aquisição do Cliente"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_cliente.canal_aquisicao_id} = ${dim_canal_aquisicao.canal_id} ;;
  }

  # Item 2.4: a tabela diária de assinaturas NÃO entra aqui (geraria fan-out).
  # Entra só o resumo pré-agregado no grão de cliente, que mantém o many_to_one.
  join: assinaturas_por_cliente {
    view_label: "Assinatura do Cliente"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_cliente.cliente_id} = ${assinaturas_por_cliente.cliente_id} ;;
  }
}
