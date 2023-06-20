﻿--1. Kreirati bazu Procedure_ i aktivirati je. 

CREATE DATABASE Procedure_
GO
USE Procedure_
--2. Kreirati tabelu Proizvodi te prilikom kreiranja uraditi insert podataka iz tabele Products 
--baze Northwind. 
SELECT *
INTO Proizvodi
FROM Northwind.dbo.Products
--3. Kreirati proceduru sp_Products_Insert kojom će se u tabeli Proizvodi uraditi insert 
--novog zapisa. 
GO
CREATE PROCEDURE sp_Products_Insert
(
	@ProductName NVARCHAR(40),
	@SupplierID INT=NULL,
	@CategoryID INT=NULL,
	@QuantityPerUnit NVARCHAR (20)= NULL,
	@UnitPrice MONEY= NULL,
	@UnitsInStock SMALLINT= NULL,
	@UnitsOnOrder SMALLINT= NULL,
	@ReorderLevel SMALLINT= NULL,
	@Discontinued BIT
)
AS
BEGIN
	INSERT INTO Proizvodi
	VALUES(@ProductName,@SupplierID,@CategoryID, @QuantityPerUnit, @UnitPrice,@UnitsInStock,@UnitsOnOrder,@ReorderLevel,@Discontinued)
	END
	GO

--4. Kreirati dva testna slučaja, u prvom poslati podatke u sva polja, u drugom samo u ona 
--koja su obavezna. 
EXEC sp_Products_Insert 'Mlijeko',1,1,2,1.4,30,0,1,1

EXEC sp_Products_Insert
	@ProductName='Brašno',
	@Discontinued=1
--5. Kreirati proceduru sp_Products_Update kojom će se u tabeli Proizvodi uraditi update 
--zapisa. 
GO
CREATE OR ALTER PROCEDURE sp_Products_Update
(
	@ProductId INT,
	@ProductName NVARCHAR(40)=NULL,
	@SupplierID INT=NULL,
	@CategoryID INT=NULL,
	@QuantityPerUnit NVARCHAR (20)= NULL,
	@UnitPrice MONEY= NULL,
	@UnitsInStock SMALLINT= NULL,
	@UnitsOnOrder SMALLINT= NULL,
	@ReorderLevel SMALLINT= NULL,
	@Discontinued BIT = NULL
)
AS
BEGIN
	UPDATE Proizvodi
	SET
	ProductName= ISNULL(@ProductName, ProductName),
	SupplierID=ISNULL(@SupplierID, SupplierID),
	CategoryID=ISNULL(@CategoryID, CategoryID),
	QuantityPerUnit=ISNULL(@QuantityPerUnit, QuantityPerUnit),
	UnitPrice=ISNULL(@UnitPrice, UnitPrice),
	UnitsInStock=ISNULL(@UnitsInStock, UnitsInStock),
	UnitsOnOrder=ISNULL(@UnitsOnOrder, UnitsOnOrder),
	ReorderLevel=ISNULL(@ReorderLevel, ReorderLevel),
	Discontinued=ISNULL(@Discontinued, Discontinued)
	WHERE ProductID=@ProductId
END
--6. Kreirati testni slučaj za update zapisa kroz proceduru. 
EXEC sp_Products_Update @ProductId=78, @ProductName='Mlijeko', @SupplierID=1

SELECT *
FROM Proizvodi
--7. Kreirati proceduru sp_Products_Delete kojom će se u tabeli Proizvodi uraditi delete 
--određenog zapisa. 
GO
CREATE PROCEDURE sp_Proizvodi_Delete
(	@ProductID int)
AS
BEGIN
	DELETE FROM Proizvodi
	WHERE ProductID=@ProductID
END
--8. Kreirati testni slučaj za brisanje proizvoda sa id-om 78. 
EXEC sp_Proizvodi_Delete @ProductID=78
--9. Kreirati tabelu StavkeNarudzbe te prilikom kreiranja uraditi insert podataka iz tabele 
--Order Details baze Northwind. 
SELECT *
INTO StavkeNar
FROM Northwind.dbo.[Order Details]

