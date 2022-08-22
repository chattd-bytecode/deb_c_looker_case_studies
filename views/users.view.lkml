# The name of this view in Looker is "Users"
view: users {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.users`
    ;;
  # drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Age" in Explore.

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_group {
    type: tier
    tiers: [15,26,36,51,66]
    style: integer
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

   dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: full_name {
    label: "Customer's Full Name"
    description: "Customer's Full Name"
    type: string
    sql: ${first_name} || ' ' || ${last_name} ;;
  }


  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: month_tiers {
    label: "Months Since Sign Up (6 Month Tiers)"
    type: tier
    tiers: [1,6,12,18,24,30,36]
    style: integer
    sql: ${months_since_signup} ;;
  }

  dimension: new_customer {
    type: string
    sql: CASE WHEN DATE_DIFF(CURRENT_DATE(),DATE (DATE ${users.created_date}),  DAY) <= 90 THEN 'New customer' ELSE 'Long-term customer' END;;
  }

  dimension: new_versus_old_customer {
    type: string
    sql: CASE WHEN DATE_DIFF(CURRENT_DATE(),DATE (${created_raw}),  DAY) <= 30 THEN 'Last Month'
              WHEN DATE_DIFF(CURRENT_DATE(),DATE (${created_raw}),  DAY) > 365 AND DATE_DIFF(CURRENT_DATE(),DATE (users.created_at),  DAY) < 730 THEN 'Last Year'
              ELSE NULL END;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    drill_fields: [detail*]
  }

  dimension: user_location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: yesterday {
    type: yesno
    sql: DATE_DIFF(DATE ${users.created_date}, CURRENT_DATE(), DAY) = -1;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: average_age {
    type: average
    sql: ${age} ;;
  }

  measure: average_days_since_signup {
    description: "Average number of days between a customer initially registering on the website and now"
    type: average
    sql: DATE_DIFF(CURRENT_DATE(),${users.created_date}, DAY) ;;
  }

  measure: average_months_since_signup {
    description: "Average number of months between a customer initially registering on the website and now"
    type: average
    sql: DATE_DIFF(CURRENT_DATE(),${users.created_date}, MONTH) ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, events.count, order_items.count]
  }

  measure: cumulative_customers {
    type: running_total
    sql: ${total_customers} ;;
  }

  # measure: cumulative_customers_percentage_change {
  #   type: number
  #   sql: round(ifnull(100 * (${cumulative_customers}/lag(${created_raw}) over(order by ${created_raw} desc) - 1), 0), 2) ;;
  #   value_format_name: percent_1
  # }

  measure: days_since_signup {
    description: "The number of days since a customer has signed up on the website"
    type: string
    sql: DATE_DIFF(CURRENT_DATE(),${users.created_date}, DAY);;
  }

  dimension: months_since_signup {
    description: "The number of months since a customer has signed up on the website"
    type: number
    sql: DATE_DIFF(CURRENT_DATE(),${users.created_date}, MONTH) ;;
  }

  measure: total_age {
    type: sum
    sql: ${age} ;;
  }

  measure: total_customers {
    type: count
    drill_fields: [detail*]
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    allow_fill: yes
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


 # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      gender ,
      age_group
    ]
  }

}
