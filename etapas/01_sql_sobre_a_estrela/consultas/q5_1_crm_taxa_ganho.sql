/*
 * 5. No CRM (crm_negocios): taxa de ganho por funil e por responsável. Diga qual
 * denominador você usou (todos os negócios × só os encerrados) e por quê.
 * Quantos negócios estão sem valor ou sem canal, e o que isso muda na leitura do
 * pipeline?
 *
 * Parte 1/2: taxa de ganho. Os nulos estão em q5_2_crm_nulos.sql.
 *
 * Assunções:
 * - Denominador = só os encerrados: won / (won + lost). Negócios ongoing ainda não tiveram
 *   desfecho; colocá-los no denominador mistura conversão com idade do pipeline e penaliza
 *   quem tem mais negócios recentes. A taxa sobre todos os negócios aparece ao lado só
 *   para comparação.
 * - encerrados (o n) aparece ao lado da taxa: alguns recortes têm poucos negócios (ex.: B2B
 *   por responsável, de 21 a 160 encerrados), e aí um negócio a mais ou a menos muda o ranking.
 * - em_aberto_90d: ongoing criados há mais de 90 dias da última data da base. Se forem
 *   negócios mortos não encerrados no CRM, a taxa sobre encerrados também fica otimista.
 * - Os níveis saem empilhados (total, funil, responsável, funil x responsável) via
 *   cube(funil, responsavel); "(todos)" indica a dimensão agregada.
 */

with base as (
	select
		funil,
		responsavel,
		status,
		dt_criacao,
		max(dt_criacao) over () as data_ref
	from crm_negocios
),

agregado as (
	select
		case
			when grouping(funil) = 0 and grouping(responsavel) = 0 then 'funil x responsavel'
			when grouping(funil) = 0 then 'funil'
			when grouping(responsavel) = 0 then 'responsavel'
			else 'total'
		end as nivel,
		funil,
		responsavel,
		count(*) as negocios,
		count(*) filter (where status = 'won') as ganhos,
		count(*) filter (where status = 'lost') as perdidos,
		count(*) filter (where status = 'ongoing') as em_aberto,
		count(*) filter (where status = 'ongoing' and dt_criacao < data_ref - interval 90 day) as em_aberto_90d
	from base
	group by cube(funil, responsavel)
)

select
	nivel,
	coalesce(funil, '(todos)') as funil,
	coalesce(responsavel, '(todos)') as responsavel,
	negocios,
	ganhos + perdidos as encerrados,
	ganhos,
	em_aberto,
	em_aberto_90d,
	round(100 * ganhos / nullif(ganhos + perdidos, 0), 2) as taxa_ganho_encerrados_pct,
	round(100 * ganhos / negocios, 2) as taxa_ganho_todos_pct
from agregado
order by
	case nivel when 'total' then 1 when 'funil' then 2 when 'responsavel' then 3 else 4 end,
	funil,
	responsavel;
