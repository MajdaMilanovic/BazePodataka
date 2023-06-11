--1. Prikazati ID narudžbe, ID proizvoda i prodajnu cijenu, te razliku prodajne cijene u 
--odnosu na prosječnu vrijednost prodajne cijene za sve stavke. Rezultat sortirati prema 
--vrijednosti razlike u rastućem redoslijedu. (Northwind) 
USE Northwind
SELECT OD.OrderID, OD.ProductID, OD.UnitPrice,
(SELECT AVG(O.UnitPrice) FROM [Order Details] AS O) 'Prosjecna cijena',
OD.UnitPrice - (SELECT AVG(O.UnitPrice) FROM [Order Details] AS O) 'Razlika'
FROM [Order Details] AS OD
ORDER BY 5
--2. Za sve proizvode kojih ima na stanju dati prikaz njihovog id-a, naziva, stanja zaliha, te 
--razliku stanja zaliha proizvoda u odnosu na prosječnu vrijednost stanja za sve proizvode 
--u tabeli. Rezultat sortirati prema vrijednosti razlike u opadajućem redoslijedu. 
--(Northwind) 

SELECT P.ProductID, P.ProductName, P.UnitsInStock,
P.UnitsInStock - (SELECT AVG(P.UnitsInStock) FROM Products AS P) 'Razlika'
FROM Products AS P
WHERE P.UnitsInStock >0
ORDER BY 4 DESC
--3. Prikazati po 5 najstarijih zaposlenika muškog, i ženskog spola uz navođenje sljedećih 
--podataka: spojeno ime i prezime, datum rođenja, godine starosti, opis posla koji obavlja, 
--spol. Konačne rezultate sortirati prema spolu rastućim, a zatim prema godinama starosti 
--opadajućim redoslijedom. (AdventureWorks2017) 
USE AdventureWorks2017
SELECT *
FROM
(SELECT TOP 5 CONCAT(P.FirstName, ' ', P.LastName) 'Ime i Prezime',HRE.BirthDate, DATEDIFF(YEAR, HRE.BirthDate, GETDATE()) 'Starost',
HRE.JobTitle, HRE.Gender
FROM HumanResources.Employee AS HRE
INNER JOIN Person.Person AS P
ON HRE.BusinessEntityID = P.BusinessEntityID
WHERE HRE.Gender='F'
ORDER BY 3 DESC) AS PODQ1
UNION
SELECT *
FROM
(SELECT TOP 5 CONCAT(P.FirstName, ' ', P.LastName) 'Ime i Prezime',HRE.BirthDate, DATEDIFF(YEAR, HRE.BirthDate, GETDATE()) 'Starost',
HRE.JobTitle, HRE.Gender
FROM HumanResources.Employee AS HRE
INNER JOIN Person.Person AS P
ON HRE.BusinessEntityID = P.BusinessEntityID
WHERE HRE.Gender='M'
ORDER BY 3 DESC) AS PODQ2
ORDER BY PODQ1.Gender, PODQ1.Starost DESC
--4. Prikazati 3 zaposlenika koji su u braku i 3 koja nisu a obavljaju poslove menadžera uz 
--navođenje sljedećih podataka: opis posla koji obavlja, datum zaposlenja, bračni status 
--i staž. Ako osoba nije u braku plaća dodatni porez (upitom naglasiti to), inače ne plaća. 
--Konačne rezultate sortirati prema bračnom statusu rastućim, a zatim prema stažu 
--opadajućim redoslijedom. (AdventureWorks2017) 
SELECT TOP 3 E.JobTitle, E.HireDate, E.MaritalStatus, 
DATEDIFF(YEAR, E.HireDate, GETDATE()) 'Staž', 'Placa dodatni porez' Porez
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%manager%' AND E.MaritalStatus='S'
UNION
SELECT TOP 3 E.JobTitle, E.HireDate, E.MaritalStatus, DATEDIFF(YEAR, E.HireDate, GETDATE()) 'Staž', 'Ne placa dodatni porez' Porez
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%manager%' AND E.MaritalStatus='M'
ORDER BY 3,4 DESC

