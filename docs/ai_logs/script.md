2.1. E-Commerce Simulation (Mô hình Shopee/Lazada)



Thực thể: User, Shop, Product (với nhiều biến thể Size/Màu), Order, Voucher.



Thách thức: Xử lý giỏ hàng, tính toán khuyến mãi chồng chéo, logic tồn kho biến thể.



Simulator: Giả lập "Flash Sale" - hàng nghìn user cùng đặt hàng một lúc, hệ thống phải trừ kho chính xác.



Chào bạn, chúng ta sẽ bắt đầu lại từ đầu với chủ đề E-Commerce Simulation này. Đây là đề tài khó nhất nhưng cũng dễ lấy điểm tuyệt đối nhất nếu bạn làm rõ được phần "Biến thể (Variants)" và "Flash Sale".



Dưới đây là quy trình thực hiện trọn gói: Từ thiết kế Database chuẩn đến Code giả lập Flash Sale.



1\. Thiết kế Database (Giải quyết bài toán Biến thể)

Sai lầm lớn nhất của sinh viên là để cột Quantity (Số lượng) ở bảng Product. Thực tế: Áo thun (Product) có thể còn màu Đỏ nhưng hết màu Xanh. => Giải pháp: Tách thành 2 bảng Products (thông tin chung) và Product\_Variants (thông tin SKU cụ thể).



Cấu trúc các file CSV cần tạo:



shops.csv: ID, Tên Shop, Đánh giá.



users.csv: ID, Tên, Ví tiền.



products.csv: ID, Tên chung (VD: iPhone 15), Mô tả.



product\_variants.csv: Variant\_ID, Product\_ID, Màu, Size, Tồn kho (Stock), Giá.



vouchers.csv: Mã, Loại (Giảm tiền/%, Freeship), Điều kiện (Đơn tối thiểu).



orders.csv: ID đơn, User mua, Tổng tiền, Thời gian.



order\_items.csv: ID chi tiết, Order\_ID, Variant\_ID (Link vào biến thể), Số lượng.



2\. Chiến thuật giả lập "Flash Sale" (Simulator Strategy)

Để giả lập Flash Sale trong code sinh dữ liệu, chúng ta không random lung tung. Chúng ta sẽ tạo kịch bản:



Kịch bản: Shop A mở bán "iPhone 15 Pro Max - Titan Tự Nhiên" giá sốc.



Kho: Chỉ có 50 cái.



Người mua: 1.000 người cùng lao vào đặt lệnh.



Kết quả mong đợi: 50 đơn hàng thành công, 950 đơn hàng bị hủy hoặc báo lỗi "Hết hàng".



3\. Code Java Triển khai (Full Script)

Bạn tạo một file Java mới tên EcommerceSimulator.java. Code này sẽ sinh ra bộ dữ liệu >10.000 dòng thể hiện đúng kịch bản trên.



Java

import java.io.BufferedWriter;

import java.io.FileOutputStream;

import java.io.OutputStreamWriter;

import java.io.IOException;

import java.nio.charset.StandardCharsets;

import java.util.\*;



public class EcommerceSimulator {



    // Cấu hình số lượng

    static final int NUM\_USERS = 2000;      // 2000 người dùng tham gia

    static final int NUM\_SHOPS = 50;        // 50 Shop

    static final int NUM\_PRODUCTS = 200;    // 200 Sản phẩm gốc

 

    // List lưu trữ ID để tạo quan hệ

    static List<String> userIds = new ArrayList<>();

    static List<String> shopIds = new ArrayList<>();

    static List<String> productIds = new ArrayList<>();

    static List<String> variantIds = new ArrayList<>();

 

    // Map giả lập kho hàng realtime cho Flash Sale (VariantID -> Stock)

    static Map<String, Integer> inventoryMap = new HashMap<>();



    static Random random = new Random();



    public static void main(String\[] args) {

        System.out.println("🚀 Bắt đầu giả lập hệ thống E-Commerce...");



        // 1. Tạo dữ liệu nền (Master Data)

        generateUsers();

        generateShops();

        generateProductsAndVariants(); // Quan trọng: Tạo hàng hóa \& Kho

        generateVouchers();



        // 2. GIẢ LẬP FLASH SALE (Transaction Data)

        // Đây là phần "Ăn điểm": Hàng nghìn người tranh nhau mua

        simulateFlashSale();



        System.out.println("✅ HOÀN TẤT! Dữ liệu đã được xuất ra file CSV.");

    }



