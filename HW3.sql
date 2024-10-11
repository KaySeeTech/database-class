-- primary and foreign keys
alter table merchants
add primary key(mid);

alter table products
add primary key(pid);

alter table sell
add foreign key (mid) references merchants (mid);

alter table sell
add foreign key (pid) references products (pid);

alter table orders
add primary key (oid);

alter table customers
add primary key (cid);

alter table contain
add foreign key (oid) references orders(oid);

alter table contain
add foreign key (pid) references products (pid);

alter table customers
add primary key (cid);

alter table place
add foreign key (cid) references customers (cid);

alter table place
add foreign key (oid) references orders(oid);

-- constraints
alter table products
add constraint names_constaint
check (name in ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor'));

alter table products
add constraint category_constaint
check (category in ('Peripheral', 'Networking', 'Computer'));

alter table sell
add constraint price_constraint
check (price between 0 and 100000);

alter table sell
add constraint quantity_available_constraint
check (quantity_available between 0 and 1000);

alter table orders
add constraint shipping_method_constraint
check (shipping_method in ('UPS','FedEx','USPS'));

alter table orders
add constraint shipping_cost_constraint
check (shipping_cost between 0 and 500);

-- Query 1: List names and sellers of products that are no longer available (quantity=0)
select products.name as product, merchants.name as merchant
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid  -- join products and merchants table with sell table
where sell.quantity_available = 0;  -- show rows where quantity is zero

-- Query 2: List names and descriptions of products that are not sold
select products.name, products.description
from products
left join sell on products.pid = sell.pid  -- left join products and sell tables
where sell.quantity_available is null;  -- looks for rows where quantity is null, those are products not sold

-- Query 3: How many customers bought SATA drives but not any routers?
select count(distinct customers.fullname) as Customers
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid  -- join all tables
where products.pid = '4' or products.pid = '5'  -- products id's 4 and 5 said they were SATA drives
except  -- exclude the count of customers that bought a router
select count(distinct customers.fullname)
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid  -- join all tables once again
where products.name = 'Router';  -- exclude customers that bought a router

-- Query 4: HP has a 20% sale on all its Networking products
select products.name, sell.price as OldPrice, sell.price * 0.8 as NewPrice -- derive a new value by multiplying by 0.8, which represents a 20% discount
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid  -- join products and merchants table with sell table
where merchants.mid = 3;   -- select all products from HP

-- Query 5: What did Uriel Whitney order from Acer?
select products.name, sell.price  -- list name and price of each item
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid  -- join each table
where customers.cid = 1 and merchants.mid = 1;  -- Uriel is customer id 1 and Acer is merchant id 1

-- Query 6: List the annual total sales for each company.
select merchants.name, year(place.order_date) as year, sum(sell.price) as sales  -- get the year and the sum of sales that year
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid  -- join all tables together
group by merchants.name, year  -- group by merchant names and years
order by merchants.name, year;  -- order so its by merchant names and years

-- Query 7: Which company had the highest annual revenue and in what year?
select merchants.name, year(place.order_date) as year, sum(sell.price) as sales  -- get the year and the sum of sales that year
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid  -- join all tables together
group by merchants.name, year
order by sales desc  -- make a list starting with highest sale during that year
limit 1;  -- group by merchant names and years


-- Query 8: On average, what was the cheapest shipping method used ever?
select orders.shipping_method, avg(orders.shipping_cost)  -- find shipping method and average cost of order
from orders
group by orders.shipping_method
having (avg(orders.shipping_cost)) <= all  -- use subquery to filter out larger shipping costs

	(select avg(orders.shipping_cost)  -- basic subquery of the average cost for each shipping method
	from orders
	group by orders.shipping_method);
    
-- Query 9: What is the best sold ($) category for each company? work
/* sanity check
select m.name, products.category,sum(sell.price) as sales-- santiy
from merchants m
inner join sell on sell.mid = m.mid  
inner join products on sell.pid = products.pid
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid
group by m.name, products.category  -- join all tables together
order by sales desc;
*/ -- 
with MerchantCategorySales as (
    select m.name as MerchantName, products.category, sum(sell.price) as TotalSales  -- select merchant names, category and sum of all sales
    from merchants m
    inner join sell on sell.mid = m.mid  
    inner join products on sell.pid = products.pid
    inner join contain on products.pid = contain.pid
    inner join orders on contain.oid = orders.oid
    inner join place on orders.oid = place.oid
    inner join customers on place.cid = customers.cid  -- join all tables together
    group by m.name, products.category),  -- group them by name and category, our base table
    
MerchantMaxSales as  -- used to find max of each group made by table above
(select MerchantName, max(TotalSales) as MaxSales  -- get the max of total sales
from MerchantCategorySales  -- use table above
group by MerchantName)

select mcs.MerchantName, mcs.category, mcs.TotalSales  -- get the categories of each company
from MerchantCategorySales mcs
inner join MerchantMaxSales mms on mcs.MerchantName = mms.MerchantName  -- join the sum and max tables
and mcs.TotalSales = mms.MaxSales;  -- find where total sales is also the max sales

-- Query 10: For each company find out which customers have spent the most and the least amounts.
select merchants.name,customers.fullname, sum(sell.price) as spent -- Sanity 
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid  -- join products and merchants table with sell table
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid
group by merchants.name, customers.fullname;

-- Create a table to get total spending for each customer 
with CustomerSpending as
(select merchants.name as merchant_name, customers.fullname as CustomerName,sum(sell.price) AS total_spent  -- sets up attributes for tables
from sell
inner join products on sell.pid = products.pid
inner join merchants on sell.mid = merchants.mid 
inner join contain on products.pid = contain.pid
inner join orders on contain.oid = orders.oid
inner join place on orders.oid = place.oid
inner join customers on place.cid = customers.cid  -- join tables together
group by merchants.name, customers.fullname
)
select cs1.merchant_name,cs1.CustomerName AS spender, cs1.total_spent AS spent  -- take customer spending and find highest sspend
from CustomerSpending cs1
where cs1.total_spent = -- filter out rows that are not max
(select max(cs2.total_spent)  -- get max spent from table
from CustomerSpending cs2 
where cs2.merchant_name = cs1.merchant_name)  -- ensures its from the same company
union all  -- combine both tables
select cs3.merchant_name,cs3.CustomerName AS lowest_spender, cs3.total_spent AS lowest_spent -- find the lowest spend from customer spending
from  CustomerSpending cs3
where  cs3.total_spent = -- filter out rows that are not the min
(select min(cs4.total_spent) -- filters out min from table
from CustomerSpending cs4 
where cs4.merchant_name = cs3.merchant_name);  -- ensure tables are from same company








