# Dimensão calendário. Grão: 1 linha por dia (data_id no formato yyyymmdd).
# Cobertura: 01/10/2025 a 20/09/2026; 09/2026 é um mês parcial.

view: dim_data {
  sql_table_name: analytics.dim_data ;;

  dimension: data_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.data_id ;;
  }

  dimension_group: data {
    type: time
    label: "Venda"
    description: "Data da venda. Use o mês/semana para séries; 09/2026 está incompleto (dados até 20/09)."
    timeframes: [raw, date, week, month, quarter, year, day_of_week, day_of_month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.data ;;
  }

  dimension: semana_iso {
    type: number
    description: "Número da semana ISO (segunda a domingo)."
    sql: ${TABLE}.semana_iso ;;
  }

  dimension: fim_de_semana {
    type: yesno
    description: "Sábado ou domingo."
    sql: ${TABLE}.fim_de_semana ;;
  }

  # Redundantes com o dimension_group; mantidos ocultos para uso em SQL
  dimension: ano {
    hidden: yes
    type: number
    sql: ${TABLE}.ano ;;
  }

  dimension: mes {
    hidden: yes
    type: number
    sql: ${TABLE}.mes ;;
  }

  dimension: nome_mes {
    hidden: yes
    type: string
    sql: ${TABLE}.nome_mes ;;
  }

  dimension: dia_semana {
    hidden: yes
    type: number
    sql: ${TABLE}.dia_semana ;;
  }
}