    // --- CÁC HÀM SINH DỮ LIỆU NỀN ---



    static void generateUsers() {

        try (BufferedWriter writer = createWriter("users.csv")) {

            writer.write("user\_id,username,email,phone\\n");

            for (int i = 1; i <= NUM\_USERS; i++) {

                String id = "U" + i;

                userIds.add(id);

                writer.write(id + ",user" + i + ",user" + i + "@mail.com,090" + i + "\\n");

            }

            System.out.println("-> Đã tạo " + NUM\_USERS + " Users.");

        } catch (IOException e) { e.printStackTrace(); }

    }



    static void generateShops() {

        try (BufferedWriter writer = createWriter("shops.csv")) {

            writer.write("shop\_id,shop\_name,rating\\n");

            for (int i = 1; i <= NUM\_SHOPS; i++) {

                String id = "S" + i;

                shopIds.add(id);

                writer.write(id + ",Shop Official " + i + "," + (3 + random.nextDouble() \* 2) + "\\n");

            }

        } catch (IOException e) { e.printStackTrace(); }

    }



    static void generateProductsAndVariants() {

        try (BufferedWriter pWriter = createWriter("products.csv");

             BufferedWriter vWriter = createWriter("product\_variants.csv")) {

 

            pWriter.write("product\_id,shop\_id,product\_name,description\\n");

            vWriter.write("variant\_id,product\_id,color,size,price,stock\_qty\\n");



            int vCount = 1;

            String\[] products = {"iPhone 15", "Samsung S24", "Áo Hoodie", "Giày Nike", "Son Mac"};

            String\[] colors = {"Đen", "Trắng", "Titan", "Hồng", "Xanh"};

            String\[] sizes = {"S", "M", "L", "XL", "256GB", "512GB"};



            for (int i = 1; i <= NUM\_PRODUCTS; i++) {

                String pId = "P" + i;

                productIds.add(pId);

                String sId = shopIds.get(random.nextInt(shopIds.size()));

                String pName = products\[random.nextInt(products.length)] + " " + i;



                pWriter.write(pId + "," + sId + "," + pName + ",Mô tả sản phẩm xịn\\n");



                // Tạo biến thể (Variants) cho mỗi sản phẩm

                int numVars = 3 + random.nextInt(3); // Mỗi SP có 3-5 biến thể

                for (int j = 0; j < numVars; j++) {

                    String vId = "V" + vCount++;

                    variantIds.add(vId);

 

                    String color = colors\[random.nextInt(colors.length)];

                    String size = sizes\[random.nextInt(sizes.length)];

                    double price = 100000 + random.nextInt(2000000);

                    int stock = random.nextInt(100); // Kho ngẫu nhiên



                    // Lưu vào Map để lát nữa giả lập trừ kho Flash Sale

                    inventoryMap.put(vId, stock);



                    vWriter.write(vId + "," + pId + "," + color + "," + size + "," + String.format("%.0f", price) + "," + stock + "\\n");

                }

            }

            System.out.println("-> Đã tạo Products \& Variants (Logic tồn kho tách biệt).");

        } catch (IOException e) { e.printStackTrace(); }

    }

 

    static void generateVouchers() {

        try (BufferedWriter writer = createWriter("vouchers.csv")) {

            writer.write("voucher\_id,code,discount\_percent,min\_order\\n");

            for(int i=1; i<=20; i++) {

                writer.write("VC"+i + ",SALE"+i + "," + (5+random.nextInt(20)) + "," + (100000\*i) + "\\n");

            }

        } catch (IOException e) { e.printStackTrace(); }

    }



    // --- PHẦN QUAN TRỌNG: GIẢ LẬP FLASH SALE ---

    static void generateOrders\_SimulateFlashSale() {

        // Tên hàm cũ, đổi tên lại cho đúng logic bên dưới

    }