--10. Kreirati proceduru sp_OrderDetails_Products_InsertUpdate kojom će se u tabeli 
--StavkeNarudzbe dodati nova stavka narudžbe a u tabeli Proizvodi umanjiti stanje za 
--zalihama. 
GO
CREATE PROCEDURE sp_StavkeNar_Proizvodi_InsertUpdate
(
	@OrderID INT,
	@ProductID INT,
	@UnitPrice MONEY,
	@Quantity SMALLINT,
	@Discount REAL
)
AS
BEGIN
	INSERT INTO StavkeNar
	VALUES (@OrderID, @ProductID,@UnitPrice,@Quantity,@Discount)

	UPDATE Proizvodi
	SET UnitsInStock=UnitsInStock-@Quantity
	WHERE ProductID=@ProductID
END
--11. Kreirati testni slučaj za prethodno kreiranu proceduru. 
EXEC sp_StavkeNar_Proizvodi_InsertUpdate 10248,1,5,4,0.1

SELECT * 
FROM StavkeNar
WHERE OrderID=10248

SELECT *
FROM Proizvodi
WHERE ProductID=1
--12. Kreirati proceduru sp_Products_SelectByProductNameOrCategoryID kojom će se u 
--tabeli Proizvodi uraditi select proizvoda prema nazivu proizvoda ili ID kategorije. 
--Ukoliko korisnik ne unese ništa od navedenog prikazati sve proizvode. 
GO
CREATE PROCEDURE sp_Products_SelectByProductNameOrCategoryID
(	
	@ProductName NVARCHAR(40)=NULL,
	@CategoryID INT=NULL
)
AS
BEGIN
	SELECT P.ProductName, P.CategoryID, P.UnitPrice, P.UnitsInStock, P.UnitsOnOrder
	FROM Proizvodi AS P
	WHERE(P.ProductName=@ProductName OR @ProductName IS NULL) AND (P.CategoryID=@CategoryID OR @CategoryID IS NULL)
END
--13. Prethodno kreiranu proceduru izvršiti sa sljedećim testnim slučajevima: 
--• Ime proizvoda'Chai'
--• Id kategorije 7 
--• Ime proizvoda'Tofu'i id kategorije=7 
--• bez slanja bilo kakvih podataka

EXEC sp_Products_SelectByProductNameOrCategoryID @ProductName= 'Chai'
EXEC sp_Products_SelectByProductNameOrCategoryID @CategoryID=7
EXEC sp_Products_SelectByProductNameOrCategoryID @ProductName= 'Tofu', @CategoryID=7
EXEC sp_Products_SelectByProductNameOrCategoryID @ProductName= NULL, @CategoryID=NULL

--14. Kreirati proceduru sp_Products_SearchByProductName kojom će se uraditi select 
--proizvoda prema nazivu. Korisniku već na unos prvog slova proizvoda treba prikazati 
--podatke. Korisnik ne mora poslati vrijednost, i tada je potrebno vratiti sve proizvode. 
--Procedura vraća sve stavke tabele Proizvodi. Obavezno kreirati tesni slučaj.
GO
CREATE PROCEDURE sp_Products_SearchByProductName
(
	@ProductName NVARCHAR (40)=NULL
)
AS
BEGIN
	SELECT *
	FROM Proizvodi AS P
	WHERE P.ProductName LIKE @ProductName + '%' OR @ProductName IS NULL
END

EXEC sp_Products_SearchByProductName @ProductName='M'
--15. Kreirati proceduru u bazi Procedure_ naziva sp_uposlenici_selectAll nad tabelama 
--odgovarajućim tabelama baze AdventureWorks2017 kojom će se dati prikaz polja 
--BusinessEntityID, FirstName, LastName i JobTitle. Proceduru podesiti da se rezultati 
--sortiraju po BusinessEntityID. 
GO
CREATE PROCEDURE sp_uposlenici_selectAll
AS
BEGIN
	SELECT E.BusinessEntityID, P.FirstName, P.LastName, E.JobTitle
	FROM AdventureWorks2017.HumanResources.Employee AS E
	INNER JOIN AdventureWorks2017.Person.Person AS P
	ON E.BusinessEntityID=P.BusinessEntityID
	ORDER BY E.BusinessEntityID
END

