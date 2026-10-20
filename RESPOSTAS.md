# Respostas aos enunciados

## 1. SQL sobre a estrela

Queries em [etapas/01_sql_sobre_a_estrela/consultas/](etapas/01_sql_sobre_a_estrela/consultas/) e resultados completos em [resultados/](etapas/01_sql_sobre_a_estrela/resultados/). As assunções de cada query estão no README e no cabeçalho do `.sql`.

### 1.1 Receita líquida por mês e grupo_canal (com LAG)

Query: [q1_receita_mensal_por_canal.sql](etapas/01_sql_sobre_a_estrela/consultas/q1_receita_mensal_por_canal.sql) · resultado: 96 linhas (12 meses × 8 grupos) em [q1_receita_mensal_por_canal.md](etapas/01_sql_sobre_a_estrela/resultados/q1_receita_mensal_por_canal.md).

- **Total: R$ 966.988,99**, o número de controle usado no LookML e no Power BI.
- A receita sobe de R$ 18 mil (out/25) para ~R$ 90 mil por mês a partir de dez/25, com pico de R$ 125,9 mil em ago/26.
- Social Pago (33%) e Busca Paga (23%) somam 56% da receita.
- **Set/26 é parcial** (dados até 20/09) e vem marcado em `mes_parcial`: as quedas de até −44% nesse mês não são comparáveis com um mês cheio.
- O `LAG` roda sobre uma grade mês × grupo, com receita 0 nos meses sem venda. Vídeo não vende em out/25: sem a grade, nov/25 seria comparado com um mês errado. A variação sobre base 0 fica nula.

### 1.2 Ticket médio por tipo_produto × faixa_etaria

Query: [q2_ticket_medio_produto_faixa.sql](etapas/01_sql_sobre_a_estrela/consultas/q2_ticket_medio_produto_faixa.sql).

| # | Tipo | Faixa | Vendas | Ticket médio | Desvio padrão | IC 95% | % planos anuais | Amostra pequena (n < 30) |
|---:|---|---|---:|---:|---:|---|---:|---|
| **1** | **Assinatura** | **35-44** | **310** | **R$ 363,81** | R$ 298,54 | R$ 330,58 a R$ 397,04 | 57,7% | Não |
| 2 | Assinatura | 25-34 | 410 | R$ 341,66 | R$ 277,94 | R$ 314,76 a R$ 368,57 | 57,1% | Não |
| 3 | Assinatura | 45+ | 121 | R$ 334,86 | R$ 279,16 | R$ 285,12 a R$ 384,61 | 56,2% | Não |
| 4 | Assinatura | 18-24 | 210 | R$ 331,66 | R$ 282,49 | R$ 293,46 a R$ 369,87 | 54,8% | Não |
| 5 | Avulso | 18-24 | 533 | R$ 227,02 | R$ 80,64 | R$ 220,18 a R$ 233,87 | — | Não |
| 6 | Avulso | 45+ | 310 | R$ 224,78 | R$ 77,66 | R$ 216,14 a R$ 233,43 | — | Não |
| 7 | Avulso | 35-44 | 787 | R$ 224,43 | R$ 81,80 | R$ 218,72 a R$ 230,15 | — | Não |
| 8 | Avulso | 25-34 | 1.057 | R$ 223,88 | R$ 81,36 | R$ 218,98 a R$ 228,79 | — | Não |

**Maior ticket: Assinatura × 35-44, R$ 363,81, sustentado por 310 vendas.**

**Confiabilidade:** a amostra é suficiente para estimar o ticket (n bem acima de 30), mas **não para dizer que essa faixa tem o maior ticket**. Os ICs das quatro faixas de Assinatura se sobrepõem: a diferença para a segunda colocada (R$ 22) cabe no ruído. O desvio padrão é alto (~R$ 300) porque Assinatura mistura planos mensais (R$ 49,90 e R$ 89,90) e anuais (R$ 479 e R$ 899), e o ticket depende mais desse mix do que da idade. A diferença que é real é entre os tipos: Assinatura (~R$ 340) contra Avulso (~R$ 225), com ICs bem separados.

### 1.3 Taxa de reembolso e recusa por categoria

Query: [q3_reembolso_recusa_categoria.sql](etapas/01_sql_sobre_a_estrela/consultas/q3_reembolso_recusa_categoria.sql).

| Categoria | Vendas | Taxa de recusa | Taxa de reembolso | Pares cliente × produto | Recusa (dedup) | Reembolso (dedup) |
|---|---:|---:|---:|---:|---:|---:|
| Assinatura | 1.144 | 5,42% | 2,87% | 1.111 | 5,58% | 2,95% |
| Certificações | 712 | 5,34% | 3,86% | 700 | 5,43% | 3,92% |
| Conversação | 687 | 5,97% | 3,10% | 675 | 6,07% | 3,15% |
| Espanhol | 653 | 6,43% | 4,09% | 643 | 6,53% | 3,99% |
| Inglês | 916 | 5,24% | 4,72% | 901 | 5,33% | 4,81% |
| **Total** | **4.112** | **5,62%** | **3,68%** | **4.030** | **5,73%** | **3,73%** |

- **Denominadores:** recusa = recusadas / tentativas de pagamento; reembolso = reembolsadas / cobradas (aprovadas + reembolsadas), porque só pode ser reembolsado quem foi cobrado. As 88 vendas gratuitas ficam fora (não há cobrança).
- **Como evito contar duas vezes:** além da taxa por transação, calculo a taxa por **par cliente × produto**. Cada par conta uma vez e é marcado como "teve recusa" ou "teve reembolso" se isso aconteceu em pelo menos uma das suas vendas. Assim, quem comprou o mesmo produto duas vezes, ou teve o cartão recusado e tentou de novo, não pesa em dobro.
- **Leitura:** nesta base a deduplicação muda pouco (4.112 vendas viram 4.030 pares: só 82 vendas repetem um par), mas protege a métrica. Inglês tem o maior reembolso (4,7%) e Espanhol a maior recusa (6,4%).

### 1.4 Recorrência em meses consecutivos