    static void simulateFlashSale() {

        System.out.println("⚡ ĐANG GIẢ LẬP FLASH SALE: 1000 người cùng tranh mua 1 sản phẩm HOT...");

 

        try (BufferedWriter oWriter = createWriter("orders.csv");

             BufferedWriter oiWriter = createWriter("order\_items.csv")) {

 

            oWriter.write("order\_id,user\_id,total\_amount,status,order\_time\\n");

            oiWriter.write("item\_id,order\_id,variant\_id,quantity,price\\n");



            // Kịch bản: Chọn 1 sản phẩm HOT nhất để làm Flash Sale

            String hotVariantId = variantIds.get(0); // Lấy biến thể đầu tiên

            int initialStock = inventoryMap.get(hotVariantId);

            System.out.println("   Mặt hàng HOT: " + hotVariantId + " | Tồn kho ban đầu: " + initialStock);



            int orderCount = 1;

            int orderItemCount = 1;



            // 1500 lượt request mua hàng dồn dập

            for (int i = 0; i < 1500; i++) {

                String userId = userIds.get(random.nextInt(userIds.size()));

                int qtyBuy = 1; // Mỗi người mua 1 cái



                // LOGIC KIỂM TRA TỒN KHO (Concurrency Simulation Logic)

                String status;

                synchronized (inventoryMap) { // Giả lập khóa (lock) kho hàng

                    int currentStock = inventoryMap.getOrDefault(hotVariantId, 0);

 

                    if (currentStock >= qtyBuy) {

                        // Còn hàng -> Trừ kho -> Tạo đơn thành công

                        inventoryMap.put(hotVariantId, currentStock - qtyBuy);

                        status = "Completed";

                    } else {

                        // Hết hàng -> Đơn bị hủy

                        status = "Cancelled (Out of Stock)";

                    }

                }



                // Ghi log đơn hàng

                String orderId = "OD" + orderCount++;

                oWriter.write(orderId + "," + userId + ",1000000," + status + ",2024-06-06 12:00:00\\n");



                // Nếu thành công thì ghi chi tiết đơn hàng

                if (status.equals("Completed")) {

                    oiWriter.write("IT" + orderItemCount++ + "," + orderId + "," + hotVariantId + "," + qtyBuy + ",1000000\\n");

                }

            }

 

            System.out.println("   Kết quả Flash Sale: Kho còn lại = " + inventoryMap.get(hotVariantId));

 

            // Tạo thêm các đơn hàng lẻ tẻ khác cho đủ 10.000 dòng

            System.out.println("⚡ Đang tạo thêm các đơn hàng thường cho đủ KPI...");

            for(int i=0; i<8500; i++) {

                 String userId = userIds.get(random.nextInt(userIds.size()));

                 String randVid = variantIds.get(random.nextInt(variantIds.size()));

                 String oId = "OD\_REG\_" + i;

                 oWriter.write(oId + "," + userId + ",500000,Completed,2024-06-07\\n");

                 oiWriter.write("IT\_REG\_" + i + "," + oId + "," + randVid + ",1,500000\\n");

            }



        } catch (IOException e) { e.printStackTrace(); }

    }



    // Tiện ích ghi file

    static BufferedWriter createWriter(String fileName) throws IOException {

        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName), StandardCharsets.UTF\_8));

        writer.write("\\uFEFF"); // BOM

        return writer;

    }

}



tạo bộ dữ liệu mẫu legacy data bằng script >10000 dòng cố tình cài cắm lỗi sai format



Đây là một chiến lược rất thông minh để "ghi điểm" trong mắt giảng viên. Việc có một bộ dữ liệu "Legacy" (Dữ liệu cũ từ hệ thống khác) đầy lỗi giúp bạn chứng minh được tính năng Data Cleaning (Làm sạch dữ liệu) hoặc ETL (Extract - Transform - Load) của hệ thống mới.



Dưới đây là script Java để sinh ra file legacy\_products\_raw.csv gồm 12.500 dòng, trong đó chứa khoảng 20% dữ liệu bị lỗi format (giá dính chữ, ngày tháng sai, null, trùng lặp...).



1\. Code Sinh Dữ Liệu "Bẩn" (LegacyDataGenerator.java)

Bạn tạo file LegacyDataGenerator.java và chạy code sau:



Java

import java.io.BufferedWriter;

import java.io.FileOutputStream;

import java.io.IOException;

import java.io.OutputStreamWriter;

import java.nio.charset.StandardCharsets;

import java.util.Random;



public class LegacyDataGenerator {



