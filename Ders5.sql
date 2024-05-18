
-- HATA YONETIMI
BEGIN TRY
	declare @rakam1 int
	set @rakam1 = 0
	declare @rakam2 int
	set @rakam2 = 10
	select @rakam2 / @rakam1
END TRY
BEGIN CATCH
	print 'Bir sayi 0 a bolunemez'
END CATCH

-- STORED PROCEDURES
ALTER PROCEDURE SpGetCustomersByTerritory
	-- Add the parameters for the stored procedure here
	@TerritoryID int = 0
AS
BEGIN
	SELECT sc.CustomerID, pp.FirstName, pp.LastName, st.Name AS Bolge FROM Sales.Customer sc
	INNER JOIN Sales.SalesTerritory st ON sc.TerritoryID = st.TerritoryID
	INNER JOIN Person.Person pp ON pp.BusinessEntityID = sc.PersonID

	SELECT * FROM Sales.SalesTerritory
END
GO


EXEC SpGetCustomersByTerritory 1

-- Parametrelerin dogrulugunun kontrol altinda tutuldugu; Satislari getiren SP:
ALTER PROCEDURE GetSalesByDate
	@start nvarchar(20), 
	@end nvarchar(20)
AS
BEGIN
	DECLARE @startDate datetime
	DECLARE @endDate datetime
	--EXEC GetSalesByDate '2012-21-01','2012-16-01'
	begin try
		SELECT @startDate = @start
		SELECT @endDate = @end
		print 'islem tamam'
	end try
	begin catch
		Print 'Gonderilen tarihler gecersizdir'
	end catch

	IF (@startDate > @endDate)
	BEGIN
		PRINT 'Hatali gonderilen parametreler sp icerisinde duzeltildi' 
		DECLARE @geciciTarih datetime
		SELECT @geciciTarih = @startDate
		SELECT @startDate = @endDate
		SELECT @endDate = @geciciTarih
	END

	SELECT pp.Name, sod.OrderQty, soh.OrderDate FROM Sales.SalesOrderHeader soh
	INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	INNER JOIN Production.Product pp ON pp.ProductID = sod.ProductID
	WHERE Soh.OrderDate > @startDate AND soh.OrderDate < @endDate
	ORDER BY soh.OrderDate desc
END
GO

EXEC GetSalesByDate '2012-01-01','2012-06-01'

-- Musteri kaydi icin Person, Customer ve Adres tablolarina giris yapan, Transaction kontrollu, Try bloklu SP:

ALTER PROCEDURE SpMusteriKaydi 
	@FirstName nvarchar(30),
	@LastName nvarchar(30),
	@MiddleName nvarchar(30) = '',
	@ProductName nvarchar(50),
	@Quantity smallint,
	@Adres nvarchar(100),
	@Sehir nvarchar(20)
AS
BEGIN
	IF(LEN(@MiddleName) = 0)
	BEGIN
		SELECT @MiddleName = null
	END
	DECLARE @count int
	SELECT @count = COUNT(1) FROM Person.Person pp
	WHERE pp.FirstName = @FirstName
	AND pp.LastName = @LastName
	AND pp.MiddleName = @MiddleName
	IF(@count = 0)
	BEGIN
		DECLARE @Id int
		SELECT @Id = MAX(pp.BusinessEntityID) + 1 from Person.Person pp
		BEGIN TRY
			BEGIN TRAN -- transaction i baslattik
			INSERT INTO [Person].[Person]
			   ([BusinessEntityID],[PersonType],[NameStyle],[Title],[FirstName],[MiddleName],[LastName],[Suffix],[EmailPromotion],[AdditionalContactInfo],[Demographics],[rowguid],[ModifiedDate])
			VALUES
			   (@Id,'SC', 0, null, @FirstName,@MiddleName,@LastName,null, 0, null, null,newid(),getdate())
		
			INSERT INTO Sales.Customer([PersonID],[rowguid],[ModifiedDate])
			VALUES (@Id, newid(), getdate())

			INSERT INTO [Person].[Address]
			   ([AddressLine1],[AddressLine2],[City],[StateProvinceID],[PostalCode],[SpatialLocation],[rowguid],[ModifiedDate])
			VALUES
			   (@Adres,null,@Sehir,214,34123,null,newid(),getdate())
			DECLARE @AdresId int
			SELECT @AdresID = MAX(AddressID) FROM Person.Address 
			WHERE AddressLine1 = @Adres AND City = @Sehir 
			COMMIT TRAN -- 3 adet INSERT cumlesini tek seferde onayladik
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN -- Hata olur ise, tum INSERT leri geri alacak
		END CATCH
	END
END
GO

-- SANAL TABLO KULLANIMI:
DECLARE @DetayliAdres TABLE(Adres nvarchar(100), Sehir nvarchar(50), Postakodu nvarchar(15))

INSERT INTO @DetayliAdres 
SELECT pa.AddressLine1 AS Adres, pa.City AS Sehir, pa.PostalCode AS Postakodu FROM Person.Address pa

SELECT * FROM @DetayliAdres

-- TABLE LOCK dan kurtulmak:
-- Burada nolock: eger ben bu select i calistirdigim anda COMMIT edilmemis transaction var ise; tablodaki kilide (LOCK) takilmamasini saglar
-- DIKKAT: o an yazilmis ama commit edilmemis verileri almaz
SELECT * FROM Person.Person nolock

-- PIVOT TABLO:
SELECT * FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod ON soh.Sa

-- CURSOR:
