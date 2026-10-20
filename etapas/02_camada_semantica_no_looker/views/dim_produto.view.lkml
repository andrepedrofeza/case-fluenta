# Dimensão de produtos. Grão: 1 linha por produto (produto_id).

view: dim_produto {
  sql_table_name: analytics.dim_produto ;;

  dimension: produto_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.produto_id ;;
  }

  dimension: nome_produto {
    type: string
    description: "Nome comercial do curso ou plano."
    sql: ${TABLE}.nome_produto ;;
  }

  dimension: categoria {
    type: string
    description: "Categoria do produto: Inglês, Espanhol, Certificações, Conversação ou Assinatura."
    sql: ${TABLE}.categoria ;;
  }

  dimension: tipo_produto {
    type: string
    description: "Avulso (curso com pagamento único) ou Assinatura (planos Plus e Premium, mensal ou anual)."
    sql: ${TABLE}.tipo_produto ;;
  }

  dimension: periodicidade_plano {
    type: string
    description: "Mensal ou Anual para assinaturas; vazio para avulsos. O mix de planos é o que mais move o ticket de Assinatura."
    sql: CASE
           WHEN ${nome_produto} LIKE 'Plano Mensal%' THEN 'Mensal'
           WHEN ${nome_produto} LIKE 'Plano Anual%' THEN 'Anual'
         END ;;
  }

  dimension: preco_lista {
    type: number
    description: "Preço de tabela do produto, antes de descontos."
    sql: ${TABLE}.preco_lista ;;
    value_format_name: brl
  }

  dimension: ativo {
    type: yesno
    description: "Produto disponível para venda atualmente."
    sql: ${TABLE}.ativo ;;
  }
}