Query: [q4_recorrencia_meses_consecutivos.sql](etapas/01_sql_sobre_a_estrela/consultas/q4_recorrencia_meses_consecutivos.sql).

| Perfil de compra | Clientes | % dos recorrentes |
|---|---:|---:|
| Só avulso | 193 | 49,7% |
| **Assinatura e avulso** | **175** | **45,1%** |
| Só assinatura | 20 | 5,2% |
| **Total recorrentes** | **388** | 100% (14,0% dos 2.780 compradores) |

**388 clientes compraram em dois meses consecutivos; 175 deles compraram assinatura e avulso.** Compra = venda aprovada e não gratuita; dez/25 → jan/26 conta como consecutivo. A base não registra a renovação mensal da assinatura como venda, então a recorrência aqui é recompra, e "só assinatura" é raro (20).

### 1.5 Taxa de ganho no CRM

Queries: [q5_1_crm_taxa_ganho.sql](etapas/01_sql_sobre_a_estrela/consultas/q5_1_crm_taxa_ganho.sql) (taxa) e [q5_2_crm_nulos.sql](etapas/01_sql_sobre_a_estrela/consultas/q5_2_crm_nulos.sql) (nulos).

| Recorte | Encerrados | Ganhos | **Taxa sobre encerrados** | Taxa sobre todos |
|---|---:|---:|---:|---:|
| **Total** | 5.167 | 431 | **8,34%** | 4,79% |
| [B2B] Corporativo | 372 | 36 | 9,68% | 5,67% |
| [B2C] Consultivo | 2.792 | 223 | 7,99% | 4,57% |
| [B2C] Transacional | 2.003 | 172 | 8,59% | 4,93% |
| Ana | 2.350 | 203 | 8,64% | 4,94% |
| Bruno | 1.276 | 102 | 7,99% | 4,63% |
| Camila | 775 | 60 | 7,74% | 4,45% |
| Diego | 522 | 41 | 7,85% | 4,53% |
| Elisa | 244 | 25 | 10,25% | 5,75% |

O cruzamento funil × responsável está no resultado completo.

**Denominador: só os encerrados (won / (won + lost)).** Os 3.833 negócios em aberto ainda não tiveram desfecho. Colocá-los no denominador mistura conversão com idade do pipeline e penaliza quem tem mais negócios recentes. A taxa sobre todos aparece ao lado só para comparação. Duas ressalvas:
- **Pipeline parado:** 2.850 dos negócios em aberto (74%) foram criados há mais de 90 dias. Se forem negócios mortos que nunca foram encerrados no CRM, até a taxa sobre encerrados é otimista.
- **Amostras pequenas:** as diferenças entre responsáveis são de 1 a 2 p.p., com n de 244 a 2.350. Elisa lidera com 25 ganhos, e alguns ganhos a menos mudariam o ranking. No B2B por responsável há só de 21 a 160 encerrados.

**Negócios sem valor ou sem canal:**

| | Negócios | % |
|---|---:|---:|
| Sem valor | 3.387 | 37,6% |
| Sem canal | 1.647 | 18,3% |
| Sem valor **ou** sem canal | 4.406 | 49,0% |
| Sem valor **e** sem canal | 628 | 7,0% |

**O que muda na leitura do pipeline:**
- **O valor do pipeline está subestimado.** A soma direta dos negócios em aberto dá R$ 1,31 milhão, mas 38% deles não têm valor. Valor nulo não é zero: extrapolando a média conhecida do mesmo funil, o pipeline seria de ~R$ 2,1 milhões (+60%). Isso é uma ordem de grandeza, não uma meta, porque supõe que o preenchimento é aleatório.
- **18% dos negócios ficam fora de qualquer leitura por canal**, sem como estimar. A conversão por canal e o retorno de marketing ficam incompletos.
- **44% dos negócios não têm cliente**, o que impede ligar o CRM às vendas (`fact_vendas`). Antes de qualquer meta sobre o pipeline, a correção é tornar valor e canal obrigatórios no CRM.

## 2. Camada semântica (LookML)

Projeto em [etapas/02_camada_semantica_no_looker/](etapas/02_camada_semantica_no_looker/). Sem instância Looker disponível, o LookML foi escrito para ser revisado como código e validado em duas frentes:
- **Sintaxe:** parser `lkml` em todos os arquivos.
- **Boas práticas:** linter LAMS, o look-at-me-sideways do Looker Open Source (descrições em campos visíveis, PKs ocultas, joins pela PK).

Como eu testaria com uma instância está no item 2.5.

```
fluenta.model.lkml            conexão, datagroup, formato R$, access_grant
manifest.lkml                 regras do LAMS
views/                        5 views da estrela + 2 hipotéticas do item 2.4
explores/vendas.explore.lkml  explore principal
explores/assinaturas.explore.lkml   explore separado (item 2.4)
```

### 2.1 Views

| View | Primary key | dimension_group | Destaques de tipo |
|---|---|---|---|
| `fact_vendas` | `venda_id` | (a data vem de `dim_data`) | `venda_gratuita` e `tem_desconto` como `yesno`; valores por linha ocultos, para forçar o uso das medidas |
| `dim_data` | `data_id` | `data` (date, week, month, quarter, year, dia da semana) | `datatype: date` e `convert_tz: no`: data de calendário, sem fuso |
| `dim_cliente` | `cliente_id` | `cadastro` | `estado` é a chave do filtro de acesso |
| `dim_produto` | `produto_id` | — | `periodicidade_plano` (Mensal/Anual), derivada porque é o que move o ticket de Assinatura (Q2) |
| `dim_canal` | `canal_id` | — | Usada duas vezes no explore (role-playing), com `from: dim_canal`: `dim_canal_venda` (canal da venda) e `dim_canal_aquisicao` (canal de aquisição do cliente) |

### 2.2 Por que o relationship importa

O `relationship` diz ao Looker quantas linhas de cada lado se correspondem. É com essa informação que ele decide se uma agregação corre risco de contar a mesma linha mais de uma vez.

