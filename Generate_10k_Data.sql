USE ShopeeDB; -- Đảm bảo đúng tên DB
GO

-- =============================================
-- 1. XÓA BẢNG CŨ NẾU CÓ (ĐỂ CHẠY LẠI KHÔNG LỖI)
-- =============================================
IF OBJECT_ID('dbo.Legacy_Orders', 'U') IS NOT NULL DROP TABLE dbo.Legacy_Orders;
IF OBJECT_ID('dbo.Legacy_Products', 'U') IS NOT NULL DROP TABLE dbo.Legacy_Products;
IF OBJECT_ID('dbo.Legacy_Users', 'U') IS NOT NULL DROP TABLE dbo.Legacy_Users;
GO

-- =============================================
-- 2. TẠO CÁC BẢNG TẠM (LEGACY SYSTEM)
-- =============================================
CREATE TABLE Legacy_Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Raw_Fullname NVARCHAR(100),
    Raw_Email NVARCHAR(100),
    Raw_Phone NVARCHAR(20)
);

CREATE TABLE Legacy_Products (
    ProdID INT IDENTITY(1,1) PRIMARY KEY,
    Raw_Name NVARCHAR(255),
    Raw_Price NVARCHAR(50), 
    Raw_Stock INT,
    Raw_Image NVARCHAR(MAX) -- Thêm cột này cho đủ bộ
);

CREATE TABLE Legacy_Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT, 
    ProdID INT, 
    OrderDate DATE,
    Quantity INT
);
GO

-- =============================================
-- 3. SCRIPT SINH 10.000 DÒNG DỮ LIỆU (OPTIMIZED)
-- =============================================
BEGIN TRANSACTION;
DECLARE @i INT = 1;
DECLARE @RandomVal INT;

-- --- PHẦN 1: TẠO 2.000 USERS ---
PRINT '>>> Đang tạo 2.000 Users...';
SET @i = 1;
WHILE @i <= 2000
BEGIN
    SET @RandomVal = ABS(CHECKSUM(NEWID())) % 100;
    
    DECLARE @Name NVARCHAR(100) = 'Khach Hang ' + CAST(@i AS NVARCHAR);
    DECLARE @Email NVARCHAR(100);
    DECLARE @Phone NVARCHAR(20);

    -- 5% Lỗi Email (Thiếu @gmail.com)
    IF @RandomVal < 5 SET @Email = 'user' + CAST(@i AS NVARCHAR); 
    ELSE SET @Email = 'user' + CAST(@i AS NVARCHAR) + '@gmail.com';

    -- 5% Lỗi SĐT (Thiếu số hoặc có chữ)
    IF @RandomVal < 5 SET @Phone = '090123'; 
    ELSE IF @RandomVal < 10 SET @Phone = '098-ABC-XYZ'; 
    ELSE SET @Phone = '09' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR);

    INSERT INTO Legacy_Users (Raw_Fullname, Raw_Email, Raw_Phone)
    VALUES (@Name, @Email, @Phone);
    SET @i = @i + 1;
END

-- --- PHẦN 2: TẠO 2.000 PRODUCTS ---
PRINT '>>> Đang tạo 2.000 Products...';
SET @i = 1;
WHILE @i <= 2000
BEGIN
    SET @RandomVal = ABS(CHECKSUM(NEWID())) % 100;
    
    DECLARE @PName NVARCHAR(255);
    DECLARE @PPrice NVARCHAR(50);
    DECLARE @PStock INT;
    DECLARE @PImage NVARCHAR(MAX) = 'https://fakeimg.pl/300/'; -- Link ảnh giả

    -- 10% Lỗi Tên/Giá
    IF @RandomVal < 5 SET @PName = NULL; -- Tên rỗng
    ELSE SET @PName = 'San Pham VIP ' + CAST(@i AS NVARCHAR);

    IF @RandomVal < 5 SET @PPrice = '-500000'; -- Giá âm
    ELSE IF @RandomVal < 8 SET @PPrice = 'Lien he shop'; -- Giá chữ
    ELSE SET @PPrice = CAST((ABS(CHECKSUM(NEWID())) % 5000) * 1000 AS NVARCHAR);

    SET @PStock = ABS(CHECKSUM(NEWID())) % 100;

    INSERT INTO Legacy_Products (Raw_Name, Raw_Price, Raw_Stock, Raw_Image)
    VALUES (@PName, @PPrice, @PStock, @PImage);
    SET @i = @i + 1;
END

-- --- PHẦN 3: TẠO 6.000 ORDERS ---
PRINT '>>> Đang tạo 6.000 Orders...';
SET @i = 1;
WHILE @i <= 6000
BEGIN
    -- Random ID từ 1-2000
    DECLARE @RandUserID INT = (ABS(CHECKSUM(NEWID())) % 2000) + 1;
    DECLARE @RandProdID INT = (ABS(CHECKSUM(NEWID())) % 2000) + 1;
    
    -- Random ngày trong 365 ngày qua
    DECLARE @RandDate DATE = DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE());

    INSERT INTO Legacy_Orders (UserID, ProdID, OrderDate, Quantity)
    VALUES (@RandUserID, @RandProdID, @RandDate, 1);

    SET @i = @i + 1;
END

COMMIT TRANSACTION;
PRINT '=== HOÀN TẤT! ĐÃ SINH XONG 10.000 DÒNG DỮ LIỆU ===';