EXEC sp_uposlenici_selectAll
GO
--16. Iz baze AdventureWorks2017 u tabelu Vendor kopirati 
--tabelu Purchasing.Vendor. 
SELECT *
INTO Vendor
FROM AdventureWorks2017.Purchasing.Vendor
--17. Kreirati proceduru sp_Vendor_deleteColumn kojom će se izvršiti brisanje kolone 
--PurchasingWebServiceURL. 
GO
CREATE PROCEDURE sp_Vendor_deleteColumn
AS
BEGIN
	ALTER TABLE Vendor
	DROP COLUMN PurchasingWebServiceURL
END

EXEC sp_Vendor_deleteColumn

SELECT * FROM Vendor
--18. Kreirati proceduru sp_Vendor_updateAccountNumber kojom će se izvršiti update 
--kolone AccountNumber tako da u svakom zapisu posljednji znak (cifra) podatka 
--isključivo bude 1. Za podatke u navedenoj koloni koji inicijalno završavaju sa 1 ne treba 
--raditi update.
GO
CREATE PROCEDURE sp_Vendor_updateAccountNumber 
AS
BEGIN
	UPDATE Vendor
	SET AccountNumber=LEFT(AccountNumber, LEN(AccountNumber)-1)+'1'
	WHERE RIGHT(AccountNumber,1) <> '1'
END

EXEC sp_Vendor_updateAccountNumber
--19. Kreirati proceduru u bazi Procedure_ naziva 
--sp_Zaposlenici_SelectByFirstNameLastNameGender nad odgovarajućim 
--tabelama baze AdventureWorks2017 kojom će se definirati sljedeći ulazni parametri: 
--- EmployeeID, 
--- FirstName, 
--- LastName, 
--- Gender. 
--Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj 
--parametara (možemo ostaviti bilo koje polje bez unijete vrijednosti parametra), te da 
--procedura daje rezultat ako je zadovoljena bilo koja od vrijednosti koje su navedene 
--kao vrijednosti parametara. Ukoliko korisnik ne unese niti jedan od parametara 
--procedura neće vraćati niti jedan zapis. Nakon kreiranja pokrenuti proceduru sa 
--sljedećim testnim slučajevima: 
--• EmployeeID = 20, 
--• LastName = Miller, 
--• LastName = Abercrombie Gender = M 

GO
CREATE PROCEDURE sp_Zaposlenici_SelectByFirstNameLastNameGender
(
	@EmployeeID INT =NULL,
	@FirstName NVARCHAR(50)=NULL,
	@LastName NVARCHAR(50) = NULL,
	@Gender NCHAR (1) =NULL
)
AS
BEGIN
	SELECT E.BusinessEntityID, P.FirstName, P.LastName, E.Gender
	FROM AdventureWorks2017.HumanResources.Employee AS E
	INNER JOIN AdventureWorks2017.Person.Person AS P
	ON E.BusinessEntityID=P.BusinessEntityID
	WHERE E.BusinessEntityID=@EmployeeID OR P.FirstName=@FirstName OR P.LastName=@LastName OR E.Gender=@Gender
END

EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender @EmployeeID=20
EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender @LastName ='Miller'

EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender @LastName = Abercrombie, @Gender =M
--20. Proceduru sp_Zaposlenici_SelectByFirstNameLastNameGender izmijeniti tako da je 
--prilikom izvršavanja moguće unijeti bilo koje vrijednosti za prva tri parametra 
--(možemo ostaviti bilo koje od tih polja bez unijete vrijednosti), a da vrijednost četvrtog 
--parametra bude F. 
--Nakon izmjene pokrenuti proceduru sa sljedećim testnim slučajevima: 
--• EmployeeID = 2, 
--• LastName = Miller 
GO
ALTER PROCEDURE sp_Zaposlenici_SelectByFirstNameLastNameGender
(
	@EmployeeID INT = NULL,
	@FirstName NVARCHAR(50) =NULL,
	@LastName NVARCHAR (50) =NULL,
	@Gender NCHAR (1)='F'
)
AS
BEGIN
	SELECT E.BusinessEntityID, P.FirstName, P.LastName, E.Gender
	FROM AdventureWorks2017.HumanResources.Employee AS E
	INNER JOIN AdventureWorks2017.Person.Person AS P
	ON E.BusinessEntityID=P.BusinessEntityID
	WHERE (E.BusinessEntityID=@EmployeeID OR P.FirstName=@FirstName OR P.LastName=@LastName) AND E.Gender=@Gender
