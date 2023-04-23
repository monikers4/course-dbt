Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

### Week 1 Project 
- How many users do we have? 130 unique users
- On average, how many orders do we receive per hour? 7.52 per hour
- On average, how long does an order take from being placed to being delivered? ~3.89 days
- How many users have only made one purchase? 25 Two purchases? 28 Three+ purchases? 71

ORDER_COUNT|CUSTOMER_COUNT
--- | --- 
1|25
2|28
3|34
4|20
5|10
6|2
7|4
8|1

_Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase._

- On average, how many unique sessions do we have per hour? ~16.3 unique sessions per hour

<details>
  <summary>SQL</summary>

  ```
-- distinct users
select count(distinct user_id) unique_users from DEV_DB.DBT_MONICAKIM4GMAILCOM.POSTGRES__USERS
-- 130

-- avg orders per hour
select
avg(order_count)
from (
  select 
  date_trunc ('hour',created_at) created_hour, 
  count(order_id) order_count
  from DEV_DB.DBT_MONICAKIM4GMAILCOM.POSTGRES__ORDERS
  group by 1
  ) a
-- 7.520833

-- avg delivery time
select 
avg(datediff(day,created_at, delivered_at)) as avg_deliverytime
from DEV_DB.DBT_MONICAKIM4GMAILCOM.POSTGRES__ORDERS
where order_status = 'delivered'
-- 3.89


-- customers that have made n number of orders
select 
order_count
,count(user_id) customer_count
from (
  select 
  user_id,
  count(order_id) as order_count
  from DEV_DB.DBT_MONICAKIM4GMAILCOM.POSTGRES__ORDERS
  group by 1
  ) a
group by 1
order by 1

-- unique sessions per hour
select 
avg(unique_sessions) avg_sessionsperhour
from (
select
date_trunc ('hour',created_at) created_hour, 
count(distinct session_id) as unique_sessions
from DEV_DB.DBT_MONICAKIM4GMAILCOM.POSTGRES__EVENTS
group by 1
) a
  ```
</details>


### Week 2 Project 
**What is our user repeat rate?**
Repeat Rate = Users who purchased 2 or more times / users who purchased

```markdown
with user_orders as (
  select 
  user_id, 
  count(order_id) as order_count
  from DEV_DB.DBT_MONICAKIM4GMAILCOM.STG_POSTGRES__ORDERS
  group by 1
)

select 
count(user_id) as total_purchasers, 
count_if(order_count>1) as repeat_purchasers,
count_if(order_count>1)/count(user_id) * 100 as pct_repeat_purchaser_rate
from user_orders
```
**Answer:** 79.8% 
TOTAL_PURCHASERS  REPEAT_PURCHASERS PCT_REPEAT_PURCHASER_RATE
124 99  79.838700

**What are good indicators of a user who will likely purchase again? **
Those who purchase regularly
Those who browse often and have converted. Conversion definition could be completed purchase and has ordered. 

-- Other data
Those who signal satisfaction with order or shares with friends/social network
Those who don't cancel or return their order

**What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?**
Users who have only ordered one time, or who do not purchase with regularity 
If the user browses, but does not order 
If user never purchases 
If user does regularly engage on site
If user has not placed order in a while
If user lives in an area where there is shipping friction. e.g., is too expensive, takes too long

-- Other data: 
- Users who cancel/return (suggesting dissatisfaction)
- Users who leave negative feedback (negative experience of some kind, unhappy with product, indicated that ordered item is not as described, etc.)
- Users who receive some kind of marketing message (discount code) and do not engage or purchase

**Explain the product mart models you added. Why did you organize the models in the way you did?**
I created a daily product aggregated fact table (fct_product_activity_daily) table that enables a daily/product level view of site information and order-related information. I chose to add page_view and add_to_cart for site_information only because I saw that the events table only had product information populated for two event types. From this new fact table, an analyst/stakeholder can obtain product-level information about activity at different points in the customer's journey as well as be able to extract information about product order performance (conversion, total orders volume, units/order, revenue).

**Tests**
For the tests, I put in basic tests to validate for uniqueness (based on the granularity of the table.)
I also created a generic test to check that a field/column doesn't have a negative value. (e.g., added this to the dim_products model to ensure no negative values for price.) I also installed the dbt_utils and great_expectations packages to scan for other useful tests. I used dbt_expectations.expect_column_pair_values_A_to_be_greater_than_B test to check that page_views >= add_to_cart for the fct_product_activity_daily model.