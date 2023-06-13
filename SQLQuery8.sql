--1. Kreirati upit koji prikazuje kreditne kartice kojima je plaćeno više od 20 narudžbi. U 
--listu uključiti ime i prezime vlasnika kartice, tip kartice, broj kartice, ukupan iznos 
--plaćen karticom. Rezultate sortirati prema ukupnom iznosu u opadajućem redoslijedu 
--zaokružene na dvije decimale. 
USE AdventureWorks2017
SELECT PP.FirstName, PP.LastName, CC.CardType, CC.CardNumber, ROUND(SUM(SOH.TotalDue),2)
FROM Person.Person AS PP
INNER JOIN Sales.PersonCreditCard AS PCC
ON PP.BusinessEntityID=PCC.BusinessEntityID
INNER JOIN Sales.CreditCard AS CC
ON PCC.CreditCardID = CC.CreditCardID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON CC.CreditCardID=SOH.CreditCardID
GROUP BY PP.FirstName, PP.LastName, CC.CardType, CC.CardNumber
HAVING COUNT(*) >20
ORDER BY 5 DESC

--2. Prikazati ime i prezime, id narudžbe, te ukupnu vrijednost narudžbe (bez popusta) 
--kupaca koji su napravili narudžbu veću od prosječne vrijednosti (sa popustom) svih 
--stavki narudžbi gdje je prodavan proizvod sa identifikacijskim brojem 779. 

SELECT PP.FirstName, PP.LastName, SUM(SOD.OrderQty*SOD.UnitPrice)
FROM Person.Person AS PP
INNER JOIN Sales.Customer AS C
ON PP.BusinessEntityID=C.CustomerID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON C.CustomerID=SOH.CustomerID
INNER JOIN Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
GROUP BY PP.FirstName, PP.LastName
HAVING SUM(SOD.OrderQty*SOD.UnitPrice) >
(SELECT AVG(SOD.LineTotal)
FROM Sales.SalesOrderDetail AS SOD
WHERE SOD.ProductID =779)
--3. Kreirati upit koji prikazuje kupce (spojeno ime i prezime) koji su u maju mjesecu 2014. 
--godine kao jednu stavku narudžbe naručili proizvod „Front Brakes“ u količini većoj od 
--5 komada. 
SELECT CONCAT(PP.FirstName, ' ',PP.LastName) 'Ime i prezime'
FROM Person.Person AS PP
INNER JOIN Sales.Customer AS C
ON PP.BusinessEntityID=C.PersonID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON C.CustomerID=SOH.CustomerID
INNER JOIN Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN Production.Product AS P
ON SOD.ProductID=P.ProductID
WHERE P.Name LIKE 'Front Brakes' AND MONTH(SOH.OrderDate)=5 AND YEAR(SOH.OrderDate)=2014 AND SOD.OrderQty>5
--4. Kreirati upit koji prikazuje kupce koji su u 7. mjesecu (datum narudžbe) utrošili više od 
--200.000 KM. U listu uključiti ime i prezime kupca te ukupni utrošak. Izlaz sortirati 
--prema utrošku opadajućim redoslijedom. 

SELECT  PP.FirstName, PP.LastName, SUM(SOH.TotalDue) 'Ukupni utrosak'
FROM Person.Person AS PP
INNER JOIN Sales.Customer AS C
ON PP.BusinessEntityID=C.PersonID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON C.CustomerID=SOH.CustomerID
WHERE MONTH(SOH.OrderDate)=7
GROUP BY PP.FirstName, PP.LastName
HAVING SUM(SOH.TotalDue) >200000
ORDER BY 3 DESC
--5. Kreirati upit koji prikazuje zaposlenike koji su obradili više od 200 narudžbi. U listu 
--uključiti ime i prezime zaposlenika te ukupan broj obrađenih narudžbi. Izlaz sortirati 
--prema ukupnom broju narudžbi opadajućim redoslijedom. 

SELECT P.FirstName, P.LastName, COUNT(*) 'Ukupan broj narudzbi'
FROM Person.Person AS P
INNER JOIN HumanResources.Employee AS E
ON P.BusinessEntityID=E.BusinessEntityID
INNER JOIN Sales.SalesPerson AS SP
ON E.BusinessEntityID=SP.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SP.BusinessEntityID=SOH.SalesPersonID
GROUP BY P.FirstName, P.LastName
HAVING COUNT(*) >200
ORDER BY 3 DESC
--6. Kreirati upit koji prikazuje proizvode kojih na skladištu ima u količini manjoj od 30 
--komada. Lista treba da sadrži naziv proizvoda, naziv skladišta (lokaciju), stanje na 
--skladištu i ukupnu prodanu količinu. U rezultate upita uključiti i one proizvode koji 
--nikad nisu prodavani, ne uzimajući u obzir njihovo stanje na skladištu. Ukoliko je 
--ukupna prodana količina prikazana kao NULL vrijednost, izlaz zamijeniti brojem 0. 