END

EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender @EmployeeID=2

EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender @LastName='Miller'
--21. Kreirati proceduru u bazi Procedure_ naziva 
--sp_Narudzbe_SelectByCustomerID nad odgovarajućim tabelama baze 
--Northwind, sa parametrom CustomerID kojom će se dati pregled ukupno naručenih 
--koločina svakog od proizvoda za unijeti ID Customera. Proceduru pokrenuti za ID 
--Customera BOLID 

GO
CREATE PROCEDURE sp_Narudzbe_SelectByCustomerID
@CustomerID NCHAR(5)
AS
BEGIN
	SELECT P.ProductName, SUM(OD.Quantity) AS 'Ukupno narucenih'
	FROM Northwind.dbo.Products AS P
	INNER JOIN Northwind.dbo.[Order Details] AS OD
	ON P.ProductID=OD.ProductID
	INNER JOIN Northwind.dbo.Orders AS O
	ON OD.OrderID=O.OrderID
	INNER JOIN Northwind.dbo.Customers AS C
	ON O.CustomerID=C.CustomerID
	WHERE C.CustomerID=@CustomerID
	GROUP BY P.ProductName
	ORDER BY 2 DESC
END

EXEC sp_Narudzbe_SelectByCustomerID @CustomerID=BOLID
--22. Koristeći bazu Northwind kreirati pogled v_Narudzbe strukture: 
--- OrderID 
--- ShippedDate 
--- Ukupno (predstavlja sumu vrijednosti stavki po narudžbi). 

GO
CREATE VIEW v_Narudzbe
AS
SELECT O.OrderID, O.ShippedDate, SUM(OD.Quantity*OD.UnitPrice) 'Ukupno'
FROM Northwind.dbo.[Order Details] AS OD
INNER JOIN Northwind.dbo.Orders AS O
ON OD.OrderID=O.OrderID
GROUP BY O.OrderID, O.ShippedDate
GO

--23. Koristeći pogled v_Narudzbe kreirati proceduru sp_Prodavci_Zemlje sa paramterima: 
--- startDate, datumski tip 
--- endDate, datumski tip 
--startDate i endDate su datumi između kojih se izračunava suma prometa po narudžbi i 
--obavezno je unijeti oba datuma. 
--Procedura ima sljedeću strukturu, odnosno vraća sljedeće podatke: 
--- OrderID 
--- Ukupno 
--pri čemu će kolona ukupno biti tipa money. 
--Omogućiti sortiranje u opadajućem redoslijedu po Ukupno. 
--Nakon kreiranja procedure pokrenuti za vrijednosti 
--• startDate = 1997-01-01, endDate= 1997-12-31 

GO
CREATE PROCEDURE sp_ProdavciZemlje
(
	@startDate DATE,
	@endDate DATE
)
AS
BEGIN
	SELECT OrderID, CAST(Ukupno AS MONEY)
	FROM v_Narudzbe
	WHERE ShippedDate BETWEEN @startDate AND @endDate
	ORDER BY 2
END
GO

EXEC sp_ProdavciZemlje @startDate='1997-01-01', @endDate = '1997-12-31'
EXEC sp_ProdavciZemlje @startDate='19970101', @endDate= '19971231'


--24. Iz baze AdventureWorks2017 u bazu Procedure_ kopirati tabelu zaglavlje i tabelu 
--stavke narudžbe za nabavke. Novokreirane tabele imenovati kao zaglavlje i detalji. U 
--kreiranim tabelama definirati PK kao u tabelama u Bazi 
--AdventureWorks2017. Definirati realtionships između tabela zaglavlje i stavke 
--narudzbe. 
SELECT *
INTO Detalji
FROM AdventureWorks2017.Purchasing.PurchaseOrderDetail

SELECT *
INTO Zaglavlje
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader

ALTER TABLE Zaglavlje
ADD CONSTRAINT PK_Zaglavlje PRIMARY KEY (PurchaseOrderID)

ALTER TABLE Detalji
ADD CONSTRAINT PK_Detalji PRIMARY KEY ([PurchaseOrderID], [PurchaseOrderDetailID])

