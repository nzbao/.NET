-- Bảng Sản phẩm
CREATE TABLE Da_SanPham (
    sMaSP INT PRIMARY KEY,
    sTenSP NVARCHAR(255) NOT NULL,
    sGia DECIMAL(10, 2) NOT NULL,
    sSoluong INT NOT NULL
);

-- Bảng Nhân viên
CREATE TABLE Da_NhanVien (
    sMaNV INT PRIMARY KEY,
    sTenNV NVARCHAR(255) NOT NULL,
    sCCCD NVARCHAR(100) NOT NULL,
    sNgaySinh DATE NOT NULL,
    sSDT NVARCHAR(255) NOT NULL,
    sNgayBatDauLam DATE NOT NULL
);

-- Bảng Khách hàng
CREATE TABLE Da_KhachHang (
    sMaKhachHang INT PRIMARY KEY,
    sTenKhachHang NVARCHAR(255) NOT NULL,
    sSDT NVARCHAR(12) NOT NULL,
    sSoDiem INT NOT NULL
);

-- Bảng Hóa đơn
CREATE TABLE Da_HoaDon (
    sMaHD INT PRIMARY KEY,
    sMaSP INT,
    sSoLuong INT NOT NULL,
    sNgayXuat DATE NOT NULL,
    sMaKhachHang INT,
    sMaNV INT,
    FOREIGN KEY (sMaSP) REFERENCES Da_SanPham(sMaSP),
    FOREIGN KEY (sMaKhachHang) REFERENCES Da_KhachHang(sMaKhachHang),
    FOREIGN KEY (sMaNV) REFERENCES Da_NhanVien(sMaNV)
);

-- Bảng Tài khoản
CREATE TABLE Da_TaiKhoan (
    sTenTK NVARCHAR(50) PRIMARY KEY,
    sMatKhau NVARCHAR(50),
    sChucVu NVARCHAR(50)
);

-- Bảng Báo cáo
CREATE TABLE Da_BaoCao (
    sMaSP INT PRIMARY KEY,
    sTenSP NVARCHAR(255) NOT NULL,
    sSoLuongTon INT NOT NULL,
    sSoLuongDaBan INT NOT NULL,
    sDoanhThu DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (sMaSP) REFERENCES Da_SanPham(sMaSP)
);

-- Bảng Chấm công
CREATE TABLE Da_ChamCong (
    sMaCC INT PRIMARY KEY IDENTITY(1,1),
    sMaNV INT NOT NULL,
    sThoiGianVao DATETIME NOT NULL,
    sThoiGianRa DATETIME NOT NULL,
    FOREIGN KEY (sMaNV) REFERENCES Da_NhanVien(sMaNV)
);

-- Bảng Lương
CREATE TABLE Da_Luong (
    sMaNV INT,
    sThoiGianLam INT NOT NULL,  -- Tổng số giờ làm
    sTienCong INT NOT NULL,      -- Lương theo giờ
    sTongLuong AS (sThoiGianLam * sTienCong) PERSISTED, -- Tổng lương
    FOREIGN KEY (sMaNV) REFERENCES Da_NhanVien(sMaNV)
);

-- Trigger cập nhật và thêm mới vào bảng báo cáo khi thêm hóa đơn
go
CREATE OR ALTER TRIGGER trg_AfterInsert_HoaDon
ON Da_HoaDon
AFTER INSERT
AS
BEGIN
    -- Cập nhật số lượng tồn và doanh thu trong bảng Da_BaoCao
    UPDATE b
    SET b.sSoLuongTon = b.sSoLuongTon - i.sSoLuong,
        b.sDoanhThu = b.sDoanhThu + (SELECT sGia FROM Da_SanPham WHERE sMaSP = i.sMaSP) * i.sSoLuong
    FROM Da_BaoCao b
    INNER JOIN inserted i ON b.sMaSP = i.sMaSP;

    -- Cập nhật số lượng tồn trong bảng Da_SanPham
    UPDATE s
    SET s.sSoluong = s.sSoluong - i.sSoLuong
    FROM Da_SanPham s
    INNER JOIN inserted i ON s.sMaSP = i.sMaSP;

    -- Thêm mới sản phẩm vào bảng báo cáo nếu chưa tồn tại
    INSERT INTO Da_BaoCao (sMaSP, sTenSP, sSoLuongTon, sSoLuongDaBan, sDoanhThu)
    SELECT s.sMaSP, s.sTenSP, s.sSoluong - i.sSoLuong, i.sSoLuong, (SELECT sGia FROM Da_SanPham WHERE sMaSP = i.sMaSP) * i.sSoLuong
    FROM Da_SanPham s
    INNER JOIN inserted i ON s.sMaSP = i.sMaSP
    WHERE NOT EXISTS (SELECT 1 FROM Da_BaoCao b WHERE b.sMaSP = s.sMaSP);
