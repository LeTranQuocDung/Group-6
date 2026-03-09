Ok 👍 giờ mình hướng dẫn bạn cách tạo Simulator đúng chuẩn cho web kiểu Shopee mini của bạn (Java Servlet + DAO + Service).
Mình sẽ giải thích theo 3 mức:
Simulator để tạo dữ liệu ảo (seed data)
Simulator để giả lập mua hàng
Simulator để stress test hệ thống
🔥 1️⃣ Simulator tạo dữ liệu ảo (Data Generator)
Đây là loại dễ nhất.
Bước 1: Tạo class DataGenerator
package service;

import java.util.Random;
import dal.ProductDAO;
import model.Product;

public class DataGenerator {

    private Random rand = new Random();

    public void generateProducts(int amount) {
        ProductDAO dao = new ProductDAO();

        for (int i = 1; i <= amount; i++) {
            Product p = new Product();
            p.setName("Product " + i);
            p.setPrice(rand.nextInt(1000) + 100);
            dao.insertProduct(p);
        }
    }
}
👉 Nó tạo sản phẩm giả và insert vào DB.
Bước 2: Tạo MigrationService
package service;

import dal.ProductDAO;

public class MigrationService {

    public String startMigration() {
        ProductDAO dao = new ProductDAO();
        
        dao.deleteAll(); // xóa dữ liệu cũ
        
        DataGenerator gen = new DataGenerator();
        gen.generateProducts(100);

        return "Generated 100 products successfully!";
    }
}
👉 Reset DB và tạo lại dữ liệu mới.
Bước 3: Gọi từ Servlet
Trong AdminImportServlet:
MigrationService service = new MigrationService();
String logs = service.startMigration();
request.setAttribute("logs", logs);
🛒 2️⃣ Simulator giả lập mua hàng
Ví dụ bạn muốn tạo 200 đơn hàng tự động:
public void simulateOrders(int amount) {
    OrderDAO dao = new OrderDAO();
    Random rand = new Random();

    for (int i = 0; i < amount; i++) {
        int userId = rand.nextInt(50) + 1;
        int productId = rand.nextInt(100) + 1;

        dao.insertOrder(userId, productId);
    }
}
👉 Giống như 200 người mua hàng giả.
💥 3️⃣ Stress Test Simulator (nâng cao)
Ví dụ tạo nhiều thread để test tải:
for (int i = 0; i < 50; i++) {
    new Thread(() -> {
        simulateOrders(100);
    }).start();
}
👉 50 luồng chạy cùng lúc.
👉 Test DB có chịu nổi không.
🎯 4️⃣ Quy trình hoạt động của Simulator
Khi admin bấm:
/admin-import
Luồng chạy:
AdminImportServlet
   ↓
MigrationService
   ↓
DataGenerator
   ↓
DAO
   ↓
Database
🧠 5️⃣ Vì sao phải tạo Simulator?
Vì:
Database ban đầu trống
Cần dữ liệu để demo
Cần test performance
Cần test tính toàn vẹn dữ liệu
