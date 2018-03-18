-- CS331 Project 1
-- Professor Heller
-- Student: Darshan Patel
-- Date: March 13, 2018

-- Simple Problems: up to 2 tables joined 

-- 1. Write a query that lists the top 10 salary takers' job title, gender and salary.
USE AdventureWorks2014;
SELECT TOP 10 E.JobTitle as [Job Title], E.Gender, (P.Rate * P.PayFrequency) as Salary
FROM HumanResources.Employee as E
	INNER JOIN HumanResources.EmployeePayHistory as P
		ON E.BusinessEntityID = P.BusinessEntityID
ORDER BY Salary DESC;

-- 2. Write a query that lists single male customers' first and last name from
--    the state British Columbia in order of their last name.
USE AdventureWorksDW2014;
SELECT C.FirstName as [First Name], C.LastName as [Last Name]
FROM dbo.DimCustomer as C
	 INNER JOIN dbo.DimGeography as G
		ON C.GeographyKey = G.GeographyKey
WHERE C.gender = N'M' and C.MaritalStatus = N'S' 
	  and G.StateProvinceName = N'British Columbia'
ORDER BY C.LastName;

-- 3. Write a query that lists customers who ordered from the UK in 2016 and their orderid.
USE TSQlV4;
SELECT C.companyname as [Name], O.orderid as [Order ID]
FROM Sales.Orders as O
	INNER JOIN Sales.Customers as C
		ON O.custid = C.custid
WHERE O.shipcountry = N'UK' AND O.orderdate >= '20160101' AND O.orderdate < '20170101'
GROUP BY C.companyname, O.orderid
ORDER BY C.companyname;

-- 4. Write a query that lists distinct ustomer names for those who have a credit limit and 
--	  have an expected delivery date in the second half of 2016 and their credit limit.
USE WideWorldImporters;
SELECT DISTINCT C.CustomerName as [Customer Name], C.CreditLimit as [Credit Limit]
FROM Sales.Customers as C
	INNER JOIN Sales.Orders as O
		ON C.CustomerId = O.CustomerId
WHERE C.CreditLimit is not NULL and O.ExpectedDeliveryDate >= '20160601'
	 AND O.ExpectedDeliveryDate < '20170101'
ORDER BY C.CreditLimit;

-- 5. Write a query that lists customer name and  how many 'DBA joke mug - mind if 
--    I join you? (Black)' mug they brought in descending order.
USE WideWorldImportersDW;
SELECT C.[Primary Contact] as [Customer], COUNT(C.[Primary Contact]) as [Number of Mugs]
FROM Fact.[Order] as O
	INNER JOIN Dimension.Customer as C
		ON C.[Customer Key] = O.[Customer Key]
WHERE C.[Customer Key] != 0 
	  and O.[Description]  LIKE N'%DBA joke mug - mind if I join you? (Black)%'
GROUP BY C.[Primary Contact]
ORDER BY COUNT(C.[Primary Contact]) DESC;

-- Medium Problems: 2 - 3 tables joined with built-in SQL functions

-- 6. Write a query that sums up the sick leave hours per gender and their average rate
--	  if their rate is greater than $20 and group by their gender
USE AdventureWorks2014;
SELECT E.Gender, SUM(E.SickLeaveHours) as [Sick Leave Hours], AVG(P.Rate) as Rate
FROM HumanResources.Employee as E
	INNER JOIN HumanResources.EmployeePayHistory as P
		ON E.BusinessEntityID = P.BusinessEntityID
WHERE P.Rate > 20
GROUP BY E.Gender;

-- 7. Write a query that lists the number of parents in each of the countries
--	  in ascending order.
USE AdventureWorksDW2014;
SELECT G.EnglishCountryRegionName as [Country],
	   COUNT(G.EnglishCountryRegionName) as [Number of Parents in the Region]
FROM dbo.DimCustomer as C
	 INNER JOIN dbo.DimGeography as G
		ON C.GeographyKey = G.GeographyKey
WHERE C.TotalChildren > 0
GROUP BY G.EnglishCountryRegionName
ORDER BY COUNT(G.EnglishCountryRegionName);


