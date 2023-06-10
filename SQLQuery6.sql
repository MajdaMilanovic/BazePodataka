--1. Prikazati tip popusta, naziv prodavnice i njen id. (Pubs) 
USE pubs
SELECT D.discounttype, S.stor_name, S.stor_id
FROM discounts AS D
INNER JOIN stores AS S
ON D.stor_id = S.stor_id

--2. Prikazati id uposlenika, ime i prezime, te naziv posla koji obavlja. (Pubs)

SELECT E.emp_id, E.fname, E.lname, J.job_desc
FROM employee AS E
INNER JOIN jobs AS J
ON E.job_id = J.job_id

--3. Prikazati spojeno ime i prezime uposlenika, teritorije i regije koje pokriva. Uslov je da su zaposlenici mlađi od 65 godina. (Northwind) 
USE Northwind
SELECT CONCAT(E.FirstName, ' ', E.LastName) 'Ime i prezime', T.TerritoryDescription, R.RegionDescription
FROM Employees AS E
INNER JOIN EmployeeTerritories AS ET
ON E.EmployeeID = ET.EmployeeID
INNER JOIN Territories AS T
ON ET.TerritoryID = T.TerritoryID
INNER JOIN Region AS R
ON T.RegionID = R.RegionID
WHERE DATEDIFF(YEAR, E.BirthDate, GETDATE())<65


--4. Prikazati ukupnu vrijednost obrađenih narudžbi sa popustom za svakog uposlenika pojedinačno. Uslov je da su narudžbe kreirane u 1996. godini,
--te u obzir uzeti samo one uposlenike čija je ukupna ukupna obrađena vrijednost veća od 20000. Podatke sortirati 
--prema ukupnoj vrijednosti (zaokruženoj na dvije decimale) u rastućem redoslijedu. 
--(Northwind) 

SELECT E.FirstName, E.LastName, ROUND(SUM((OD.UnitPrice*OD.Quantity)*(1-OD.Discount)),2) 'Ukupna vrijednost s popustom'
FROM [Order Details] AS OD
INNER JOIN Orders AS O
ON OD.OrderID = O.OrderID
INNER JOIN Employees AS E
ON O.EmployeeID = E.EmployeeID
WHERE YEAR(O.OrderDate)=1996
GROUP BY E.FirstName, E.LastName
HAVING  ROUND(SUM((OD.UnitPrice*OD.Quantity)*(1-OD.Discount)),2) >20000
ORDER BY 3

--5. Prikazati naziv dobavljača, adresu i državu dobavljača, te nazive proizvoda koji pripadaju kategoriji pića a ima ih na stanju više od 30 komada.
--Rezultate upita sortirati po državama u abedecednom redoslijedu. (Northwind) 

SELECT S.CompanyName, S.Address, S.Country,P.ProductName
FROM Suppliers AS S
INNER JOIN Products AS P
ON S.SupplierID = P.SupplierID
INNER JOIN Categories AS C
ON P.CategoryID = C.CategoryID
WHERE C.Description LIKE '%drinks%' AND P.UnitsInStock >30
ORDER BY 3



--6. Prikazati kontakt ime kupca, njegov id, id narudžbe, datum kreiranja narudžbe (prikazan u formatu dan.mjesec.godina, npr. 24.07.2021), te ukupnu vrijednost 
--narudžbe sa i bez popusta. Prikazati samo one narudžbe koje su kreirane u 1997. godini. 
--Izračunate vrijednosti zaokružiti na dvije decimale, te podatke sortirati prema ukupnoj vrijednosti narudžbe sa popustom u opadajućem redoslijedu. (Northwind) 

SELECT C.ContactName, C.CustomerID, O.OrderID,
FORMAT(O.OrderDate, 'dd.mm.yyyy') 'Datum narudzbe',
SUM(OD.UnitPrice*OD.Quantity) 'Ukupno bez popusta',
ROUND(SUM((OD.UnitPrice*OD.Quantity)*(1-OD.Discount)),2) 'Ukupno s popustom'
FROM Customers AS C
INNER JOIN Orders AS O
ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] AS OD
ON O.OrderID = OD.OrderID
WHERE YEAR(O.OrderDate) = 1997
GROUP BY c.ContactName, C.CustomerID, O.OrderID, FORMAT(O.OrderDate, 'dd.mm.yyyy')
ORDER BY 6 DESC
--7. U tabeli Customers baze Northwind ID kupca je primarni ključ. 
--U tabeli Orders baze Northwind ID kupca je vanjski ključ. 
--Koristeći set operatore prikazati: 
--a) sve kupce 
--b) kupce koji su obavili narudžbu 
--c) one kupce koji nisu obavili narudžbu (ukoliko ima takvih) 
--a)
SELECT C.CustomerID
FROM Customers AS C
UNION
SELECT O.CustomerID
FROM Orders AS O
--b)
SELECT C.CustomerID
FROM Customers AS C
INTERSECT
SELECT O.CustomerID
FROM Orders AS O
--c)
SELECT C.CustomerID
FROM Customers AS C
EXCEPT
SELECT O.CustomerID
FROM Orders AS O
--10. Odrediti da li je svaki autor napisao bar po jedan naslov. (Pubs) 
--a) ako ima autora koji nisu napisali niti jedan naslov navesti njihov ID. 
--b) dati pregled autora koji su napisali bar po jedan naslov. 
USE pubs
SELECT *
FROM authors

SELECT A.au_id
FROM authors AS A
INTERSECT
SELECT TA.au_id
FROM titleauthor AS TA
--ovom provjerom vidimo da nije svaki autor napisao barem 1 naslov

--a)
SELECT A.au_id 'Autori koji nisu napisali niti jedan naslov'
FROM authors AS A
LEFT OUTER JOIN titleauthor AS TA
ON A.au_id = TA.au_id
WHERE TA.title_id IS NULL

--b)
SELECT A.au_id 'Autori koji su napisali barem jedan naslov'
FROM authors AS A
INTERSECT
SELECT TA.au_id
FROM titleauthor AS TA

--11. Prikazati 10 najskupljih stavki narudžbi.
--Upit treba da sadrži id stavke, naziv proizvoda, količinu, cijenu i vrijednost stavke narudžbe.
--Cijenu i vrijednost stavke narudžbe zaokružiti na dvije decimale. Izlaz formatirati na način da uz količinu stoji “kom” (npr.50 kom),
--a uz cijenu i vrijednost stavke narudžbe “KM” (npr. 50 KM). (AdventureWorks2017) 

USE AdventureWorks2017
SELECT TOP 10 PP.Name,
SOD.SalesOrderDetailID, 
CONCAT(SOD.OrderQty, ' kom') Kolicina,
CONCAT(SOD.UnitPrice, '	KM') 'Cijena',
CONCAT(ROUND((SOD.OrderQty*SOD.UnitPrice),2), ' KM') 'Vrijednost'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS PP
ON SOD.ProductID = PP.ProductID
ORDER BY ROUND((SOD.OrderQty*SOD.UnitPrice),2) DESC

--12. Kreirati upit koji prikazuje ukupan broj narudžbi po teritoriji na kojoj je kreirana narudžba. Lista treba da sadrži sljedeće kolone:
--naziv teritorije, ukupan broj narudžbi. 
--Uzeti u obzir samo teritorije gdje ima više od 1000 kupaca. (AdventureWorks2017)

SELECT  SOT.Name, COUNT(SOH.SalesOrderID) 'Ukupan broj narudzbi'
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesTerritory AS SOT
ON SOH.TerritoryID=SOT.TerritoryID
GROUP BY SOT.Name
HAVING COUNT(SOH.CustomerID)>1000

--13. Kreirati upit koji prikazuje zaradu od prodaje proizvoda.
--Lista treba da sadrži naziv proizvoda, ukupnu zaradu bez uračunatog popusta i  ukupnu zaradu sa uračunatim popustom. Iznos zarade zaokružiti na dvije decimale.
--Uslov je da se prikaže zarada samo za stavke gdje je bilo popusta. Listu sortirati po zaradi opadajućim redoslijedom. (AdventureWorks2017)

SELECT PP.Name, 
ROUND(SUM(SOD.OrderQty*SOD.UnitPrice),2) 'Ukupna zarada bez popusta',
CAST(ROUND(SUM(SOD.LineTotal),2) AS DECIMAL(18,2)) 'Ukupna zarada s popustom'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS PP
ON SOD.ProductID = PP.ProductID
WHERE SOD.UnitPriceDiscount >0
GROUP BY PP.Name
ORDER BY 3 DESC

