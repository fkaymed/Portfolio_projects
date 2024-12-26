select distinct *
from Portfolioproject.dbo.House_sales

--change the format for the datesold
Alter table Portfolioproject.dbo.House_sales
Add Salesdate date

Update Portfolioproject.dbo.House_sales
Set Salesdate = CONVERT(date, datesold)

--date with the highest number of sales
select distinct Salesdate, count(Salesdate) summary
from Portfolioproject.dbo.House_sales
group by Salesdate
order by summary desc


--postcode with the highest average price per sale
select distinct postcode, price, avg(price) over (partition by postcode order by postcode) average
from Portfolioproject.dbo.House_sales
order by average desc


--The year with the lowest number of sales
select PARSENAME(Replace(Salesdate,'-','.'),3)
from Portfolioproject.dbo.House_sales

Alter table Portfolioproject.dbo.House_sales
add Sales_year nvarchar(255) 
Update Portfolioproject.dbo.House_sales
set Sales_year = PARSENAME(Replace(Salesdate,'-','.'),3)

select distinct Sales_year, count(Sales_year) summary_
from Portfolioproject.dbo.House_sales
group by Sales_year
order by summary_


--Top 6 postcodes by year's price
with cte as(
Select *, RANK() over (partition by postcode order by price desc) pc
from Portfolioproject.dbo.House_sales) 
select *
from cte
where pc >0 and pc <7

