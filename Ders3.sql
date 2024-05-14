-- Ders 3
-- Exists, Any-Some , In, All

-- IN
SELECT * FROM Person.Person pp
WHERE pp.BusinessEntityID IN (10,20,22,25)

-- Sadece alisverisi olan musterileri almak istersek
SELECT DISTINCT PP.BusinessEntityID, pp.FirstName, pp.LastName FROM Sales.SalesOrderHeader soh
INNER JOIN Person.Person pp ON soh.CustomerID = pp.BusinessEntityID

-- Sadece Person tablosundaki bilgileri gormek istiyor isem: Yukaridaki cumleye gore daha verimli calisacak olan bir cumle kullanabilirim:
SELECT DISTINCT pp.BusinessEntityID, PP.FirstName, PP.LastName FROM Person.Person pp
WHERE pp.BusinessEntityID IN
(SELECT soh.CustomerID FROM Sales.SalesOrderHeader soh)

SELECT DISTINCT pp.BusinessEntityID, pp.FirstName, pp.LastName FROM Person.Person pp
WHERE EXISTS (SELECT * FROM Sales.SalesOrderHeader soh WHERE soh.CustomerID = pp.BusinessEntityID)

-- EXISTS
-- Satisi olan urunlerin listesi
SELECT DISTINCT pp.ProductID, pp.Name FROM Production.Product pp
INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID

-- Yukaridaki aramanin yerine daha verimli asagidaki cumleyi kullanabiliriz
SELECT DISTINCT pp.ProductID, pp.Name FROM Production.Product pp
WHERE EXISTS (SELECT * FROM Sales.SalesOrderDetail sod WHERE sod.ProductID = pp.ProductID) 

-- ANY
-- Sadece 1 adet siparis gecilen urunlerin listesi
SELECT DISTINCT pp.ProductID, pp.Name, pp.Color FROM Production.Product pp
INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
WHERE sod.OrderQty = 1

-- Yukaridaki cumleyi daha verimli asagidaki gibi yazabiliriz:
SELECT DISTINCT pp.ProductID, pp.Name, pp.Color FROM Production.Product pp
WHERE ProductID = ANY(SELECT ProductID FROM Sales.SalesOrderDetail WHERE OrderQty = 1)

-- ALL
SELECT DISTINCT pp.ProductID, pp.Name FROM Production.Product pp
INNER JOIN Sales.SalesOrderDetail sod on pp.ProductID = sod.ProductID
WHERE pp.ListPrice > (select avg(sod.UnitPrice) FROM Sales.SalesOrderDetail sod)

SELECT DISTINCT pp.ProductID, pp.Name FROM Production.Product pp
WHERE pp.ListPrice > ALL(SELECT AVG(sod.UnitPrice) FROM Sales.SalesOrderDetail sod)
AND pp.ProductID IN(SELECT sod.ProductID FROM Sales.SalesOrderDetail sod)

-- Ornek:
-- Satisi olmayan urunlerin listesi:
SELECT pp.ProductID, pp.Name FROM Production.Product pp
WHERE pp.ProductID NOT IN(SELECT sod.ProductID FROM Sales.SalesOrderDetail sod)

SELECT pp.ProductID, pp.Name FROM Production.Product pp
WHERE  NOT EXISTS(SELECT * FROM Sales.SalesOrderDetail sod WHERE pp.ProductID = sod.ProductID)


-- INNER JOIN alternatifi CROSS APPLY
SELECT he.JobTitle, pp.FirstName, pp.LastName FROM HumanResources.Employee he
INNER JOIN Person.Person pp ON he.BusinessEntityID = pp.BusinessEntityID 
-- CROSS APPLY ile
SELECT he.JobTitle, pp.FirstName, pp.LastName FROM HumanResources.Employee he
CROSS APPLY (SELECT * FROM Person.Person pp WHERE he.BusinessEntityID = pp.BusinessEntityID) pp

-- OUTER JOIN alternatifi OUTER APPLY
SELECT pp.FirstName, pp.LastName, he.JobTitle FROM Person.Person pp
LEFT OUTER JOIN HumanResources.Employee he ON pp.BusinessEntityID = he.BusinessEntityID
-- OUTER APPLY
SELECT pp.FirstName, pp.LastName, he.JobTitle FROM Person.Person pp
OUTER APPLY (SELECT * FROM HumanResources.Employee he WHERE pp.BusinessEntityID = he.BusinessEntityID) he


