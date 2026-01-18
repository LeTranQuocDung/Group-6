1. NHÓM TÍNH NĂNG KỸ THUẬT CỐT LÕI (CORE TECHNICAL - BẮT BUỘC)
Đây là nhóm tính năng "xương sống" để vận hành dự án và đáp ứng yêu cầu kỹ thuật của môn học.

1.1. Import & Data Cleaning (Chuyển đổi dữ liệu hệ thống cũ)
Mô tả: Hệ thống cho phép Admin tải lên các file CSV chứa dữ liệu lớn (10.000+ bản ghi) từ hệ thống Legacy.

Yêu cầu xử lý sâu:

Phát hiện lỗi định dạng: Tự động nhận diện các trường hợp sai chuẩn như giá tiền chứa ký tự lạ (VD: "150k" -> convert thành 150000), định dạng ngày tháng sai, hoặc thiếu thông tin bắt buộc.

Cơ chế Tự sửa lỗi (Auto-Correction): Thay vì từ chối toàn bộ file, hệ thống áp dụng thuật toán để sửa các lỗi phổ biến (VD: Tồn kho "Out of Stock" -> set về 0) và ghi log lại các dòng đã sửa.

Báo cáo Import: Hiển thị Dashboard thống kê: Số dòng thành công, Số dòng được làm sạch, Số dòng thất bại.

1.2. High Concurrency Simulator (Giả lập giao dịch Real-time)
Mô tả: Module chạy nền (Background Service) giả lập bối cảnh hàng nghìn người dùng truy cập cùng lúc.

Yêu cầu xử lý sâu:

Bot Order Generation: Tự động sinh đơn hàng ngẫu nhiên (Random User, Random Product) với tần suất cao (ví dụ: 10 đơn/giây).

Stress Test Database: Kiểm thử khả năng chịu tải của Database khi có nhiều luồng (Threads) cùng trừ tồn kho một lúc.

Real-time Dashboard: Cập nhật doanh thu và biến động kho hàng theo thời gian thực trên giao diện Admin mà không cần reload trang.

2. NHÓM TÍNH NĂNG NGHIỆP VỤ (BUSINESS FEATURES - ĐIỂM 10)
Đây là nhóm tính năng thể hiện độ phức tạp nghiệp vụ, sử dụng AI để thiết kế Logic.

2.1. Hệ thống Khuyến mãi Đa tầng (Advanced Promotion Engine)
Mô tả: Không chỉ là giảm giá đơn thuần, hệ thống hỗ trợ cơ chế "Voucher Stacking" (Áp dụng chồng chéo) phức tạp như Shopee.

Phân tích chi tiết:

Thời hạn & Vòng đời: Voucher có Start Date và End Date. Hệ thống phải tự động vô hiệu hóa mã khi hết hạn hoặc chưa đến giờ kích hoạt.

Quota (Giới hạn số lượng):

Global Limit: Tổng cộng chỉ có 1000 mã toàn sàn.

User Limit: Mỗi khách hàng chỉ được dùng tối đa 1 lần.

Điều kiện áp dụng (Constraints):

Min Spend: Đơn hàng phải từ 200k trở lên mới được dùng.

Discount Cap (Trần giảm giá): Giảm 10% nhưng tối đa không quá 50k (để tránh lỗ vốn với đơn hàng trị giá quá cao).

Targeting (Phân khúc): Mã chỉ dành riêng cho khách hàng mới (New User) hoặc khách hàng thân thiết (VIP).

2.2. Giỏ hàng Thông minh (Smart Cart Logic)
Mô tả: Giỏ hàng đóng vai trò là bộ đệm kiểm tra tính toàn vẹn của giao dịch trước khi thanh toán.

Phân tích chi tiết:

Shop Grouping: Tự động gom nhóm các sản phẩm thuộc cùng một Shop để tính phí vận chuyển riêng biệt cho từng gói hàng.

Real-time Validation (Kiểm tra lại giá & Kho):

Kịch bản: Khách thêm sản phẩm vào giỏ lúc giá 100k. Hai ngày sau quay lại thanh toán, giá đã tăng lên 120k hoặc hết hàng.

Xử lý: Hệ thống phải tự động phát hiện sự thay đổi, cập nhật giá mới trong giỏ và hiển thị cảnh báo: "Giá sản phẩm đã thay đổi, vui lòng kiểm tra lại".

Stock Reservation (Giữ chỗ tạm thời): Khi khách bấm "Thanh toán", hệ thống tạm giữ tồn kho trong 10 phút. Nếu không thanh toán xong, nhả tồn kho ra lại.

2.3. Quản lý Sản phẩm Đa biến thể (SKU Management)
Mô tả: Xử lý cấu trúc sản phẩm phức tạp (1 Sản phẩm cha -> Nhiều biến thể con).

Phân tích chi tiết:

SKU (Stock Keeping Unit): Mỗi biến thể (VD: Áo Đỏ - Size M) là một SKU riêng biệt với Giá tiền riêng và Tồn kho riêng.

Logic hiển thị: Khi khách chọn "Màu Đỏ", hệ thống chỉ cho phép chọn các Size còn hàng tương ứng với màu đỏ đó (Disable các size hết hàng).

2.4. Sự kiện Flash Sale (Concurrency Control)
Mô tả: Bán sản phẩm giới hạn trong khung giờ vàng với lượng truy cập đột biến.

Phân tích chi tiết:

Countdown Timer: Đồng hồ đếm ngược đồng bộ server-side.

Chống Bán lố (Overselling Prevention): Sử dụng Database Transaction hoặc Optimistic Locking để đảm bảo nếu kho còn 1 cái, 100 người bấm mua cùng lúc thì chỉ 1 người thành công, 99 người còn lại nhận thông báo "Hết hàng".
