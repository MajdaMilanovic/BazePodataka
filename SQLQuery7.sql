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
--8. Kreirati upit koji prikazuje ime i prezime, korisničko ime (sve iza znaka „\“ u koloni 
--LoginID), dužinu korisničkog imena, titulu, datum zaposlenja (dd.mm.yyyy), starost i 
--staž zaposlenika. Uslov je da se prikaže 10 najstarijih zaposlenika koji obavljaju bilo 
--koju ulogu menadžera. (AdventureWorks2017) 
SELECT TOP 10 CONCAT(PP.FirstName, ' ', PP.LastName) 'Ime i prezime',
RIGHT(E.LoginID, CHARINDEX('\', REVERSE(E.LoginID))-1) 'Korisnicko ime',
LEN(RIGHT(E.LoginID, CHARINDEX('\', REVERSE(E.LoginID))-1)) 'Duzina korisnickog imena',
E.JobTitle,
FORMAT(E.HireDate, 'dd.MM.yyyy'),
DATEDIFF(YEAR, E.BirthDate, GETDATE()) 'Starost',
DATEDIFF(YEAR, E.HireDate, GETDATE()) 'Staž'
FROM Person.Person AS PP
INNER JOIN HumanResources.Employee AS E
ON E.BusinessEntityID=PP.BusinessEntityID
WHERE E.JobTitle LIKE '%manager%'
ORDER BY 6 DESC

--9. Kreirati upit koji prikazuje naziv modela i opis proizvoda. Uslov je da naziv modela 
--sadrži riječ „Mountain“, i da je jezik na kojem su pohranjeni podaci engleski. 
--(AdventureWorks2017
SELECT PM.Name, PD.Description
FROM Production.ProductModel AS PM
INNER JOIN Production.ProductModelProductDescriptionCulture AS PMPDC
ON PM.ProductModelID=PMPDC.ProductModelID
INNER JOIN Production.ProductDescription AS PD
ON PD.ProductDescriptionID=PMPDC.ProductDescriptionID
INNER JOIN Production.Culture AS C
ON C.CultureID=PMPDC.CultureID
WHERE C.Name LIKE 'English' AND PM.Name LIKE '%Mountain%'

--10. Kreirati upit koji prikazuje id proizvoda, naziv i cijenu proizvoda(ListPrice), te ukupnu 
--količinu proizvoda na zalihama po lokacijama. Uzeti u obzir samo proizvode koji 
--pripadaju kategoriji „Bikes“. Izlaz sortirati po ukupnoj količini u opadajućem 
--redoslijedu. (AdventureWorks2017) 
SELECT PP.ProductID, PP.Name, PP.ListPrice, PL.Name 'Lokacija', SUM(PI.Quantity) 'Stanje zaliha'
FROM Production.Product AS PP
INNER JOIN Production.ProductInventory AS PI
ON PP.ProductID=PI.ProductID
INNER JOIN Production.Location AS PL
ON PI.LocationID=PL.LocationID
INNER JOIN Production.ProductSubcategory AS PS
ON PP.ProductSubcategoryID=PS.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PC
ON PS.ProductCategoryID=PC.ProductCategoryID
WHERE PC.Name LIKE 'Bikes'
GROUP BY PP.ProductID, PP.Name, PP.ListPrice, PL.Name
ORDER BY 5 DESC

--11. Kreirati upit koji prikazuje ukupno ostvarenu zaradu po zaposleniku, za robu 
--isporučenu na područje Evrope, u januaru mjesecu 2014. godine. Lista treba da sadrži 
--ime i prezime zaposlenika, datum zaposlenja (dd.mm.yyyy), mail adresu, te ukupnu 
--ostvarenu zaradu zaokruženu na dvije decimale. Izlaz sortirati po zaradi u opadajućem 
--redoslijedu. (AdventureWorks2017) 

SELECT CONCAT(PP.FirstName, ' ', PP.LastName) 'Ime i prezime',
 FORMAT(E.HireDate,'dd.MM.yyyy') 'Datum zaposlenja',E.HireDate,EA.EmailAddress,
 SUM(SOD.UnitPrice*SOD.OrderQty)'Ukupna zarada'
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
INNER JOIN Person.EmailAddress AS EA
ON PP.BusinessEntityID=EA.BusinessEntityID
INNER JOIN Sales.SalesPerson AS SP
ON E.BusinessEntityID=SP.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOH.SalesPersonID=SP.BusinessEntityID
INNER JOIN Sales.SalesOrderDetail AS SOD
ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN Person.Address AS A
ON SOH.ShipToAddressID=A.AddressID
INNER JOIN Person.StateProvince AS SPP
ON A.StateProvinceID=SPP.StateProvinceID
INNER JOIN Sales.SalesTerritory AS ST
ON SPP.TerritoryID=ST.TerritoryID
WHERE ST.[Group] = 'Europe' AND YEAR(SOH.ShipDate) =2014 AND MONTH(SOH.ShipDate) =1
GROUP BY CONCAT(PP.FirstName, ' ', PP.LastName),
FORMAT(E.HireDate,'dd.MM.yyyy'), E.HireDate, EA.EmailAddress
ORDER BY [Ukupna zarada] DESC