No explore `vendas` a base é a fato (1 linha por venda), e todas as dimensões entram como `many_to_one`: várias vendas para um cliente, um produto, um canal e uma data. Nesse arranjo:
- **Medidas da fato saem corretas com SQL simples** (`SUM`, `COUNT`), porque nenhum join duplica vendas.
- **Medidas das dimensões são protegidas.** O Looker sabe que `dim_cliente` está do lado "one" e que cada cliente se repete a cada venda. Por isso aplica symmetric aggregates nas medidas dessa view: `dim_cliente.qtd_clientes` vira uma contagem distinta pela PK e dá **3.020 clientes**.
- **Se o relationship estivesse errado:**
  - Declarado como `one_to_one`, o Looker trataria o join como seguro e faria `COUNT(*)`: daria **4.200**, uma "cliente" por venda, sem nenhum erro visível.
  - Declarado como `one_to_many` ou `many_to_many` sem necessidade, os números continuariam certos, mas toda soma da fato passaria a usar symmetric aggregates: SQL mais pesado e mais lento.

Ou seja, o relationship errado pode gerar número errado sem aviso nenhum ou desperdiçar processamento. Ele precisa refletir a cardinalidade real, e isso pressupõe uma `primary_key` única em cada view.

### 2.3 Medidas

Todas partem da regra única de receita (README, assunções gerais). As taxas são calculadas a partir de contagens componentes, que ficam ocultas, e nunca como média de taxas. Assim continuam corretas em qualquer recorte.

| Medida | Definição | Por quê |
|---|---|---|
| `receita_liquida` | Soma de `valor_liquido` das vendas aprovadas e não gratuitas | Definição oficial de Receita |
| `qtd_vendas` | Todas as vendas, em qualquer status | Volume bruto; para as vendas com receita, existe `qtd_vendas_validas` |
| `clientes_unicos` | Clientes distintos com venda aprovada e não gratuita | Conta compradores efetivos, não quem só teve o cartão recusado |
| `ticket_medio` | `receita_liquida / qtd_vendas_validas` | Numerador e denominador sobre a mesma base de vendas |
| `taxa_reembolso` | Reembolsadas / cobradas (aprovadas + reembolsadas), sem gratuitas | Só pode ser reembolsado quem foi cobrado (igual à Q3) |
| `pct_vendas_com_desconto` | Vendas válidas com desconto > 0 / vendas válidas | As gratuitas têm 100% de desconto e inflariam o indicador |

Medidas extras: `taxa_recusa`, e `receita_bruta` e `total_descontos`, estas duas restritas por `access_grant`.

### 2.4 Fan-out com `fact_assinaturas_diaria`

**O problema.** A nova tabela tem 1 linha por cliente por dia. Ao juntá-la ao explore via `dim_cliente`, cada venda se repete uma vez por dia de assinatura daquele cliente. Uma venda de R$ 479 de um cliente com 300 dias de assinatura passa a somar R$ 143.700. É o fan-out: o join um-para-muitos multiplica as linhas da fato antes da agregação.

**Como o Looker mitiga (symmetric aggregates).** Quando o join é declarado `one_to_many`, o Looker reescreve as medidas do lado "one" para que cada linha conte uma única vez. Na prática ele gera algo como `SUM(DISTINCT hash(pk) + valor) - SUM(DISTINCT hash(pk))`, e a receita volta a ficar correta. Mas há limitações:
- só funciona com PK correta em todas as views e relationship correto;
- o SQL fica bem mais caro;
- não resolve medidas semiaditivas: somar 30 fotos diárias de MRR dá 30× o MRR do mês;
- a pergunta continua ambígua ("receita de quem tinha assinatura ativa em qual dia?").

**Minha solução** está implementada como código hipotético, marcado como tal nos arquivos:
1. **Explore separado** [`assinaturas`](etapas/02_camada_semantica_no_looker/explores/assinaturas.explore.lkml): cada grão no seu explore. As análises de assinatura (assinantes ativos, MRR médio diário) acontecem ali, com uma PK composta cliente × dia.
2. **Agregação prévia em PDT** [`assinaturas_por_cliente`](etapas/02_camada_semantica_no_looker/views/assinaturas_por_cliente.view.lkml): resume a tabela diária para 1 linha por cliente (primeiro dia, dias como assinante, se está ativo hoje). Com isso o join no explore de vendas volta a ser `many_to_one` e a receita não infla. A PDT é reconstruída pelo mesmo `datagroup` da carga.
3. **Cruzamentos no tempo** (receita e assinantes por mês): seriam feitos com uma derived table no grão comum mês × canal, ou combinando os dois explores no dashboard, em vez de um join direto.

Não dependo dos symmetric aggregates como solução principal. Eles corrigem a soma, mas escondem um modelo com grãos misturados.

### 2.5 Governança e validação contra o SQL da Parte 1

**Governança aplicada:**
- **Filtro regional:** `access_filter` em `dim_cliente.estado`, ligado ao user attribute `estados_permitidos`, nos dois explores. O time Sul recebe `"PR,SC,RS"` e a diretoria recebe `"%"`. O filtro entra sempre no `WHERE` e o usuário não consegue removê-lo.
- **Campos financeiros:** `access_grant: ver_financeiro` restringe `receita_bruta` e `total_descontos` aos departamentos Financeiro e Diretoria.
- **`hidden: yes`:** em todas as PKs e FKs, nos valores por linha (`valor_bruto`, `desconto`, `valor_liquido`), nas colunas redundantes de `dim_data` e nas contagens que compõem as taxas. Quem usa o explore só encontra medidas que já aplicam a regra de receita.

**Como eu validaria que os números do Explore batem com o SQL da Parte 1:**
1. **LookML Validator** na IDE do Looker, para pegar campos e referências quebradas antes de qualquer número.
2. **Números de controle:** montar no Explore os mesmos recortes das queries da Parte 1 e comparar valor a valor:

   | Recorte no Explore | Valor esperado | Query da Parte 1 |
   |---|---|---|
   | Receita líquida, sem filtros | R$ 966.988,99 | Q1 (soma de todos os meses e canais) |
   | Receita líquida, jan/26 × Social Pago | R$ 30.834,62 | Q1 (uma linha) |
   | Vendas válidas e ticket médio, sem filtros | 3.738 e R$ 258,69 | Q2 (soma das vendas e média ponderada das linhas) |
   | Taxa de reembolso, sem filtros | 3,68% | Q3 (linha Total) |

   Vale testar pelo menos um total e um recorte cruzado (mês × canal), porque é no join que costumam aparecer duplicações.