SELECT  P.Name, L.Name, I.Quantity,
ISNULL((SELECT SUM(SOD.OrderQty)
FROM Sales.SalesOrderDetail AS SOD
WHERE SOD.ProductID=P.ProductID
),0) 'Prodana kolicina'
FROM Production.Product AS P
INNER JOIN Production.ProductInventory AS I
ON P.ProductID=I.ProductID
INNER JOIN Production.Location AS L
ON I.LocationID=L.LocationID
WHERE I.Quantity<30 OR 
P.ProductID NOT IN 
				  (SELECT DISTINCT SOD.ProductID
				   FROM Sales.SalesOrderDetail AS SOD)
ORDER BY 4 DESC
--7. Prikazati ukupnu prodanu količinu i ukupnu zaradu (uključujući popust) od prodaje 
--svakog pojedinog proizvoda po teritoriji. Uzeti u obzir samo prodaju u sklopu ponude 
--pod nazivom “Volume Discount 11 to 14” i to samo gdje je ukupna prodana količina
--veća od 100 komada. Zaradu zaokružiti na dvije decimale, te izlaz sortirati po zaradi u 
--opadajućem redoslijedu. 
SELECT  PP.Name, ST.Name Teritorija, SUM(SOD.OrderQty) 'Ukupna prodana kolicina',
CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2)) 'Ukupna zarada'
FROM Production.Product AS PP
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN Sales.SalesTerritory AS ST
ON SOH.TerritoryID=ST.TerritoryID
INNER JOIN Sales.SpecialOfferProduct AS SOP
ON SOD.SpecialOfferID=SOP.SpecialOfferID AND SOD.ProductID=SOP.ProductID
INNER JOIN Sales.SpecialOffer AS SO
ON SOP.SpecialOfferID=SO.SpecialOfferID
WHERE SO.Description LIKE 'Volume Discount 11 to 14'
GROUP BY PP.Name, ST.Name
HAVING SUM(SOD.OrderQty)>100
ORDER BY 4 DESC
--8. Kreirati upit koji prikazuje naziv proizvoda, naziv lokacije, stanje zaliha na lokaciji, 
--ukupno stanje zaliha na svim lokacijama i ukupnu prodanu količinu (stanja i ukupnu 
--prodanu količinu izračunati za svaki proizvod pojedinačno). Uzeti u obzir prodaju samo 
--u 2013. godini. U rezultatima NULL vrijednosti zamijeniti sa 0 i sortirati po ukupnoj 
--prodanoj količini u opadajućem redoslijedu.

SELECT PP.Name, L.Name, I.Quantity 'Zalihe na lokacijama',
(
	SELECT SUM(I1.Quantity)
	FROM Production.ProductInventory AS I1
	INNER JOIN Production.Location AS L1
	ON I1.LocationID=I1.LocationID
	WHERE I.ProductID=PP.ProductID
)'Ukupno stanje na lokacijama',
ISNULL((   SELECT SUM(SOD.OrderQty)
	FROM Sales.SalesOrderHeader AS SOH
	INNER JOIN Sales.SalesOrderDetail AS SOD
	ON SOH.SalesOrderID=SOD.SalesOrderID
	WHERE YEAR(SOH.OrderDate)=2013 AND SOD.ProductID=PP.ProductID),0) 'Ukupna prodana kolicina'
FROM Production.Product AS PP
INNER JOIN Production.ProductInventory AS I
ON PP.ProductID=I.ProductID
INNER JOIN Production.Location AS L
ON I.LocationID=L.LocationID
INNER JOIN Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
ORDER BY 5 DESC
--9. Kreirati upit kojim će se prikazati narudžbe kojima je na osnovu popusta kupac uštedio 
--100KM i više. Upit treba da sadrži id narudžbe, ime i prezime kupca i stvarnu ukupnu 
--vrijednost narudžbe zaokruženu na 2 decimale. Podatke je potrebno sortirati po stvarnoj 
--ukupnoj vrijednosti narudžbe u rastućem redosljedu. 
USE AdventureWorks2017
SELECT SOH.SalesOrderID, PP.FirstName, PP.LastName, 
CAST(SUM(SOD.LineTotal) AS DECIMAL (18,2)) 'Ukupno'
FROM Person.Person AS PP
INNER JOIN Sales.Customer AS C
ON PP.BusinessEntityID=C.PersonID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON C.CustomerID=SOH.CustomerID
INNER JOIN Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
GROUP BY SOH.SalesOrderID, PP.FirstName, PP.LastName
HAVING SUM(SOD.UnitPrice*SOD.OrderQty*SOD.UnitPriceDiscount)>=100
ORDER BY 4


