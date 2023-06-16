--1. Kreirati bazu View_ i aktivirati je.

CREATE DATABASE View_
GO 
USE View_

--2. U bazi View_ kreirati pogled v_Employee sljedeće strukture: 
--- prezime i ime uposlenika kao polje ime i prezime, 
--- teritoriju i 
--- regiju koju pokrivaju 
--Uslov je da se dohvataju uposlenici koji su stariji od 60 godina. (Northwind) 

GO
CREATE VIEW v_Employee
AS 
SELECT E.FirstName + ' ' + E.LastName 'Ime i prezime', T.TerritoryDescription 'Teritorija', R.RegionDescription 'Regija'
FROM Northwind.dbo.Employees AS E
INNER JOIN Northwind.dbo.EmployeeTerritories AS ET
ON E.EmployeeID=ET.EmployeeID
INNER JOIN Northwind.dbo.Territories AS T
ON ET.TerritoryID=T.TerritoryID
INNER JOIN Northwind.dbo.Region AS R
ON T.RegionID=R.RegionID
WHERE DATEDIFF(YEAR, E.BirthDate, GETDATE()) > 60
GO
--3. Koristeći pogled v_Employee prebrojati broj teritorija koje uposlenik pokriva po jednoj 
--regiji. Rezultate sortirati prema broju teritorija u opadajućem redoslijedu, te prema 
--prezimenu i imenu u rastućem redoslijedu. 
SELECT VE.[Ime i prezime], VE.Regija, COUNT(VE.Teritorija) 'Broj teritorija'
FROM v_Employee AS VE
GROUP BY VE.[Ime i prezime], VE.Regija
ORDER BY 3 DESC, 1

--4. Kreirati pogled v_Sales sljedeće strukture: (Adventureworks2017) 
--- Id kupca 
--- Ime i prezime kupca 
--- Godinu narudžbe 
--- Vrijednost narudžbe bez troškova prevoza i takse 
GO
CREATE VIEW v_Sales
AS 
SELECT SC.CustomerID 'Id kupca', CONCAT(PP.FirstName, ' ', PP.LastName) 'Ime i prezime', YEAR(SOH.OrderDate) 'Godina narudzbe', SOH.SubTotal 'Vrijednost' 
FROM AdventureWorks2017.Person.Person AS PP
INNER JOIN AdventureWorks2017.Sales.Customer AS SC
ON PP.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH
ON SC.CustomerID=SOH.CustomerID
GO

--5. Koristeći pogled v_Sales dati pregled sumarno ostvarenih prometa po osobi i godini. 

SELECT VS.[Godina narudzbe], VS.[Ime i prezime], SUM(VS.Vrijednost) 'Sumarno ostvaren promet'
FROM v_Sales AS VS
GROUP BY VS.[Godina narudzbe], VS.[Ime i prezime]

--6. Koristeći pogled v_Sales dati pregled zapisa iz 2013. godine u kojima je vrijednost 
--narudžbe u intervalu 10% u odnosu na prosječnu vrijednost narudžbe iz 2013 godine. 
--Pregled treba da sadrži ime i prezime kupca i vrijednost narudžbe, sortirano prema 
--vrijednosti nraudžbe obrnuto abecedno. 
GO
CREATE VIEW v_Sales2013
AS 
SELECT *
FROM v_Sales AS VS
WHERE VS.[Godina narudzbe] =2013
GO

SELECT VS13.[Ime i prezime], VS13.Vrijednost
FROM v_Sales2013 AS VS13
WHERE VS13.Vrijednost BETWEEN 
		(SELECT AVG(VS13_2.Vrijednost) FROM v_Sales2013 AS VS13_2) - 0.1 * (SELECT AVG(VS13_2.Vrijednost) FROM v_Sales2013 AS VS13_2) 
		AND
		(SELECT AVG(VS13_2.Vrijednost) FROM v_Sales2013 AS VS13_2) + 0.1 * (SELECT AVG(VS13_2.Vrijednost) FROM v_Sales2013 AS VS13_2)
		ORDER BY 2 DESC


--		7. Kreirati tabelu Zaposlenici te prilikom kreiranja uraditi insert podataka iz tabele 
--Employees baze Northwind. 

SELECT *
INTO Zaposlenici
FROM Northwind.dbo.Employees
--8. Kreirati pogled v_Zaposlenici koji će dati pregled ID-a, imena, prezimena i 
--države zaposlenika. 
GO
CREATE VIEW v_Zaposlenici
AS
SELECT Z.EmployeeID, Z.FirstName, Z.LastName, Z.Country
FROM Zaposlenici AS Z
GO

--9. Modificirati prethodno kreirani pogled te onemogućiti unos podataka kroz pogled za 
--uposlenike koji ne dolaze iz Amerike ili Velike Britanije.

CREATE OR ALTER VIEW v_Zaposlenici
AS
SELECT Z.EmployeeID, Z.FirstName, Z.LastName, Z.Country
FROM Zaposlenici AS Z
WHERE Z.Country IN ('USA', 'UK')
WITH CHECK OPTION
GO


--10. Testirati prethodno modificiran view unosom ispravnih i neispravnih podataka (napisati 
--2 testna slučaja). 

INSERT INTO v_Zaposlenici
VALUES ('FirstName1', 'LastName1', 'BIH')

INSERT INTO v_Zaposlenici
VALUES ('FirstName1', 'LastName1', 'USA')

SELECT *
FROM v_Zaposlenici

--11. Koristeći tabele Purchasing.Vendor i Purchasing.PurchaseOrderDetail kreirati 
--v_Purchasing pogled sljedeće strukture: 
--- Name iz tabele Vendor 
--- PurchaseOrderID iz tabele Purchasing.PurchaseOrderDetail 
--- DueDate iz tabele Purchasing.PurchaseOrderDetail 
--- OrderQty iz tabele Purchasing.PurchaseOrderDetail 
--- UnitPrice iz tabele Purchasing.PurchaseOrderDetail 
--- ukupno kao proizvod OrderQty i UnitPrice 
--Uslov je da se dohvate samo oni zapisi kod kojih DueDate pripada 1. ili 3. kvartalu. 
--(AdventureWorks2017)

GO
CREATE VIEW V_Purchasing
AS
SELECT V.Name, POD.PurchaseOrderID, POD.DueDate, POD.OrderQty, POD.UnitPrice,POD.OrderQty*POD.UnitPrice 'Ukupno'
FROM AdventureWorks2017.Purchasing.Vendor AS V
INNER JOIN AdventureWorks2017.Purchasing.PurchaseOrderHeader AS POH
ON V.BusinessEntityID=POH.VendorID
INNER JOIN AdventureWorks2017.Purchasing.PurchaseOrderDetail AS POD
ON POH.PurchaseOrderID=POD.PurchaseOrderID
WHERE DATEPART(QUARTER, POD.DueDate)=1 OR DATEPART(QUARTER, POD.DueDate)=3
GO

--12. Koristeći pogled v_Purchasing dati pregled svih dobavljača čiji je ukupan broj stavki u 
--okviru jedne narudžbe jednak minimumu, odnosno maksimumu ukupnog broja stavki 
--po dostavljačima i purchaseOrderID.
--Pregled treba imati sljedeću strukturu: 
--- Name 
--- PurchaseOrderID 
--- Ukupan broj stavki

GO
CREATE VIEW V_Purchasing_prebrojano
AS
SELECT VP.Name, VP.PurchaseOrderID, COUNT(*) 'Ukupan broj stavki'
FROM V_Purchasing AS VP
GROUP BY VP.Name, VP.PurchaseOrderID
GO

SELECT VPP.Name, VPP.PurchaseOrderID, VPP.[Ukupan broj stavki]
FROM V_Purchasing_prebrojano AS VPP
WHERE VPP.[Ukupan broj stavki]=(SELECT MAX(VPP.[Ukupan broj stavki]) FROM V_Purchasing_prebrojano AS VPP) OR
	  VPP.[Ukupan broj stavki]=(SELECT MIN(VPP.[Ukupan broj stavki]) FROM V_Purchasing_prebrojano AS VPP)
	  ORDER BY 3 DESC
--13. U bazi radna kreirati tabele Osoba i Uposlenik. 
--Strukture tabela su sljedeće: 
--- Osoba 
--OsobaID cjelobrojna varijabla, primarni ključ 
--VrstaOsobe 2 unicode karaktera, obavezan unos 
--Prezime 50 unicode karaktera, obavezan unos 
--Ime 
--- Uposlenik 
--50 unicode karaktera, obavezan unos 
--UposlenikID cjelobrojna varijabla, primarni ključ 
--NacionalniID 15 unicode karaktera, obavezan unos 
--LoginID 256 unicode karaktera, obavezan unos 
--RadnoMjesto 50 unicode karaktera, obavezan unos 
--DtmZapos datumska varijabla 
--Spoj tabela napraviti prema spoju između tabela 
--Person.Person i HumanResources.Employee baze AdventureWorks2017. 14. Nakon 
--kreiranja tabela u tabelu Osoba kopirati odgovarajuće podatke iz tabele Person.Person, 
--a u tabelu Uposlenik kopirati odgovarajuće zapise iz tabele 
--HumanResources.Employee. 

CREATE TABLE Osoba
(
	OsobaID		INT CONSTRAINT PK_Osoba PRIMARY KEY,
	VrstaOsobe  NVARCHAR  (2) NOT NULL,
	Prezime		NVARCHAR (50) NOT NULL,
	Ime			NVARCHAR (50) NOT NULL
)

CREATE TABLE Uposlenik
(
	UposlenikID		INT CONSTRAINT PK_Uposlenik PRIMARY KEY,
	NacionalniID	NVARCHAR(15) NOT NULL,
	LoginID			NVARCHAR(256) NOT NULL,
	RadnoMjesto		NVARCHAR(50) NOT NULL,
	DatumZapos		DATE,
	CONSTRAINT FK_Uposlenik_Osoba FOREIGN KEY (UposlenikID) REFERENCES Osoba(OsobaID)
)
--14.	Nakon kreiranja tabela u tabelu Osoba kopirati odgovarajuæe podatke iz tabele Person.Person, a u tabelu Uposlenik kopirati odgovarajuæe zapise iz tabele HumanResources.Employee.

INSERT INTO Osoba
SELECT P.BusinessEntityID, P.PersonType, P.LastName, P.FirstName
FROM AdventureWorks2017.Person.Person AS P

INSERT INTO Uposlenik
SELECT E.BusinessEntityID, E.NationalIDNumber, E.LoginID, E.JobTitle, E.HireDate
FROM AdventureWorks2017.HumanResources.Employee AS E
--15. Kreirati pogled (view) v_Osoba_Uposlenik nad tabelama Uposlenik i Osoba koji će 
--sadržavati sva polja obje tabele.

GO
CREATE VIEW v_Osoba_Uposlenik
AS
SELECT *
FROM Osoba AS O
INNER JOIN Uposlenik AS U
ON O.OsobaID=U.UposlenikID
GO

--16. Koristeći pogled v_Osoba_Uposlenik prebrojati koliko se osoba zaposlilo po 
--godinama

SELECT YEAR(VOU.DatumZapos) 'Godina', COUNT(*) 'Broj osoba'
FROM v_Osoba_Uposlenik AS VOU
GROUP BY YEAR(VOU.DatumZapos)
ORDER BY 2
