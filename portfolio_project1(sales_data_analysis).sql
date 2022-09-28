/* PORTFOLIO PROJECT
   
   Dataset Name: Global Superstore sales data (2012-2016)
                 A sales data analysis 
   Dataset source: github
   link: https://github.com/abjta1029/sample_data_files/blob/main/global_superstore_sales_data(2012-2016).xlsx
   
   Schema: portfolio_project
   table1: Sales_data
    |  Column name  |  type  |
    +---------------+--------+
    |     rowID     |   int  |
    |   orderID     | varchar|
    |   orderDate   |  date  |
    |   shipDate    |  date  |
    |   salesyears  |  date  |
    |  customerID   | varchar|
    |  customerName | varchar|
    |    segment    | varchar|
    |     city      | varchar|
    |     state     | varchar|
    |    country    | varchar|
    |    region     | varchar|
    |    market     | varchar|
    |   productID   | varchar|
    |   category    | varchar|
    |  sub_category | varchar|
    |  productName  | varchar|
    |     sales     |   int  |
    |    quantity   |   int  |
    |    discount   |   int  |
    |    profit     |   int  |
    |  shippingCost |   int  |
    | orderPriority | varchar|
    +---------------+--------+
    
    table2: returnedItem
    |  Column name  |  type  |
    +---------------+--------+
    |   returned    | varchar|
    |   orderID     | varchar|
    +---------------+--------+  */


select top(10)*from sales_data;
select COUNT(*) as total_num_of_rows from sales_data;

select top(10)*from returnedItem;
select COUNT(*) as total_num_of_rows from returnedItem;


-- Question1: Total sales value and also salse value by years
select sum(sales) as total_sales_value_in_USD from sales_data;

select distinct salesyears,sum(sales) as sales_value_in_USD
from sales_data 
group by Salesyears
order by Salesyears asc; 


-- Question2: Total quantity sold and also quantity sold by years
select sum(quantity) as total_quantity from sales_data;

select distinct salesyears,sum(Quantity) as total_quantity
from sales_data 
group by Salesyears
order by Salesyears asc;


-- Question3: Total profit made and also profit made by years
select sum(Profit) as total_profit_in_USD from sales_data;

select distinct salesyears,sum(Profit) as total_profit_in_USD
from sales_data 
group by Salesyears
order by Salesyears asc;


-- Question4: Total number of products sold in each category
select distinct sub_category, category, count(rowid) as num_of_product_sold_in_each_category
from sales_data
group by Sub_Category,category
order by category asc;


-- Question5: Total value(in USD) of products sold in each category
select distinct sub_category, category, sum(Sales) as value_of_products_in_USD
from sales_data
group by Sub_Category,category
order by category asc;


 -- Question6: Top 20 products which have highest number of sold quantity 
select distinct productname, sum(quantity) as num_of_products, sum(Sales) as value_of_products_in_USD
from sales_data
group by productname
order by num_of_products desc
OFFSET 0 ROWS FETCH FIRST 20 ROWS ONLY; 


-- Question7: Top 10 profit making product
select distinct productname,sub_category,sum(profit) as total_profit
from sales_data
group by productname,sub_category
order by total_profit desc
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY;


-- Question8: Top 10 loss making product
select distinct productname,sub_category,sum(profit) as total_loss
from sales_data
group by productname,sub_category
order by total_loss asc
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY;


-- Question9: sales by country
select distinct country, region, market, sum(sales) as sales_value_in_USD
from sales_data
group by country, region, market
order by country;


-- Question10: The average,minimum and maximum number of days required to deliver the product
select avg(datediff(dd,orderdate,shipdate)) as avg_num_of_days
from sales_data;

select min(datediff(dd,orderdate,shipdate)) as min_num_of_days
from sales_data;
-- '0' signify same day delivery

select max(datediff(dd,orderdate,shipdate)) as max_num_of_days
from sales_data;


-- Question11:Maximum discount offerd
-- using subquery
select productname,Sales,Quantity,discount
from sales_data
where Discount in(select max(discount) from sales_data)

-- using cte
with cte_disc (max_discount) as(
select max(discount) from sales_data)
select productname,Sales,Quantity,discount
from sales_data s,cte_disc d
where s.Discount=d.max_discount;


-- Question12: Total number of items returned and also Number of item returned each year
select COUNT(Returned) as total_num_returned_products from returnedItem;


with cte_returned (num_of_product,years)as(
select r.order_id_returned_product,s.salesyears
from returnedItem r
left join sales_data s
on r.order_id_returned_product=s.orderid)
select count(num_of_product) as num_of_returned_Item,years
from cte_returned
group by years
order by years asc;
