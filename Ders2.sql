SELECT ProductID AS ID, Name AS Isim, ListPrice AS Fiyat FROM SalesLT.Product

SELECT c.CustomerID, c.ModifiedDate, c.ModifiedDate FROM SalesLT.Customer c --ALIAS

SELECT pp.FirstName + ' ' + pp.LastName AS [Isim Soyisim] FROM SalesLT.Customer pp
WHERE pp.LastName = 'Baker'

SELECT pp.FirstName + ' ' + pp.LastName AS [Isim Soyisim] FROM SalesLT.Customer pp
WHERE pp.LastName = 'Baker' AND pp.FirstName = 'Alex'

SELECT pp.FirstName + ' ' + pp.LastName AS [Isim Soyisim] FROM SalesLT.Customer pp
WHERE pp.LastName != 'Baker' AND pp.FirstName = 'Alex'

-- Isim, Fiyat ve tarihi, Fiyat 0dan buyuk olanlar VE Fiyat 100den kucuk olanlar ve 2010 yilindan oncekileri aldik, Fiyata gore azalan siraladik
SELECT pp.Name, pp.ListPrice, pp.SellStartDate FROM SalesLT.Product pp
WHERE ListPrice > 0 AND ListPrice < 1000 AND pp.SellStartDate < '2010-01-01'
ORDER BY ListPrice desc

SELECT pp.FirstName, pp.MiddleName, pp.LastName FROM SalesLT.Customer pp
WHERE pp.LastName LIKE 'A%' AND pp.FirstName LIKE '%A' -- %: Herhangi uzunlukta joker

-- MiddleNAme NULL olmayanlari cektik:
-- NULL icin 'is' veya 'is not' kullanmamiz gerekiyor
SELECT pp.FirstName, pp.MiddleName, pp.LastName FROM SalesLT.Customer pp
WHERE pp.MiddleName is not NULL

-- _ : tek harf jokeri
SELECT pp.FirstName, pp.MiddleName, pp.LastName FROM SalesLT.Customer pp
WHERE pp.LastName LIKE 'A___' AND pp.FirstName LIKE '%A' AND LEN(pp.FirstName) = 5


SELECT pp.Name, pp.ListPrice, pp.SellStartDate FROM SalesLT.Product pp
WHERE ListPrice > 0 AND ListPrice < 1000
-- yukaridakinin alternatifi:
SELECT pp.Name, pp.ListPrice, pp.SellStartDate FROM SalesLT.Product pp
WHERE ListPrice BETWEEN 0 AND 1000

-- String (Yazi) Fonksiyonlari
SELECT ASCII('E') -- Bir akarakterin AscII kod numarasini almak icin:
SELECT CHAR(69) -- Bir karakterin kod numarasindan kendisini alabilmek icin
SELECT LEN('Mustafa Emre Tekinsoy')
SELECT LTRIM('       Emre')
SELECT LEN(RTRIM('Emre        '))
SELECT LOWER('Emre Tekinsoy')
SELECT UPPER('Emre Tekinsoy')

SELECT LEFT('TR34 76576576576576', 4)
SELECT RIGHT('www.dhgfasfdhf.org', 3) 

SELECT pp.FirstName, pp.LastName, UPPER(LEFT(pp.FirstName, 3)) FROM  SalesLT.Customer pp

SELECT REPLICATE('**** ', 4)

SELECT REPLACE('çiğdem', 'ç', 'c')

SELECT SUBSTRING('Indirim kodunuz: 1234. Lutfen kimseyle paylasmayiniz',18, 4)

SELECT CHARINDEX('Kodunuz', 'Sayin Emre bey, Kodunuz: 1234. jhgjhasdgjha', 0)

SELECT SUBSTRING('Sayin Nazmiye HAnim, Kodunuz: 1234. ', CHARINDEX('Kodunuz', 'Sayin Nazmiye HAnim, Kodunuz: 1234. jhgjhasdgjha', 0) + LEN('Kodunuz: ') + 1, 4)

-- Matematiksel Islemler (+, -, *, /)
SELECT pp.Name, pp.ListPrice * 0.9 AS [%10 Iskontolu], pp.ListPrice FROM SalesLT.Product pp
WHERE pp.ListPrice > 0

-- Aggrigate Functions (Tablo bazinda matemtiksel fonksiyonlar)
-- En dusuk Fiyat (0 haric)
SELECT MIN(pp.ListPrice) FROM SalesLT.Product pp
WHERE pp.ListPrice > 0