--5. Prikazati po 5 najstarijih zaposlenika koje se nalaze na prvom ili četvrtom 
--organizacionom nivou. Grupe se prave u zavisnosti od polja EmailPromotion. Prvu 
--grupu će činiti oni čija vrijednost u pomenutom polju je 0, zatim drugu će činiti oni sa 
--vrijednosti 1, dok treću sa vrijednosti 2. Za svakog zaposlenika potrebno je prikazati 
--spojeno ime i prezime, organizacijski nivo na kojem se nalazi, te da li prima email 
--promocije. Pored ovih polja potrebno je uvesti i polje pod nazivom „Prima“ koje će 
--sadržavati poruke: Ne prima (ukoliko je EmailPromotion = 0), Prima selektirane 
--(ukoliko je EmailPromotion = 1) i Prima (ukoliko je EmailPromotion = 2). Konačne 
--rezultate sortirati prema organizacijskom nivou i dodatno uvedenom polju. 
--(AdventureWorks2017)
SELECT *
FROM
(SELECT TOP 5 CONCAT(PP.FirstName, ' ', PP.LastName) 'Ime i prezime',
E.OrganizationLevel, PP.EmailPromotion, DATEDIFF(YEAR, E.BirthDate, GETDATE()) 'Starost',
'Ne prima' Prima
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID = PP.BusinessEntityID
WHERE PP.EmailPromotion =0 AND (E.OrganizationLevel=1 OR E.OrganizationLevel=4)
ORDER BY 4 DESC) AS A
UNION
SELECT *
FROM
(SELECT TOP 5 CONCAT(PP.FirstName, ' ', PP.LastName) 'Ime i prezime',
E.OrganizationLevel, PP.EmailPromotion, DATEDIFF(YEAR, E.BirthDate, GETDATE()) 'Starost',
'Ne prima' Prima
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID = PP.BusinessEntityID
WHERE PP.EmailPromotion =1 AND (E.OrganizationLevel=1 OR E.OrganizationLevel=4)
ORDER BY 4 DESC) AS B
UNION 
SELECT *
FROM
(SELECT TOP 5 CONCAT(PP.FirstName, ' ', PP.LastName) 'Ime i prezime',
E.OrganizationLevel, PP.EmailPromotion, DATEDIFF(YEAR, E.BirthDate, GETDATE()) 'Starost',
'Ne prima' Prima
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID = PP.BusinessEntityID
WHERE PP.EmailPromotion =2 AND (E.OrganizationLevel=1 OR E.OrganizationLevel=4)
ORDER BY 4 DESC) AS C
ORDER BY 2, 4
--6. Prikazati id narudžbe, datum narudžbe i datum isporuke za narudžbe koje su isporučene
--na područje Kanade u 7. mjesecu 2014. godine. Uzeti u obzir samo narudžbe koje nisu 
--plaćene kreditnom karticom. Datume formatirati na način (dd.mm.yyyy).
--(AdventureWorks2017) 
SELECT SOH.SalesOrderID, FORMAT(SOH.OrderDate, 'dd.MM.yyyy') 'Datum narudzbe',
FORMAT(SOH.ShipDate, 'dd.MM.yyyy') 'Datum isporuke'
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesTerritory AS ST
ON SOH.TerritoryID=ST.TerritoryID
WHERE ST.Name LIKE 'Canada' AND MONTH(SOH.ShipDate) =7 AND YEAR(SOH.ShipDate)=2014 AND SOH.CreditCardID IS NULL

--7. Kreirati upit koji prikazuje minimalnu, maksimalnu i prosječnu vrijednost narudžbe bez 
--uračunatog popusta po mjesecima u 2013. godini (datum narudžbe). Rezultate sortirati 
--po mjesecima u rastućem redoslijedu, te vrijednosti zaokružiti na dvije decimale. 
--(AdventureWorks2017) 
SELECT PODQ.Mjesec, AVG(PODQ.[Vrijednost bez popusta]) 'Prosjek',
MIN(PODQ.[Vrijednost bez popusta]) 'Minimalna',
MAX(PODQ.[Vrijednost bez popusta]) 'Maksimalna'
FROM
(SELECT SOH.SalesOrderID, MONTH(SOH.OrderDate) 'Mjesec',
ROUND(SUM(SOD.UnitPrice*SOD.OrderQty),2) 'Vrijednost bez popusta'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY SOH.SalesOrderID, MONTH(SOH.OrderDate) ) AS PODQ
GROUP BY PODQ.Mjesec
ORDER BY 1
