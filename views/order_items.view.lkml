# The name of this view in Looker is "Order Items"
view: order_items {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.order_items`
    ;;
  # drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    hidden: no
    primary_key: yes
    label: "Order ID"
    type: number
    sql: ${TABLE}.id ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension gropoiup of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name ,
      quarter,
      year
    ]
    hidden: no
    label: "Order created"
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
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
    # hidden: yes
    label: "Delivered on"
    sql: ${TABLE}.delivered_at ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Inventory Item ID" in Explore.

  dimension: inventory_item_id {
    # hidden: yes
    type: number
    label: "Inventory item ID"
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    # hidden: yes
    label: "Order ID"
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    # hidden: yes
    label: "Product ID"
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name ,
      quarter,
      year
    ]
    # hidden: yes
    label: "Returned on"
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    # hidden: yes
    label: "Sale price"
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: valid_orders {
    hidden: yes
    description: "Canceled, returned and future orders excluded"
    label: "Valid order"
    type: string
    sql: CASE WHEN order_items.shipped_at IS NOT NULL AND order_items.returned_at IS NOT NULL AND ${order_items.created_date} < CURRENT_DATE() THEN 'Yes' ELSE 'No' END;;
  }

  dimension: yesterday {
    hidden: yes
    type: yesno
    label: "Yesterday's (yes/no)"
    sql: DATE_DIFF(DATE ${order_items.created_date}, CURRENT_DATE(), DAY) = -1;;
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: average_cost {
    # hidden: yes
    description: "Average cost of items sold from inventory"
    label: "Average cost"
    type: average
    sql: ${sale_price} ;;
  }

  # measure: average_gross_margin_amount {
  # hidden: yes
  #   description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold"
  #   type: number
  #   sql: ${total_gross_revenue} - ${total_cost} ;;
  # }

   measure: average_spend_per_customer {
    # hidden: yes
    description: "Total Sale Price / total number of customers"
    label: "Average spend per customer"
    type: number
    sql: ${total_sale_price}/${users.total_customers} ;;
    value_format_name: usd
  }

  # measure: cumulative_total_sales {
  #   description: "Cumulative total sales from items sold (running total)"
  #   type: number
  #   sql: ${total_sale_price} ;;
  # }

  measure: gross_margin_percentage {
    # hidden: yes
    description: "Total Gross Margin Amount / Total Gross Revenue"
    label: "Gross margin percentage"
    type: number
    sql: ${total_gross_margin_amount}/${total_gross_revenue} ;;
    value_format_name: percent_2
  }

  measure: item_return_rate {
    # hidden: yes
    description: "Number of Items Returned / total number of items sold"
    label: "Item return rate"
    type: number
    sql: (${number_of_items_returned}/${number_of_orders}) ;;
  }

  dimension: lifetime_orders_tier {
    description: "The total number of orders that a customer has placed since first using the website. Customers are typically analyzed in groupings rather than by the specific number of orders placed"
    label: "Total Orders Tiers"
    type: tier
    tiers: [1,2,3,6,10]
    style: integer
    sql: ${customer_behavior_group.lifetime_orders} ;;
  }
  dimension: lifetime_revenue_tier {
    description: "The total amount of revenue brought in from an individual customer over the course of their patronage. Lifetime revenue is often analyzed based on specific value groupings."
    label: "Revenue Tiers"
    type: tier
    tiers: [4.99,19.99,49.99,99.99,499.99,999.99]
    style: interval
    sql: ${customer_behavior_group.total_revenue}  ;;
    value_format_name: usd
  }

  measure: number_of_customers_returning_items {
    # hidden: yes
    description: "Number of users who have returned an item at some point"
    label: "Number of customers returning items"
    type: count_distinct
    sql: ${users.id}  ;;
    # filters: [number_of_items_returned: ""]
  }

  measure: number_of_items_returned {
    # hidden: yes
    description: "Number of items that were returned by dissatisfied customers"
    label: "Number of items returned"
    type: count_distinct
    sql: order_items.returned_at IS NOT NULL ;;
  }

  measure: number_of_orders {
    # hidden: yes
    label: "Number of orders"
    type: count
  }

  measure: revenue_percentage {
    # hidden: yes
    description: "Percentage of the total revenue"
    label: "Revenue Percentage"
    type: number
    sql: ${total_gross_margin_amount}/${total_gross_revenue} ;;
    value_format_name: percent_2
  }

  dimension_group: shipped {
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
    # hidden: yes
    label: "Order shipped on"
    sql: ${TABLE}.shipped_at ;;
  }

  measure: total_cost {
    # hidden: yes
    description: "Total cost of items sold from inventory"
    label: "Total cost"
    type: sum
    sql: ${products.cost} ;;
    filters: {
      field: valid_orders
      value: "Yes"
    }
  }

  measure: total_gross_margin_amount {
    # hidden: yes
    description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold"
    label: "Total gross margin amount"
    type: number
    sql: ${total_gross_revenue} - ${total_cost};;
    value_format_name: usd
    drill_fields: [products.category,products.brand,total_gross_margin_amount]
  }

  measure: total_gross_revenue {
    # hidden: yes
    description: "Total revenue from completed sales (canceled, returned and future orders excluded)"
    label: "Total gross revenue"
    type: sum
    # sql: IFNULL(${sale_price},0);;
    sql: ${sale_price} ;;
    filters: {
      field: valid_orders
      value: "Yes"
      }
    value_format_name: usd_0
  }

  measure: total_revenue {
    # hidden: yes
    description: "Total revenue from sales (canceled and returned orders included)"
    label: "Total revenue"
    type: sum
    sql: ${sale_price};;
    value_format_name: usd_0
  }

  measure: total_sale_price {
    # hidden: yes
    type: sum
    label: "Total sale price"
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  dimension: user_id {
    # hidden: yes
    label: "User ID"
    type: number
    sql: ${TABLE}.user_id ;;
  }

  measure: users_with_returns_percentage {
    # hidden: yes
    description: "Number of Customer Returning Items / total number of customers"
    label: "Users with returns (percentage)"
    type: number
    sql: ${number_of_customers_returning_items}/${users.total_customers} ;;
  }

  # dimension: order_sequence {
  #   description: "The order in which a customer placed orders over their lifetime as a fashion.ly customer
  #                 (i.e. if customer A placed two orders, one on January 30, 2016 and the other on June 30, 2016,
  #                 the January 1 order would have an order sequence of 1, and the June 30 order would have an
  #                 order sequence of 2)"
  #   sql:  ;;
  # }

  # measure: days_between_orders {
  #   description: "Days Between Orders The number of days between one order and the next order"
  #   type: number
  # }

  # measure: average_days_between_orders {
  #   description: "The average number of days between orders placed"
  #   type: number
  # }

  # dimension: is_first_purchase {
  #   description: "Indicator for whether a purchase is a customer’s first purchase or not"
  #   type: yesno
  # }

  # measure: has_subsequent_order {
  #   description: "Indicator for whether or not a customer placed a subsequent order on the website"
  #   type: yesno
  # }

  # dimension: sixty_day_repeat_purchase_rate {
  #   description: "The percent of customers that have purchased from the website again within 60 days of a prior purchase"
  #   type: number
  # }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.brand ,
      inventory_items.product_name,
      products.name,
      products.id
    ]
  }
}