3. **Aba SQL do Explore:** conferir o SQL que o Looker gera. Cada medida com `filters:` deve virar um `CASE WHEN` dentro da agregação, com a mesma regra da Parte 1, e os joins devem sair como `LEFT JOIN` por chave, sem fan-out. Rodar esse SQL e a query da Parte 1 lado a lado no SQL Runner.
4. **Automatizar:** transformar os números de controle em testes de dados do Looker (blocos `test:` com `assert`), rodando no CI (por exemplo, com Spectacles) a cada pull request. Assim, uma mudança na regra de receita quebra o build antes de chegar ao dashboard.
5. **Governança:** usar *sudo* como um usuário regional para confirmar que o `access_filter` recorta os estados e que os campos com `access_grant` somem para quem não tem permissão.

## 3. Dashboard AARRR

**Entrega:**
- Dashboard em PDF: [etapas/03_dashboard_de_funil_de_growth_AARRR/dashboard_aarrr.pdf](etapas/03_dashboard_de_funil_de_growth_AARRR/dashboard_aarrr.pdf).
- Projeto Power BI: `dashboard_aarrr.pbip`, com modelo e visuais versionáveis como texto.

Os valores abaixo são do período padrão (jun–ago/26), comparado com o período anterior de mesma duração (mar–mai/26).

### Pergunta de negócio e resposta

**Estamos crescendo de forma saudável? Ainda não.**

| Etapa | Indicador | Jun–ago/26 | Variação | Leitura |
|---|---|---|---|---|
| Aquisição | Cadastros | 1.618 | ▼ 1,9% | Estável em ~540 por mês desde out/25 |
| Ativação | 3+ lições em 7 dias | 26,1% | ▲ 0,2 p.p. | Parada em ~26% há 11 meses |
| Retenção | Retidos em D30 | 25,8% | ▼ 3,1 p.p. | Queda dentro da variação amostral (erro padrão da diferença ≈ 2,3 p.p.) |
| Receita | Receita líquida | R$ 307,9 mil | ▲ 17,3% | Puxada pelo pico de agosto; ~R$ 90 mil por mês desde dezembro |
| Recomendação | % via Indicação | 7,0% | ▼ 0,2 p.p. | Estável entre 5% e 8% |

A receita cresce, mas a base do funil está parada: os cadastros não crescem e 3 em cada 4 novos alunos param na primeira semana. **O gargalo é a ativação.** No histórico, quem conclui 3 lições nos 7 primeiros dias retém **4,1× mais** em D30 (60,5% contra 14,6%; no período padrão do painel, 3,7×: 56,0% contra 15,1%), e a ativação não melhorou em quase um ano. Por isso o painel termina no bloco "onde agir", que aponta para o onboarding: é exatamente o que o teste `exp_onboarding_v2` da etapa 4 ataca.

### North Star Metric

**Alunos ativados: novos cadastros que concluem 3 ou mais lições nos 7 primeiros dias.** No trimestre foram **422**, ▼ 1,4%.

> *Justificativa em uma linha: une aquisição e o valor entregue ao aluno, prevê retenção (no histórico, ativados retêm 4× mais) e é a alavanca que o squad de growth controla.*

A NSM é uma **estimativa**: cadastros × taxa de ativação. Os dados de engajamento cobrem uma amostra de ~50% dos cadastros, representativa da base (a no máximo 1,1 p.p. em canal, objetivo, estado e faixa etária). Contar só os ativados observados mediria a cobertura do tracking, e não a ativação: essa contagem cairia 54% de junho para agosto apenas porque a cobertura caiu. A base observada (168 ativados entre 644 usuários) aparece na dica de ferramenta do cartão.

### Como o painel atende ao enunciado

| Item pedido | No painel |
|---|---|
| Aquisição por canal e semana | Mapa de calor canal × semana de cadastro, com totais |
| Ativação (3+ lições em 7 dias) | Cartão com variação e tendência por mês de cadastro |
| Retenção (1 − churn_d30) por canal e objetivo | Cartão e dois gráficos de barras (canal e objetivo); barras claras indicam amostra pequena (n < 100) |
| Receita, ticket e mix avulso × assinatura | Cartão com receita, ticket e % assinatura; colunas empilhadas por mês |
| Recomendação (proxy) | Cartão e tendência do % de cadastros via Indicação, com a limitação no subtítulo |
| Pergunta no topo e NSM | Título com a pergunta, resposta dinâmica e cartão da NSM com a justificativa |
| Filtros e comparação | Período, Canal e Estado; cada KPI traz a variação contra o período anterior de mesma duração |
| Títulos com a conclusão, escalas e cores | Títulos dinâmicos (mudam com os filtros), eixos a partir de zero, sem 3D nem eixo duplo; paleta segura para daltônicos (azul = favorável, vermelhão = desfavorável, sempre com ▲▼) |
| Notas de qualidade | Rodapé com definições, limitações e data de atualização |

O filtro de **Período** atua em tudo, exceto nas três tendências mensais (ativação, receita e indicação), que mostram o histórico e dizem isso no título ("Histórico mensal: …"). Os segmentos de retenção seguem o período e destacam em azul claro os recortes com menos de 100 alunos: num trimestre, cada canal tem de 19 a 228 alunos na amostra. O texto sob os filtros informa a cobertura dos dados (cadastros até 31/08, ativação e retenção até 14/08), para que um período depois dessas datas não pareça uma queda real.

### Proxy de Recomendação e limitação

**Proxy:** % dos cadastros que chegam pelo canal **Indicação**. Foi de 7,0% no trimestre e de 6,7% no histórico, estável entre 5% e 8% por mês.