END;

-- Dữ liệu mẫu cho bảng Sản phẩm
INSERT INTO Da_SanPham (sMaSP, sTenSP, sGia, sSoluong) VALUES
(1, N'Sản phẩm A', 100.00, 50),
(2, N'Sản phẩm B', 200.00, 30),
(3, N'Sản phẩm C', 150.00, 20);

-- Dữ liệu mẫu cho bảng Nhân viên
INSERT INTO Da_NhanVien (sMaNV, sTenNV, sCCCD, sNgaySinh, sSDT, sNgayBatDauLam) VALUES
(1, N'Phạm Văn Hoàng', '030204008108', '2004-08-08', '0981015808', '2020-01-01'),
(2, N'Trần Thị B', '000000000002', '1985-05-15', '0987654321', '2019-06-15');

-- Dữ liệu mẫu cho bảng Khách hàng
INSERT INTO Da_KhachHang (sMaKhachHang, sTenKhachHang, sSDT, sSoDiem) VALUES
(1, N'Khách hàng 1', '0981015808', 100),
(2, N'Khách hàng 2', '0876426628', 200);

-- Dữ liệu mẫu cho bảng Hóa đơn
INSERT INTO Da_HoaDon (sMaHD, sMaSP, sSoLuong, sNgayXuat, sMaKhachHang, sMaNV) VALUES
(1, 1, 2, '2024-11-10', 1, 1),
(2, 2, 1, '2024-11-11', 2, 1);

-- Dữ liệu mẫu cho bảng Tài khoản
INSERT INTO Da_TaiKhoan (sTenTK, sMatKhau, sChucVu) VALUES 
('admin', 'admin123', N'Quản trị viên'),
('user1', 'user123', N'Người dùng');

-- Dữ liệu mẫu cho bảng Chấm công
INSERT INTO Da_ChamCong (sMaNV, sThoiGianVao, sThoiGianRa) VALUES 
(1, '2024-11-10 08:00:00', '2024-11-10 17:00:00'),
(2, '2024-11-10 09:00:00', '2024-11-10 18:00:00'),
(2, '2024-12-10 09:00:00', '2024-12-10 18:00:00');

-- Tính lương từ bảng Chấm công
INSERT INTO Da_Luong (sMaNV, sThoiGianLam, sTienCong)
SELECT 
    c.sMaNV,
    SUM(DATEDIFF(HOUR, c.sThoiGianVao, c.sThoiGianRa)) AS sThoiGianLam,
    10000 AS sTienCong -- Example hourly rate
FROM 
    Da_ChamCong c
GROUP BY 
    c.sMaNV;

-- Kiểm tra dữ liệu
	
SELECT * FROM Da_SanPham;
SELECT 
    h.sMaHD,
    h.sMaSP,
    h.sSoLuong,
    s.sGia,
    (h.sSoLuong * s.sGia) AS sTongTien,
	sMaKhachHang,
	sMaNV
FROM 
    Da_HoaDon h
JOIN 
    Da_SanPham s ON h.sMaSP = s.sMaSP;
SELECT * FROM Da_Luong;
SELECT * FROM Da_KhachHang;
SELECT * FROM Da_TaiKhoan;

-- Cleanup: Drop tables and trigger
DROP TRIGGER IF EXISTS trg_AfterInsert_HoaDon;

-- Drop tables in reverse order of dependency
DROP TABLE IF EXISTS Da_ChamCong;
DROP TABLE IF EXISTS Da_Luong;
DROP TABLE IF EXISTS Da_BaoCao;
DROP TABLE IF EXISTS Da_HoaDon;
DROP TABLE IF EXISTS Da_TaiKhoan;
DROP TABLE IF EXISTS Da_KhachHang;
DROP TABLE IF EXISTS Da_NhanVien;
DROP TABLE IF EXISTS Da_SanPham;