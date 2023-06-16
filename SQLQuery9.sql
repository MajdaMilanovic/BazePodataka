--1. Prikazati ime i prezime, broj godina staža, opis posla uposlenika te broj 
--knjiga uposlenika koji su u?estvovali u objavljivanju više od broja 
--objavljenih naslova izdava?a sa id 0736 a koji imaju više od 30 godina staža. 
--Rezultate upita sortirati prema godinama staža rastu?im i prema broju 
--naslova u opadaju?em redoslijedu. (Pubs) 
USE pubs

SELECT E.fname, E.lname, DATEDIFF(YEAR, E.hire_date, GETDATE()) 'STAZ', J.job_desc, COUNT(*)
FROM employee AS E
INNER JOIN jobs as J
ON E.job_id=J.job_id
INNER JOIN publishers AS P
ON E.pub_id=P.pub_id
INNER JOIN titles AS T
ON P.pub_id=T.pub_id
WHERE DATEDIFF(YEAR, E.hire_date, GETDATE()) >30
GROUP BY  E.fname, E.lname, DATEDIFF(YEAR, E.hire_date, GETDATE()), J.job_desc
HAVING COUNT(*) > (SELECT COUNT(*)
                   FROM titles AS T
				   WHERE T.pub_id=0736)
				   ORDER BY 3, 4 DESC
GO
--2. Napisati upit kojim ?e se prikazati ime i prezime uposlenika koji rade na 
--poziciji dizajnera, a koji su u?estvovali u objavljivanju knjiga ?ija je 
--prosje?na prodata koli?ina ve?a od prosje?ne prodane koli?ine izdava?ke 
--ku?e sa id 0877. U rezultatima upita prikazati i prosje?nu prodanu koli?inu. 
--(Pubs) 
SELECT E.fname, E.lname, AVG(S.qty) 'Prosjecna prodana kolicina'
FROM employee AS E
INNER JOIN jobs as J 
ON E.job_id=J.job_id
INNER JOIN publishers AS P
ON E.pub_id=P.pub_id
INNER JOIN titles AS T
ON P.pub_id=T.pub_id
INNER JOIN sales AS S
ON T.title_id=S.title_id
WHERE J.job_desc LIKE 'Designer'
GROUP BY E.fname, E.lname
HAVING AVG(S.qty) > (SELECT AVG(S.qty)
					 FROM titles AS T
					 INNER JOIN sales AS S
					 ON T.title_id=S.title_id
					 WHERE T.pub_id=0877)

--3. Kreirati upit koji prikazuje sumaran iznos svih transakcija (šema 
--Production) po godinama (uzeti u obzir i transakcije iz arhivske tabele). U 
--rezultatu upita prikazati samo dvije kolone: kalendarska godina i ukupan 
--iznos transakcija u godini. Iznos transakcije predstavlja umnožak koli?ine i 
--stvarne cijene. (AdventureWorks2017) 
USE AdventureWorks2017
SELECT YEAR(T1.TransactionDate) 'Godina', ROUND(SUM(T1.Quantity*T1.ActualCost),2) 'Ukupno'
FROM (SELECT TH.TransactionDate, TH.Quantity, TH.ActualCost
	  FROM Production.TransactionHistory AS TH
	  UNION ALL
	  SELECT TH.TransactionDate, TH.Quantity,TH.ActualCost
	  FROM Production.TransactionHistoryArchive AS TH) AS T1
GROUP BY YEAR(T1.TransactionDate)
ORDER BY 1

--4. Za potrebe menadžmenta neophodno je kreirati sljede?e upite: 
--(AdventureWorks2017) 
--a) Upit koji prikazuje zaradu po proizvodu u 5. mjesecu 2013. godine (sa i 
--bez popusta) 
--b) Upit koji prikazuje ukupnu zaradu po proizvodu u 2013. godini (sa i bez 
--popusta) 
--c) Upit koji prikazuje ukupnu zaradu po godinama (sa i bez popusta) 
--d) Upit koji prikazuje zaradu sa popustom po godinama i podkategorijama, 
--ali samo proizvoda koji pripadaju kategoriji „Bikes“ (Mountain Bikes, 
--Road Bikes, Touring Bikes).

--a)
SELECT PP.ProductID, SUM(SOD.OrderQty*SOD.UnitPrice) 'Zarada',  SUM((SOD.OrderQty*SOD.UnitPrice)*(1-SOD.UnitPriceDiscount)) 'Zarada s popustom'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013 AND MONTH(SOH.OrderDate)=5
GROUP BY PP.ProductID

--b)
SELECT PP.Name, SUM(SOD.OrderQty*SOD.UnitPrice) 'Zarada',  SUM((SOD.OrderQty*SOD.UnitPrice)*(1-SOD.UnitPriceDiscount)) 'Zarada s popustom'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY PP.Name

--c)
SELECT YEAR(SOH.OrderDate), SUM(SOD.OrderQty*SOD.UnitPrice) 'Zarada',  SUM((SOD.OrderQty*SOD.UnitPrice)*(1-SOD.UnitPriceDiscount)) 'Zarada s popustom'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
GROUP BY YEAR(SOH.OrderDate)


