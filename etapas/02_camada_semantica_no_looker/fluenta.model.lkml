# Modelo semântico de vendas da Fluenta (arquitetura estrela).
# Conexão hipotética: no teste os dados estão em DuckDB; em produção seria o DW (ex.: BigQuery).

connection: "fluenta_dw"

include: "/views/*.view.lkml"
include: "/explores/*.explore.lkml"

week_start_day: monday

# Formato monetário em reais (o Looker só traz usd/eur/gbp prontos)
named_value_format: brl {
  value_format: "\"R$\" #,##0.00"
}

# Cache e PDTs atualizam quando chega venda nova no DW, no máximo a cada 24h
datagroup: fluenta_diario {
  sql_trigger: SELECT MAX(data_id) FROM analytics.fact_vendas ;;
  max_cache_age: "24 hours"
}

persist_with: fluenta_diario

# Governança: campos financeiros detalhados (bruto e desconto) só para Financeiro e Diretoria
access_grant: ver_financeiro {
  user_attribute: departamento
  allowed_values: ["financeiro", "diretoria"]
}