    public static void main(String\[] args) {

        String fileName = "legacy\_products\_raw.csv";

        int totalRows = 12500; // > 10.000 dòng theo yêu cầu



        // Dữ liệu mẫu để ghép tên

        String\[] brands = {"Samsung", "Apple", "Xiaomi", "Oppo", "Sony", "LG", "Nokia"};

        String\[] types = {"Dien thoai", "May tinh bang", "Tai nghe", "Sac du phong", "Op lung"};

        String\[] statusList = {"New", "Old", "Refurbished", "Unknown"};



        try (BufferedWriter writer = new BufferedWriter(

                new OutputStreamWriter(new FileOutputStream(fileName), StandardCharsets.UTF\_8))) {



            // 1. Ghi BOM để mở Excel không lỗi font

            writer.write("\\uFEFF");



            // 2. Header kiểu cũ (Viết hoa, không chuẩn convention)

            writer.write("PROD\_ID,PROD\_NAME,PRICE\_RAW,STOCK\_QTY,IMPORT\_DATE,STATUS,NOTE\\n");



            Random random = new Random();



            for (int i = 1; i <= totalRows; i++) {

                boolean isErrorRow = random.nextInt(100) < 20; // 20% dòng sẽ bị lỗi format



                // --- A. Tạo dữ liệu chuẩn trước ---

                String id = String.valueOf(1000 + i);

                String name = types\[random.nextInt(types.length)] + " " + brands\[random.nextInt(brands.length)] + " " + i;

 

                double realPrice = 100000 + random.nextInt(9000000);

                String priceStr = String.format("%.0f", realPrice); // Giá chuẩn: 150000

 

                int realStock = random.nextInt(500);

                String stockStr = String.valueOf(realStock); // Tồn kho chuẩn: 50

 

                // Ngày chuẩn: YYYY-MM-DD

                String dateStr = "2023-" + (1 + random.nextInt(12)) + "-" + (1 + random.nextInt(28));

                String status = statusList\[random.nextInt(statusList.length)];

                String note = "";



                // --- B. Cố tình phá hoại (Inject Errors) ---

                if (isErrorRow) {

                    int errorType = random.nextInt(6); // Random 6 kiểu lỗi phổ biến

 

                    switch (errorType) {

                        case 0: // Lỗi Giá: Dính chữ "k", "đ", dấu phẩy

                            if (random.nextBoolean()) {

                                priceStr = (realPrice / 1000) + "k"; // VD: 150k

                            } else {

                                priceStr = String.format("%,.0f", realPrice) + " vnd"; // VD: 150,000 vnd

                            }

                            note = "ERR\_FORMAT\_PRICE";

                            break;



                        case 1: // Lỗi Tồn kho: Số âm hoặc chữ

                            if (random.nextBoolean()) {

                                stockStr = "-" + random.nextInt(10); // VD: -5

                            } else {

                                stockStr = "Out of Stock"; // VD: Chữ thay vì số

                            }

                            note = "ERR\_LOGIC\_STOCK";

                            break;



                        case 2: // Lỗi Ngày tháng: Định dạng sai hoặc ngày không tồn tại

                            dateStr = "13/20/2023"; // Tháng 20?

                            note = "ERR\_FORMAT\_DATE";

                            break;



                        case 3: // Lỗi Null: Dữ liệu quan trọng bị rỗng

                            name = "";

                            note = "ERR\_MISSING\_NAME";

                            break;



                        case 4: // Lỗi Trùng lặp ID (Duplicate Key)

                            id = String.valueOf(1000 + i - 1); // Trùng với dòng trước đó

                            note = "ERR\_DUPLICATE\_ID";

                            break;

 

                        case 5: // Lỗi Encoding/Rác

                            name = "#N/A @ERROR!!!";

                            break;

                    }

                }



                // Ghi vào file

                writer.write(id + "," + name + "," + priceStr + "," + stockStr + "," + dateStr + "," + status + "," + note + "\\n");

            }



            System.out.println("✅ Đã tạo xong file " + fileName + " (" + totalRows + " dòng).");

            System.out.println("⚠️ Cảnh báo: File chứa nhiều lỗi định dạng để test Data Cleaning.");



        } catch (IOException e) {

            e.printStackTrace();

        }

    }

}

