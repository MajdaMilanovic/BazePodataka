--1. Prikazati količinski najmanju i najveću vrijednost stavke narudžbe. (Northwind) 
USE Northwind
GO
SELECT MAX(OD.Quantity) Najveća, MIN(OD.Quantity) Najmanja
FROM [Order Details] AS OD

--2. Prikazati količinski najmanju i najveću vrijednost stavke narudžbe za svaku od narudžbi 
--pojedinačno. (Northwind) 
SELECT OD.OrderID, MAX(OD.Quantity) Najveća, MIN(OD.Quantity) Najmanja
FROM [Order Details] AS OD
GROUP BY OD.OrderID

--3. Prikazati ukupnu zaradu bez popusta od svih narudžbi. (Northwind) 
SELECT SUM(OD.Quantity*OD.UnitPrice) 'Ukupna zarada'
FROM [Order Details] AS OD

--4. Prikazati ukupnu zaradu za svaku narudžbu pojedinačno uzimajući u obzir i popust. Rezultate 
--zaokružiti na dvije decimale i sortirati prema ukupnoj vrijednosti naružbe u opadajućem 
--redoslijedu. (Northwind) 
SELECT OD.OrderID, ROUND(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),2) 'Ukupna zarada'
FROM [Order Details] AS OD
GROUP BY OD.OrderID
ORDER BY 2 DESC

--5. Prebrojati stavke narudžbe na kojima su naručene količine veće od 50 (uključujući i graničnu 
--vrijednost). Uzeti u obzir samo one stavke narudžbe gdje je odobren popust. (Northwind) 
SELECT COUNT(*)
FROM [Order Details] AS O
WHERE O.Discount >0 AND O.Quantity >=50

--6. Prikazati prosječnu cijenu stavki narudžbe za svaku narudžbu pojedinačno. Sortirati po 
--prosječnoj cijeni u opadajućem redoslijedu. (Northwind) 
SELECT OD.OrderID, AVG(OD.UnitPrice)
FROM [Order Details] AS OD
GROUP BY OD.OrderID
ORDER BY 2 DESC

--7. Prikazati ukupan broj stavki narudžbi na kojima je odobren popust. (Northwind) 
SELECT COUNT(*)
FROM [Order Details] AS O
WHERE O.Discount>0

--8. Prikazati ukupan broj narudžbi u kojima je unesena regija kupovine. (Northwind) 
SELECT COUNT(*)
FROM Orders AS O
WHERE O.ShipRegion IS NOT NULL

--9. Modificirati prethodni upit tako da se dobije broj narudžbi u kojima nije unesena regija 
--kupovine. (Northwind) 
SELECT COUNT(*)
FROM Orders AS O
WHERE O.ShipRegion IS NULL

--10. Prikazati ukupne troškove prevoza od narudžbi po uposlenicima (za uposlenika je dovoljno 
--prikazati njegov identifikacijski broj). Uslov je da ukupni troškovi prevoza nisu prešli 7500 
--pri čemu se rezultat treba sortirati opadajućim redoslijedom po visini troškova prevoza. 
--(Northwind) 
SELECT O.EmployeeID, SUM(O.Freight) 'Ukupno'
FROM Orders AS O 
GROUP BY O.EmployeeID
HAVING SUM(O.Freight) <7500
ORDER BY 2 DESC

--11. Prikazati ukupnu vrijednost troškova prevoza po državama ali samo ukoliko je veća od 
--4000 za robu koja se kupila u Francuskoj, Njemačkoj ili Švicarskoj. (Northwind) 
SELECT O.ShipCountry, SUM(O.Freight) 'Ukupno'
FROM Orders AS O
WHERE O.ShipCountry IN('France', 'Germany', 'Switzerland')
GROUP BY O.ShipCountry
HAVING SUM(O.Freight)>4000

--12. Prikazati ukupan broj proizvoda, za svaki model pojedinačno. Lista treba da sadrži ID modela 
--proizvoda i njihov ukupan broj. Uslov je da proizvod pripada nekom modelu i da je ukupan 
--broj proizvoda po modelu veći od 3. U listu uključiti (prebrojati) samo one proizvode čiji naziv 
--počinje slovom 'S'. (AdventureWorks2017)

USE AdventureWorks2017

SELECT PP.ProductModelID, COUNT(*) 'Broj proizvoda'
FROM Production.Product AS PP
WHERE PP.ProductModelID IS NOT NULL AND PP.Name LIKE 'S%'
GROUP BY PP.ProductModelID
HAVING COUNT(*)>3

--13. Prikazati 10 najprodavanijih proizvoda. Za proizvod je dovoljno prikazati njegov 
--identifikacijski broj. Ulogu najprodavanijeg ima onaj koji je u najvećim količinama prodat.
--(Northwind)

USE Northwind
SELECT TOP 10 OD.ProductID, SUM(OD.Quantity) 'Suma'
FROM [Order Details] AS OD
GROUP BY OD.ProductID
ORDER BY 2 DESC

--14. Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadrži identifikacijski 
--broj proizvoda, ukupnu zaradu bez popusta, ukupnu zaradu sa popustom. Vrijednost zarade 
--zaokružiti na dvije decimale. Uslov je da se prikaže zarada samo za stavke gdje je bilo popusta. 
--Listu sortirati prema ukupnoj zaradi sa popustom u opadajućem redoslijedu. 
--(AdventureWorks2017)

USE AdventureWorks2017

SELECT SOD.ProductID, 
ROUND(SUM(SOD.OrderQty*SOD.UnitPrice),2) 'Ukupna zarada bez popusta',
CAST(ROUND(SUM(SOD.LineTotal),2) AS DECIMAL(18,2)) 'Ukupna zarada sa popustom'
FROM Sales.SalesOrderDetail AS SOD
WHERE SOD.UnitPriceDiscount>0
GROUP BY SOD.ProductID
ORDER BY 3 DESC