**Limitações:**
- **Só capta indicação rastreada** (link ou código). A recomendação boca a boca chega como Direto ou Busca Orgânica e fica invisível.
- **Não liga indicador a indicado.** Sem esse vínculo, não dá para medir o coeficiente viral (quantos novos alunos cada aluno traz) nem saber se quem indica são os alunos ativados.
- **Mede o resultado, não a intenção.** Um aluno satisfeito que ainda não indicou ninguém não aparece. A disposição a recomendar pediria uma pesquisa, como o NPS.

**Como eu evoluiria:**
- Código de indicação por aluno, para ligar indicador e indicado e calcular o coeficiente viral.
- NPS ao fim da primeira semana, para cruzar a disposição a recomendar com a ativação.
- Pergunta "como nos conheceu?" no cadastro, para estimar o boca a boca que hoje cai em Direto e Busca Orgânica.

### Visão mobile

O painel não foi configurado em layout móvel. A versão para celular reaproveitaria os mesmos visuais, em retrato, com estas mudanças:

| Elemento | Desktop (1920 × 1080) | Mobile (retrato) |
|---|---|---|
| Ordem | Leitura em grade, da esquerda para a direita | Uma coluna, na ordem da decisão: resposta → NSM → "onde agir" → KPIs → tendências |
| "Onde agir" | Último bloco | Sobe para logo depois da NSM: é a mensagem principal, e no celular a pessoa olha só a primeira tela |
| Filtros | Três segmentações no topo | Recolhidos no painel de filtros, com o período padrão já aplicado; no topo fica só a linha "Comparação: …" |
| Cartões AARRR | Cinco lado a lado | Grade 2 × 2 (Aquisição, Ativação, Retenção, Recomendação), com Receita na largura toda (tem três valores) |
| Mapa de calor canal × semana | 14 semanas × 8 canais | Ilegível a ~360 px: troca por barras de cadastros por canal no período, com a tendência semanal total abaixo |
| Retenção | Canal e objetivo lado a lado | Empilhados, um gráfico por vez |
| Gráficos de linha | Rótulo em todos os pontos | Rótulo só no último ponto e eixo com meses alternados |
| Títulos | Conclusão completa | Versões curtas da mesma conclusão (ex.: "Ativação parada em 26%") |
| Notas de qualidade | Rodapé completo | Uma linha ("Definições e limitações ⓘ") abrindo o texto completo numa dica ou numa página de detalhe |

## 4. Painel do teste A/B (exp_onboarding_v2)

**Entrega:**
- Painel em PDF, no corte de 20/09: [etapas/04_painel_diario_de_acompanhamento_de_teste_AB/dashboard_testeab.pdf](etapas/04_painel_diario_de_acompanhamento_de_teste_AB/dashboard_testeab.pdf).
- Projeto Power BI: `dashboard_testeab.pbip`.

O painel tem uma **data de corte** que mostra o teste como estava em qualquer dia, do 1º dia de entrada (24/08) até a maturação da última coorte (20/09). Todas as medidas são recalculadas para aquela data. Assim, o mesmo painel serve para o acompanhamento diário e para reproduzir o que o squad teria visto em cada dia.

### Como o painel atende ao enunciado

| Item pedido | No painel |
|---|---|
| Usuários por variante por dia e checagem 50/50 com alerta visual | Colunas de usuários por variante por dia; barras do **z diário** em azul, âmbar (\|z\| > 1,96, aviso) ou vermelhão (\|z\| > 3,29, alerta); cartão com a divisão acumulada e o z |
| Conversão acumulada por variante, diferença absoluta e relativa, IC | Linhas de ativação acumulada por variante; cartão com Δ em p.p., IC 95% e relativo com IC; gráfico da evolução do Δ com o IC e o MDE |
| Dias decorridos × 21 planejados; amostra atual × necessária (20%, +2 p.p.) | Cartão de duração (entrada + maturação) e cartão de amostra madura × 6.507 por braço, calculada no próprio DAX |
| Receita por usuário (secundária) e segmento por dispositivo | Barras de receita por usuário com o Δ e o IC no subtítulo; matriz por dispositivo com o Δ, o IC e o n |
| Aviso de leitura ("não decida antes de X") | Faixa no topo que muda com a data de corte: ⏳ NÃO DECIDA ANTES DE 20/09 · ⛔ PARE (SRM) · ✔ PRONTO PARA DECISÃO |

### Decisões erradas que o painel pode induzir e como o desenho as reduz

Os exemplos vêm do próprio experimento, relido dia a dia pela data de corte.

