SELECT * FROM portfolio.`sales-data-sample`;
# checking unique values
select distinct  status  from portfolio.`sales-data-sample`;
select distinct PRODUCTLINE FROM  portfolio.`sales-data-sample` ;
select distinct COUNTRY FROM  portfolio.`sales-data-sample` ;
select distinct DEALSIZE FROM  portfolio.`sales-data-sample`;
select distinct TERRITORY FROM  portfolio.`sales-data-sample` ;

## ANALYSIS
##GROUPING SALES BY PRODUCT LINE
SELECT PRODUCTLINE , SUM(SALES) AS REVENUE
FROM portfolio.`sales-data-sample` 
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

## YEAR MADE MOST SALES 
SELECT YEAR_ID , SUM(SALES) AS REVENUE
FROM portfolio.`sales-data-sample` 
GROUP BY YEAR_ID
ORDER BY 2 DESC;

## WHY THE SALES WERE LOW IN THE YEAR 2005
SELECT DISTINCT MONTH_ID FROM  portfolio.`sales-data-sample`
WHERE YEAR_ID= 2005;
##OPERATED FOR ONLY 5 MONTHS 

## SALES BY DEALSIZE

SELECT DEALSIZE , SUM(SALES) AS REVENUE
FROM portfolio.`sales-data-sample` 
GROUP BY DEALSIZE
ORDER BY 2 DESC;

## BEST MONTH FOR SALES FOR A SPECIFIC YEAR 
SELECT MONTH_ID, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
FROM portfolio.`sales-data-sample` 
WHERE YEAR_ID= 2003
GROUP BY MONTH_ID
order by 2 DESC;

SELECT MONTH_ID, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
FROM portfolio.`sales-data-sample` 
WHERE YEAR_ID= 2004
GROUP BY MONTH_ID
order by 2 DESC;
SELECT MONTH_ID, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
FROM portfolio.`sales-data-sample` 
WHERE YEAR_ID= 2005
GROUP BY MONTH_ID
order by 2 DESC;

## CHECKING FOR 2004 AND 2003 , NOVEMBER WAS THE BEST MONTH FOR MOST SALES EXCLUDING YEAR 2005 

## WHAT PRODUCT SOLD MOST ON NOVEMVER IN YEAR 2004 AND 2003
SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
FROM portfolio.`sales-data-sample` 
WHERE YEAR_ID= 2004 AND MONTH_ID=11
GROUP BY MONTH_ID, PRODUCTLINE
order by 3 DESC;

SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
FROM portfolio.`sales-data-sample` 
WHERE YEAR_ID= 2003 AND MONTH_ID=11
GROUP BY MONTH_ID, PRODUCTLINE
order by 3 DESC;

## RFM analysis- indexing technique  
## who's best customer 



DROP TABLE IF EXISTS #rfm 
with rfm as 
(
select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from [dbo].[sales_data_sample]) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [dbo].[sales_data_sample])) Recency
	from [PortfolioDB].[dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm



--What products are most often sold together? 
--select * from [dbo].[sales_data_sample] where ORDERNUMBER =  10411

select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [PortfolioDB].[dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc

--Which city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from [PortfolioDB].[dbo].[sales_data_sample]
where country = 'UK'
group by city
order by 2 desc



---Which is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from [PortfolioDB].[dbo].[sales_data_sample]
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc
