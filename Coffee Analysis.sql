CREATE DATABASE Coffee_Shop_Sales_Db

--select * from [dbo].[Coffee Shop Sales ] 
--Exec sp_columns [Coffee Shop Sales ]

--alter table [Coffee Shop Sales ]
--alter column unit_price float    ----change column datatype from varchar to int

--select Round(Sum(transaction_qty * ISNULL(unit_price,0)),0) 'Total_Sales'
--from [Coffee Shop Sales ]
--where month(Transaction_date) IN (5)

--select Month(transaction_date) as 'Month' --Number of Month
--,Round(SUM(transaction_qty * ISNULL(unit_price,0)),0) as 'Total_Sales'  ---Total Sales Column
--,Round((Round(SUM(transaction_qty * ISNULL(unit_price,0)),0) 
--- lag(Round(SUM(transaction_qty * ISNULL(unit_price,0)),0),1)--Month sales Difference
--over(order by Month(transaction_date)))/ lag(Round(SUM(transaction_qty * ISNULL(unit_price,0)),0),1) --Percentage
--over(order by Month(transaction_date)) *100,0) as 'Mom_Increase_Percentage'  ---
--,lag(Round(SUM(transaction_qty * ISNULL(unit_price,0)),0),1)--Month sales Difference
--over(order by Month(transaction_date))
--from [Coffee Shop Sales ]
--where Month(transaction_date) in (4,5)  --for months 4(PM) and 5(CM)
--group by Month(transaction_date)
--order by Month(transaction_date)


--select count(transaction_id) 'Total Orders'
--from [Coffee Shop Sales ]
--where Month(transaction_date) = 3 


select Month(transaction_date) as 'Month' --Number of Month
,count(transaction_id) as 'Total_Orders'  ---Total Sales Column
,(count(transaction_id)- lag(count(transaction_id),1)--Month sales Difference
over(order by Month(transaction_date)))
/ lag(count(transaction_id),1) --Percentage
over(order by Month(transaction_date)) * 100  as 'Mom_Increase_Percentage'  ---
,lag(count(transaction_id),1)--Month sales Difference
over(order by Month(transaction_date))
from [Coffee Shop Sales ]
where Month(transaction_date) in (4,5)  --for months 4(PM) and 5(CM)
group by Month(transaction_date)
order by Month(transaction_date)
