/*
 * 3. Taxa de reembolso e de recusa por categoria de produto. Como você evita
 * contar duas vezes o mesmo cliente que comprou o mesmo produto mais de uma
 * vez?
 *
 * Assunções:
 * - Vendas gratuitas ficam fora: não há cobrança. Além disso, 11 gratuitas aparecem como
 *   reembolsadas/recusadas, uma inconsistência registrada nas checagens de qualidade.
 * - Taxa de recusa = recusadas / tentativas de pagamento (todas as vendas pagas).
 * - Taxa de reembolso = reembolsadas / pagamentos capturados (aprovadas + reembolsadas):
 *   só pode ser reembolsado quem foi cobrado, então recusadas não entram no denominador.
 *
 * Deduplicação: além da taxa por transação, a mesma taxa é calculada por par
 * cliente x produto. Cada par conta uma vez e é marcado como "teve recusa" ou "teve
 * reembolso" se isso ocorreu em pelo menos uma das vendas. Assim, quem comprou o mesmo
 * produto duas vezes, ou teve o cartão recusado e tentou de novo, não pesa em dobro.
 */

with vendas as (
	select
		f.cliente_id,
		f.produto_id,
		f.status_pagamento,
		p.categoria
	from
		fact_vendas f
		inner join dim_produto p on f.produto_id = p.produto_id
	where not f.venda_gratuita
),

por_transacao as (
	select
		coalesce(categoria, 'Total') as categoria,
		count(*) as vendas,
		count(*) filter (where status_pagamento = 'recusado') as recusadas,
		count(*) filter (where status_pagamento = 'reembolsado') as reembolsadas,
		count(*) filter (where status_pagamento in ('aprovado', 'reembolsado')) as cobradas
	from vendas
	group by rollup(categoria)
),

pares as (
	select
		categoria,
		cliente_id,
		produto_id,
		bool_or(status_pagamento = 'recusado') as teve_recusa,
		bool_or(status_pagamento = 'reembolsado') as teve_reembolso,
		bool_or(status_pagamento in ('aprovado', 'reembolsado')) as foi_cobrado
	from vendas
	group by
		categoria,
		cliente_id,
		produto_id
),

por_par as (
	select
		coalesce(categoria, 'Total') as categoria,
		count(*) as pares,
		count(*) filter (where teve_recusa) as pares_com_recusa,
		count(*) filter (where teve_reembolso) as pares_com_reembolso,
		count(*) filter (where foi_cobrado) as pares_cobrados
	from pares
	group by rollup(categoria)
)

select
	t.categoria,
	t.vendas,
	t.recusadas,
	t.reembolsadas,
	round(100 * t.recusadas / t.vendas, 2) as taxa_recusa_pct,
	round(100 * t.reembolsadas / t.cobradas, 2) as taxa_reembolso_pct,
	p.pares as pares_cliente_produto,
	round(100 * p.pares_com_recusa / p.pares, 2) as taxa_recusa_dedup_pct,
	round(100 * p.pares_com_reembolso / p.pares_cobrados, 2) as taxa_reembolso_dedup_pct
from
	por_transacao t
	inner join por_par p on t.categoria = p.categoria
order by
	t.categoria = 'Total',
	t.categoria;
