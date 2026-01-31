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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.Random;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DataGenerator {

    private static final String FOLDER = "C:/data/";
    private static final Random rand = new Random();
    
    // CẤU HÌNH SỐ LƯỢNG
    private static final int TOTAL_USERS = 10000;
    private static final int TOTAL_SHOPS = 200;
    private static final int TOTAL_PRODUCTS = 5000;
    private static final int TOTAL_VARIANTS = 12000;
    private static final int TOTAL_ORDERS = 15000;
    private static final int TOTAL_ITEMS = 40000;

    // DATA POOL (KHO TỪ VỰNG ĐỂ GHÉP)
    private static final String[] HO = {"Nguyen", "Tran", "Le", "Pham", "Hoang", "Huynh", "Phan", "Vu", "Vo", "Dang", "Bui", "Do", "Ho", "Ngo", "Duong", "Ly"};
    private static final String[] DEM = {"Van", "Thi", "Minh", "Duc", "My", "Ngoc", "Quang", "Tuan", "Anh", "Hong", "Xuan", "Thu", "Gia", "Thanh"};
    private static final String[] TEN = {"Anh", "Tuan", "Dung", "Hung", "Long", "Diep", "Lan", "Mai", "Hoa", "Cuong", "Manh", "Kien", "Trang", "Linh", "Phuong", "Thao", "Vy", "Tu", "Dat", "Son", "Khanh", "Huyen"};
    
    // DATA POOL SẢN PHẨM (ĐỂ TẠO TÊN SP ĐA DẠNG)
    private static final String[] PROD_TYPE = {"Dien thoai", "Laptop", "Ao thun", "Quan Jean", "Giay Sneaker", "Tai nghe", "Son moi", "Kem chong nang", "Dong ho"};
    private static final String[] BRANDS = {"Samsung", "iPhone", "Xiaomi", "Oppo", "Dell", "Macbook", "Asus", "Coolmate", "Zara", "Gucci", "Nike", "Adidas", "Sony", "JBL", "Casio", "Rolex"};
    private static final String[] ADJECTIVES = {"Cao cap", "Gia re", "Chinh hang", "Sieu ben", "Moi 100%", "Fullbox", "Xach tay", "Giam gia soc", "Limited Edition"};

    // FORMAT NGÀY
    private static final SimpleDateFormat dfStd = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat dfErr = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    public static void main(String[] args) {
        new File(FOLDER).mkdirs();
        System.out.println("Dang tao data rac");
        
        genUsers(TOTAL_USERS);
        genShops(TOTAL_SHOPS);
        genProducts(TOTAL_PRODUCTS);
        genVariants(TOTAL_VARIANTS); // <--- Lỗi Stock âm, Giá 0
        genVouchers(100);
        genOrders(TOTAL_ORDERS);     // <--- Lỗi ngày tháng
        genOrderItems(TOTAL_ITEMS);

        System.out.println("Done");
    }

    // 1. GEN USER (HỌ + ĐỆM + TÊN)
    private static void genUsers(int count) {
        try(BufferedWriter bw = new BufferedWriter(new FileWriter(FOLDER + "users.csv"))){
            bw.write("id,full_name,email,phone,wallet,note"); bw.newLine();
            for(int i=1; i<=count; i++) {
                String ho = getRandom(HO);
                String dem = getRandom(DEM);
                String ten = getRandom(TEN);
                String fullName = ho + " " + dem + " " + ten;
                
                // Tạo email theo tên để trông thật hơn
                String email = removeAccent(ten).toLowerCase() + "." + removeAccent(ho).toLowerCase() + i + "@gmail.com";
                String phone = "09" + String.format("%08d", rand.nextInt(100000000));
                String note = "";

                // 🎲 CÀI LỖI 10%
                if(rand.nextDouble() < 0.1) {
                    int type = rand.nextInt(3);
                    switch (type) {
                        case 0 -> {
                            email = email.replace("@", "");
                            note="Loi Email";
                        }
                        case 1 -> {
                            phone = phone.substring(1);
                            note="Loi Phone";
                        }
                        default -> {
                            fullName = fullName.toLowerCase();
                            note="Loi Ten";
                            // Tên viết thường
                        }
                    }
                    // Mất @
                    // Mất số 0
                                    }
                bw.write(i + "," + fullName + "," + email + "," + phone + "," + (rand.nextInt(500)*10000) + "," + note);
                bw.newLine();
            }
        } catch(Exception e){}
    }

    // 2. GEN PRODUCT (LOẠI + HÃNG + TÍNH TỪ) -> Tránh trùng lặp tên
    private static void genProducts(int count) {
        try(BufferedWriter bw = new BufferedWriter(new FileWriter(FOLDER + "products.csv"))){
            bw.write("id,shop_id,name,description"); bw.newLine();
            for(int i=1; i<=count; i++) {
                String type = getRandom(PROD_TYPE);
                String brand = getRandom(BRANDS);
                String adj = getRandom(ADJECTIVES);
                String name = type + " " + brand + " " + adj + " - Ma " + i; // Thêm mã để chắc chắn unique
                
                bw.write(i + "," + (rand.nextInt(TOTAL_SHOPS)+1) + "," + name + ",Mo ta chi tiet cho san pham " + name);
                bw.newLine();
            }
        } catch(Exception e){}
    }

    // 3. GEN VARIANTS (CÀI LỖI STOCK ÂM, GIÁ 0)
    private static void genVariants(int count) {
        try(BufferedWriter bw = new BufferedWriter(new FileWriter(FOLDER + "product_variants.csv"))){
            bw.write("id,product_id,color,size,stock,price"); bw.newLine();
            String[] colors = {"Den", "Trang", "Xanh", "Do", "Vang", "Bac", "Hong", "Xam"};
            String[] sizes = {"S", "M", "L", "XL", "29", "30", "31", "32", "128GB", "256GB"};

            for(int i=1; i<=count; i++) {
                int stock = rand.nextInt(50) + 1;
                double price = (rand.nextInt(100) + 1) * 10000;

                // ☠️ CÀI LỖI 15%
                if(rand.nextDouble() < 0.15) {
                    if(rand.nextBoolean()) stock = -1 * rand.nextInt(10); // Âm kho
                    else price = 0; // Giá 0
                }
                bw.write(i + "," + (rand.nextInt(TOTAL_PRODUCTS)+1) + "," + getRandom(colors) + "," + getRandom(sizes) + "," + stock + "," + price);
                bw.newLine();
            }
        } catch(Exception e){}
    }

    // 4. GEN ORDERS (CÀI LỖI NGÀY THÁNG)
    private static void genOrders(int count) {
        try(BufferedWriter bw = new BufferedWriter(new FileWriter(FOLDER + "orders.csv"))){
            bw.write("id,user_id,total_amount,created_at"); bw.newLine();
            for(int i=1; i<=count; i++) {
                String dateStr = (rand.nextDouble() < 0.1) ? dfErr.format(new Date()) : dfStd.format(new Date());
                bw.write(i + "," + (rand.nextInt(TOTAL_USERS)+1) + "," + ((rand.nextInt(50)+1)*10000) + "," + dateStr);
                bw.newLine();
            }
        } catch(Exception e){}
    }

    // --- CÁC HÀM PHỤ ---
    private static void genShops(int c) { try(BufferedWriter w=new BufferedWriter(new FileWriter(FOLDER+"shops.csv"))){w.write("id,shop_name,rating\n");for(int i=1;i<=c;i++)w.write(i+",Shop "+getRandom(HO)+" Official,"+ (3+rand.nextDouble()*2) +"\n");}catch(Exception e){} }
    private static void genOrderItems(int c) { try(BufferedWriter w=new BufferedWriter(new FileWriter(FOLDER+"order_items.csv"))){w.write("id,order_id,variant_id,quantity,price_at_purchase\n");for(int i=1;i<=c;i++)w.write(i+","+(rand.nextInt(TOTAL_ORDERS)+1)+","+(rand.nextInt(TOTAL_VARIANTS)+1)+",1,100000\n");}catch(Exception e){} }
    private static void genVouchers(int c) { try(BufferedWriter w=new BufferedWriter(new FileWriter(FOLDER+"vouchers.csv"))){w.write("code,value,min_order,start_date,end_date\n");for(int i=1;i<=c;i++)w.write("VOUCHER"+i+",10000,50000,2026-01-01,2026-12-31\n");}catch(Exception e){} }
    
    // Helper lấy ngẫu nhiên từ mảng
    private static String getRandom(String[] arr) { return arr[rand.nextInt(arr.length)]; }
    private static String removeAccent(String s) { return s.replaceAll("[^a-zA-Z0-9]", ""); } // Đơn giản hóa
}