--10. Kreirati upit kojim se prikazuje da li su muškarci ili žene napravili veći broj narudžbi. 
--Način provjere spola jeste da kupci čije ime završava slovom „a“ predstavljaju ženski 
--spol. U rezultatima upita prikazati spol (samo jedan), ukupan broj narudžbi koje su 
--napravili kupci datog spola i ukupnu potrošenu vrijednost zaokruženu na dvije 
--decimale.

SELECT TOP 1 IIF(RIGHT(P.FirstName, 1) LIKE 'a', 'F', 'M') 'Spol', COUNT(*) 'Ukupno',
ROUND(SUM(SOH.TotalDue),2) 'Ukupna potrosena vrijednost'
FROM Person.Person AS P
INNER JOIN Sales.Customer AS C
ON P.BusinessEntityID=C.PersonID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON C.CustomerID=SOH.CustomerID
GROUP BY IIF(RIGHT(P.FirstName,1) LIKE 'a','F','M')
ORDER BY 2 DESC

--11. Kreirati upit koji prikazuje ukupan broj proizvoda, ukupnu količinu proizvoda na 
--skladištu, te ukupnu vrijednost proizvoda na skladištu (umnožak količine i ListPrice). 
--Rezultate prikazati grupisane po nazivu dobavljača te uzeti u obzir samo one zapise 
--gdje je sumarna količina na lageru veća od 100 i vrijednost cijene proizvoda veća od 0.
--Rezultate sortirati prema ukupnoj količini na lageru u opadajućem redoslijedu.

SELECT V.Name, COUNT(*), SUM(I.Quantity) 'Ukupna kolicina',
SUM(P.ListPrice*I.Quantity) 'Ukupna vrijednost'
FROM Production.Product AS P
INNER JOIN Production.ProductInventory AS I
ON P.ProductID=I.ProductID
INNER JOIN Purchasing.ProductVendor AS PV
ON P.ProductID=PV.ProductID
INNER JOIN Purchasing.Vendor AS V
ON PV.BusinessEntityID=V.BusinessEntityID
WHERE P.ListPrice>0
GROUP BY V.Name
HAVING SUM(I.Quantity)>100
ORDER BY 3 DESC
--12. Kreirati upit koji prikazuje uposlenike koji obavljaju ulogu predstavnika prodaje a 
--obradili su 125 i više narudžbi i prodali količinski 8000 i više proizvoda. U rezultatima 
--upita prikazati id, ime i prezime uposlenika, ukupan broj narudžbi i ukupan broj 
--prodatih proizvoda. Rezultate sortirati prema ukupnom broju narudžbi u opadajućem 
--redoslijedu. (Northwind)

USE Northwind
SELECT E.EmployeeID, E.FirstName, E.LastName, COUNT(*) AS 'Broj narudzbi', PODQ.[Ukupna prodaja] AS 'Prodato'
FROM Employees AS E
INNER JOIN Orders AS O
ON E.EmployeeID=O.EmployeeID
INNER JOIN
(SELECT E1.EmployeeID, SUM(OD1.Quantity) AS 'Ukupna prodaja'
FROM Employees AS E1
INNER JOIN Orders AS O1
ON E1.EmployeeID=O1.EmployeeID
INNER JOIN [Order Details] AS OD1
ON O1.OrderID=OD1.OrderID
WHERE E1.Title LIKE 'Sales Representative'
GROUP BY E1.FirstName, E1.LastName, E1.EmployeeID
) AS PODQ
ON E.EmployeeID=PODQ.EmployeeID
WHERE E.Title LIKE 'Sales Representative' AND PODQ.[Ukupna prodaja]>8000
GROUP BY E.EmployeeID, E.FirstName, E.LastName, PODQ.[Ukupna prodaja]
HAVING COUNT(*)>125
ORDER BY 4 DESC