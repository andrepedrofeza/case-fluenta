/*
 * 5. (continuação) Quantos negócios estão sem valor ou sem canal, e o que isso muda
 * na leitura do pipeline?
 *
 * Parte 2/2: nulos por status e impacto no valor do pipeline.
 *
 * Assunções:
 * - Valor nulo não é valor zero: o negócio existe, só não teve o valor preenchido. Não
 *   imputamos zero.
 * - Pipeline = soma de valor dos negócios ongoing. Com parte deles sem valor, a soma
 *   direta subestima o pipeline.
 * - valor_estimado extrapola o valor médio conhecido do mesmo funil e status para os
 *   negócios sem valor. Isso supõe que o preenchimento é aleatório dentro de cada funil:
 *   é uma ordem de grandeza, não um número para meta.
 * - Canal nulo não tem como ser estimado: esses negócios ficam fora de qualquer leitura
 *   de conversão ou retorno por canal.
 */

with por_funil as (
	select
		status,
		funil,
		count(*) as negocios,
		count(*) filter (where valor is null) as sem_valor,
		count(*) filter (where canal_id is null) as sem_canal,
		count(*) filter (where valor is null and canal_id is null) as sem_valor_e_canal,
		count(*) filter (where valor is null or canal_id is null) as sem_valor_ou_canal,
		count(*) filter (where cliente_id is null) as sem_cliente,
		coalesce(sum(valor), 0) as valor_conhecido,
		coalesce(sum(valor), 0) + count(*) filter (where valor is null) * coalesce(avg(valor), 0) as valor_estimado
	from crm_negocios
	group by
		status,
		funil
)

select
	coalesce(status, 'Total') as status,
	sum(negocios)::bigint as negocios,
	sum(sem_valor)::bigint as sem_valor,
	sum(sem_canal)::bigint as sem_canal,
	sum(sem_valor_e_canal)::bigint as sem_valor_e_canal,
	sum(sem_valor_ou_canal)::bigint as sem_valor_ou_canal,
	sum(sem_cliente)::bigint as sem_cliente,
	round(100 * sum(sem_valor) / sum(negocios), 2) as pct_sem_valor,
	round(100 * sum(sem_canal) / sum(negocios), 2) as pct_sem_canal,
	round(sum(valor_conhecido), 2) as valor_conhecido,
	round(sum(valor_estimado), 2) as valor_estimado,
	round(100 * (sum(valor_estimado) / sum(valor_conhecido) - 1), 2) as subestimacao_pct
from por_funil
group by rollup(status)
order by
	status is null,
	status;