| # | Leitura ingênua | Decisão errada | Como o desenho reduz |
|---|---|---|---|
| 1 | **Olhar todo dia e parar no primeiro p < 0,05.** No dia 8 (31/08), a variante B aparece com +11,9 p.p. (+59%) e p < 0,0001 | Lançar com um efeito 8× maior que o real. Com 20 olhadas, a chance de um falso positivo fica muito acima dos 5% nominais | O aviso no topo diz **"NÃO DECIDA ANTES DE 20/09"** até completar 21 dias de entrada + 7 de maturação (regra pré-registrada no rodapé). O p-valor fica só na dica de ferramenta; o destaque é o IC |
| 2 | **Achar que o efeito dos primeiros dias vale para todos** (efeito novidade, ou um perfil diferente de quem entra no início) | Superestimar o impacto no planejamento | O gráfico da diferença ao longo do tempo mostra o efeito encolhendo de +11,9 para +1,4 p.p., e o título diz isso. Exige a duração completa (3 ciclos semanais) |
| 3 | **Contar como "não convertido" quem ainda não completou 7 dias** | Taxas que mudam todo dia sem razão. E uma variante que só *acelera* a ativação parece melhor no começo, sem ativar mais gente no fim | Só usuários maduros entram na conversão; o cartão de amostra separa os maduros dos atribuídos; a curva começa em 31/08 |
| 4 | **Ignorar a divisão 50/50, ou reagir a todo alarme diário** | Ler um teste com atribuição quebrada; ou encerrar um teste válido por um alarme falso (07/09: 396 × 318, z = −2,9) | O cartão de divisão 50/50 vem antes do resultado, e as barras do z diário ficam coloridas por alerta. Alerta vermelho só com \|z\| > 3,29, porque com 21 checagens diárias um falso a 5% é esperado; o dia 07/09 fica em âmbar, como aviso. No `exp_checkout_botao_unico`, a mesma checagem dispararia (53/47, z ≈ 7,6) e bloquearia a leitura |
| 5 | **Confundir significativo com relevante** | "Deu significativo, então ganhamos +2 p.p.", quando o IC é de +0,2 a +2,7 e cabe um efeito quase nulo. Ou o oposto: no dia 25 o IC passa de 0 e alguém conclui que "não funciona" | O IC vem logo abaixo do Δ no cartão. O gráfico da diferença traz o IC e linhas de referência em 0 e no MDE (+2 p.p.), e o aviso final manda decidir pelo IC contra o MDE |
| 6 | **Ler só o efeito relativo** ("+7%", "+59%") | Superestimar o ganho | O Δ absoluto em p.p. vem em destaque; o relativo vem abaixo, sempre com o seu IC |
| 7 | **Usar a métrica secundária como prova** ("receita por usuário +22%") | Prometer receita que o teste não mostra: o IC vai de −R$ 0,06 a +R$ 1,34, e só ~2,5% dos usuários têm receita em 7 dias | O visual é marcado como "secundária", e o título dinâmico diz "diferença não significativa" |
| 8 | **Pescar subgrupo** ("só funciona no desktop") | Lançar só no desktop, com base em ruído: o mobile não é significativo, mas os ICs se sobrepõem | A matriz por dispositivo mostra o IC de cada segmento ao lado do Total e é marcada como "exploratório". A diferença entre desktop e mobile não é significativa (p ≈ 0,31) |
| 9 | **Estender o teste até ficar significativo** | Inflar o falso positivo do mesmo jeito que parar cedo | A duração e a amostra (6.507 por braço) são fixas e aparecem nos cartões. O aviso "amostra insuficiente" diz explicitamente para não estender |

### Leitura em 20/09: a hipótese foi aceita?

A leitura é válida: a divisão está ok (z = +1,42), a duração foi cumprida e a amostra foi atingida (122% da necessária).

| | Controle | Variante B | Diferença |
|---|---|---|---|
| Ativação (3+ lições em 7 dias) | 20,25% | 21,68% | **+1,43 p.p.** (IC 95%: +0,17 a +2,69) · relativo +7,1% · p ≈ 0,026 |

A resposta depende de qual hipótese se testa:
- **"A variante B aumenta a ativação?" → sim.** O IC não inclui o zero (z ≈ 2,2, p ≈ 0,026), e a leitura foi feita na data pré-registrada, sem *peeking*.
- **"A ativação sobe para pelo menos 22% (+2 p.p.)?" → não confirmada.** A estimativa (+1,43) fica abaixo de +2 p.p. O IC até alcança +2,69, mas também é compatível com um efeito quase nulo (+0,17), e a chance de o efeito real ser ≥ +2 p.p. fica em torno de 19%. O MDE serviu para dimensionar a amostra; se +1,4 p.p. compensa é uma decisão de negócio.

**Por dispositivo (exploratório):** no mobile, o IC (−0,47 a +2,50) cruza o zero. Isso **não** mostra que o onboarding não funciona no mobile:
- o teste não foi dimensionado para o subgrupo;
- a diferença entre desktop (+2,48) e mobile (+1,01) não é significativa (z ≈ 1,0, p ≈ 0,31);
- o mobile tem 72% dos usuários.

A melhor estimativa para os dois dispositivos continua sendo o efeito total.

**Em ordem de grandeza:** +1,43 p.p. sobre ~1.600 cadastros por trimestre dá cerca de **+23 alunos ativados por trimestre (+5,5% na NSM)**. Como, no histórico, quem ativa retém 4× mais, isso daria ~10 alunos retidos a mais por trimestre. É uma associação, não um efeito causal provado pelo teste.

**Recomendação: lançar o onboarding v2.** O efeito é positivo e confiável, não há sinal de dano, e a receita por usuário vai na mesma direção (+R$ 0,64, não significativa). Três cuidados:
1. **Comunicar o efeito certo:** "+1,4 p.p. (entre +0,2 e +2,7)", e não o "+7%" sozinho nem os +11,9 p.p. do dia 8.
2. **Manter um holdout pequeno (ex.: 5%):** o efeito encolheu ao longo do teste, o que sugere efeito novidade.
3. **Não projetar receita nem decidir por dispositivo** a partir deste teste.

*Sobre o z:* ele mede quantos "erros padrão" (o ruído esperado por acaso) cabem na diferença observada. Acima de ~2, dificilmente é acaso. Mas o z cresce com a amostra, então ele diz se o efeito é real, não se é grande: o tamanho vem do IC.

## 5. Crítica do dashboard de Performance Comercial

### 5.1 Problemas por gravidade

O critério é o risco para a decisão, não a estética. Três níveis:
- **Número errado ou não confiável:** a decisão parte de um dado incorreto.
- **Leitura distorcida:** o número está certo, mas o visual induz a conclusão errada.
- **Falta de foco:** a informação certa existe, mas é difícil de achar.

| # | Problema | Decisão errada que induz | Correção |
|---|---|---|---|
| 1 | **Três telas mostram "Receita" com números diferentes** | Cada área defende o número da sua tela; ninguém sabe qual é o real, e o dashboard perde a credibilidade inteira, inclusive no que está certo | Uma definição única de Receita, calculada uma vez na camada semântica e reutilizada em todas as telas (ver 5.3) |
| 2 | **Vermelho/verde de "abaixo/acima da meta" sem meta visível e sem legenda** | O usuário recebe um julgamento (bom/ruim) sem saber contra o quê nem por quanto: −1% e −40% ficam com a mesma cor. A meta pode estar desatualizada sem ninguém perceber. Vermelho/verde é o par mais confundido por daltônicos (~8% dos homens) | Mostrar a meta e o % atingido (barra de progresso com o ritmo esperado do mês). Paleta azul/laranja, sempre com ▲▼ e o valor; a cor nunca é o único sinal |
| 3 | **Sem filtro de data, período fixo em "últimos 90 dias"** | Sem comparação, não dá para saber se o número é bom. A janela móvel muda todo dia, mistura meses incompletos e não serve para fechamento de mês nem para reunião (o número de segunda já não é o de terça) | Filtro de período com padrão no mês corrente, comparação com o período anterior e com o mesmo período do ano anterior, e aviso de mês parcial |
| 4 | **Barras com eixo Y começando em 90%** | Nas barras, o comprimento é o valor: uma diferença de 2% vira uma barra 3× maior. Leva a cortar ou premiar canais por diferenças irrelevantes | Eixo sempre em zero nas barras. Se a diferença pequena importar, mostrá-la explicitamente (Δ em p.p. ou gráfico de variação) |
| 5 | **Receita e nº de vendas no mesmo gráfico com eixo duplo** | A posição relativa das linhas depende só da escala escolhida em cada eixo: cruzamentos e "descolamentos" são artefatos e sugerem uma relação que não existe | Dois gráficos alinhados no mesmo eixo X, ou o indicador que a comparação tenta mostrar: o ticket médio (receita / vendas) |
| 6 | **Pizza 3D com 11 fatias (canais)** | A perspectiva aumenta as fatias da frente, e comparar 11 ângulos é impossível. O ranking de canais lido no gráfico pode estar errado, e é com ele que se aloca verba | Barras horizontais ordenadas, os 5 maiores canais mais "Outros", eixo em zero, com a variação vs o período anterior |
| 7 | **14 KPIs em cartões iguais na mesma linha** | Sem hierarquia, tudo parece igualmente importante e nada se destaca; o usuário escolhe o número que confirma a sua tese | 3 a 4 KPIs na primeira dobra, ligados à pergunta do painel; o resto vai para uma página de detalhe ou tooltip |

Os itens 1 a 3 se corrigem primeiro: enquanto eles existirem, melhorar os gráficos (4 a 7) só deixa mais bonito um número em que ninguém confia.

### 5.2 Wireframe da versão corrigida

