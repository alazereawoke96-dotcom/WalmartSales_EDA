-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

SELECT * FROM walmartsales.sales;

SELECT time FROM sales;

-- time of day
SELECT time, 
(
case
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end ) as time_of_date
 FROM sales;

alter table sales add column time_of_day varchar(10);
update sales
set time_of_day =
(
case
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end ) ;
 SET SQL_SAFE_UPDATES = 0;

-- day name
select date,dayname(date) from sales;
alter table sales add column day_name varchar(40);
update sales
set day_name = dayname(date);

-- month name
select date,monthname(date) as name_of_month from sales;
alter table sales add column month_name varchar(10);
update sales
set month_name = monthname(date);

SELECT * FROM walmartsales.sales;

-- How many unique cities does the data have?
select distinct city from sales;

-- In which city is each branch?
select distinct city,branch from sales;

-- How many unique product lines does the data have?
select distinct product_line from sales;
select count(distinct product_line) cnt_product_line from sales;

-- What is the most common payment method?
select distinct payment from sales;
select distinct payment ,count( payment) cnt_payment from sales
group by payment
order by 2 desc;

-- What is the most selling product line?
select product_line from sales;
select distinct product_line, count(product_line) cnt_product_line from sales
group by product_line
order by 2 desc;

-- What is the total revenue by month?
select month_name as month ,sum(total)  total_revenue from sales
group by 1
order by 2;

-- What month had the largest COGS(cost of good sold)?
select month_name as month, sum(cogs) sum_cogs from sales
group by 1
order by 2 desc;

-- What product line had the largest revenue?
select product_line , sum(total) sum_rev from sales
group by 1
order by 2 desc;

-- What is the city with the largest revenue?
select branch, city , sum(total) revenue_sum from sales
group by 1,2
order by 3 desc;

-- What product line had the largest VAT?
select product_line ,avg(tax_pct) as tax_pct from sales 
group by 1
order by 2 desc;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select avg(quantity) from sales;

select product_line,
case 
when avg(quantity) > 6  then "Good"
else "Bad"
end as performance
from sales
group by product_line;



-- Which branch sold more products than average product sold?
select branch, sum(quantity) sum_qty from sales
group by 1
having sum(quantity) > ( select avg(quantity) from sales) ;
 

 -- What is the most common product line by gender?
 select gender, product_line, count(gender) count_gender from sales 
 group by gender,product_line
 order by count_gender desc;
 
 
 -- What is the average rating of each product line?
select product_line, avg(rating) avg_rate
from sales
group by 1
order by 2 desc;
-- or
select product_line, round(avg(rating),2) avg_rate
from sales
group by 1
order by 2 desc;

-- -----------------------------SALES----------------------------
-- Number of sales made in each time of the day per weekday
select time_of_day,count(*) total_sales from sales
where day_name= "monday"
group by 1
order by 2 desc;

-- Which of the customer types brings the most revenue?
select  customer_type,sum(total) revenue from sales
group by 1
order by 2 desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select city,avg(tax_pct) vat from sales
group by 1
order by 2 desc  ;

-- Which customer type pays the most in VAT?
select customer_type,sum(tax_pct) vat from sales
group by 1
order by 2 desc  ;

-- ----------------------------CUSTOMER----------------------------------
-- How many unique customer types does the data have?
select distinct customer_type from sales;

-- How many unique payment methods does the data have?
select distinct payment from sales;

-- What is the most common customer type?
select distinct customer_type,count(customer_type) count_customer_type from sales
group by 1
order by 2 desc;

-- Which customer type buys the most?
select distinct customer_type,count(customer_type) count_customer_type from sales
group by 1
order by 2 desc;

-- What is the gender of most of the customers?
select gender,count(gender) cunt_gender from sales
group by 1
order by 2 desc;

-- What is the gender distribution per branch?
select gender,count(gender) cunt_gender from sales
where branch = "A"
group by 1
order by 2 desc;
-- Which time of the day do customers give most ratings?
select time_of_day,avg(rating) avg_rating from sales
group by 1
order by 2 desc;

 -- Which time of the day do customers give most ratings per branch?
 select time_of_day,avg(rating) avg_rating from sales
 where branch = "A"
group by 1
order by 2 desc;
 
-- Which day of the week has the best avg ratings?
select day_name ,avg(rating) avg_rating from sales
group by 1
order by 2 desc;

-- Which day of the week has the best average ratings per branch?
select day_name ,avg(rating) avg_rating from sales
 where branch = "A"
group by 1
order by 2 desc;

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- --                                          Revenue And Profit Calculations                                                           ---
-- we can calculate cogs using
-- $ COGS = unitsPrice * quantity $
select unit_price,quantity,unit_price*quantity cogs from sales;

-- we can calculate vat(tax_pct) using
-- $ VAT = 5% * COGS $
select cogs, 5/100*cogs vat from sales;

-- we can calculate total(gross_sales)  using
-- $ total(gross_sales) = VAT + COGS $
select tax_pct,cogs total,tax_pct+cogs total from sales;

-- $ grossProfit(grossIncome) = total(gross_sales) - COGS $
select total,COGS ,total-cogs grossIncome from sales;

-- Gross Margin is gross profit expressed in percentage of the total(gross profit/revenue)
-- Gross Margin=grossincome/revenue
select gross_income/total*100 from sales;


SELECT * FROM walmartsales.sales;



SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;