ALTER TABLE Detalji
ADD CONSTRAINT FK_Detalji FOREIGN KEY ([PurchaseOrderID]) REFERENCES Zaglavlje ([PurchaseOrderID])
--25. Kreirati proceduru sp_Narudzbe_Stavke sa paramterima: 
--- status, kratki cjelobrojni tip 
--- mjesecNarudzbe, cjelobrojni tip 
--- kvartalIsporuke, cjelobrojni tip 
--- vrijednostStavke, realni tip Procedura je sljedeće strukture: 
--- status 
--- mjesec datuma narudžbe 
--- kvartal datuma isporuke 
--- naručena količina 
--- cijena 
--- vrijednost stavke kao proizvod količine i cijene 
--Uslov je da procedura dohvata samo one zapise u kojima je vrijednost kolone vrijednost 
--stavki između 100 i 500, pri čemu će prilikom pokretanja procedure rezultati biti 
--sortirani u opadajućem redoslijedu. Proceduru kreirati tako da je prilikom izvršavanja 
--moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koje polje bez unijetog 
--parametra), te da procedura daje rezultat ako je zadovoljena bilo koja od vrijednosti 
--koje su navedene kao vrijednosti parametara. 
--Nakon kreiranja procedure pokrenuti za sljedeće testne slučajeve: 
--• status = 3 
--• kvartal_isporuke = 4 
--• mjesec_narudzbe = 3, 
--• status = 1 

GO
CREATE PROCEDURE sp_NarudzbeStavke
(
	@status TINYINT = NULL,
	@mjesec_narudzbe INT =NULL,
	@kvartal_isporuke INT =NULL,
	@vrijednost_stavke REAL = NULL
)
AS
BEGIN
	SELECT Z.Status, MONTH(Z.OrderDate) 'Mjesec',
	DATEPART(QUARTER, Z.ShipDate) 'Kvartal',
	D.OrderQty, D.UnitPrice, D.OrderQty*D.UnitPrice 'Vrijednost stavke'
	FROM Zaglavlje AS Z
	INNER JOIN Detalji AS D
	ON Z.PurchaseOrderID=D.PurchaseOrderID
	WHERE (Z.Status = @status OR MONTH(Z.OrderDate) =@mjesec_narudzbe OR DATEPART(QUARTER, Z.ShipDate)=@kvartal_isporuke OR
		   D.OrderQty * D.UnitPrice = @vrijednost_stavke)
		   AND (D.OrderQty * D.UnitPrice) BETWEEN 100 AND 500
		   ORDER BY 6

END
GO

EXEC sp_NarudzbeStavke @status=3

EXEC sp_NarudzbeStavke @kvartal_isporuke = 4

EXEC sp_NarudzbeStavke @mjesec_narudzbe = 3, @status=1

--26. Kreirati proceduru sp_Narudzbe_Stavke_sum sa paramterima: 
--- status, kratki cjelobrojni tip 
--- mjesecNarudzbe, cjelobrojni tip 
--- kvartalIsporuke, cjelobrojni tip 
--Procedura je sljedeće strukture: 
--- Status 
--- mjesec datuma narudžbe 
--- kvartal datuma isporuke 
--- ukupnu vrijednost narudžbe 
--Uslov je da procedura dohvata samo one zapise u kojima je vrijednost kolone ukupno 
--između 10000 i 5 000 000, pri čemu će prilikom pokretanja procedure rezultati biti 
--sortirani u opadajućem redoslijedu. 
--Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj 
--parametara (možemo ostaviti bilo koje polje bez unijetog parametra), te da procedura 
--daje rezultat ako je zadovoljena bilo koja od vrijednosti koje su navedene kao 
--vrijednosti parametara. 
--Nakon kreiranja procedure pokrenuti za sljedeće testne slučajeve: 
--• status = 1 
--• kvartal_isporuke = 4, mjesec_narudzbe = 3 

