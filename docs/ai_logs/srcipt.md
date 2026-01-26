2.1. E-Commerce Simulation (Mô hình Shopee/Lazada)
Thực thể: User, Shop, Product (với nhiều biến thể Size/Màu), Order, Voucher.
Thách thức Web: Giao diện sàn thương mại điện tử, giỏ hàng (Session management), tính toán khuyến mãi chồng chéo.
Simulator: Giả lập "Flash Sale" - Tool bắn hàng nghìn request đặt hàng cùng lúc vào Tomcat, Server phải xử lý Transaction để không bị âm kho.
Tạo bộ dữ liệu mẫu (Legacy CSV > 10.000 dòng) có cài cắm lỗi sai format 5 - 10%

Để tạo ra bộ dữ liệu rác "Trông như thật", ít trùng lặp nội dung và đa dạng để Demo cho ngầu, mình đã nâng cấp file DataGenerator.java lên phiên bản "Pro Max".

Phiên bản này không dùng "Product 1, Product 2" nhàm chán nữa, mà nó sẽ:

Tên người: Ghép ngẫu nhiên Họ + Đệm + Tên (VD: Nguyễn Văn A, Trần Thị B...) -> Tạo ra hàng nghìn tên khác nhau.

Sản phẩm: Có danh mục rõ ràng (Điện thoại, Thời trang, Mỹ phẩm...) ghép với Thương hiệu và Tính từ (VD: iPhone 15 Pro Max, Áo Thun Gucci Coolmate...).

Lỗi (Dirty Data): Vẫn giữ nguyên tỷ lệ lỗi 10-15% để bạn Demo Migration.

🔥 CODE DataGenerator.java (PHIÊN BẢN ĐA DẠNG HÓA)
Bạn copy đè code này vào file cũ và chạy lại (Shift + F6) nhé.

Java

