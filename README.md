# Case Fluenta: Especialista em Inteligência de Dados

> Documento de decisões e assunções. As respostas de cada etapa estão em [RESPOSTAS.md](RESPOSTAS.md).

## Entregáveis

| Etapa | Onde |
|---|---|
| 1. SQL sobre a estrela | [`etapas/01_sql_sobre_a_estrela/`](etapas/01_sql_sobre_a_estrela/): uma query por pergunta (`consultas/`) e o resultado (`resultados/`) |
| 2. Camada semântica | [`etapas/02_camada_semantica_no_looker/`](etapas/02_camada_semantica_no_looker/): model, views e explores |
| 3. Dashboard AARRR | [`dashboard_aarrr.pdf`](etapas/03_dashboard_de_funil_de_growth_AARRR/dashboard_aarrr.pdf) e o projeto Power BI `dashboard_aarrr.pbip` (a fato `fact_onboarding_aluno` vem de `fact_onboarding_aluno.sql`) |
| 4. Painel do teste A/B | [`dashboard_testeab.pdf`](etapas/04_painel_diario_de_acompanhamento_de_teste_AB/dashboard_testeab.pdf) e o projeto `dashboard_testeab.pbip` |
| 5 e 6. Crítica e indicadores | [RESPOSTAS.md](RESPOSTAS.md), seções 5 e 6 (com wireframe) |

**Como abrir:** os PDFs mostram a versão final dos painéis. Os `.pbip` abrem no Power BI Desktop com os dados em cache; para atualizar, aponte o parâmetro `PastaRepo` para uma pasta com os CSVs do case em `dados/` (*Transformar dados → Editar parâmetros*). O SQL está no dialeto DuckDB, com cada CSV carregado *as is* numa tabela de mesmo nome: todo tratamento fica nas queries, documentado.

## Priorização

Números confiáveis antes dos visuais: **(1)** SQL e dashboard AARRR, com a mesma regra de receita no SQL, no LookML e no Power BI, conferida por números de controle (receita total de R$ 966.988,99); **(2)** painel A/B, com a validade estatística (divisão 50/50, maturação, amostra) antes do resultado; **(3)** LookML, validado sem instância por parser e linter; **(4)** textos das etapas 5 e 6. **Fora do escopo:** visão mobile configurada (explicada no RESPOSTAS.md, seção 3), dbt e orquestração (o SQL versionado basta para este volume) e modelo preditivo de churn.

## Assunções e decisões

### Gerais e qualidade dos dados

| Tema | Decisão | Impacto |
|---|---|---|
| Data de referência | 20/09/2026, a última data da base | Set/26 é mês parcial |
| Receita | **Uma definição só:** `valor_liquido` de vendas aprovadas e não gratuitas (flag `venda_gratuita`), igual no SQL, no LookML e nos painéis | Reembolsadas, recusadas e gratuitas nunca somam receita |
| Compra efetiva | Venda aprovada e não gratuita | Base do ticket, da recorrência e dos clientes únicos |
| 88 vendas gratuitas (11 reembolsadas ou recusadas) | Fora de receita, ticket e taxas de pagamento | Sem cobrança não existe recusa nem reembolso real |
| CRM: nulos em valor (38%), canal (18%) e cliente (44%) | Nulo ≠ zero; nunca imputado | Ver 1.5 |
| `ab_testes`: SRM no `exp_checkout_botao_unico` (53/47, z ≈ −7,6) | Resultado desse teste é inválido | Só o `exp_onboarding_v2` é analisado |

### Etapa 1: SQL (também no cabeçalho de cada `.sql`)