GO
CREATE PROCEDURE sp_Narudzbe_stavke_sum
(
@status TINYINT = NULL,
@mjesec_narudzbe INT =NULL,
@kvartal_isporuke INT = NULL
)
AS
BEGIN

	SELECT Z.Status, MONTH(Z.OrderDate) 'Mjesec', DATEPART(QUARTER, Z.ShipDate) 'Kvartal',
	SUM(D.OrderQty*D.UnitPrice) AS Ukupno
	FROM Zaglavlje AS Z
	INNER JOIN Detalji AS D
	ON Z.PurchaseOrderID=D.PurchaseOrderID
	WHERE (Z.Status =@status OR MONTH(Z.OrderDate) =@mjesec_narudzbe OR
	DATEPART(QUARTER, Z.Status)=@kvartal_isporuke)
	GROUP BY Z.Status,  MONTH(Z.OrderDate), DATEPART(QUARTER, Z.ShipDate)
	HAVING SUM(D.OrderQty*D.UnitPrice) BETWEEN 10000 AND 500000
	ORDER BY 4
END
GO

EXEC sp_Narudzbe_stavke_sum @status=1

EXEC sp_Narudzbe_stavke_sum @kvartal_isporuke = 4, @mjesec_narudzbe = 3


--27. Kreirati bazu Indeksi i aktivirati je. 

CREATE DATABASE Indeksi
GO

USE Indeksi

--28. Kreirati tabelu ProizvodiOsobe koja će nastati spajanjem tabela Product i Person baze 
--AdventureWorks2017 CROSS JOIN-om i prilikom kreiranja importovati 10 miliona 
--zapisa. 

SELECT TOP 10000000 P.ProductID, P.Name, P.ProductNumber, P.Color, P.ListPrice, PP.BusinessEntityID, PP.FirstName, PP.LastName, PP.MiddleName
INTO ProizvodiOsobe
FROM AdventureWorks2017.Production.Product AS P
CROSS JOIN AdventureWorks2017.Person.Person AS PP
--29. Kreirati nonclustered index kojim će se ubrzati pretraga po imenu i prezimenu. Kreirati 
--testni slučaj i pogledati aktualni plan izvršenja. Izbrisati kreirani index.

CREATE INDEX IX_proizvodiOsobe_FirstName_LastNameE
ON ProizvodiOsobe(FirstName, LastName)

SELECT PO.FirstName, PO.LastName
FROM ProizvodiOsobe AS PO
WHERE PO.FirstName LIKE 'A%' AND PO.LastName LIKE 'S%'

DROP INDEX IX_proizvodiOsobe_FirstName_LastNameE
ON ProizvodiOsobe

--30. Kreirati nonclustered indeks koji će omogućiti bržu pretragu prema imenu i prezimenu 
--a također u definiciju indexa uključiti i srednje ime, kao dodatak. Kreirati testni slučaj
--i pogledati plan izvršenja. Izbrisati kreirani index. 

CREATE INDEX IX_proizvodiOsobe_LastName_INC_MiddleNamE
ON ProizvodiOsobe(FirstName, LastName) INCLUDE (MiddleName)

SELECT PO.FirstName, PO.LastName, PO.MiddleName
FROM ProizvodiOsobe AS PO
WHERE PO.FirstName LIKE 'A%' AND PO.LastName LIKE 'S%' AND PO.MiddleName LIKE 'L'
GROUP BY PO.FirstName, PO.LastName, PO.MiddleName

DROP INDEX IX_proizvodiOsobe_LastName_INC_MiddleNamE
ON ProizvodiOsobe
--31. Kreirati kompozitni primarni ključ nad kolonama ProductId i 
--BusindessEntityId. Kreirati testni slučaj za upotrebu primarnog ključa, te nakon 
--testiranja izbrisati primarni ključ. 
ALTER TABLE ProizvodiOsobe
ADD CONSTRAINT PK_ProizvodiOsobe PRIMARY KEY (ProductId, BusinessEntityId)

SELECT *
FROM ProizvodiOsobe AS PO
WHERE PO.ProductID = 1 AND PO.BusinessEntityID = 14951

ALTER TABLE ProizvodiOsobe
DROP PK_ProizvodiOsobe

--32. Kreirati clustered index nad kolonom ProductNumber. Kreirati testni slučaj za upotrebu 
--indexa i pogledati plan izvršenja. Izbrisati kreirani index. 

CREATE CLUSTERED INDEX IX_proizvodiOsobe_ProductNumbeR
ON ProizvodiOsobe(ProductNumber)

SELECT *
FROM ProizvodiOsobe AS PO
WHERE PO.ProductNumber LIKE 'A%'