-- UNION, EXCEPT, INTERSECT
-- UNION: iki sonuc kumesini alt alta birlestirir
-- Hem bizim tedarikciden aldigimiz, ve hem de musterilerin siparis gectigi urunlerin ortak listesi (birlestirilmis listesi):
SELECT pw.ProductID, pw.DueDate AS Tarih, pw.StockedQty AS Adet, 'GELEN' AS Durum FROM Production.WorkOrder pw
UNION
SELECT sod.ProductID, sod.ModifiedDate AS Tarih, sod.OrderQty AS Adet, 'SATILAN' AS Durum FROM Sales.SalesOrderDetail sod 
ORDER BY Tarih
-- Bu sekilde UNION yaptigimizda iki sonuc kumesi oldugu gibi birlestirilir,
-- Mukerrer kayit olusabilir, eger bunlari iptal etmesini istersek:
SELECT pw.ProductID, pw.DueDate AS Tarih, pw.StockedQty AS Adet, 'GELEN' AS Durum FROM Production.WorkOrder pw
UNION ALL
SELECT sod.ProductID, sod.ModifiedDate AS Tarih, sod.OrderQty AS Adet, 'SATILAN' AS Durum FROM Sales.SalesOrderDetail sod 
ORDER BY Tarih

-- UNION ALL ORNEK
SELECT * INTO Person.PersonBCKP FROM Person.Person

-- Hem ilk hem de ikinci sonuc kumesinde ayni olan isimleri eledik:
SELECT a.FirstName, a.LastName FROM Person.PersonBCKP a
WHERE a.FirstName LIKE '%a%'
UNION ALL
SELECT b.FirstName, b.LastName FROM Person.Person b
WHERE b.FirstName LIKE '%z%'


-- INTERSECT: iki sonuc kumesinin ortak yanlarini cikartir
-- Satis yapan calisanlarin listesi (iki sonuc kumesinin kesisimi)
SELECT he.BusinessEntityID AS ID FROM HumanResources.Employee he
INTERSECT
SELECT soh.SalesPersonID AS ID FROM Sales.SalesOrderHeader soh

-- Yukaridaki sonuc kumesine isim ve soyisim de eklemek istersek:
-- Join ile yaparsam:
SELECT pp.BusinessEntityID, pp.FirstName, pp.LastName FROM Person.Person pp
INNER JOIN (SELECT he.BusinessEntityID AS ID FROM HumanResources.Employee he
INTERSECT
SELECT soh.SalesPersonID AS ID FROM Sales.SalesOrderHeader soh) ortak ON pp.BusinessEntityID = ortak.ID

SELECT pp.BusinessEntityID, pp.FirstName, pp.LastName FROM Person.Person pp
WHERE BusinessEntityID IN (SELECT he.BusinessEntityID AS ID FROM HumanResources.Employee he
INTERSECT
SELECT soh.SalesPersonID AS ID FROM Sales.SalesOrderHeader soh)

-- EXCEPT: Ikinci listede olanlar haric
-- Tedarikciden siparisi olup, hic satisi olmayan urunler:
SELECT pw.ProductID FROM Production.WorkOrder pw
EXCEPT
SELECT sod.ProductID FROM Sales.SalesOrderDetail sod



-- VIEWS: 
-- Execution Plan'in onceden kaydedilerek, hazir bazi sorgularin sanki bir tablo gibi kullanilabildigi yapilardir:


ALTER VIEW [dbo].[VwSonYilinSatislari]
AS
SELECT        Sales.Customer.CustomerID, Person.Person.FirstName, Person.Person.LastName, Sales.SalesOrderHeader.OrderDate, Production.Product.Name AS Urun, Sales.SalesOrderDetail.OrderQty
FROM            Sales.Customer INNER JOIN
                         Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID INNER JOIN
                         Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID INNER JOIN
                         Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID INNER JOIN
                         Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID AND Sales.Customer.PersonID = Person.Person.BusinessEntityID
WHERE        (YEAR(Sales.SalesOrderHeader.OrderDate) >= 2014)