--d)
SELECT YEAR(SOHV.OrderDate) 'Godina',
CAST((SELECT SUM(SOD.LineTotal) 'Ukupna vrijednost s popustom'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN Production.ProductSubcategory AS PS
ON PP.ProductSubcategoryID=PS.ProductSubcategoryID
WHERE YEAR(SOH.OrderDate)= YEAR(SOHV.OrderDate) AND PS.Name LIKE 'Mountain bikes') AS DECIMAL(18,2)) 'Mountain bikes',
CAST((SELECT SUM(SOD.LineTotal) 'Ukupna vrijednost s popustom'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN Production.ProductSubcategory AS PS
ON PP.ProductSubcategoryID=PS.ProductSubcategoryID
WHERE YEAR(SOH.OrderDate)= YEAR(SOHV.OrderDate) AND PS.Name LIKE 'Road bikes') AS DECIMAL(18,2)) 'Road bikes',
CAST((SELECT SUM(SOD.LineTotal) 'Ukupna vrijednost s popustom'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN Production.ProductSubcategory AS PS
ON PP.ProductSubcategoryID=PS.ProductSubcategoryID
WHERE YEAR(SOH.OrderDate)= YEAR(SOHV.OrderDate) AND PS.Name LIKE 'Touring bikes') AS DECIMAL(18,2)) 'Touring bikes'
FROM Sales.SalesOrderHeader AS SOHV
GROUP BY YEAR(SOHV.OrderDate)
ORDER BY 1

--5. Kreirati upit koji prikazuje ?etvrtu najve?u satnicu uposlenika u preduze?u. 
--U rezultatima upita prikazati pored vrijednosti satnice i ime i prezime 
--zaposlenika. (AdventureWorks2017) 

SELECT TOP 1 *
FROM (SELECT TOP 4 PP.FirstName, PP.LastName, EPH.Rate
	  FROM HumanResources.EmployeePayHistory AS EPH
	  INNER JOIN HumanResources.Employee AS E
	  ON EPH.BusinessEntityID=E.BusinessEntityID
	  INNER JOIN Person.Person AS PP
	  ON EPH.BusinessEntityID=PP.BusinessEntityID
	  ORDER BY 3 DESC) AS PODQ
ORDER BY 3

--6. Kreirati upit koji ?e prikazati 50% zadnje kreiranih narudžbi. Upitom je 
--potrebno prikazati identifikacijski broj narudžbe, datum narudžbe, kontakt 
--ime kupca i ukupnu vrijednost narudžbe sa popustom(zaokruženu na dvije 
--decimale). (Northwind)USE NorthwindSELECT TOP 50 PERCENT O.OrderID, O.OrderDate, C.ContactName,ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) 'Ukupno s popustom'FROM Customers AS CINNER JOIN Orders AS OON C.CustomerID=O.CustomerIDINNER JOIN [Order Details] AS ODON O.OrderID=OD.OrderIDGROUP BY O.OrderID, O.OrderDate, C.ContactNameORDER BY O.OrderDate DESC--7. Na?i proizvode ?ijom je prodajom ostvaren najmanji i najve?i ukupni 
--promet (uzimaju?i u obzir i popust), a zatim odrediti razliku izme?u 
--najmanjeg prometa po proizvodu i prosje?nog prometa prodaje proizvoda, 
--te najve?eg prometa po proizvodu i prosje?nog prometa prodaje proizvoda. 
--Rezultate prikazati zaokružene na dvije decimale. Upit treba sadržavati 
--nazive proizvoda sa njihovim ukupnim prometom te izra?unate razlike.(AdventureWorks2017) 

USE AdventureWorks2017
SELECT PODQ1.Name Proizvod, PODQ1.Najmanji, PODQ2.Name Proizvod, PODQ2.Najveci,
PODQ1.Najmanji-PODQ3.Prosjecan 'Razlika min-avg',
PODQ2.Najveci-PODQ3.Prosjecan 'Razlika max-avg'
FROM
(SELECT TOP 1 P.Name, CAST(SUM(SOD.LineTotal) AS DECIMAL (18,2)) 'Najmanji'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS P
ON SOD.ProductID=P.ProductID
GROUP BY P.Name
ORDER BY 2) AS PODQ1,
(SELECT TOP 1 P.Name, CAST(SUM(SOD.LineTotal) AS DECIMAL (18,2)) 'Najveci'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS P
ON SOD.ProductID=P.ProductID
GROUP BY P.Name
ORDER BY 2 DESC) AS PODQ2,
(SELECT CAST(AVG(PODQ.[Ukupan promet]) AS DECIMAL (18,2)) 'Prosjecan'
FROM (SELECT P.Name, SUM(SOD.LineTotal) 'Ukupan promet'
	  FROM Sales.SalesOrderDetail as SOD
	  INNER JOIN Production.Product AS P
	  ON SOD.ProductID=P.ProductID
	  GROUP BY P.Name) AS PODQ) AS PODQ3

