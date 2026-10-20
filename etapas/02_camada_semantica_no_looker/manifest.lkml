project_name: "fluenta"

# Regras do linter look-at-me-sideways (LAMS), rodado com `npx lams`.
# Desde a v3 as regras precisam ser ativadas aqui, no bloco #LAMS.
# Fora de propósito:
# - K1 e E2: exigem a convenção de nome "pk1_<campo>" na chave primária. As views usam
#   primary_key: yes com o nome original da coluna, e todos os joins já são feitos pela PK.
# - F3: proíbe count sem filtro, mas qtd_vendas é intencionalmente o total bruto.

#LAMS
#rule: F1 {} # Campos não referenciam outras views diretamente
#rule: F2 {} # Sem view_label em campos individuais
#rule: F4 {} # Todo campo visível tem description
#rule: E1 {} # Joins referenciam campos via ${}
#rule: E6 {} # foreign_key só aponta para primary key
#rule: E7 {} # Label do explore é curta
#rule: K3 {} # Primary key declarada no topo da view
#rule: K4 {} # Primary key é hidden
#rule: W1 {} # Indentação consistente