-- FUNCTIONS
SELECT NEWID()
SELECT YEAR('2024-05-13')

DECLARE @RAKAM int
SELECT @RAKAM  = 12
SELECT @RAKAM * 2

SELECT dbo.EmailOlustur('Çi?dem', 'Tekinsoy', 'ODA?')

SELECT pp.FirstName, pp.LastName, Dbo.EmailOlustur(pp.FirstName, pp.LastName, 'ODA?') AS email FROM Person.Person pp

-- KOSUL IFADELERI
IF (1 = 1)
BEGIN
	PRINT 'if calisti'
END

IF (1 = 0)
BEGIN
	PRINT 'IF calisti'
END
ELSE IF(1=1)
BEGIN
	Print 'Else if calisti'
END
ELSE
BEGIN
	PRINT 'Else calisti'
END


DECLARE @TransferKodu int
SELECT @TransferKodu = 3
IF (@TransferKodu = 0)
BEGIN
	Print 'Virman'
END
ELSE IF (@TransferKodu = 1)
BEGIN
	PRINT 'Havale'
END
ELSE IF (@TransferKodu = 2)
BEGIN
	PRINT 'EFT'
END
ELSE IF (@TransferKodu = 3)
BEGIN
	PRINT 'Swift'
END
ELSE IF (@TransferKodu = 4)
BEGIN
	PRINT 'Arbitraj'
END
ELSE
BEGIN
	PRINT 'Diger'
END

-- Function Ornekleri:


ALTER FUNCTION [dbo].[EmailOlustur]
(
	@isim nvarchar(50),
	@soyisim nvarchar(50),
	@domain nvarchar(30)
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @email nvarchar(100)

	SELECT @email = @isim + '.' + @soyisim + '@' + @domain + '.com.tr'
	SELECT @email = LOWER(@email)
	SELECT @email = REPLACE(@email, 'ç', 'c')
	SELECT @email = REPLACE(@email, 'ğ', 'g')
	SELECT @email = REPLACE(@email, 'ü', 'u')
	SELECT @email = REPLACE(@email, 'ö', 'o')
	SELECT @email = REPLACE(@email, 'ş', 's')
	SELECT @email = REPLACE(@email, 'ı', 'i')
	-- Return the result of the function
	RETURN @email

END

SELECT dbo.EmailOlustur('Emre', 'Tekinsoy', 'BtAkdemi')

SELECT pp.FirstName, pp.LastName, dbo.EmailOlustur(pp.FirstName, pp.LastName, 'Odaş') AS email FROM Person.Person pp

-- Kdv Hesaplayan bir fonksiyon yazalim:
ALTER FUNCTION KdvHesapla
(
	@fiyat decimal(18,2)
)
RETURNS decimal(18,2)
AS
BEGIN
	IF (@fiyat < 100)
	BEGIN
		RETURN @fiyat * 0.18
	END
	ELSE IF (@fiyat < 1000)
	BEGIN
		RETURN @fiyat * 0.2
	END
	--ELSE IF (@fiyat >= 100 AND @fiyat < 1000)

	RETURN @fiyat * 0.24

END
GO

SELECT pp.Name, pp.ListPrice, dbo.KdvHesapla(pp.ListPrice) AS KDV, CONVERT(decimal(18,2), pp.ListPrice + dbo.KdvHesapla(pp.ListPrice)) AS SATIS FROM Production.Product pp
WHERE pp.ListPrice > 0

-- Bolum yapan bir fonksiyon:
ALTER FUNCTION [dbo].[Divide]
(
	@rakam decimal(18,2),
	@bolen decimal(18,2)
)
RETURNS decimal(18,2)
AS
BEGIN
	IF (@bolen = 0)
	BEGIN
		RETURN 0
	END
	RETURN @rakam / @bolen

END
GO

-- Donguler: WHILE
DECLARE @rakam int
SELECT @rakam = -3
WHILE(10 > @rakam)
BEGIN
	PRINT @rakam 
	DECLARE @birfazlasi int
	SET @birfazlasi = @rakam - 1
	SELECT @rakam = @birfazlasi
END
SELECT @rakam

-- CHARINDEX: bir yazinin icinde arama yapmami saglar: index doner (kacinci karakter)
SELECT CHARINDEX(':','Bizim sql egitimizde egitmenin adi: Emre Tekinsoy',  0)

-- Bosluk Temizleyen fonksiyon
CREATE FUNCTION BoslukTemizle
(
	@yazi nvarchar(500)
)
RETURNS nvarchar(500)
AS
BEGIN

	SELECT @yazi = LTRIM(@yazi) -- soldaki bosluklari aldim
	
	SELECT @yazi = RTRIM(@yazi) -- sagdaki bosluklari aldim
	
	WHILE(CHARINDEX('  ', @yazi, 0) > 0) -- icerisinde cift space oldugu surece
	BEGIN
	-- buldugun her CIFT boslugu TEK ile degistir
		SELECT @yazi = REPLACE(@yazi, '  ', ' ') 
	END
	
	RETURN @yazi

END
GO

SELECT dbo.BoslukTemizle('                      Mustafa              Emre                                    Tekinsoy               ')


-- buyuk miktarda icerigin sayfa sayfa belli bir sayida gosterilmesi
CREATE FUNCTION Paging 
(	
	-- Add the parameters for the function here
	@PageSize int,
	@PageNumber int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT * 
	FROM Production.Product
	Order by Name
	OFFSET @PageSize * @PageNumber ROWS
	FETCH NEXT @PageSize ROWS ONLY
)
GO
SELECT * FROM dbo.Paging(10, 2)
SELECT * FROM Production.Product ORDER BY Name

SELECT dbo.Divide(12.4, 2)
SELECT dbo.Divide(5, 0)

-- Tablo Donen Fonksiyonlar

ALTER FUNCTION IsmeGoreSatisGetir
(	
	@ad nvarchar(50),
	@gobekad nvarchar(50),
	@soyad nvarchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	CASE WHEN pp.MiddleName is null THEN pp.FirstName + ' ' + pp.LastName
		ELSE pp.FirstName + ' ' + pp.MiddleName + ' ' + pp.LastName
		END IsimSoyisim,
	soh.DueDate,
	sod.UnitPrice
	FROM Person.Person pp
	LEFT OUTER JOIN Sales.Customer sc ON sc.PersonID = pp.BusinessEntityID
	LEFT OUTER JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = sc.CustomerID
	LEFT OUTER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	WHERE pp.FirstName = @ad AND pp.MiddleName = @gobekad AND pp.LastName = @soyad
)
GO

SELECT * FROM dbo.IsmeGoreSatisGetir('Erick','L', 'Sai')

-- Baska ornek:
ALTER FUNCTION KdvIlePRoductTablosu
(	
	@kdv decimal(18,2)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT pp.*, pp.ListPrice * @kdv AS SatisTutrari FROM Production.Product pp
)
GO

SELECT p.ListPrice, p.SatisTutrari, p.* FROM dbo.KdvIlePRoductTablosu(1.18) p
WHERE ListPrice  >0


CREATE FUNCTION StoktakiUrunleriGetir(
	@minimumAdet int
)
RETURNS TABLE
AS
RETURN(
	SELECT pp.*, ppi.LocationID, ppi.Shelf, ppi.Quantity FROM Production.Product pp
	INNER JOIN Production.ProductInventory ppi ON pp.ProductID = ppi.ProductID
	WHERE ppi.Quantity > @minimumAdet
)

select * from dbo.StoktakiUrunleriGetir(200)

-- TRIGGER
-- Sql yapisindaki olaylardir: Bir tabloda bir degisiklik oldugunda buna gore calistirmak istedimiz bir kod varsa devreye almamizi saglar

CREATE TRIGGER TestLOG 
   ON  Sales.SalesOrderHeader 
   AFTER INSERT
AS 
BEGIN
	-- Bir siparis girilirken gecmis tarihli ise tarihi duzelticez
	DECLARE @GirisTarihi DateTime
	SELECT @GirisTarihi = yeni.DueDate FROM inserted yeni
	DECLARE @Bugun DateTime
	SELECT @Bugun = GETDATE()

	IF (@GirisTarihi > @Bugun)
	BEGIN
		SELECT @GirisTarihi = @Bugun
		UPDATE Sales.SalesOrderHeader
		SET DueDate = @GirisTarihi
		WHERE SalesOrderID = (SELECT SalesOrderID FROM inserted)
	END

END
GO
