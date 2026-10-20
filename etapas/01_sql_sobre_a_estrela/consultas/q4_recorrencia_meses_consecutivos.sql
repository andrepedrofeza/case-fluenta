/*
 * 4. Clientes que compraram em dois meses consecutivos (recorrência) e quantos
 * deles compraram assinatura e avulso.
 *
 * Assunções:
 * - Compra = venda aprovada e não gratuita. Reembolsada não é compra efetiva e gratuita
 *   não é compra.
 * - Meses consecutivos usam o índice ano * 12 + mes, para 12/2025 -> 01/2026 contar.
 * - Basta um par de meses consecutivos em qualquer ponto do histórico.
 * - "Compraram assinatura e avulso": o perfil considera todo o histórico de compras do
 *   cliente recorrente e separa em só avulso, só assinatura e ambos.
 * - A base não registra renovação mensal de assinatura como nova venda (só 85 pares
 *   cliente x produto se repetem), então um assinante mensal ativo não aparece como
 *   recorrente só por renovar: a recorrência aqui é recompra.
 */

with compras as (
	select
		f.cliente_id,
		p.tipo_produto,
		d.ano * 12 + d.mes as mes_idx
	from
		fact_vendas f
		inner join dim_produto p on f.produto_id = p.produto_id
		inner join dim_data d on f.data_id = d.data_id
	where
		f.status_pagamento = 'aprovado'
		and not f.venda_gratuita
),

meses_cliente as (
	select distinct
		cliente_id,
		mes_idx
	from compras
),

recorrentes as (
	select distinct cliente_id
	from meses_cliente
	qualify mes_idx - lag(mes_idx) over (partition by cliente_id order by mes_idx) = 1
),

perfil as (
	select
		c.cliente_id,
		case
			when bool_or(c.tipo_produto = 'Assinatura') and bool_or(c.tipo_produto = 'Avulso') then 'Assinatura e avulso'
			when bool_or(c.tipo_produto = 'Assinatura') then 'Só assinatura'
			else 'Só avulso'
		end as perfil_compra
	from
		compras c
		semi join recorrentes r on c.cliente_id = r.cliente_id
	group by c.cliente_id
),

totais as (
	select
		(select count(*) from recorrentes) as total_recorrentes,
		count(distinct cliente_id) as total_compradores
	from compras
)

select
	coalesce(p.perfil_compra, 'Total recorrentes') as perfil_compra,
	count(*) as clientes,
	round(100 * count(*) / any_value(t.total_recorrentes), 2) as pct_dos_recorrentes,
	round(100 * count(*) / any_value(t.total_compradores), 2) as pct_dos_compradores
from
	perfil p
	cross join totais t
group by rollup(p.perfil_compra)
order by
	p.perfil_compra is null,
	clientes desc;