Uma página, desenhada para a pergunta "a receita está no ritmo da meta?". Os valores são ilustrativos; os do CRM vêm da Q5.

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│ PERFORMANCE COMERCIAL · A receita está no ritmo da meta do mês?                                │
│ Período [Set/2026 ▾]  Comparar com [Mês anterior ▾]  Canal [Todos ▾]  Estado [Todos ▾]         │
│ Atualizado em 21/09/2026 06:00 · Dados até 20/09 · Receita = aprovadas e não gratuitas (i)     │
├────────────────────────────────────┬───────────────────┬───────────────────┬───────────────────┤
│ RECEITA LÍQUIDA                    │ VENDAS VÁLIDAS    │ TICKET MÉDIO      │ TAXA DE REEMBOLSO │
│ R$ 89,3 mil                        │ 397               │ R$ 224,90         │ 3,4%              │
│ [###############-----] 78% da meta │ ▼ 12% vs ago      │ ▲ 3% vs ago       │ ▲ 0,4 p.p. vs ago │
│               ^ ritmo hoje: 67%    │                   │                   │                   │
│ Meta do mês: R$ 115 mil            │                   │                   │                   │
│ ▼ 9% vs mesmo período de ago       │                   │                   │                   │
├────────────────────────────────────┴───────────────────┼───────────────────┴───────────────────┤
│ Set/26 no ritmo: 78% da meta com 67% do mês            │ 2 canais pagos = 55% da receita       │
│ R$ mil                                                 │ R$ mil, set/26 · seta vs ago          │
│ 120 ┤                               ##                 │ Social Pago   ############## 25,3  ▼  │
│ 115 ┤ -- -- -- -- -- -- -- -- -- -- ## -- meta         │ Busca Paga    #############  23,8  ▼  │
│  80 ┤          ##    ##    ## ## ## ## ::              │ Busca Org.    ########       13,7  ▼  │
│  40 ┤    ## ## ## ## ## ## ## ## ## ## ::              │ E-mail        ####            6,9  ▼  │
│   0 ┼─##─##─##─##─##─##─##─##─##─##─##─::              │ Direto        ###             5,8  ▲  │
│       O  N  D  J  F  M  A  M  J  J  A  S*              │ Outros (3)    ########       13,8  ▼  │
│ :: set/26 parcial · eixo começa em zero                │ Barras ordenadas, eixo em zero        │
├────────────────────────────────────────────────────────┼───────────────────────────────────────┤
│ Vendas e ticket lado a lado, sem eixo duplo            │ Pipeline CRM: 74% aberto há >90 dias  │
│ Nº de vendas válidas / mês     Ticket médio (R$) / mês │ Taxa de ganho (encerrados)  8,3%      │
│        # #####                            #            │ Em aberto                   3.833     │
│     ##########                    # #######            │   dos quais >90 dias        2.850     │
│   ############                 ############            │ Sem valor preenchido        38%       │
│   O..........S*                O..........S*           │                                       │
│ Dois gráficos, mesmo eixo X, cada um na sua escala     │                                       │
├────────────────────────────────────────────────────────┴───────────────────────────────────────┤
│ NOTAS · Definições: (i) em cada KPI (glossário) · Meta: Plano Comercial 2026 (Financeiro)      │
│ Limitações: set/26 parcial; 18% dos negócios do CRM sem canal · Detalhe dos demais KPIs: pág. 2│
│ Cores: azul = acima da meta, laranja = abaixo, sempre com ▲▼ e o valor (legível p/ daltônicos) │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

Decisões do desenho:
- **Pergunta no título e títulos que dizem a conclusão** ("Set/26 no ritmo: 78% da meta com 67% do mês"), não apenas "Receita por mês".
- **Hierarquia:** a Receita ocupa o cartão maior e vem com a meta, o % atingido e o **ritmo esperado** (dias decorridos / dias do mês). Isso resolve o mês parcial: 78% da meta no dia 20 está no ritmo, não abaixo.
- **Comparação justa:** o mês parcial é comparado com o mesmo período do mês anterior (1 a 20/08), não com o mês cheio.
- **Uma métrica por gráfico,** eixos em zero, mês parcial destacado (`::` no wireframe; hachurado no painel).
- **Rodapé de notas:** definições (o ícone (i) abre o glossário), a fonte da meta, as limitações e a data de atualização.
- **Mobile:** os 4 KPIs viram uma grade 2×2 no topo e os gráficos ficam empilhados em uma coluna, na ordem de leitura (receita × meta, canais, vendas/ticket, CRM). Os filtros vão para uma gaveta.

### 5.3 Conversa com o dono do dashboard e definição única de Receita

**Conduzindo a mudança sem atrito:**
1. **Começar pelo uso, não pela crítica.** Perguntar quem usa o painel, para quais decisões e quais 3 números a pessoa olha primeiro. Conferir também os logs de uso. A conversa passa a ser sobre o objetivo dela, não sobre o trabalho dela.
2. **Partir de uma dor compartilhada e concreta.** Escolho o problema 1 (Receita divergente) e reconcilio os três números junto com o dono: "esta tela soma o valor bruto, esta inclui reembolsos, esta usa a data de pagamento". Ninguém defende um número errado, e o dono vira aliado da mudança.
3. **Usar critérios, não gosto.** Cada ajuste é justificado pela decisão que ele protege (a tabela 5.1) ou por um guia de visualização da empresa. Assim não é a minha opinião contra a dela.
4. **Construir em paralelo e iterar.** Monto a versão nova ao lado da atual, valido com 2 ou 3 usuários e mantenho as duas por um ciclo de fechamento. Começo pelo que é crítico (Receita, meta, filtro de data), uma entrega pequena e visível; o visual vem depois.
5. **Dar o crédito ao dono.** Ele apresenta a versão nova ao time. O dashboard continua sendo dele, agora com dados certificados.

**Garantindo uma única definição de "Receita":**
1. **Definição escrita e aprovada.** Fica no glossário de métricas, com dono formal (Financeiro/Controladoria junto com Dados) e o aval de Comercial e Marketing. Exemplo: *receita líquida = soma do valor líquido das vendas aprovadas e não gratuitas, pela data da venda.*
2. **Calculada em um único lugar.** A medida fica na camada semântica (`receita_liquida` no LookML da etapa 2, ou uma medida DAX num dataset certificado e compartilhado no Power BI). Os dashboards consomem essa medida e nenhum deles recalcula receita por conta própria.
3. **Variantes com nome próprio.** Bruta, caixa e contábil podem existir, mas se chamam "Receita bruta", "Receita caixa" etc. Nada se chama só "Receita" além da oficial.
4. **Testes e controle de mudança.** Um teste automatizado compara a medida com o fechamento do ERP/Financeiro, como os testes da etapa 2. Mudar a regra exige pull request e revisão, e o efeito retroativo fica registrado.
5. **Definição visível no painel.** O ⓘ no cartão mostra a regra e o link para o glossário, para que quem lê saiba exatamente o que está vendo.

## 6. Da necessidade ao indicador

> "Quero saber se o marketing está dando retorno."

### 6.1 Perguntas antes de construir

1. **Que decisão a resposta vai apoiar?** Realocar verba entre canais, mudar o orçamento total ou justificar o investimento?
2. **"Retorno" é o quê, e em que prazo?** Receita, margem, alunos que ficam (LTV) ou leads? Em 30 dias ou em 12 meses?
3. **Quanto se investe, em quê, e onde isso está registrado?** Sem custo por canal não há ROI.
4. **O que conta como marketing?** Só mídia paga, ou também SEO, e-mail, indicação e afiliados? No consultivo, o que é mérito do consultor?
5. **Existe meta?** CAC máximo, retorno mínimo, payback. Com que frequência a verba é revista?
6. **Que números você usa hoje** (Google Ads, Meta, RD Station) **e onde eles não batem?**

### 6.2 Indicadores propostos

Canal = canal de aquisição do cliente. Coorte = mês de cadastro: cada mês de investimento é comparado com o que os clientes que ele trouxe geraram depois.

| Indicador | Definição | Fonte | Grão / frequência | Decisão |
|---|---|---|---|---|
| **CAC** | Investimento do canal no mês / novos pagantes da coorte (1ª compra aprovada e não gratuita) | Custos de mídia + `dim_cliente` + `fact_vendas` | Canal × coorte / mensal | Realocar verba e definir o CAC máximo por canal |
| **ROAS D90** | Receita líquida da coorte em 90 dias / investimento do mês da coorte | `fact_vendas` + `dim_cliente` + custos | Canal × coorte / mensal, quando a coorte completa 90 dias | Aumentar ou reduzir o orçamento; abaixo de 1 = payback acima de 90 dias |
| **Conversão em 60 dias** | Cadastros com 1ª compra em até 60 dias / cadastros da coorte | `dim_cliente` + `fact_vendas` (consultivo: `crm_negocios`) | Canal × semana / semanal | Ajustar campanhas antes do fechamento: separar volume de compradores |
| **Retenção D30** | 1 − `churn_d30` dos cadastrados pelo canal | `usuarios_features_churn` | Canal × coorte / mensal | Rever público e promessa do canal: vender sem reter encarece o CAC real |

### 6.3 Limitações explícitas

- **Atribuição:** em 100% das vendas o canal da venda é o canal de aquisição do cliente (*first-touch* fixo). Recompra vinda de e-mail é creditada ao anúncio original, o que superestima a mídia de aquisição e subestima o CRM. O efeito real (incremental) só se mede com testes de holdout ou pausa controlada.
- **Vendas consultivas:** o crédito é dividido com o consultor, e 54% dos negócios ganhos não têm `cliente_id` (18% dos negócios não têm canal). Sem corrigir o preenchimento do CRM, o consultivo não se liga à receita.
- **Ciclo de compra:** mediana de 32 dias do cadastro à 1ª compra (p90 de 75 dias; só 14% na 1ª semana). A campanha de um mês rende nos 2 a 3 meses seguintes: por isso a leitura é por coorte, e o mês corrente sempre parece pior.
- **Custo e causalidade:** a base não tem investimento, e orgânico e indicação também custam. Além disso, a sazonalidade (pico de dez/jan) move todos os canais juntos: crescer junto com o investimento não prova que o investimento causou o crescimento.
