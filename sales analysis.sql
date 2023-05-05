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
with rfm as 
(

select customername,
sum(Sales) as revenue,
avg(sales) as avgmonetaryvalue,
count(ordernumber) frequency,
max(orderdate) as last_order_date,
(select max(ORDERDATE) from  portfolio.`sales-data-sample` ) as max_order_date,
datediff(DD,max(orderdate),(select(orderdate) from  portfolio.`sales-data-sample` )) as recency
from  portfolio.`sales-data-sample` 
group by customername
), 
rfm_calc as (
select r.*,
ntile(4) over (order by recency) rfm_recency ,
ntile(4) over (order by frequency) rfm_frequency ,
ntile(4) over (order by avgmonetaryvalue) rfm_monetary 
from rfm as r 
order by  4 desc
) 
select c.* 
from rfm_calc c


