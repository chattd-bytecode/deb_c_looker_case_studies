view: order_items_dt {

  derived_table: {
    sql: select users.id ,
    order_items.created_at ,
     RANK () OVER (PARTITION BY users.id ORDER BY order_items.created_at ASC) as rank
     FROM `looker-partners.thelook.users` users
     LEFT JOIN `looker-partners.thelook.order_items` order_items ON order_items.user_id = users.id
    ORDER BY users.id, order_items.created_at asc;;
}

dimension: id {
  type: number
  sql: ${TABLE}.id ;;
}

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

measure: rank {
  type: number
  sql: ${TABLE}.rank ;;
  }

}
