/*
 * 1. Receita líquida por mês e por `grupo_canal`, considerando apenas vendas
 * aprovadas e não gratuitas. Mostre também a variação percentual sobre o mês
 * anterior (LAG).
 *
 * Assunções:
 * - "Não gratuita" = venda_gratuita = false. Nesta base equivale a valor_liquido > 0
 *   (as 88 gratuitas têm valor zero), mas a flag deixa a regra explícita.
 * - Meses sem venda em um grupo entram com receita 0 (grade mês x grupo), para o LAG
 *   comparar sempre com o mês imediatamente anterior, e não com o último mês com venda.
 * - 09/2026 é parcial (dados até 20/09) e vem sinalizado em mes_parcial: a variação
 *   desse mês contra um mês cheio não é comparável.
 * - Grupo "Social Pago" reúne dois canais (instagram e facebook); a análise é por grupo.
 */

with receita as (
	select
		d.ano,
		d.mes,
		c.grupo_canal,
		sum(f.valor_liquido) as receita_liquida
	from
		fact_vendas f
		inner join dim_canal c on f.canal_id = c.canal_id
		inner join dim_data d on f.data_id = d.data_id
	where
		f.status_pagamento = 'aprovado'
		and not f.venda_gratuita
	group by
		d.ano,
		d.mes,
		c.grupo_canal
),

meses as (
	select
		ano,
		mes,
		max(data) < last_day(max(data)) as mes_parcial
	from dim_data
	group by
		ano,
		mes
),

grupos as (
	select distinct grupo_canal
	from dim_canal
),

grade as (
	select
		m.ano,
		m.mes,
		m.mes_parcial,
		g.grupo_canal,
		coalesce(r.receita_liquida, 0) as receita_liquida
	from
		meses m
		cross join grupos g
		left join receita r
			on
				m.ano = r.ano
				and m.mes = r.mes
				and g.grupo_canal = r.grupo_canal
)

select
	ano,
	mes,
	grupo_canal,
	mes_parcial,
	round(receita_liquida, 2) as receita_liquida,
	round(lag(receita_liquida) over w, 2) as receita_liquida_mes_anterior,
	round(100 * (receita_liquida / nullif(lag(receita_liquida) over w, 0) - 1), 2) as variacao_pct
from grade
window w as (partition by grupo_canal order by ano, mes)
order by
	ano,
	mes,
	grupo_canal;