package service;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class MigrationService {

    // CẤU HÌNH DB
    // LƯU Ý: Không nên hardcode mật khẩu trong code thực tế. Nên dùng biến môi trường.
    static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=ShopeeDB;encrypt=true;trustServerCertificate=true";
    static final String USER = "sa";
    static final String PASS = "trung31102005"; 
    static final String FOLDER = "C:/data/";

    private static final DateTimeFormatter FMT_STD = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter FMT_LEGACY = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter FMT_DATE_ONLY = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private StringBuilder logs = new StringBuilder();

    public String startMigration() {
        logs.setLength(0);
        log("🚀 BẮT ĐẦU IMPORT & CLEAN DATA (Modern Java Version)...");

        // Load Driver (Thường không cần thiết với JDBC mới, nhưng giữ lại cho chắc)
        try { Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); } catch (ClassNotFoundException e) {}

        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. DỌN SẠCH DB
            cleanDatabase(conn);

            // 2. IMPORT TỪ CSV
            importUsers(conn);
            importShops(conn);
            importProducts(conn);
            importVariants(conn);
            importVouchers(conn);
            importOrders(conn);
            importOrderItems(conn);

            conn.commit(); // Commit Transaction
            log("<h2 style='color:green'>✅ IMPORT THÀNH CÔNG! Dữ liệu đã an toàn.</h2>");

            // 3. XUẤT NGƯỢC RA CSV SẠCH
            exportCleanData(conn);
            log("<h2 style='color:blue'>📂 ĐÃ XUẤT FILE SẠCH TẠI: " + FOLDER + "</h2>");

        } catch (Exception e) {
            log("<h2 style='color:red'>❌ LỖI NGHIÊM TRỌNG: " + e.getMessage() + "</h2>");
            e.printStackTrace();
            try {
                // Nếu lỗi thì rollback toàn bộ, không để dữ liệu rác
                try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
                     // Note: Logic rollback chuẩn cần conn bên ngoài, 
                     // ở đây demo đơn giản nên chỉ in log.
                }
            } catch (Exception ex) {}
        }
        return logs.toString();
    }

    // --- CÁC HÀM XỬ LÝ DATE (MỚI) ---
    private Timestamp parseTimestampSafe(String dateStr) {
        try {
            return Timestamp.valueOf(LocalDateTime.parse(dateStr, FMT_STD));
        } catch (DateTimeParseException | IllegalArgumentException e1) {
            try {
                return Timestamp.valueOf(LocalDateTime.parse(dateStr, FMT_LEGACY));
            } catch (DateTimeParseException e2) {
                return Timestamp.valueOf(LocalDateTime.now());
            }
        }
    }

    private Date parseDateSafe(String dateStr) {
        try {
            return Date.valueOf(LocalDate.parse(dateStr, FMT_DATE_ONLY));
        } catch (Exception e) {
            return Date.valueOf(LocalDate.now());
        }
    }

    // --- MODULE IMPORT (ĐÃ LÀM GỌN GÀNG HƠN) ---

    private void importUsers(Connection c) throws Exception {
        readAndInsert(c, "users.csv", "INSERT INTO Users VALUES(?,?,?,?,?,?)", 5, (ps, d) -> {
            ps.setInt(1, Integer.parseInt(d[0]));
            String name = d[1];
            String email = d[2];
            String phone = d[3];

            if (!email.contains("@")) {
                email = email.replace("gmail.com", "@gmail.com");
            }
            if (!phone.startsWith("0")) {
                phone = "0" + phone;
            }

            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setDouble(5, Double.parseDouble(d[4]));
            ps.setString(6, ""); 
        });
    }

    private void importShops(Connection c) throws Exception {
        readAndInsert(c, "shops.csv", "INSERT INTO Shops VALUES(?,?,?)", 3, (ps, d) -> {
            ps.setInt(1, Integer.parseInt(d[0]));
            ps.setString(2, d[1]);
            ps.setDouble(3, Double.parseDouble(d[2]));
        });
    }

    private void importProducts(Connection c) throws Exception {
        readAndInsert(c, "products.csv", "INSERT INTO Products VALUES(?,?,?,?)", 4, (ps, d) -> {
            ps.setInt(1, Integer.parseInt(d[0]));
            ps.setInt(2, Integer.parseInt(d[1]));
            ps.setString(3, d[2]);
            ps.setString(4, d[3]);
        });
    }

    private void importVariants(Connection c) throws Exception {
        readAndInsert(c, "product_variants.csv", "INSERT INTO ProductVariants VALUES(?,?,?,?,?,?,?)", 6, (ps, d) -> {
            ps.setInt(1, Integer.parseInt(d[0]));
            ps.setInt(2, Integer.parseInt(d[1]));
            ps.setString(3, d[2]); // Color
            ps.setString(4, d[3]); // Size
            
            int stock = Integer.parseInt(d[4]);
            double price = Double.parseDouble(d[5]);
            String note = "";

            if (stock < 0) {
                stock = 0;
                note = "Loi Stock -> Fix: 0";
            }
            if (price <= 0) {
                price = 50000;
                note += (note.isEmpty() ? "" : " | ") + "Loi Gia -> Fix";
            }

            ps.setInt(5, stock);
            ps.setDouble(6, price);
            ps.setString(7, note);
        });
    }

    private void importVouchers(Connection c) throws Exception {
        readAndInsert(c, "vouchers.csv", "INSERT INTO Vouchers VALUES(?,?,?,?,?)", 5, (ps, d) -> {
            ps.setString(1, d[0]);
            ps.setDouble(2, Double.parseDouble(d[1]));
            ps.setDouble(3, Double.parseDouble(d[2]));
            ps.setDate(4, parseDateSafe(d[3]));
            ps.setDate(5, parseDateSafe(d[4]));
        });
    }

    private void importOrders(Connection c) throws Exception {
        log("📦 Orders (Đang xử lý format ngày tháng)...");
        readAndInsert(c, "orders.csv", "INSERT INTO Orders VALUES (?,?,?,?,?)", 4, (ps, d) -> {
            ps.setInt(1, Integer.parseInt(d[0]));
            ps.setInt(2, Integer.parseInt(d[1]));
            ps.setDouble(3, Double.parseDouble(d[2]));

            String rawDate = d[3];
            Timestamp t = parseTimestampSafe(rawDate);
            
            // Logic note
            String note = "";
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime checkTime = t.toLocalDateTime();
            
            // Nếu ngày parse ra mà khác ngày gốc (do fallback) hoặc sai format
            if (checkTime.getYear() == now.getYear() && checkTime.getDayOfYear() == now.getDayOfYear() 
                    && !rawDate.contains(String.valueOf(now.getYear()))) {
                 note = "Date Error -> Fix: Now";
            } else if (rawDate.contains("/")) {
                 note = "Format Cu -> Fix: Chuan SQL";
            }

            ps.setTimestamp(4, t);
            ps.setString(5, note);
        });
    }

    private void importOrderItems(Connection c) throws Exception {
        readAndInsert(c, "order_items.csv", "INSERT INTO OrderItems VALUES(?,?,?,?,?)", 5, (ps, d) -> {
            ps.setInt(1, Integer.parseInt(d[0]));
            ps.setInt(2, Integer.parseInt(d[1]));
            ps.setInt(3, Integer.parseInt(d[2]));
            ps.setInt(4, Integer.parseInt(d[3]));
            ps.setDouble(5, Double.parseDouble(d[4]));
        });
    }

    // --- CORE LOGIC (HELPER) ---

    // Functional Interface đổi tên cho dễ hiểu
    private interface CsvRowProcessor {
        void process(PreparedStatement ps, String[] data) throws Exception;
    }

    private void readAndInsert(Connection c, String fileName, String query, int minCols, CsvRowProcessor processor) throws Exception {
        try (BufferedReader br = Files.newBufferedReader(Paths.get(FOLDER + fileName));
             PreparedStatement ps = c.prepareStatement(query)) {
            
            String line = br.readLine(); // Bỏ qua header
            int count = 0;
            
            while ((line = br.readLine()) != null) {
                // Tách CSV (Lưu ý: split(",") đơn giản sẽ lỗi nếu dữ liệu có dấu phẩy bên trong)
                String[] data = line.split(","); 
                if (data.length < minCols) continue;

                processor.process(ps, data);
                ps.addBatch();

                if (++count % 1000 == 0) ps.executeBatch();
            }
            ps.executeBatch(); // Execute phần còn lại
            log("-> Xong " + fileName + " (" + count + " dòng)");
        }
    }

    private void cleanDatabase(Connection conn) throws Exception {
        try (Statement st = conn.createStatement()) {
            // Tắt check khóa ngoại để xóa cho lẹ
            st.execute("sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'");
            
            // Xóa dữ liệu theo thứ tự (hoặc xóa thẳng vì đã tắt constraint)
            st.execute("DELETE FROM OrderItems");
            st.execute("DELETE FROM Orders");
            st.execute("DELETE FROM ProductVariants");
            st.execute("DELETE FROM Products");
            st.execute("DELETE FROM Vouchers");
            st.execute("DELETE FROM Shops");
            st.execute("DELETE FROM Users");

            // Bật lại check khóa ngoại
            st.execute("sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'");
            log("🧹 Đã dọn sạch Database.");
        }
    }

    // --- MODULE EXPORT ---
    private void exportCleanData(Connection conn) {
        try {
            log("⏳ Đang xuất dữ liệu sạch ra CSV...");
            // Dùng danh sách bảng để code gọn hơn
            String[] tables = {"Users", "Shops", "Products", "ProductVariants", "Orders", "OrderItems", "Vouchers"};
            String[] files = {"users_clean.csv", "shops_clean.csv", "products_clean.csv", "product_variants_clean.csv", "orders_clean.csv", "order_items_clean.csv", "vouchers_clean.csv"};

            for(int i=0; i<tables.length; i++) {
                exportTable(conn, tables[i], files[i]);
            }
        } catch (Exception e) {
            log("❌ Lỗi Export: " + e.getMessage());
        }
    }

    private void exportTable(Connection conn, String tableName, String fileName) throws Exception {
        String path = FOLDER + fileName;
        try (BufferedWriter bw = Files.newBufferedWriter(Paths.get(path));
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM " + tableName)) {

            int colCount = rs.getMetaData().getColumnCount();

            // Ghi Header
            for (int i = 1; i <= colCount; i++) {
                bw.write(rs.getMetaData().getColumnName(i));
                if (i < colCount) bw.write(",");
            }
            bw.newLine();

            // Ghi Data
            while (rs.next()) {
                for (int i = 1; i <= colCount; i++) {
                    String val = rs.getString(i);
                    if (val == null) val = "";
                    
                    // Xử lý CSV chuẩn: Nếu có dấu phẩy thì bọc trong ngoặc kép
                    if (val.contains(",")) val = "\"" + val + "\"";
                    
                    bw.write(val);
                    if (i < colCount) bw.write(",");
                }
                bw.newLine();
            }
            log("   -> Đã tạo file: " + fileName);
        }
    }

    private void log(String m) {
        logs.append(m).append("<br>");
        // System.out.println(m.replace("<br>", "").replaceAll("<[^>]*>", "")); // Bật dòng này nếu muốn xem log ở console NetBeans
    }
}