| # | Assunção | Impacto |
|---|---|---|
| 1.1 | `LAG` sobre uma grade mês × `grupo_canal`, com receita 0 em mês sem venda; `mes_parcial` marca set/26 | Vídeo não vende em out/25: sem a grade, nov/25 seria comparado com o mês errado |
| 1.2 | Ticket por venda (receita / vendas válidas); faixa etária do cadastro; IC 95% da média e alerta para n < 30 | O ticket de Assinatura depende do mix mensal × anual, não da faixa: as faixas não diferem significativamente |
| 1.3 | Recusa = recusadas / tentativas; reembolso = reembolsadas / cobradas; taxa também por par cliente × produto | Só é reembolsado quem foi cobrado; recompra e retentativa não pesam em dobro |
| 1.4 | Meses consecutivos por `ano * 12 + mes`; basta um par no histórico; perfil sobre todo o histórico do cliente | Dez/25 → jan/26 conta. Renovação não é registrada como venda: recorrência é recompra |
| 1.5 | Taxa de ganho sobre encerrados (com a taxa sobre todos e o n ao lado); abertos há mais de 90 dias sinalizados | Abertos ainda não têm desfecho (8,3% × 4,8%); 74% do aberto está parado |
| 1.5 | Valor nulo estimado pela média do mesmo funil × status, só como ordem de grandeza; canal nulo não é estimado | O pipeline está ~60% subestimado; 18% dos negócios ficam fora das leituras por canal |

### Etapas 2 a 6

| Tema | Decisão | Impacto |
|---|---|---|
| LookML (2) | Sem instância: conexão hipotética (`fluenta_dw`, dialeto BigQuery); `fact_assinaturas_diaria` como código hipotético (explore separado + PDT) | Verificável como código |
| Medidas e governança (2) | `qtd_vendas` = total bruto; ticket e % com desconto sobre vendas válidas; `access_filter` pelo estado do cliente | Mesma base no numerador e no denominador |
| North Star (3) | **Alunos ativados** (3+ lições em 7 dias) | No histórico, quem ativa retém 4× mais em D30 (60,5% × 14,6%) |
| Engajamento (3) | `usuarios_features_churn` é uma amostra de ~50% dos cadastros, representativa (±1,1 p.p.); NSM = cadastros × taxa de ativação | Contar só os observados criaria quedas falsas (−54% de jun a ago) |
| Modelo e período (3) | Estrela com `fact_onboarding_aluno` e `fact_vendas`; padrão jun–ago/26 contra o período anterior; tendências mensais mostram o histórico | Filtro de estado vale para as duas fatos; set/26 e coortes sem 30 dias ficam fora |
| "Saudável" (3) | Cadastros crescendo e retenção D30 ≥ 40% | Limite a calibrar com o Growth |
| Maturação do A/B (4) | Só usuários com 7 dias completos; decisão em 20/09 (13/09 + 7) | Evita ler o +11,9 p.p. das primeiras coortes |
| Rigor do A/B (4) | 6.507 por braço (20% → 22%, α 5%, poder 80%); IC de Wald; alerta de SRM só com \|z\| > 3,29 | Checagem diária sem alarme falso |
| Leitura do A/B (4) | B aumenta a ativação: **sim** (+1,43 p.p., IC +0,17 a +2,69). Atinge +2 p.p.: **não confirmado** | Lançar com holdout; dispositivo só exploratório |
| Marketing (6) | Canal = canal de aquisição (first-touch); CAC e ROAS só como definição | A base não tem dados de investimento |

## Ferramentas e uso de IA

**Ferramentas:** DuckDB (SQL), LookML validado com o parser `lkml` e o linter LAMS, Power BI Desktop em formato de projeto `.pbip` (modelo e visuais versionáveis como texto) e `sqlfluff` (padronização do SQL).

**Uso de IA:** usei o **Claude Code**, como assistente na estrutura do projeto, no perfil e na qualidade dos dados, no rascunho do SQL, do LookML e do DAX, e na montagem dos visuais do Power BI pelos arquivos do projeto.

A IA acelera o que é repetitivo e libera tempo para o que exige julgamento; a validação continua sendo minha. Rodei e avaliei todas as queries, conferi os números do Power BI contra o SQL e revisei os painéis. As decisões de negócio (NSM, denominadores, leitura do A/B, priorização) são minhas.