SELECT pp.Name, pp.ListPrice FROM SalesLT.Product pp
WHERE pp.ListPrice = (SELECT MIN(pp.ListPrice) FROM SalesLT.Product pp
WHERE pp.ListPrice > 0)

-- Aggrigate Function da gruplama yapmak:
SELECT pp.ProductCategoryID, MIN(pp.ListPrice) FROM SalesLT.Product pp
GROUP BY pp.ProductCategoryID
HAVING  pp.ProductCategoryID is not null
-- Aggrigate Function lar ile birlikte WHERE kullanilamaz. Bunun yerine HAVING kullanabilirim: ancak bunu da sadece GROUP BY yapti[im sutunlar ile birlikte kullanabilirim

-- GROUP BY kullanilan Aggrigate Function i hangi kolona gore gruplanarak verilecegini belirler
SELECT pp.ProductCategoryID, MIN(pp.ListPrice) FROM
(SELECT * FROM SalesLT.Product ppFiltreli WHERE ppFiltreli.ListPrice > 0) AS pp
GROUP BY pp.ProductCategoryID
HAVING  pp.ProductCategoryID is not null

SELECT pp.Name, MAX(pp.ListPrice) FROM
(SELECT * FROM SalesLT.Product ppFiltreli WHERE ppFiltreli.Name is not null) AS pp
GROUP BY pp.Name

-- Kolonun ortalamisi: AVG
SELECT AVG(pp.ListPrice) FROM SalesLT.Product pp
-- Kolonun toplami
SELECT SUM(ss.UnitPrice * ss.OrderQty) FROM SalesLT.SalesOrderDetail ss

SELECT COUNT(1) FROM SalesLT.Product
-- Asagidaki sonuc kumelerinden yola cikarak; SQL i en az yoracak bicimde yukarida 1 yazdik
SELECT * FROM SalesLT.Product
SELECT Color FROM SalesLT.Product
SELECT 1 FROM SalesLT.Product

-- Eger bir text icerisinde tek tirnak karakter olarak kullanilacak ise '' olarak yazilir
SELECT * FROM SalesLT.Customer WHERE FirstName = 'Jack Le''agsfa'


-- EK BILGI:
-- SQL Injection Ornegi
-- ' OR 1=1 GO DELETE * FROM PErson.Person --

SELECT COUNT(1) FROM SalesLT.Customer pp
WHERE pp.FirstName = 'Terri' AND pp.LastName = 'Duffy'

-- Datetime fonksiyonlari:
SELECT getdate()
-- yy, yyyy : yil
-- qq, q: quarter
-- mm, m: month
-- dd, d: day
-- wk, ww: week
-- dw: day of week (pazartesiye 3 eklersem: per. verir)
-- hh: hour
-- mi, n: minute
-- ss, s: second
-- ms: millisecond

SELECT DATEADD(mm, 3, getdate())
SELECT DATEADD(hh, 3, GETUTCDATE())
SELECT DATEDIFF(mm, '1976-03-18', '2024-03-31')
SELECT DATEFROMPARTS(2024, 5, 6)
SELECT DATETIMEFROMPARTS(2024, 5,6,15,56,0, 0)
SELECT DATEPART(dw, getdate())
SELECT DATENAME(dw, getdate())
SELECT DAY(getdate())
SELECT YEAR(getdate())
SELECT MONTH(getdate())


--convert, newid, declare, set, case-when, top, distinct
-- Değişken tanımlamak
DECLARE @rakam nvarchar(12) --değişken tanımladık
SET @rakam = '23' -- atama yaptık
SELECT @rakam = '23' -- atama yaptık
-- Tur donusumu
SELECT CONVERT(int, @rakam)

-- yeni bir uniqueidentifier üretmek için;
SELECT NEWID()

-- sonuç kümesinin ilk n satırını çağırmak istersek: örnek ilk 10 satır:
SELECT TOP 10 * FROM SalesLT.Product

-- mükerrer satırları elemek istersek:
SELECT DISTINCT sa.City, sa.CountryRegion FROM SalesLT.Address sa


-- Insert Update Delete
INSERT INTO ProductBackup
           ([Name]
           ,[ProductNumber]
           ,[StandardCost]
           ,[ListPrice]
		   ,SellStartDate
           ,[ModifiedDate]
           ,[rowguid])
     VALUES 
           ('Kask2'
           ,'K2'
           ,123.95
           ,133.95
           ,'2024-06-01'
           ,getdate()
           ,newid())

UPDATE SalesLT.Product 
SET ProductNumber = 'K21', ListPrice = 223.55, StandardCost = 205.76
WHERE ProductID = 2007
-- DIKKAT: WHERE kosulunu eklemez isem butun tabloyu update eder

DELETE FROM SalesLT.Product
WHERE ProductID = 2007
-- DIKKAT: WHERE kosulunu eklemez isem butun tabloyu siler

SELECT * INTO ProductBackup FROM SalesLT.Product

UPDATE ProductBackup SET ListPrice = 99 
DELETE FROM ProductBackup 
-- Eger tabloyu tamamen reset lemek istersek:
TRUNCATE TABLE ProductBackup


-- Sorgularimizda Tablo Birlestirmek:
-- INNER JOIN; kesisim kumesi
SELECT sc.FirstName, sc.LastName, sc.CustomerID, sa.AddressType, ad.AddressLine1, ad.City 
FROM SalesLT.Customer sc
INNER JOIN SalesLT.CustomerAddress sa ON sc.CustomerID = sa.CustomerID
INNER JOIN SalesLT.Address ad ON sa.AddressID = ad.AddressID

SELECT sp.Name, sd.OrderQty, sh.OrderDate, pc.Name AS Category FROM SalesLT.SalesOrderDetail sd
INNER JOIN SalesLT.SalesOrderHeader sh ON sh.SalesOrderID = sd.SalesOrderID
INNER JOIN SalesLT.Product sp ON sp.ProductID = sd.ProductID
INNER JOIN SalesLT.ProductCategory pc ON sp.ProductCategoryID = pc.ProductCategoryID

SELECT sc.FirstName, sc.LastName, SUM(soh.SubTotal) FROM SalesLT.Customer sc
INNER JOIN SalesLT.SalesOrderHeader soh ON sc.CustomerID = soh.CustomerID
GROUP BY sc.FirstName, sc.LastName
Order BY sc.FirstName

SELECT sc.FirstName, sc.LastName, soh.SubTotal FROM SalesLT.Customer sc
INNER JOIN SalesLT.SalesOrderHeader soh ON sc.CustomerID = soh.CustomerID
Order BY sc.FirstName

-- Yukarida sadece alisverisi olan (kesisim kumesi) musterileri getirdik
-- Asagida alisverisi olsun yada olmasin tum musterileri gorelim, varsa alisverisi onu da yazsin
SELECT * FROM
SalesLT.Customer sc LEFT OUTER JOIN SalesLT.SalesOrderHeader soh 
ON sc.CustomerID = soh.CustomerID

SELECT sc.FirstName, sc.LastName, soh.SubTotal FROM
 SalesLT.SalesOrderHeader soh RIGHT OUTER JOIN SalesLT.Customer sc 
ON sc.CustomerID = soh.CustomerID

-- Butun urunler listelensin, eger varsa satisi, satis rakami ve satildigi sehir de gelsin,
-- Satis yok ise, YOK yazsin
SELECT 
sp.Name AS Urun,
CASE WHEN SUM(sod.OrderQty) is null THEN 'YOK'
	ELSE CONVERT(nvarchar(20),SUM(sod.OrderQty)) END AS Adet,
sa.City
FROM SalesLT.Product sp
LEFT OUTER JOIN SalesLT.SalesOrderDetail sod ON sp.ProductID = sod.ProductID
LEFT OUTER JOIN SalesLT.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
LEFT OUTER JOIN SalesLT.Address sa ON sa.AddressID = soh.ShipToAddressID
GROUP BY sp.Name, sa.City
ORDER BY SUM(sod.OrderQty) desc

-- Butun sehirlerin adi gelsin, eger varsa bu sehirde ssatis yapilan musteri, musterinin adi da gelsin, yoksa BU SEHIRDE SATIS YAPILMADI yazsin
SELECT DISTINCT
sa.City,
CASE WHEN sc.FirstName is null THEN 'BU SEHRE SATIS YOK'
	ELSE sc.FirstName + ' ' + sc.LastName END AS [Isim Soyisim] 
FROM SalesLT.Address sa
LEFT OUTER JOIN SalesLT.SalesOrderHeader soh ON sa.AddressID = soh.ShipToAddressID
LEFT OUTER JOIN SalesLT.Customer sc ON soh.CustomerID = sc.CustomerID
ORDER BY sa.City