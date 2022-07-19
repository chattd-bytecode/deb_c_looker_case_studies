# The name of this view in Looker is "Customer Behavior Group"
view: customer_behavior_group {
  derived_table: {
    sql: SELECT
         user_id as user_id ,
         COUNT(distinct ORDER_ID) as lifetime_orders ,
         MIN(CREATED_AT) as first_purchase ,
         MAX(CREATED_AT) as most_recent_purchase ,
         SUM(SALE_PRICE) as total_revenue
       FROM order_items
       GROUP BY user_id
       ;;
  }
 # This primary key is the unique key for this table in the underlying database.
 # You need to define a primary key in a view in order to join to other views.

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    primary_key: yes
  }

  # Dimensions
  dimension: days_from_purchase {
    description: "The number of days since a customer placed his or her most recent order on the website."
    sql: DATE_DIFF(CURRENT_DATE(),DATE (${TABLE}.most_recent_purchase),  DAY) ;;
  }

  dimension: is_active {
    description: "Customer is considered active if a purchase has been     made in the last 90 days"
    label: "Is Active"
    type: yesno
    sql: ${days_from_purchase} <= 90;;
  }

  dimension: lifetime_orders {
    description: "The total number of orders placed over the course of customers’ lifetimes."
    label: "Total lifetime orders"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: lifetime_orders_tier {
    description: "The total number of orders that a customer has placed since first using the website. Customers are typically analyzed in groupings rather than by the specific number of orders placed"
    label: "Total Orders Tiers"
    type: tier
    tiers: [1,2,3,6,10]
    style: integer
    sql: ${lifetime_orders} ;;
  }

  dimension: lifetime_revenue_tier {
    description: "The total amount of revenue brought in from an individual customer over the course of their patronage. Lifetime revenue is often analyzed based on specific value groupings."
    label: "Revenue Tiers"
    type: tier
    tiers: [4.99,19.99,49.99,99.99,499.99,999.99]
    style: interval
    sql: ${TABLE}.total_revenue  ;;
    value_format_name: usd
  }

  dimension: repeat_customer{
    label: "Repeat Customers"
    description: "Customers with more than 1 order"
    type: yesno
    sql: ${lifetime_orders}>1 ;;
  }

  dimension: total_revenue {
    description: "The total amount of revenue brought in over the course of customers’ lifetimes."
    type: number
    sql: ${TABLE}.total_revenue ;;
    value_format_name: usd
  }

  # Measures
  measure: average_lifetime_orders {
    description: "The average number of orders that a customer places over the course of their lifetime as a customer."
    type: average
    sql: ${lifetime_orders} ;;
  }

  measure: average_lifetime_revenue {
    description: "The average amount of revenue that a customer brings in over the course of their lifetime as a customer."
    type: average
    sql: ${TABLE}.total_revenue ;;
    value_format_name: usd
  }

  measure: customers {
    description: "Number of customers."
    type: count
  }

  measure: days_since_last_order {
    description: "The number of days since a customer placed his or her most recent order on the website."
    type: number
    sql: ${TABLE}.days_since_last_order ;;
  }

  # Dimension Groups
  dimension_group: first_order {
    description: "The date in which a customer placed his or her first order on the fashion.ly website."
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
    sql: ${TABLE}.first_purchase ;;
  }

  dimension_group: last_order {
    description: "The date in which a customer placed his or her most recent order on the fashion.ly website."
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
    sql: ${TABLE}.most_recent_purchase ;;
  }
}
