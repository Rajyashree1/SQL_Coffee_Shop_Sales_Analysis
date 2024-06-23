CREATE DATABASE Coffee_Shop_Sales_Db

select * from [dbo].[Coffee Shop Sales ] 
Exec sp_columns [Coffee Shop Sales ]

alter table [Coffee Shop Sales ]
alter column unit_price float    ----change column datatype from varchar to float

select Round(Sum(transaction_qty * ISNULL(unit_price,0)),0) 'Total_Sales'
from [Coffee Shop Sales ]
where month(Transaction_date) IN (5)


----TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
select Month(transaction_date) as 'Month' --Number of Month
,Round(SUM(transaction_qty * ISNULL(unit_price,0)),0) as 'Total_Sales'  ---Total Sales Column
,Round((Round(SUM(transaction_qty * ISNULL(unit_price,0)),0) 
- lag(Round(SUM(transaction_qty * ISNULL(unit_price,0)),0),1)--Month sales Difference
over(order by Month(transaction_date)))/ lag(Round(SUM(transaction_qty * ISNULL(unit_price,0)),0),1) --Percentage
over(order by Month(transaction_date)) *100,0) as 'Mom_Increase_Percentage'  ---
,lag(Round(SUM(transaction_qty * ISNULL(unit_price,0)),0),1)--Month sales Difference
over(order by Month(transaction_date))
from [Coffee Shop Sales ]
where Month(transaction_date) in (4,5)  --for months 4(PM) and 5(CM)(April,May)
group by Month(transaction_date)
order by Month(transaction_date)




select count(transaction_id) 'Total Orders'
from [Coffee Shop Sales ]
where Month(transaction_date) = 3 

-----TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS 'Month',
    (COUNT(transaction_id)) AS 'Total_Orders',
    round(cast((COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)))  as float)
	/ (LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))),2) *100
	AS 'Mom_Increase_Percentage'
FROM 
    [Coffee Shop Sales ]
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);



select Sum(Transaction_qty)  as 'Total_Sold_Qty'
from [dbo].[Coffee Shop Sales ]
where Month(transaction_date) = 5

---TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
select Month(transaction_date) 'Month',Sum(Transaction_qty)  as 'Total_Sold_Qty',
round(cast(Sum(Transaction_qty)  - lag(Sum(Transaction_qty),1) over (order by Month(transaction_date)) as float)/
lag(Sum(Transaction_qty),1) over (order by Month(transaction_date))*100,0) as  'Mom_Increase_Percentage'

from [dbo].[Coffee Shop Sales ]
where Month(transaction_date) IN (4,5)
group by Month(transaction_date)
order by Month(transaction_date)

-----CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    [dbo].[Coffee Shop Sales ]
WHERE 
    cast(transaction_date as date) = '20230518'

--select * from [dbo].[Coffee Shop Sales ] where cast(transaction_date as date) = '20230518'

--Exec sp_columns [Coffee Shop Sales ]

-----Rounding of the values-----
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    [Coffee Shop Sales ]
WHERE 
    cast(transaction_date as date) = '20230518' --For 18 May 2023

----SALES TREND OVER PERIOD
SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        [Coffee Shop Sales ]
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;

--DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    [Coffee Shop Sales ]
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);

--COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales,avg_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        [Coffee Shop Sales ]
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;





--SALES BY STORE LOCATION
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM [Coffee Shop Sales ]
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC

--WEEK Day concept in MS sql
select case when DATEPART(DW,cast((transaction_date) as date)) IN (1,7) then 'Week Ends' else 'Week Days' end 'Days'
,transaction_date
from [dbo].[Coffee Shop Sales ]
where --cast((transaction_date) as date) = '20230107'
 month(transaction_date) = 5 


--SALES BY WEEKDAY / WEEKEND:
SELECT 
    CASE 
        WHEN DATEPART(DW,cast((transaction_date) as date)) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
   [Coffee Shop Sales ]
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY --DATEPART(DW,cast((transaction_date) as date))
    CASE 
        WHEN DATEPART(DW,cast((transaction_date) as date)) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;


--SALES BY PRODUCT CATEGORY (name product category - Flavours,Packaged ,Chocolate,Branded,Bakery,Tea,Coffee,Coffee beans,Drinking Chocolate,Loose Tea)
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM [Coffee Shop Sales ]
WHERE
	MONTH(transaction_date) = 5  --and product_category = 'Coffee'
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC


--select  distinct product_category,STRING_AGG (cast(product_category as nvarchar(max)),',')   from [Coffee Shop Sales ]
--group by product_category


--SALES BY PRODUCTS (TOP 10)
SELECT  top 10
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM [Coffee Shop Sales ]
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10

--SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty),0) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    [Coffee Shop Sales ]
WHERE 
    DATEPART(DW,cast((transaction_date) as date)) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND DATEPART(hour,cast((transaction_time) as time)) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)

--Exec sp_columns [Coffee Shop Sales ]
--select  Transaction_time from [Coffee Shop Sales ]


--TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DATEPART(DW,cast((transaction_date) as date)) = 2 THEN 'Monday'
        WHEN DATEPART(DW,cast((transaction_date) as date)) = 3 THEN 'Tuesday'
        WHEN DATEPART(DW,cast((transaction_date) as date)) = 4 THEN 'Wednesday'
        WHEN DATEPART(DW,cast((transaction_date) as date)) = 5 THEN 'Thursday'
        WHEN DATEPART(DW,cast((transaction_date) as date)) = 6 THEN 'Friday'
        WHEN DATEPART(DW,cast((transaction_date) as date)) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty),0) AS Total_Sales
FROM 
    [Coffee Shop Sales ]
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY DATEPART(DW,cast((transaction_date) as date)) 
	order by DATEPART(DW,cast((transaction_date) as date)) asc
	
--TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    DATEPART(HOUR,cast((transaction_time) as time)) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty),0) AS Total_Sales
FROM 
    [Coffee Shop Sales ]
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
     DATEPART(HOUR,cast((transaction_time) as time))
ORDER BY 
     DATEPART(HOUR,cast((transaction_time) as time))

















