/*
 * 2. Ticket médio por tipo_produto e por faixa_etaria do cliente. Qual combinação
 * tem o maior ticket e quantas vendas a sustentam? (Comente a confiabilidade da
 * amostra.)
 *
 * Assunções:
 * - Ticket médio = receita líquida / nº de vendas, com a mesma regra da Q1 (aprovadas e
 *   não gratuitas): gratuitas puxariam o ticket para baixo e reembolsadas/recusadas não
 *   viraram receita.
 * - faixa_etaria vem do cadastro do cliente (dim_cliente), não da data da venda.
 * - Confiabilidade: IC 95% da média (1.96 * desvio / raiz(n)). Combinações com n < 30
 *   são sinalizadas como amostra pequena.
 * - pct_planos_anuais mostra o mix dentro de Assinatura: plano mensal (49.90/89.90) e
 *   anual (479/899) convivem no mesmo tipo, então o ticket depende mais do mix de planos
 *   do que da faixa etária.
 */

with vendas as (
	select
		p.tipo_produto,
		cl.faixa_etaria,
		f.valor_liquido,
		p.nome_produto like 'Plano Anual%' as plano_anual
	from
		fact_vendas f
		inner join dim_produto p on f.produto_id = p.produto_id
		inner join dim_cliente cl on f.cliente_id = cl.cliente_id
	where
		f.status_pagamento = 'aprovado'
		and not f.venda_gratuita
),

ticket as (
	select
		tipo_produto,
		faixa_etaria,
		count(*) as qtd_vendas,
		avg(valor_liquido) as ticket_medio,
		stddev_samp(valor_liquido) as desvio_padrao,
		avg(plano_anual::int) as pct_planos_anuais
	from vendas
	group by
		tipo_produto,
		faixa_etaria
)

select
	rank() over (order by ticket_medio desc) as ranking,
	tipo_produto,
	faixa_etaria,
	qtd_vendas,
	round(ticket_medio, 2) as ticket_medio,
	round(desvio_padrao, 2) as desvio_padrao,
	round(ticket_medio - 1.96 * desvio_padrao / sqrt(qtd_vendas), 2) as ic95_inferior,
	round(ticket_medio + 1.96 * desvio_padrao / sqrt(qtd_vendas), 2) as ic95_superior,
	case when tipo_produto = 'Assinatura' then round(100 * pct_planos_anuais, 1) end as pct_planos_anuais,
	qtd_vendas < 30 as amostra_pequena
from ticket
order by ranking;
