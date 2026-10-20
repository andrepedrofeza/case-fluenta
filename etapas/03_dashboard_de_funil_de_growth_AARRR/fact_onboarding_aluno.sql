/*
 * Fato de onboarding do aluno (etapa 3), um snapshot acumulado: 1 linha por cliente cadastrado,
 * com os marcos do processo (cadastro, ativação em 7 dias, retenção em D30). Permite calcular
 * Aquisição, Ativação e Retenção no Power BI sem usar a usuarios_features_churn, e mantém o
 * modelo em estrela (fatos ligados só a dimensões).
 *
 * Chaves:
 * - cliente_id -> dim_cliente
 * - canal_id (canal de aquisição) -> dim_canal
 * - data_id (data de cadastro, yyyymmdd) -> dim_data
 *
 * Ativação e retenção só existem para a amostra instrumentada: os clientes presentes em
 * usuarios_features_churn (~47%). Nos demais, ativado, retido_d30 e status_ativacao ficam
 * vazios, e as médias do Power BI ignoram esses clientes.
 */

select
	cl.cliente_id,
	strftime(cl.dt_cadastro, '%Y%m%d')::integer as data_id,
	cl.canal_aquisicao_id as canal_id,
	u.cliente_id is not null as instrumentado,
	u.licoes_concluidas_7d,
	u.sessoes_7d,
	u.usou_app,
	u.tem_assinatura,
	case when u.cliente_id is not null then (u.licoes_concluidas_7d >= 3)::int end as ativado,
	case when u.cliente_id is not null then 1 - u.churn_d30 end as retido_d30,
	case
		when u.cliente_id is null then null
		when u.licoes_concluidas_7d >= 3 then 'Ativado (3+ lições em 7 dias)'
		else 'Não ativado'
	end as status_ativacao
from
	dim_cliente cl
	left join usuarios_features_churn u on cl.cliente_id = u.cliente_id
order by cl.cliente_id;
