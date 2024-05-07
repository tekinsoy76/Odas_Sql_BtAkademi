SELECT ProductID AS ID, Name AS Isim, ListPrice AS Fiyat FROM Production.Product

SELECT c.CustomerID, c.ModifiedDate, c.ModifiedDate FROM Sales.Customer c --ALIAS

SELECT pp.FirstName + ' ' + pp.LastName AS [Isim Soyisim] FROM Person.Person pp
WHERE pp.LastName = 'Baker'

SELECT pp.FirstName + ' ' + pp.LastName AS [Isim Soyisim] FROM Person.Person pp
WHERE pp.LastName = 'Baker' AND pp.FirstName = 'Alex'

SELECT pp.FirstName + ' ' + pp.LastName AS [Isim Soyisim] FROM Person.Person pp
WHERE pp.LastName != 'Baker' AND pp.FirstName = 'Alex'

-- Isim, Fiyat ve tarihi, Fiyat 0dan buyuk olanlar VE Fiyat 100den kucuk olanlar ve 2010 yilindan oncekileri aldik, Fiyata gore azalan siraladik
SELECT pp.Name, pp.ListPrice, pp.SellStartDate FROM Production.Product pp
WHERE ListPrice > 0 AND ListPrice < 1000 AND pp.SellStartDate < '2010-01-01'
ORDER BY ListPrice desc

SELECT pp.FirstName, pp.MiddleName, pp.LastName FROM Person.Person pp
WHERE pp.LastName LIKE 'A%' AND pp.FirstName LIKE '%A' -- %: Herhangi uzunlukta joker

-- MiddleNAme NULL olmayanlari cektik:
-- NULL icin 'is' veya 'is not' kullanmamiz gerekiyor
SELECT pp.FirstName, pp.MiddleName, pp.LastName FROM Person.Person pp
WHERE pp.MiddleName is not NULL

-- _ : tek harf jokeri
SELECT pp.FirstName, pp.MiddleName, pp.LastName FROM Person.Person pp
WHERE pp.LastName LIKE 'A___' AND pp.FirstName LIKE '%A' AND LEN(pp.FirstName) = 5


SELECT pp.Name, pp.ListPrice, pp.SellStartDate FROM Production.Product pp
WHERE ListPrice > 0 AND ListPrice < 1000
-- yukaridakinin alternatifi:
SELECT pp.Name, pp.ListPrice, pp.SellStartDate FROM Production.Product pp
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

SELECT pp.FirstName, pp.LastName, UPPER(LEFT(pp.FirstName, 3)) FROM  Person.Person pp

SELECT REPLICATE('**** ', 4)

SELECT REPLACE('çiğdem', 'ç', 'c')

SELECT SUBSTRING('Indirim kodunuz: 1234. Lutfen kimseyle paylasmayiniz',18, 4)

SELECT CHARINDEX('Kodunuz', 'Sayin Emre bey, Kodunuz: 1234. jhgjhasdgjha', 0)

SELECT SUBSTRING('Sayin Nazmiye HAnim, Kodunuz: 1234. jhgjhasdgjha', CHARINDEX('Kodunuz', 'Sayin Nazmiye HAnim, Kodunuz: 1234. jhgjhasdgjha', 0) + LEN('Kodunuz: ') + 1, 4)

-- Matematiksel Islemler (+, -, *, /)
SELECT pp.Name, pp.ListPrice * 0.9 AS [%10 Iskontolu], pp.ListPrice FROM Production.Product pp
WHERE pp.ListPrice > 0

-- Aggrigate Functions (Tablo bazinda matemtiksel fonksiyonlar)
-- En dusuk Fiyat (0 haric)
SELECT MIN(pp.ListPrice) FROM Production.Product pp
WHERE pp.ListPrice > 0

SELECT pp.Name, pp.ListPrice FROM Production.Product pp
WHERE pp.ListPrice = (SELECT MIN(pp.ListPrice) FROM Production.Product pp
WHERE pp.ListPrice > 0)

-- Aggrigate Function da gruplama yapmak:
SELECT pp.Class, MIN(pp.ListPrice) FROM Production.Product pp
GROUP BY pp.Class
HAVING  pp.Class is not null
-- Aggrigate Function lar ile birlikte WHERE kullanilamaz. Bunun yerine HAVING kullanabilirim: ancak bunu da sadece GROUP BY yapti[im sutunlar ile birlikte kullanabilirim

-- GROUP BY kullanilan Aggrigate Function i hangi kolona gore gruplanarak verilecegini belirler
SELECT pp.Class, MIN(pp.ListPrice) FROM
(SELECT * FROM Production.Product ppFiltreli WHERE ppFiltreli.ListPrice > 0) AS pp
GROUP BY pp.Class
HAVING  pp.Class is not null

SELECT pp.Class, MAX(pp.ListPrice) FROM
(SELECT * FROM Production.Product ppFiltreli WHERE ppFiltreli.Class is not null) AS pp
GROUP BY pp.Class

-- Kolonun ortalamisi: AVG
SELECT AVG(pp.ListPrice) FROM Production.Product pp
-- Kolonun toplami
SELECT SUM(ss.UnitPrice * ss.OrderQty) FROM Sales.SalesOrderDetail ss

SELECT COUNT(1) FROM Production.Product
-- Asagidaki sonuc kumelerinden yola cikarak; SQL i en az yoracak bicimde yukarida 1 yazdik
SELECT * FROM Production.Product
SELECT Color FROM Production.Product
SELECT 1 FROM Production.Product

-- Eger bir text icerisinde tek tirnak karakter olarak kullanilacak ise '' olarak yazilir
SELECT * FROM Person.Person WHERE FirstName = 'Jack Le''agsfa'


-- EK BILGI:
-- SQL Injection Ornegi
-- ' OR 1=1 GO DELETE * FROM PErson.Person --

SELECT COUNT(1) FROM Person.Person pp
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