-- 8. Write a query that determines which customers had a difference of
-- at least 30 days in an order and show their name, orderid, and date difference.
USE TSQLV4;
SELECT C.companyname as [Name], O.orderid as [Order ID], 
	   DATEDIFF(day, O.orderdate, O.shippeddate) as [Date Difference]
FROM Sales.Orders as O
	INNER JOIN Sales.Customers as C
		ON O.custid = C.custid
WHERE DATEDIFF(day, O.orderdate, O.shippeddate) >= 30
ORDER BY DATEDIFF(day, O.orderdate, O.shippeddate), C.companyname;

-- 9. Write a query that finds individual (not toy store) customers who ordered in 2013
--    and waited one day for their order to be delivered. 
USE WideWorldImporters;
SELECT C.CustomerName as [Customer Name], O.ExpectedDeliveryDate as [Expected Delivery Date]
FROM Sales.Customers as C
	INNER JOIN Sales.Orders as O
		ON C.CustomerId = O.CustomerId
WHERE DATEDIFF(day, O.orderdate, O.ExpectedDeliveryDate) > 1 
		and O.orderdate >= '20130101' and O.orderdate < '20130201'
		and C.CustomerName not LIKE '%toys%'
ORDER BY O.ExpectedDeliveryDate;

-- 10. Write a query that lists "The Gu" red shirts bought at Tailspin Toys (Belgreen, AL),
--    the quantity, and the sum of price. 
USE WideWorldImportersDW;
SELECT O.[Description], COUNT(O.[Description]) as [Quantity],
	   SUM(O.[Total Including Tax]) as [Sum of Sales]
FROM Fact.[Order] as O
	INNER JOIN Dimension.Customer as C
		ON C.[Customer Key] = O.[Customer Key]
WHERE C.Customer LIKE '%Belgreen%' and O.[Description]  LIKE N'"The Gu%'
GROUP BY O.[Description]
ORDER BY SUM(O.[Total Including Tax]) DESC;

-- 11. Write a query that lists the SalesYTD rounded to the thousandths for each
--    of the salesperson, ordered by SalesYTD and last name.
USE AdventureWorks2014;
SELECT CONCAT(P.FirstName, ' ',P.LastName) as [Name], ROUND(T.SalesYTD,-3) as [SalesYTD]
FROM Sales.SalesPerson as S
	INNER JOIN Person.Person as P
		ON S.BusinessEntityID = P.BusinessEntityID
	INNER JOIN Sales.SalesTerritory as T
		ON S.TerritoryID = T.TerritoryID
GROUP BY P.LastName, P.FirstName, T.SalesYTD
ORDER BY T.SalesYTD, P.LastName;

-- 12. Write a query that lists the number of non-American professionals who own 3 or more cars
--    from each country.
USE AdventureWorksDW2014;
SELECT G.EnglishCountryRegionName as [Country],
       COUNT(C.EnglishOccupation) as [Number of Professionals]
FROM dbo.DimCustomer as C
	 INNER JOIN dbo.DimGeography as G
		ON C.GeographyKey = G.GeographyKey
WHERE G.EnglishCountryRegionName != N'United States' 
		and C.EnglishOccupation = N'Professional'
		and C.NumberCarsOwned >= 3
GROUP BY G.EnglishCountryRegionName, C.EnglishOccupation
ORDER BY G.EnglishCountryRegionName;

-- 13. Write a query that lists customers who placed at least 20 orders and 
--    their number of orders.
USE TSQLV4;
SELECT C.contactname AS [Name], COUNT(O.orderid) AS [Number of Orders]
FROM Sales.Customers AS C
	INNER JOIN Sales.Orders AS O
		ON C.custid = O.custid
GROUP BY C.contactname
HAVING COUNT(O.orderid) >= 20
ORDER BY COUNT(O.orderid), C.contactname;

-- 14. Write a query that lists non toy store customers who have ordered the first two months
--    of 2014 and their average transaction is less than -3000 in the time frame
--    in ascending order.
USE WideWorldImporters;
SELECT C.CustomerName as [Customer Name], AVG(T.TransactionAmount) as [Avg. Transaction]
FROM Sales.Customers as C
	INNER JOIN Sales.Orders as O
		ON C.CustomerId = O.CustomerId
	INNER JOIN Sales.CustomerTransactions as T
		ON C.CustomerId = T.CustomerId
WHERE T.TaxAmount = 0 and O.OrderDate >= '20140101' and O.Orderdate < '20140301'
	  and C.CustomerName NOT LIKE N'Wingtip%' and C.CustomerName NOT LIKE N'Tailspin%'
GROUP BY C.CustomerName
HAVING AVG(T.TransactionAmount) < -3000
ORDER BY AVG(T.TransactionAmount);

-- 15. Write a query that lists customers that brought a medium blue jacket in July 
--	   and the quantity as well as the salesperson associated.
USE WideWorldImportersDW;
SELECT S.[SalesPerson Key] as [Salesperson Key], C.[Customer],  O.Quantity, O.[Order Date Key]
FROM Fact.[Order] as O
	INNER JOIN Dimension.Customer as C
		ON C.[Customer Key] = O.[Customer Key]
	INNER JOIN Fact.Sale as S
		ON S.[SalesPerson Key] = O.[SalesPerson Key]
WHERE C.[Customer Key] != 0 and O.[Description] LIKE N'%jacket (Blue) M%' 
      and MONTH(O.[Order Date Key]) = 7
GROUP BY S.[SalesPerson Key], C.[Customer], O.Quantity, O.[Order Date Key]
ORDER BY S.[SalesPerson Key], O.[Order Date Key];



-- Complex Problems

-- 16. Construct a function that will take in a date and return the number of years 
--	  in between then and now. Using this function, write a query that returns the 
--	  name, their rate and the number of years each Human Resources employee has 
--	  worked til present day. 
USE AdventureWorks2014;

IF OBJECT_ID (N'dbo.YearsAtWork', N'FN') IS NOT NULL
	DROP FUNCTION YearsAtWork
CREATE FUNCTION dbo.YearsAtWork(@originaldate date)
RETURNS INT 
AS
BEGIN
	DECLARE @years int;
	SELECT @years = DATEDIFF(year, @originaldate, GETDATE())
	FROM HumanResources.Employee
	WHERE HireDate = @originaldate
	RETURN @years;
END;

SELECT CONCAT(P.FirstName, ' ', P.LastName) as [Name], H.Rate, 
       dbo.YearsAtWork(E.HireDate) as [Years at Company]
FROM HumanResources.Employee as E
INNER JOIN Person.Person as P
	ON E.BusinessEntityID = P.BusinessEntityID
INNER JOIN HumanResources.EmployeePayHistory as H
	ON E.BusinessEntityID = H.BusinessEntityID
ORDER BY dbo.YearsAtWork(E.HireDate), H.Rate, P.LastName;

-- 17. Write a function that populates a table with products purchased, the quantity
--    and average price a single parents has brought. Write a query to display 
--    it where price and quantity is in ascending order.
USE AdventureWorksDW2014;

DROP TABLE IF EXISTS dbo.SingleParentPurchases;
CREATE TABLE dbo.SingleParentPurchases(
	ProductName nvarchar(50) not null,
	Quantity int not null,
	Price float not null
	CONSTRAINT productname_pk PRIMARY KEY (ProductName)
);

INSERT INTO dbo.SingleParentPurchases(ProductName,Quantity,Price)
SELECT  P.EnglishProductName as [Product Name], COUNT(P.EnglishProductName) as Quantity, 
        AVG(I.SalesAmount) as Price
FROM dbo.FactInternetSales as I
	INNER JOIN dbo.DimCustomer as C
		ON I.CustomerKey = C.CustomerKey
	INNER JOIN dbo.DimProduct as P
		ON I.ProductKey = P.ProductKey
WHERE C.MaritalStatus = N'S' and C.TotalChildren > 0
GROUP BY P.EnglishProductName; 

SELECT ProductName as [Product], Quantity, Price
FROM dbo.SingleParentPurchases
ORDER BY Price, Quantity;

-- 18. Write a function that computes the total amount of money a customer spent.
--    Write a query that lists the top 5 buyers rounded to the thousandths, 
--    the total amount they spent in descending order and their shipping city. 
USE TSQLV4;

IF OBJECT_ID (N'dbo.TotalMoneySpent', N'FN') IS NOT NULL
	DROP FUNCTION TotalMoneySpent
GO
CREATE FUNCTION dbo.TotalMoneySpent(@name VARCHAR(50)) 
RETURNS FLOAT
AS
BEGIN
	DECLARE @total float
	SELECT @total = SUM(OD.unitprice * OD.qty)
	FROM Sales.Orders as O
	INNER JOIN Sales.OrderDetails as OD
		ON O.orderid = OD.orderid
	INNER JOIN Sales.Customers as C
		ON O.custid = C.custid
	WHERE C.contactname = @name
	RETURN @total;
END;

SELECT TOP 5 C.contactname as [Name], 
       ROUND(dbo.TotalMoneySpent(C.contactname),-3) as [Total Spent], O.shipcity as City
FROM Sales.Orders as O
	INNER JOIN Sales.OrderDetails as OD
		ON O.orderid = OD.orderid
	INNER JOIN Sales.Customers as C
		ON O.custid = C.custid
GROUP BY C.contactname, O.shipcity
ORDER BY dbo.TotalMoneySpent(C.contactname) DESC;

-- 19. Write a function that will populates a table of customers who do not go over 
--    their credit limit, their category name and their shop number. Write a query to 
--    display the table. 
USE WideWorldImporters;

DROP TABLE IF EXISTS dbo.RecentGoodStandings;
CREATE TABLE dbo.RecentGoodStandings(
	CustomerName nvarchar(100) not null,
	CustomerCategoryName nvarchar(50) not null,
	ShopNumber nvarchar(50) not null
	CONSTRAINT customername_pk PRIMARY KEY (CustomerName)
);

INSERT INTO dbo.RecentGoodStandings(CustomerName,CustomerCategoryName,ShopNumber)
SELECT DISTINCT C.CustomerName as CustomerName, 
				CC.CustomerCategoryName as CustomerCategoryName, 
				C.DeliveryAddressLine1 as ShopNumber
FROM Sales.CustomerTransactions as CT
	INNER JOIN Sales.Customers as C
		ON C.CustomerID = CT.CustomerID
	INNER JOIN Sales.CustomerCategories as CC
		ON C.CustomerCategoryID = CC.CustomerCategoryID
WHERE C.CreditLimit is not NULL and CT.TransactionAmount >=0 
		and CT.TransactionAmount < C.CreditLimit
		and DATEDIFF(year, C.AccountOpenedDate,GETDATE()) <= 2
ORDER BY C.CustomerName;

SELECT CustomerName as [Name], CustomerCategoryName as [Store Type],
	   ShopNumber as [Shop Number]
FROM dbo.RecentGoodStandings;

-- 20. Write a function that will compute the difference in retail price and unit price 
--    for a certain product. Write a query that lists products that differ in less than 
--    one dollar from its retail and unit price, and its quantiy, in the city Astor Park
--    in the order of the difference then quantity.
USE WideWorldImportersDW;

IF OBJECT_ID (N'dbo.DifferenceInPrice', N'FN') IS NOT NULL
	DROP FUNCTION DifferenceInPrice
GO
CREATE FUNCTION dbo.DifferenceInPrice(@product varchar(50)) 
RETURNS float
AS
BEGIN
	DECLARE @difference float
	SELECT @difference = [Recommended Retail Price] - [Unit Price]
	FROM Dimension.[Stock Item] 
	WHERE [Stock Item] = @product
	RETURN @difference;
END;

SELECT SI.[Stock Item], dbo.DifferenceInPrice([Stock Item]) as [Difference in Price], O.Quantity
FROM Dimension.[Stock Item] as SI
	INNER JOIN Fact.[Order] as O
		ON SI.[Stock Item Key] = O.[Stock Item Key]
	INNER JOIN Dimension.City as C
		ON O.[City Key] = C.[City Key]
WHERE dbo.DifferenceInPrice([Stock Item]) < 1.00 and C.city = N'Astor Park'
ORDER BY dbo.DifferenceInPrice([Stock Item]), O.Quantity;
