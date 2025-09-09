					/*TẠO KHÓA MÃ HÓA*/
create symmetric key QLBH48K14104 
with algorithm = AES_256
encryption by password = '@48K141.04';
go
					/* R3 - TẠO CƠ SỞ DỮ LIỆU */

create database QLBH
go
drop database QLBH
go
use QLBH
create table Nhanvien
(
	NV_ID	varchar(10),
	NV_TEN	nvarchar(100) not null,
	NV_SDT	varbinary(max) not null ,--Chỉnh sửa kiểu dữ liệu
	primary key(NV_ID)
)
go
create table Taikhoan
(
	TK_ID	varchar(10), 
	NV_ID	varchar(10) unique, 
	TK_TENDN	varbinary(max) not null, --Chỉnh sửa kiểu dữ liệu
	TK_MK	varbinary(max) not null, --Chỉnh sửa kiểu dữ liệu
	primary key(TK_ID),
	foreign key(NV_ID) references Nhanvien(NV_ID)
) 
go
create table KH
(
	KH_ID varchar(10),         
    KH_TEN nvarchar(50) not null,           
    KH_SDT varbinary(max) not null, --Chỉnh sửa kiểu dữ liệu
	primary key(KH_ID),  
)
go
create table BAN
(	
	B_STT varchar(5),
	primary key(B_STT)
)
go
create table ThongTinDatBan
(
	TTDB_ID	varchar(20), 
	B_STT	varchar(5) not null, 
	KH_ID	varchar(10) not null, 
	TTDB_GIO	time not null, 
	TTDB_NGAY	date not null,
	TTDB_SL	int not null,
	primary key(TTDB_ID),
	foreign key(B_STT) references Ban(B_STT),
	foreign key(KH_ID) references KH(KH_ID)
)
go
create table Mon
(
	MON_ID	varchar(5),
	MON_TEN	nvarchar(100) not null,
	MON_GIA	numeric(15,0) not null,
	primary key(MON_ID)
)
go
create table Hoadon
(
	HD_ID	varchar(20),
	NV_ID	varchar(10) not null,
	B_STT	varchar(5) not null ,
	HD_DATE	date not null,
	HD_TONG	numeric(15,0) not null,
	HD_KM	decimal(4, 2) not null DEFAULT 0,
	primary key(HD_ID),
	foreign key (NV_ID) references Nhanvien(NV_ID),
	foreign key (B_STT) references Ban(B_STT)
)
go

create table Chitiethoadon
(	
	CTHD_ID	varchar(20), 
	HD_ID	varchar(20) not null, 
	MON_ID	varchar(5) not null, 
	CTHD_SL	int not null,
	primary key(HD_ID,CTHD_ID), --Thay đổi khóa chính
	foreign key(HD_ID) references Hoadon(HD_ID),
	foreign key(MON_ID) references Mon(MON_ID)
)
go
----------------------------------------------------------------------------------------------------------------------------------------------

				/* TẠO DỮ LIỆU DUMP MỖI BẢNG 1000 DÒNG */


/*
Tạo bảng tên random cho cho cột KH_tên và NV_tên

*/



CREATE TABLE ten (
    Ho NVARCHAR(50),
    TenLot NVARCHAR(50),
    Ten NVARCHAR(50)
);

INSERT INTO ten (Ho, TenLot, Ten)
VALUES
(N'Nguyễn', N'Văn', N'Hùng'),
(N'Trần', N'Thị', N'Lan'),
(N'Lê', N'Đức', N'Minh'),
(N'Phạm', N'Văn', N'Thanh'),
(N'Hoàng', N'Thị', N'Hà'),
(N'Vũ', N'Ngọc', N'Sơn'),
(N'Đặng', N'Đình', N'Tú'),
(N'Bùi', N'Văn', N'Phong'),
(N'Đỗ', N'Thị', N'Hương'),
(N'Phạm', N'Công', N'Toàn'),
(N'Ngô', N'Văn', N'Dũng'),
(N'Võ', N'Thị', N'Loàn'),
(N'Đinh', N'Nguyên', N'Quyền'),
(N'Dương', N'Văn', N'Bình'),
(N'Lý', N'Công', N'An');

/*Hàm tạo tên tự động*/
CREATE OR ALTER PROC XACDINHTEN @HOVATEN NVARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @HO NVARCHAR(50),
            @TENLOT NVARCHAR(50),
            @TEN NVARCHAR(50)

    SET @HO = (SELECT TOP 1 HO FROM TEN ORDER BY NEWID())
    SET @TENLOT = (SELECT TOP 1 TENLOT FROM TEN ORDER BY NEWID())
    SET @TEN = (SELECT TOP 1 TEN FROM TEN ORDER BY NEWID())

    SET @HOVATEN = @HO + ' ' + @TENLOT + ' ' + @TEN
END
DECLARE @TEN NVARCHAR(100)
EXEC XACDINHTEN @TEN OUTPUT
PRINT @TEN


---------------------------------------------
/*TẠO BẢNG NHÂN VIÊN*/

/*TẠO TỰ ĐỘNG NV_ID*/
CREATE OR ALTER FUNCTION NVID()
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @NV_ID VARCHAR(20),
			@I VARCHAR(20)
	SELECT @I = MAX(RIGHT(NV_ID,8))FROM Nhanvien
	IF @I IS NULL
		SET @NV_ID = '00000001'
	ELSE
		BEGIN
			SELECT @I = CAST(RIGHT('000000000'+ CAST(MAX(RIGHT(NV_ID,8)) + 1 AS VARCHAR),8) AS VARCHAR)
			FROM Nhanvien
			SELECT @NV_ID = CAST(@I AS VARCHAR)
		END
	RETURN @NV_ID
END
PRINT DBO.NVID()

/*
INSERT 100 DÒNG BẢNG NHÂN VIÊN
*/
CREATE OR ALTER PROC ADD1000NV 
AS
BEGIN 
DECLARE	@NV_ID VARCHAR(20), 
		@TEN NVARCHAR(100), 
		@SDT VARBINARY(MAX),
		@I INT = 0
	WHILE @I <= 1000
	BEGIN
		SET @NV_ID = DBO.NVID()
		EXEC XACDINHTEN @TEN OUTPUT
		OPEN SYMMETRIC KEY QLBH48K14104 
		DECRYPTION BY PASSWORD = '@48K141.04';
		--Mã hóa
		SET @SDT = ENCRYPTBYKEY(KEY_GUID('QLBH48K14104'),
								CAST('090' + RIGHT('0000000' + CAST(CAST( 1+ RAND()*10000000 AS INT) AS VARCHAR),7 ) AS VARBINARY)); 
		CLOSE SYMMETRIC KEY QLBH48K14104
		INSERT INTO NHANVIEN VALUES (@NV_ID, @TEN, @SDT)
		SET @I = @I + 1
	END
END
EXEC ADD1000NV
SELECT * FROM NHANVIEN
DELETE FROM NHANVIEN
--Giải mã DỮ LIỆU
OPEN SYMMETRIC KEY QLBH48K14104
DECRYPTION BY PASSWORD= '@48K141.04'
SELECT NV_ID, NV_TEN, CAST(DECRYPTBYKEY(NV_SDT) AS VARCHAR) AS N'ĐÃ MÃ HÓA'
FROM NHANVIEN
CLOSE SYMMETRIC KEY QLBH48K14104
---------------------------------------------


/*TẠO BẢN MÓN*/

/*MON_ID: tạo tự động, kiểm tra nếu đã tồn tại mã Món 
-> tính mã Món mới =  RIGHT('00000'+ @i,5) (@i = max(mã số của mã Món cũ) +1). 
Số lượng ký tự mã MON_ID là 5 ký tự. Nếu chưa tồn tại thì @i = 1*/
CREATE OR ALTER FUNCTION MONID()
RETURNS VARCHAR(5)
AS
BEGIN
    DECLARE @MaxMONID VARCHAR(5)
    DECLARE @NewMONID VARCHAR(5)
    SELECT @MaxMONID = MAX(MON_ID) FROM Mon
    IF @MaxMONID IS NULL
        SET @NewMONID = '00001'
    ELSE
        SET @NewMONID = RIGHT('00000' + CAST(CAST(@MaxMONID AS INT) + 1 AS VARCHAR(5)), 5)

    RETURN @NewMONID
END
SELECT dbo.MONID()

/*Mon_Ten: bằng chuỗi 'Mon' + @i với i chạy tự 1 -> 1000*/
GO
CREATE OR ALTER FUNCTION dbo.MON_TEN(@I INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @MON_TEN VARCHAR(100)
    BEGIN
        SET @MON_TEN = 'Mon' + CAST(@i AS VARCHAR(10)) 
    END   
    RETURN @MON_TEN
END
SELECT DBO.MON_TEN(1)


/*
INSERT 1000 DÒNG BẢNG MÓN
*/

CREATE OR ALTER PROC ADD1000MON 
AS
BEGIN 
DECLARE	@MON_ID VARCHAR(20), 
		@TEN NVARCHAR(100), 
		@GIA NUMERIC (15,0),
		@I INT = 0
	WHILE @I <= 1000
	BEGIN
		SET @MON_ID = dbo.MONID()
		SET @TEN = DBO.MON_TEN(@I)
		SELECT  @GIA = CAST(30 + (RAND() * (60 - 30)) AS INT) * 1000 
		INSERT INTO MON VALUES (@MON_ID,@TEN,@GIA)
		SET @I = @I + 1
	END
END
EXEC ADD1000MON
SELECT * FROM MON


---------------------------------------------

/*TẠO BẢNG BÀN*/

/* B_STT: @i với i từ 1 -> 1000*/
CREATE OR ALTER FUNCTION BSTT(@i INT)
RETURNS	VARCHAR(20)
AS
BEGIN
    DECLARE @STT INT;
    IF @i < 1 OR @i > 1000
    BEGIN
        RETURN NULL;
    END
    SET @STT = @i;
    RETURN CAST(@STT AS VARCHAR);
END;
SELECT DBO.BSTT(5)


/*INSERT 1000 DÒNG*/

CREATE OR ALTER PROC ADD1000BAN
AS
BEGIN 
DECLARE	@BSTT VARCHAR(20),
		@I INT = 1
	WHILE @I <= 1000
	BEGIN
		SELECT @BSTT =  DBO.BSTT(@I)
		INSERT INTO BAN VALUES (@BSTT)
		SET @I = @I + 1	
	END
END
EXEC ADD1000BAN
SELECT * FROM BAN
DELETE FROM BAN
S

---------------------------------------------

/*TẠO BẢNG KHÁCH HÀNG*/


/*KH_ID: tạo tự động, kiểm tra nếu đã tồn tại mã KH 
-> tính mã KH mới =  RIGHT('0000000000'+ @i ,10) (@i = max(mã số của mã KH cũ) +1). 
Số lượng ký tự mã KH_ID là 10 ký tự*/
GO
CREATE OR ALTER FUNCTION KHID()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxKHID VARCHAR(10)
    DECLARE @NewKHID VARCHAR(10)
    SELECT @MaxKHID = MAX(KH_ID) FROM KH
    IF @MaxKHID IS NULL
        SET @NewKHID = '0000000001'
    ELSE
        SET @NewKHID = RIGHT('0000000000' + CAST(CAST(@MaxKHID AS INT) + 1 AS VARCHAR(10)), 10)
    RETURN @NewKHID
END
GO
SELECT DBO.KHID()

/*KH_Ten: EXEC XACDINHTEN @KH_TEN OUTPUT */


/*INSERT 1000 DÒNG BẢNG KHÁCH HÀNG*/
CREATE OR ALTER PROC ADD1000KHACHHANG
AS
BEGIN 
DECLARE	@KH_ID VARCHAR(20),
		@KH_TEN NVARCHAR(100),
		@KH_SDT VARBINARY(MAX),
		@I INT = 1
	WHILE @I <= 1000
	BEGIN
		SET @KH_ID = DBO.KHID()
		EXEC XACDINHTEN @KH_TEN OUTPUT
		OPEN SYMMETRIC KEY QLBH48K14104
		DECRYPTION BY PASSWORD = '@48K141.04';
		--Mã hóa
		SET @KH_SDT = ENCRYPTBYKEY(KEY_GUID('QLBH48K14104'), 
								   CAST('091' + RIGHT('0000000' + CAST(CAST( 1+ RAND()*10000000 AS INT) AS VARCHAR),7)AS VARBINARY));
		CLOSE SYMMETRIC KEY QLBH48K14104
		INSERT INTO KH VALUES (@KH_ID, @KH_TEN, @KH_SDT)
		SET @I = @I + 1	
	END
END
EXEC ADD1000KHACHHANG
SELECT * FROM KH
--GIẢI MÃ DỮ LIỆU
OPEN SYMMETRIC KEY QLBH48K14104
DECRYPTION BY PASSWORD= '@48K141.04'
SELECT KH_ID, KH_TEN, CAST(DECRYPTBYKEY(KH_SDT) AS VARCHAR) AS N'ĐÃ MÃ HÓA'
FROM KH
CLOSE SYMMETRIC KEY QLBH48K14104

---------------------------------------------

/*TẠO BẢNG THÔNG TIN ĐẶT BÀN*/

/*TTDB_ID:  tạo tự động, kiểm tra nếu đã tồn tại mã TTDB -> tính mã TTDB mới =  RIGHT('00000000'+ @i ,10) (@i = max(mã số của mã TTDB cũ) +1). 
Số lượng ký tự mã TTDB_ID là 10 ký tự. Nếu chưa tồn tại thì @i = 1
*/
CREATE OR ALTER FUNCTION TTDBID()
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @TTDB_ID VARCHAR(20),
			@I VARCHAR(20)
	SELECT @I = MAX(RIGHT(TTDB_ID,10))FROM ThongTinDatBan
	IF @I IS NULL
		SET @TTDB_ID = '0000000001'
	ELSE
		BEGIN
			SELECT @I = CAST(RIGHT('00000000000'+ CAST(MAX(RIGHT(TTDB_ID,10)) + 1 AS VARCHAR),10) AS VARCHAR)
			FROM ThongTinDatBan
			SELECT @TTDB_ID = CAST(@I AS VARCHAR)
		END
	RETURN @TTDB_ID
END
PRINT DBO.TTDBID()


/*B_STT: Random từ bảng BÀN*/
SELECT TOP 1 B_STT FROM BAN ORDER BY NEWID()
go


/*KH_ID:  Random từ bảng KH */
SELECT TOP 1 KH_ID FROM KH ORDER BY NEWID()


/* NGAY: kiểm tra có ngày chưa, nếu chưa thì set ngày 15/1/2022. Nếu có thì tạo ngày mới = ngày cũ + 1  */
SELECT DATEADD(DAY, CAST(RAND() * 1014 AS INT) + 1, '2022-01-15')


/*GIO: random giờ từ 10h sáng đến 10h tối.*/
SELECT CAST(DATEADD(HOUR, CAST(RAND() * 12 AS INT) + 10, 0) AS TIME


	/*INSERT 1000 DÒNG VÀO BẢNG THÔNG TIN ĐẶT BÀN*/
CREATE OR ALTER PROC ADD1000TTDB
AS
BEGIN 
DECLARE	@TTDBID VARCHAR(20),
		@BSTT VARCHAR(10),
		@KHID VARCHAR(20),
		@GIO TIME,
		@NGAY DATE,
		@SL INT,
		@I INT = 1
	WHILE @I <= 1000
	BEGIN
		SET @TTDBID = DBO.TTDBID()
		SET @BSTT = (SELECT TOP 1 B_STT FROM BAN ORDER BY NEWID())
		SET @KHID = (SELECT TOP 1 KH_ID FROM KH ORDER BY NEWID())
		SET @GIO = (SELECT CAST(DATEADD(HOUR, CAST(RAND() * 12 AS INT) + 10, 0) AS TIME))
		SET @NGAY = (SELECT DATEADD(DAY, CAST(RAND() * 1014 AS INT) + 1, '2022-01-15'))
		SET @SL = (SELECT CAST(2+RAND() * 10 AS INT))
		INSERT INTO ThongTinDatBan VALUES (@TTDBID, @BSTT,@KHID,@GIO,@NGAY,@SL)
		SET @I = @I + 1	
	END
END
EXEC ADD1000TTDB
SELECT * FROM ThongTinDatBan


---------------------------------------------
/*TẠO BẢNG TÀI KHOẢN*/

/*TK_ID: tạo tự động, kiểm tra nếu đã tồn tại mã TK -> tính mã TK mới =  RIGHT('000000'+ @i ,6) (@i = max(mã số của mã TK cũ) +1). 
Số lượng ký tự mã TK_ID là 6 ký tự. Nếu chưa tồn tại thì @i = 1*/

CREATE OR ALTER FUNCTION FTKID()
RETURNS NVARCHAR(6)
AS
BEGIN
    DECLARE @TK_ID VARCHAR(6),
            @I INT
    SELECT @I = MAX(CAST(TK_ID AS INT)) FROM Taikhoan
    IF @I IS NULL
        SET @TK_ID = RIGHT('000000' + CAST(1 AS VARCHAR), 6)
    ELSE
        SET @TK_ID = RIGHT('000000' + CAST(@I + 1 AS VARCHAR), 6)

    RETURN @TK_ID
END
SELECT DBO.FTKID()

/*INSERT 1000 DÒNG VÀO BẢNG TÀI KHOẢN*/
CREATE OR ALTER PROC ADD1000TK 
AS
BEGIN
	DECLARE @TK_ID VARCHAR(10),
			@NV_ID VARCHAR(20),
			@TENDN VARBINARY(MAX),
			@MATKHAU VARBINARY(MAX),
			@I INT = 1
	WHILE @I <= 1000
		BEGIN
			SET @TK_ID = DBO.FTKID()
			SET @NV_ID = CAST(RIGHT('000000000'+ CAST(@I AS VARCHAR),8) AS VARCHAR)
			SELECT @TENDN = NV_SDT
			FROM NHANVIEN 
			WHERE @NV_ID = NV_ID
			OPEN SYMMETRIC KEY QLBH48K14104
				DECRYPTION BY PASSWORD = '@48K141.04';
				--Mã hóa
				SET @MATKHAU = ENCRYPTBYKEY(KEY_GUID('QLBH48K14104'),
										CAST('0123456' AS VARBINARY)); 
				CLOSE SYMMETRIC KEY QLBH48K14104
			INSERT INTO TAIKHOAN VALUES (@TK_ID, @NV_ID, @TENDN, @MATKHAU)
			set @I = @I + 1
		END
END
EXEC ADD1000TK 
SELECT * FROM TAIKHOAN
select * from nhanvien
--GIẢI MÃ DỮ LIỆU TK_TENDN VÀ TK_MK
OPEN SYMMETRIC KEY QLBH48K14104
DECRYPTION BY PASSWORD= '@48K141.04'
SELECT NV_ID, TK_ID, 
		CAST(DECRYPTBYKEY(TK_TENDN) AS VARCHAR) AS N'TÊN ĐN ĐÃ MÃ HÓA',
		CAST(DECRYPTBYKEY(TK_MK) AS VARCHAR) AS N'MK ĐÃ MÃ HÓA'
FROM TAIKHOAN
CLOSE SYMMETRIC KEY QLBH48K14104
---------------------------------------------

/*TẠO BẢNG HÓA ĐƠN*/

/*HD_ID: tạo tự động, kiểm tra nếu đã tồn tại mã HD -> tính mã HD mới =  'HD' + RIGHT('0000000000'+ @i ,10)
(@i = max(mã số của mã HD cũ) +1). Số lượng ký tự mã HD_ID là 10 ký tự. Nếu chưa tồn tại thì @i = 1
*/
CREATE OR ALTER FUNCTION FDID()
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @HD_ID VARCHAR(20),
			@I VARCHAR(20)
	SELECT @I = MAX(RIGHT(HD_ID,10))FROM HOADON
	IF @I IS NULL
		SET @HD_ID = 'HD0000000001'
	ELSE
		BEGIN
			SELECT @I = CAST(RIGHT('00000000000'+ CAST(MAX(RIGHT(HD_ID,10)) + 1 AS VARCHAR),10) AS VARCHAR)
			FROM HOADON
			SELECT @HD_ID = 'HD' + CAST(@I AS VARCHAR)
		END
	RETURN @HD_ID
END
PRINT DBO.FDID()

/*INSERT 1000 DÒNG VÀO BẢNG HÓA ĐƠN*/
CREATE OR ALTER PROC ADD1000HD
AS
BEGIN
	DECLARE @HDID VARCHAR(20),
			@NV_ID VARCHAR(20),
			@BSTT INT,
			@HDDATE DATE,
			@HD_TONG NUMERIC(15,0),
			@HDKM NUMERIC (5,2),
			@I INT = 1
	WHILE @I <= 1000
		BEGIN
			SET @HDID = DBO.FDID()
			SET @NV_ID = (SELECT TOP 1 NV_ID FROM NHANVIEN ORDER BY NEWID())
			SET @BSTT = (SELECT TOP 1 B_STT FROM BAN ORDER BY NEWID())
			SET @HDDATE = (SELECT DATEADD(DAY, CAST(RAND() * 1014 AS INT) + 1, '2022-01-01'))
			SET @HD_TONG = (SELECT CAST(30 + (RAND() * (3000 - 30)) AS INT) * 1000)
			SET @HDKM = (SELECT CASE WHEN RAND()<=0.666 THEN 0.1
									 WHEN RAND()<=0.333 THEN 0
									 WHEN RAND()>0.666 THEN 0.2
						 END)
			INSERT INTO HOADON VALUES (@HDID,@NV_ID,@BSTT,@HDDATE,@HD_TONG,@HDKM)
			SET @I = @I+1
		END
END
EXEC ADD1000HD
SELECT * FROM HOADON
---------------------------------------------

/*INSERT 1000 DÒNG VÀO BẢNG CTHD*/
CREATE OR ALTER PROCEDURE ADD1000CTHD
AS
BEGIN
    DECLARE @HD_ID VARCHAR(20),
            @CTHD_ID varchar(20),
            @MON_ID VARCHAR(5),
            @CTHD_SL INT,
            @i INT = 1
	
    WHILE @i <= 1000
    BEGIN
        DECLARE @J INT = 0,
                @M INT = 1
        SET @J = FLOOR(1 + (RAND() * 5))  -- Số chi tiết hóa đơn cho mỗi hóa đơn ngẫu nhiên
        SELECT TOP 1 @HD_ID = HD_ID FROM Hoadon ORDER BY NEWID()  -- Chọn ngẫu nhiên 1 hóa đơn
		SET @CTHD_ID = '1'
        WHILE @M <= @J
        BEGIN
            SELECT TOP 1 @MON_ID = MON_ID FROM Mon ORDER BY NEWID()  -- Chọn ngẫu nhiên 1 món
            SET @CTHD_SL = 1 + CAST(RAND() * 10 AS INT)  -- Số lượng ngẫu nhiên từ 1 đến 10
            INSERT INTO CHITIETHOADON ( HD_ID, CTHD_ID, MON_ID, CTHD_SL)
            VALUES (@HD_ID, CAST(@CTHD_ID AS VARCHAR), @MON_ID, @CTHD_SL)  -- Sử dụng @CTHD_ID hiện tại
            SET @CTHD_ID = CAST(CAST(@CTHD_ID AS INT) + 1 AS VARCHAR) -- Tăng @CTHD_ID cho mỗi lần chèn
            SET @M = @M + 1
        END
        SET @i = @i + 1
    END
END
EXEC ADD1000CTHD

SELECT * FROM NHANVIEN
SELECT * FROM KH
SELECT * FROM MON
SELECT * FROM ThongTinDatBan 
SELECT * FROM BAN
SELECT * FROM HOADON
SELECT * FROM CHITIETHOADON 

----------------------------------------------------------------------------------------------------------------------------------------------
						/*MODULE MÃ HÓA*/
/* HÀM - TẠO MỚI MÃ NHÂN VIÊN */
create or alter function NVIDMoi()
returns varchar(20)
as
begin
    declare @nvid varchar(20)
    declare @i varchar(20)
    select @i = max(nv_id) from nhanvien
    if @i is null
    begin
        set @nvid = '00000001'
    end
    else
    begin
        set @nvid = @i + 1
		set @nvid = right('00000000' + cast(@nvid as varchar),8)
    end
    return @nvid
end
select * from nhanvien
select dbo.NVIDMoi() 

/* THỦ TỤC - THÊM MỚI THÔNG TIN NHÂN VIÊN */
create or alter proc themnhanvien   @tennv nvarchar(100),
									@sdt varchar(20),
									@ret bit output
as
begin
	declare @nvid varchar(20),
			@sdtmahoa varbinary(max) --thêm vào biến mã hóa
	set @nvid = dbo.NVIDMoi()
	open symmetric key QLBH48K14104
	decryption by password = '@48K141.04'
	--Mã hóa 
	set @sdtmahoa = encryptbykey(key_guid('QLBH48K14104'), cast( @sdt as varbinary(max))) --mã hóa sđt nhập vào dô biến @sdtmahoa
	close symmetric key QLBH48K14104
	insert into Nhanvien values (@nvid,@tennv,@sdtmahoa)
	if @@ROWCOUNT > 0
		set @ret = 1
	else
		set @ret = 0
end
go

declare @tennv nvarchar(100),@sdt varchar(20),@ret bit 
set @tennv = N'Nguyễn Văn B'
set @sdt = '091422784'
exec themnhanvien @tennv,@sdt,@ret out
print @ret
select * from nhanvien
--giải mã dữ liệu
OPEN SYMMETRIC KEY QLBH48K14104
DECRYPTION BY PASSWORD= '@48K141.04'
SELECT NV_ID, NV_TEN, CAST(DECRYPTBYKEY(NV_SDT) AS VARCHAR) AS N'ĐÃ MÃ HÓA'
FROM NHANVIEN
CLOSE SYMMETRIC KEY QLBH48K14104

/* HÀM - TẠO MỚI MỘT TÀI KHOẢN ID */
create or alter function ftkid()
returns nvarchar(6)
as
begin
    declare @tk_id varchar(6),
            @i int
    select @i = max(cast(tk_id as int)) from taikhoan
    if @i is null
        set @tk_id = right('000000' + cast(1 as varchar), 6)
    else
        set @tk_id = right('000000' + cast(@i + 1 as varchar), 6)

    return @tk_id
end
select dbo.ftkid()


/* TRIGGER - KHI THÊM MỚI MỘT THÔNG TIN NHÂN VIÊN, HÃY THÊM MỚI TÀI KHOẢN CHO NHÂN VIÊN ĐÓ VỚI TÊN ĐN: SĐT, MK: 0123456*/
create or alter trigger trgafterinsertnhanvien
on nhanvien
after insert
as
begin
	open symmetric key QLBH48K14104
	decryption by password = '@48K141.04'
	INSERT INTO Taikhoan (tk_id, nv_id, tk_tendn, tk_mk)
    SELECT 
        dbo.FTKID(), -- Gọi hàm tạo ID tài khoản
        NV_ID, -- NV_ID từ inserted
        NV_SDT, --ĐÃ MÃ HÓA TRƯỚC ĐÓ RỒI
        EncryptByKey(Key_GUID('QLBH48K14104'), CAST('0123456' AS VARBINARY(MAX))) -- Mã hóa mật khẩu mặc định
    FROM 
        inserted;
	close symmetric key QLBH48K14104

end
select * from Nhanvien
select * from taikhoan
--insert vào nhanvien
declare @tennv nvarchar(100),@sdt varchar(20),@ret bit 
set @tennv = N'Nguyễn Văn d'
set @sdt = '091442334'
exec themnhanvien @tennv,@sdt,@ret out
print @ret
--giải mã dữ liệu
OPEN SYMMETRIC KEY QLBH48K14104
DECRYPTION BY PASSWORD= '@48K141.04'
SELECT TK_ID, NV_ID, 
		CAST(DECRYPTBYKEY(TK_TENDN) AS VARCHAR) AS N'ĐÃ MÃ HÓA',
		CAST(DECRYPTBYKEY(TK_MK) AS VARCHAR) AS N'ĐÃ MÃ HÓA'
FROM TAIKHOAN
CLOSE SYMMETRIC KEY QLBH48K14104

SELECT * FROM KH
/*HÀM TẠO KH_ID */
create or alter function fk_taokhid ()
returns varchar(20)
as
begin
	declare @kh_id varchar(20)
	select @kh_id = cast(max(kh_id) as int)
	from kh
	if @kh_id is null set @kh_id ='0000000001'
	else set @kh_id = right('0000000000' + cast(@kh_id + 1  as varchar(20)),10)
	return @kh_id
end
select dbo.fk_taokhid ()

/*THỦ TỤC THÊM MỚI MỘT KHÁCH HÀNG*/
create or alter proc sp_insertkh (@ten nvarchar(100),
								  @kh_sdt varchar(20),
								  @ret bit output)
as
begin
	declare @kh_id varchar(20),
			@kh_sdtmahoa varbinary(max)
	set @kh_id = dbo.fk_taokhid()
	open symmetric key QLBH48K14104
	decryption by password = '@48K141.04'
	--Mã hóa
	set @kh_sdtmahoa =  encryptbykey(key_guid('QLBH48K14104'),cast (@kh_sdt as varbinary(max)))
	insert into kh
	values (@kh_id, @ten, @kh_sdtmahoa)
	if @@ROWCOUNT > 0 set @ret = 1
	else set @ret = 0
end

declare @ten nvarchar(100),
		@kh_sdt varchar(20),
		@ret bit
set @ten = N'Nguyễn Văn B'
set @kh_sdt = '087765473'
exec sp_insertkh @ten, @kh_sdt, @ret output
print @ret

select * from kh
--giải mã dữ liệu
OPEN SYMMETRIC KEY QLBH48K14104
DECRYPTION BY PASSWORD= '@48K141.04'
SELECT KH_ID, KH_TEN, 
		CAST(DECRYPTBYKEY(KH_SDT) AS VARCHAR) AS N'ĐÃ MÃ HÓA'
FROM KH
CLOSE SYMMETRIC KEY QLBH48K14104

----------------------------------------------------------------------------------------------------------------------------------------------
						/* MODULE */

/*	HÀM - Tạo Món ID mới (MON_ID)*/
create or alter function createMONID()
returns varchar(20)
as
begin
	declare @mon_id varchar(20),
			@i varchar(20)
	select @i = max(mon_id) from mon
	if @i is null
		begin
			set @mon_id = '00001'
		end
	else
		begin
			set @mon_id = @i + 1
			set @mon_id = right('00000' + cast(@mon_id as varchar),5)
		end
	return  @mon_id
end
print dbo.createMONID()
select * from MON

/*THỦ TỤC - THÊM MỘT MÓN MỚI*/
create or alter proc addMon @tenmon nvarchar(100),
							@giamon numeric (15,0),
							@ret bit output
as
begin
	declare @monid varchar(20)
	set @monid = dbo.createMONID()
	insert into Mon values (@monid, @tenmon, @giamon)
	if @@ROWCOUNT > 0 set @ret = 1
	else set @ret = 0
end

declare @tenmon nvarchar(100),
		@giamon numeric (15,0),
		@ret bit
set @tenmon = N'Gà sốt cay'
set @giamon = 85000
exec addMon @tenmon, @giamon,@ret output
print @ret
select * from Mon

/* THỦ TỤC - CHỈNH SỬA TÊN MÓN */
create or alter proc chinhsuatenmon  @monid varchar(10),
							@tenmon nvarchar(10), 
							@ret bit output
as
begin
	update mon
	set mon_ten=@tenmon
	where mon_id = @monid

	if @@rowcount>0
		set @ret=1
	else
		set @ret=0
end 

declare @a varchar(10), @b nvarchar(10), @c bit
exec chinhsuatenmon '00001','abc', @c output
print @c
select * from Mon


/* THỦ TỤC - CẬP NHẬT GIÁ MỚI CHO MÓN TRONG MENU */
create or alter proc spUpdateGiaMon @MonID varchar(5), 
									@GiaNew INT,
									@ret bit output 
as
begin
	Update mon
	set mon_gia = @GiaNew
	where mon_id = @MonID
	if @@ROWCOUNT <= 0 
		begin
			set @ret = 0
			return
		end
	set @ret = 1
end
declare @ret bit
exec spUpdateGiaMon '00006', 70000, @ret output
print @ret
select * from mon


/* TRIGGER - THAY VÌ XÓA MÓN, CẬP NHẬT GIÁ MÓN ĐÓ VỀ 0 */
create trigger tgXoamon
on Mon
instead of delete
as
begin
    declare @monid varchar(5)

    -- Lấy món ID từ bảng deleted 
    select @monid = mon_id from deleted

    -- Cập nhật giá món về 0 thay vì xóa món
    update Mon
    set mon_gia = 0
    where mon_id = @monid
end
delete from mon where mon_id = '00005'
select * from mon

/* THỦ TỤC - THÊM MỘT BÀN MỚI - THÊM MỘT BẢN GHI VÀO BẢNG BÀN */
create proc themban @ret bit output
as
begin
	declare @bstt varchar(5)
	select @bstt= max(cast(b_stt as int)) from ban
	if @bstt is null 
		begin
			set @bstt = 1
		end
	else
		begin 
			set @bstt =@bstt + 1
		end
	insert into ban(b_stt) 
    values (@bstt)
	if @@rowcount>0
		set @ret = 1
	else 
		set @ret = 0 	 
end

declare @a bit
exec themban @a output
print @a

select * from BAN


/*HÀM - TẠO THÔNG TIN ĐẶT BÀN ID MỚI (TTDB_ID)*/
create or alter function createTTDBID()
returns varchar(20)
as
begin
	declare @ttdbid varchar(20),
			@i varchar(20)
	select @i = max(ttdb_id) from thongtindatban
	if @i is null
		begin
			set @ttdbid = '0000000001'
		end
	else
		begin
			set @ttdbid = @i + 1
			set @ttdbid = right('00000000000' + cast(@ttdbid as varchar), 10)
		end
	return @ttdbid
end
print dbo.createTTDBID()


/* THỦ TỤC - THÊM MỚI MỘT THÔNG TIN ĐẶT BÀN MỚI*/
create or alter proc addTTDB @bstt int,
							 @khid varchar(20),
							 @gio time,
							 @ngay date,
							 @sl int,
							 @ret bit output
as
begin
	declare @ttdbid varchar(20)
	/*kiểm tra ngày và giờ*/
	if  @ngay < getdate() or 
		(@ngay = getdate() and @gio < cast (getdate() as time)) 
		or @ngay is null or @gio is null
		begin
			set @ret = 0
			return
		end
	/*kiểm tra số lượng*/
	if @sl < 0
		begin
			set @ret = 0
			return
		end
	set @ttdbid = dbo.createTTDBID()
	set @ret = 1
	insert into thongtindatban values (@ttdbid, @bstt, @khid, @gio, @ngay, @sl)
end
select * from thongtindatban
declare @bstt int,
		@khid varchar(20),
		@gio time,
		@ngay date,
		@sl int,
		@ret bit 
set @bstt = 6
set	@khid = '0000000386'
set @gio = '12:30'
set @ngay = '2024-10-21'--ngày trong tương lai
set @sl = 10
exec addTTDB @bstt, @khid, @gio, @ngay, @sl, @ret output
print @ret


/* HÀM - TẠO MỚI MÃ NHÂN VIÊN */
create or alter function NVIDMoi()
returns varchar(20)
as
begin
    declare @nvid varchar(20)
    declare @i varchar(20)
    select @i = max(nv_id) from nhanvien
    if @i is null
    begin
        set @nvid = '00000001'
    end
    else
    begin
        set @nvid = @i + 1
		set @nvid = right('00000000' + cast(@nvid as varchar),8)
    end
    return @nvid
end
select * from nhanvien
select dbo.NVIDMoi() 


/* THỦ TỤC - THÊM MỚI THÔNG TIN NHÂN VIÊN */
create or alter proc themnhanvien   @tennv nvarchar(100),
									@sdt varchar(10),
									@ret bit output
as
begin
	declare @nvid varchar(20)
	set @nvid = dbo.NVIDMoi()
	insert into Nhanvien values (@nvid,@tennv,@sdt)
	if @@ROWCOUNT > 0
		set @ret = 1
	else
		set @ret = 0
end
go

declare @tennv nvarchar(100),@sdt varchar(10),@ret bit 
set @tennv = N'Nguyễn Văn A'
set @sdt = 091422784
exec themnhanvien @tennv,@sdt,@ret out
print @ret
select * from nhanvien


/* HÀM - TẠO MỚI MỘT TÀI KHOẢN ID */
create or alter function ftkid()
returns nvarchar(6)
as
begin
    declare @tk_id varchar(6),
            @i int
    select @i = max(cast(tk_id as int)) from taikhoan
    if @i is null
        set @tk_id = right('000000' + cast(1 as varchar), 6)
    else
        set @tk_id = right('000000' + cast(@i + 1 as varchar), 6)

    return @tk_id
end
select dbo.ftkid()


/* TRIGGER - KHI THÊM MỚI MỘT THÔNG TIN NHÂN VIÊN, HÃY THÊM MỚI TÀI KHOẢN CHO NHÂN VIÊN ĐÓ VỚI TÊN ĐN: SĐT, MK: 0123456*/
create or alter trigger trgafterinsertnhanvien
on nhanvien
after insert
as
begin
    declare @nv_sdt varchar(15),
            @nv_id varchar(20),
            @tk_mk varchar(50), 
			@tk_id varchar(20)
	set @tk_id = dbo.FTKID()
    -- lấy thông tin từ bảng inserted (bảng tạm chứa dữ liệu vừa được thêm vào)
    select @nv_sdt = nv_sdt, @nv_id = nv_id
    from inserted
    -- đặt mật khẩu mặc định
    set @tk_mk = '0123456'
    -- chèn tài khoản mới vào bảng taikhoan
    insert into taikhoan (tk_tendn, tk_mk, nv_id,tk_id)
    values (@nv_sdt, @tk_mk, @nv_id, @tk_id)
end
select * from Nhanvien
select * from taikhoan
insert into nhanvien values ('00002002', 'A', '098378462')


/* HÀM - TẠO MỚI MỘT HÓA ĐƠN ID */
create or alter function FHDID()
returns nvarchar(20)
as
begin
	declare @hd_id varchar(20),
			@i varchar(20)
	select @i = max(right(hd_id,10))from hoadon
	if @i is null
		set @hd_id = 'HD0000000001'
	else
		begin
			select @i = cast(right('00000000000'+ cast(max(right(hd_id,10)) + 1 as varchar),10) as varchar)
			from hoadon
			select @hd_id = 'HD' + cast(@i as varchar)
		end
	return @hd_id
end
print dbo.fhdid()
go


/* THỦ TỤC - THÊM MỚI MỘT HÓA ĐƠN*/
create or alter proc addhoadonnew   @NV_ID varchar(20), 
									@B_STT int, 
									@HD_TONG float,
									@HD_KM float, 
									@ret bit output
as
begin
	declare @hd_id varchar(20), @dh_date date
	set @hd_id= [dbo].[FDID]()
	set @dh_date =GETDATE()
	if not exists (select 1 from Nhanvien where @NV_ID= NV_ID)
		begin
			print N'Không hợp lệ'
			set @ret=0
			rollback
			return
		end
	if not exists (select 1 from BAN where @B_STT=B_STT)
		begin
			print N'Không hợp lệ'
			set @ret=0
			rollback
			return
		end
	insert into Hoadon values(@hd_id, @NV_ID, @B_STT,@dh_date,@HD_TONG, @HD_KM)
	set @ret=1	
end
select *from Hoadon

DECLARE @result BIT;
EXEC addhoadonnew '00000647', 1, 1000000.0, 10.0, @result OUTPUT;
PRINT @result;


/* HÀM - TẠO MỚI MỘT CHI TIẾT HÓA ĐƠN ID CỦA MỘT HÓA ĐƠN */
create or alter function ffcthdid(@hd_id varchar(20))
returns varchar
as
begin
    declare @cthdid varchar(20);
    select @cthdid =cast ( isnull(max(cast(cthd_id as int)), 0) + 1 as varchar )
    from chitiethoadon 
    where hd_id = @hd_id;
    return @cthdid;
end;

declare @hd_id varchar(20) 
set @hd_id = 'hd0000000008'
print dbo.ffcthdid(@hd_id);


/* THỦ TỤC - THÊM MỚI MỘT HÓA ĐƠN CHI TIẾT CỦA MỘT HÓA ĐƠN CỤ THỂ*/
create or alter proc addCTHDnew @hd_id varchar(20), 
								@mon_id varchar(10), 
								@cthd_sl int,
								@ret bit output
as
begin
	declare @cthd_id varchar(20)
	if not exists (select 1 from Hoadon  where @hd_id=HD_ID )
		begin
			print N'Không hợp lệ'
			set @ret=0
			rollback
			return
		end
	if not exists (select 1 from Mon where @mon_id=MON_ID)
		begin
			print N'Không hợp lệ'
			set @ret=0
			rollback
			return
		end
	set @cthd_id=[dbo].[ffcthdid](@hd_id)
	insert into Chitiethoadon values(@cthd_id, @hd_id, @mon_id,@cthd_sl)
	set @ret=1
	
end
DECLARE @ret BIT;
EXEC addCTHDnew @hd_id = 'HD0000000860', @mon_id = '00562', @cthd_sl = 3, @ret = @ret OUTPUT;
PRINT @ret
select * from Chitiethoadon


/* TRIGGER - SAU KHI XÓA MỘT CHI TIẾT HÓA ĐƠN, KIỂM TRA HÓA ĐƠN ĐÓ. 
NẾU SỐ LƯỢNG CTHD CỦA HÓA ĐƠN ĐÓ = 0 THÌ XÓA HÓA ĐƠN ĐÓ KHỎI BẢNG HÓA ĐƠN*/

create or alter trigger XoaCTHD
on Chitiethoadon
after delete
as
begin
	Declare @CTHD_ID varchar(10), @HD_ID varchar(20), @Dem INT
	Select @CTHD_ID = CTHD_ID , @HD_ID = HD_ID
	From deleted
	Select @Dem = Count(CTHD_ID) 
	From Chitiethoadon
	Where HD_ID = @HD_ID
	if @Dem = 0
	begin
		Delete Hoadon
		Where HD_ID = @HD_ID
	end
end

Select * from Chitiethoadon
Select * from Hoadon

Delete From Chitiethoadon
Where CTHD_ID = '00001' and HD_ID = 'HD0000000017'


/* THỦ TỤC - HIỂN THỊ DOANH THU THEO NGÀY */
create or alter proc hienthidoanhthutheongay 
as
begin
	select hd_date as Ngay, sum(hd_tong) as Doanhthu
	from hoadon
	group by hd_date
	order by hd_date desc
end
exec hienthidoanhthutheongay


/* THỦ TỤC - HIỂN THỊ DOANH THU THEO THÁNG */
create or alter proc dttheothang
as
begin
    select month(HD_DATE) as Thang,year(HD_DATE) AS Nam,sum(HD_TONG) as Doanhthu
    from Hoadon
    group by year(HD_DATE),month(HD_DATE)
    order by nam desc, thang asc
end
exec dttheothang


/* THỦ TỤC - HIỂN THỊ DOANH THU THEO NĂM*/
create or alter proc dttheonam
as
begin
    select year(HD_DATE) as Nam,sum(HD_TONG) as Doanhthu
    from Hoadon
    group by year(HD_DATE)
    order by Nam desc
end
exec dttheonam












