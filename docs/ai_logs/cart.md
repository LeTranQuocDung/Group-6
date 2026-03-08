Đây là bộ code JSP hoàn chỉnh cho các trang Chi tiết sản phẩm, Giỏ hàng và Thông báo thành công theo phong cách giao diện Shopee. Code đã được tối ưu hóa các thành phần tương tác (JavaScript) và định dạng tiền tệ.

1. Phân tích chức năng chính
Dưới đây là sơ đồ luồng dữ liệu giữa các trang bạn đã cung cấp:

Product Detail: Hiển thị thông tin, chọn thuộc tính (màu sắc, dung lượng) và xử lý tăng/giảm số lượng. Chức năng "Mua ngay" sẽ gửi yêu cầu trực tiếp đến giỏ hàng với hành động cụ thể.

Cart: Hiển thị danh sách sản phẩm từ Session, tính tổng tiền và cho phép xóa sản phẩm.

Success: Trang đích sau khi hoàn tất thanh toán.

2. Các điểm cần lưu ý kỹ thuật
Trang Chi tiết sản phẩm (product_detail.jsp)
Xử lý hình ảnh: Sử dụng hàm changeImg(el) để thay đổi ảnh chính khi người dùng di chuột qua bộ sưu tập ảnh phụ.

Logic Giỏ hàng: Form gửi dữ liệu (id, quantity, action) về CartServlet. Nút "Mua Ngay" sử dụng JavaScript để đổi giá trị action thành buynow trước khi submit.

Định dạng tiền: Sử dụng String.format("%,.0f", price) để hiển thị dạng 15,000,000.

Trang Giỏ hàng (cart.jsp)
Dữ liệu: Lấy đối tượng Cart từ session.getAttribute("cart").

Trạng thái trống: Tự động kiểm tra nếu giỏ hàng null hoặc rỗng để hiển thị giao diện "Giỏ hàng trống" kèm nút "Mua ngay".

3. Gợi ý nâng cấp Code
Để hệ thống hoạt động hoàn hảo, bạn cần đảm bảo các Model Java của mình có các phương thức sau:

Model	Phương thức cần thiết
Product	getId(), getName(), getImage(), getPrice(), getDescription()
CartItem	getProduct(), getQuantity(), getPrice(), getTotalPrice()
Cart	getItems() (trả về List), getTotalQuantity(), getTotalMoney()
Ví dụ về Servlet xử lý (CartServlet)
Bạn nên có một đoạn xử lý logic tương tự như sau trong doPost của Servlet:

Java
String action = request.getParameter("action");
if (action.equals("add") || action.equals("buynow")) {
    // 1. Lấy Product từ DB theo ID
    // 2. Thêm vào đối tượng Cart trong Session
    // 3. Nếu là 'buynow', redirect thẳng tới cart.jsp, nếu 'add' thì ở lại trang cũ
}
Bạn có muốn mình hỗ trợ viết code cho file CartServlet.java để xử lý logic thêm/xóa sản phẩm và tính toán giỏ hàng không?
package model;



import java.util.ArrayList;

import java.util.List;



public class Cart {



    private List<CartItem> items;



    public Cart() {

        items = new ArrayList<>();

    }



    public List<CartItem> getItems() {

        return items;

    }



    // 1. Thêm sản phẩm vào giỏ

    public void addItem(CartItem newItem) {

        // Kiểm tra xem món này đã có trong giỏ chưa

        for (CartItem item : items) {

            if (item.getProduct().getId() == newItem.getProduct().getId()) {

                // Nếu có rồi -> Cộng dồn số lượng

                item.setQuantity(item.getQuantity() + newItem.getQuantity());

                return;

            }

        }

        // Nếu chưa có -> Thêm mới

        items.add(newItem);

    }



    // 2. Xóa sản phẩm

    public void removeItem(int productId) {

        items.removeIf(item -> item.getProduct().getId() == productId);

    }



    // 3. Tính tổng tiền cả giỏ hàng

    public double getTotalMoney() {

        double total = 0;

        for (CartItem item : items) {

            total += item.getTotalPrice();

        }

        return total;

    }



    // 4. Đếm tổng số lượng sản phẩm (để hiện lên cái icon giỏ hàng)

    public int getTotalQuantity() {

        int total = 0;

        for (CartItem item : items) {

            total += item.getQuantity();

        }

        return total;

    }

}

package model;



public class CartItem {



    private Product product;

    private int quantity;

    private double price; // Giá tại thời điểm mua



    public CartItem() {

    }



    public CartItem(Product product, int quantity, double price) {

        this.product = product;

        this.quantity = quantity;

        this.price = price;

    }



    // Getter & Setter

    public Product getProduct() {

        return product;

    }



    public void setProduct(Product product) {

        this.product = product;

    }



    public int getQuantity() {

        return quantity;

    }



    public void setQuantity(int quantity) {

        this.quantity = quantity;

    }



    public double getPrice() {

        return price;

    }



    public void setPrice(double price) {

        this.price = price;

    }



    // Tính tổng tiền của item này (Giá x Số lượng)

    public double getTotalPrice() {

        return price * quantity;

    }

}

package controller;



import dal.ProductDAO;

import model.Cart;

import model.CartItem;

import model.Product;

import java.io.IOException;

import javax.servlet.ServletException;

import javax.servlet.annotation.WebServlet;

import javax.servlet.http.HttpServlet;

import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;

import javax.servlet.http.HttpSession;



@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})

public class CartServlet extends HttpServlet {



    @Override

    protected void doGet(HttpServletRequest request, HttpServletResponse response)

            throws ServletException, IOException {

        // Vào trang /cart thì hiện giao diện giỏ hàng

        String action = request.getParameter("action");



        if (action != null && action.equals("delete")) {

            // Xử lý xóa

            int id = Integer.parseInt(request.getParameter("id"));

            HttpSession session = request.getSession();

            Cart cart = (Cart) session.getAttribute("cart");

            if (cart != null) {

                cart.removeItem(id);

            }

            // Quay lại trang giỏ hàng

            response.sendRedirect("cart");

        } else {

            // Mặc định: Xem giỏ hàng

            request.getRequestDispatcher("cart.jsp").forward(request, response);

        }

    }



    @Override

    protected void doPost(HttpServletRequest request, HttpServletResponse response)

            throws ServletException, IOException {

        // Xử lý Thêm vào giỏ (Form submit từ trang Detail)

        HttpSession session = request.getSession();

        Cart cart = (Cart) session.getAttribute("cart");



        // Nếu chưa có giỏ thì tạo mới

        if (cart == null) {

            cart = new Cart();

            session.setAttribute("cart", cart);

        }



        try {

            int id = Integer.parseInt(request.getParameter("id"));

            int quantity = Integer.parseInt(request.getParameter("quantity"));



            // Lấy thông tin sản phẩm từ DB

            ProductDAO dao = new ProductDAO();

            Product p = dao.getProductById(id);



            // Tạo item mới và thêm vào giỏ

            CartItem item = new CartItem(p, quantity, p.getPrice());

            cart.addItem(item);



            // Lưu lại vào session

            session.setAttribute("cart", cart);



            // Chuyển hướng đến trang giỏ hàng

          // Lấy tín hiệu action từ form gửi lên

String action = request.getParameter("action");



if ("buynow".equals(action)) {

    // Nếu là mua ngay, chuyển đến trang cart.jsp nhưng kèm theo lệnh tự submit sang checkout

    // Hoặc đơn giản là chuyển hướng đến một trang trung gian

    response.sendRedirect("cart.jsp?checkout=true");

} else {

    String referer = request.getHeader("Referer");

    response.sendRedirect(referer != null ? referer : "home");

}

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect("home");

        }

    }

}

package controller;



import dal.OrderDAO;

import model.Cart;

import model.User;

import java.io.IOException;

import javax.servlet.ServletException;

import javax.servlet.annotation.WebServlet;

import javax.servlet.http.HttpServlet;

import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;

import javax.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})

public class CheckoutServlet extends HttpServlet {

@Override

protected void doGet(HttpServletRequest request, HttpServletResponse response)

        throws ServletException, IOException {

    // Gọi lại doPost để xử lý logic thanh toán

    doPost(request, response);

}

    @Override

    protected void doPost(HttpServletRequest request, HttpServletResponse response)

            throws ServletException, IOException {

        

        HttpSession session = request.getSession();

        Cart cart = (Cart) session.getAttribute("cart");

        User user = (User) session.getAttribute("account");



        // 1. Kiểm tra đăng nhập

        if (user == null) {

            response.sendRedirect("login.jsp"); // Chưa đăng nhập bắt đi login

            return;

        }



        // 2. Kiểm tra giỏ hàng

        if (cart == null || cart.getItems().isEmpty()) {

            response.sendRedirect("home");

            return;

        }



        // 3. Gọi DAO xử lý Transaction

        try {

            OrderDAO dao = new OrderDAO();

            dao.addOrder(user, cart); // Hàm Transaction nãy viết

            

            // 4. Thành công -> Xóa giỏ hàng

            session.removeAttribute("cart");

            

            // 5. Chuyển hướng trang thông báo

            response.sendRedirect("checkout_success.jsp");

            

        } catch (Exception e) {

            e.printStackTrace();

            // Lỗi -> Về lại giỏ hàng và báo lỗi (Ông có thể thêm msg)

            response.sendRedirect("cart.jsp?error=checkout_failed"); 

        }

    }

}

Gemini đã nói
Bạn vừa gửi thêm các thành phần quan trọng để xử lý luồng Giỏ hàng (Cart) và Thanh toán (Checkout). Đây là những "mạch máu" của một trang web bán hàng.

Dưới đây là tổng hợp những gì bạn đã bổ sung:

1. Model: Giỏ hàng & Vật phẩm
CartItem.java: Đại diện cho một dòng trong giỏ hàng. Nó lưu trữ đối tượng Product, số lượng mua, và đặc biệt là biến price (giá tại thời điểm bỏ vào giỏ) để đảm bảo tính nhất quán nếu sau này sản phẩm thay đổi giá.

Cart.java: Quản lý danh sách các CartItem. Nó bao gồm các logic nghiệp vụ như:

Thêm mới hoặc cộng dồn số lượng nếu sản phẩm đã tồn tại.

Xóa sản phẩm khỏi giỏ.

Tính tổng tiền toàn bộ giỏ hàng (getTotalMoney).

Đếm tổng số lượng để hiển thị badge trên icon giỏ hàng (getTotalQuantity).

2. Controller: Điều hướng & Logic
CartServlet.java:

doGet: Dùng để xem giỏ hàng hoặc xóa một item (thông qua parameter action=delete).

doPost: Xử lý khi người dùng nhấn "Thêm vào giỏ hàng" hoặc "Mua ngay" từ trang chi tiết sản phẩm. Nó lưu trữ đối tượng Cart vào HttpSession để dữ liệu không bị mất khi người dùng chuyển trang.

CheckoutServlet.java:

Kiểm tra trạng thái đăng nhập (yêu cầu đối tượng User trong session).

Kiểm tra giỏ hàng có trống hay không.

Gọi OrderDAO để thực hiện lưu đơn hàng vào database (thường sử dụng Transaction để đảm bảo lưu cả Order và OrderItems cùng lúc).

Xóa giỏ hàng sau khi thanh toán thành công.

🔍 Một vài lưu ý nhỏ để hoàn thiện:
Thiếu file OrderDAO.java: Trong CheckoutServlet, bạn có gọi `dao.addOrder(user,

Bạn đã dừng câu trả lời này
Bạn đã nói
tôi muốn trừ kho với âm kho

Gemini đã nói
Để giải quyết vấn đề trừ kho và chống âm kho, bạn cần xử lý tại lớp OrderDAO (file mà bạn chưa gửi). Đây là phần cực kỳ quan trọng vì nó liên quan đến tính toàn vẹn dữ liệu.

Dưới đây là cách triển khai logic này trong Java bằng SQL Transaction để đảm bảo: Nếu một mặt hàng không đủ số lượng, toàn bộ đơn hàng sẽ bị hủy (Rollback).

1. Cập nhật OrderDAO.java (Xử lý trừ kho & Chống âm kho)
Bạn nên sử dụng câu lệnh UPDATE kèm điều kiện WHERE stock >= ?. Nếu số lượng dòng bị ảnh hưởng (rowCount) bằng 0, nghĩa là kho đã hết.

Java
package dal;

import model.Cart;
import model.CartItem;
import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class OrderDAO extends DBContext {

    public void addOrder(User user, Cart cart) throws Exception {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Chèn vào bảng Orders
            String sqlOrder = "INSERT INTO Orders (user_id, total_amount, created_at) VALUES (?, ?, GETDATE())";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, user.getId());
            psOrder.setDouble(2, cart.getTotalMoney());
            psOrder.executeUpdate();

            // Lấy ID của Order vừa tạo
            ResultSet rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) {
                orderId = rs.getInt(1);
            }

            // 2. Duyệt từng item trong giỏ để chèn vào OrderItems và TRỪ KHO
            String sqlItem = "INSERT INTO OrderItems (order_id, variant_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)";
            String sqlUpdateStock = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";

            PreparedStatement psItem = conn.prepareStatement(sqlItem);
            PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock);

            for (CartItem item : cart.getItems()) {
                // A. Kiểm tra và trừ kho
                psStock.setInt(1, item.getQuantity());
                psStock.setInt(2, item.getProduct().getId()); // Giả sử ID ở đây là VariantID
                psStock.setInt(3, item.getQuantity()); // Điều kiện: stock >= số lượng mua

                int rowsAffected = psStock.executeUpdate();
                if (rowsAffected == 0) {
                    // Nếu không có dòng nào được update -> Hết hàng
                    throw new Exception("Sản phẩm " + item.getProduct().getName() + " đã hết hàng hoặc không đủ số lượng!");
                }

                // B. Chèn vào OrderItems
                psItem.setInt(1, orderId);
                psItem.setInt(2, item.getProduct().getId());
                psItem.setInt(3, item.getQuantity());
                psItem.setDouble(4, item.getPrice());
                psItem.executeUpdate();
            }

            conn.commit(); // Thành công hết thì mới lưu vào DB
        } catch (Exception e) {
            if (conn != null) conn.rollback(); // Lỗi bất kỳ chỗ nào là hủy toàn bộ đơn hàng
            throw e; 
        } finally {
            if (conn != null) conn.close();
        }
    }
}
2. Tại sao làm cách này lại chống được âm kho?
Tính nguyên tử (Atomicity): Nhờ conn.setAutoCommit(false), nếu bạn mua 5 món mà món thứ 5 hết hàng, 4 món trước đó đã trừ kho cũng sẽ được hoàn lại (Rollback).

Điều kiện WHERE stock >= ?: Đây là chốt chặn quan trọng nhất ở tầng Database. Kể cả khi có 2 người cùng nhấn mua một lúc (Concurrent requests), Database sẽ xử lý tuần tự. Người đến sau nếu thấy stock không đủ thỏa mãn điều kiện WHERE thì executeUpdate() sẽ trả về 0, kích hoạt lệnh rollback.

3. Gợi ý thêm cho UI (Trang Cart)
Trong file cart.jsp, bạn nên thêm một đoạn kiểm tra lỗi để báo cho người dùng biết tại sao thanh toán thất bại:

Java
<%
    String error = request.getParameter("error");
    if("checkout_failed".equals(error)) {
%>
    <div class="alert alert-danger">Thanh toán thất bại! Vui lòng kiểm tra lại số lượng tồn kho.</div>
<% } %>
Bạn có muốn tôi hỗ trợ viết thêm logic kiểm tra số lượng (Validation) ngay tại trang Giỏ hàng trước khi nhấn Thanh toán không? Hay bạn muốn xử lý phần Lịch sử đơn hàng?
Chào bạn, tôi hiểu rồi. Để code của bạn chạy được trên web và hiển thị đúng dữ liệu, chúng ta cần xử lý 3 vấn đề chính đang bị "vênh" trong code bạn gửi:

Sự khác biệt giữa Product và ProductVariant: Trong DB của bạn có bảng ProductVariants (lưu màu, size, kho), nhưng trong CartItem bạn lại đang lưu Product. Khi trừ kho, ta phải trừ ở bảng Variant.

Logic trừ kho (Chống âm kho): Như bạn muốn, phải dùng Transaction.

Lớp OrderDAO: Bạn chưa có lớp này để kết nối Servlet với Database.

Dưới đây là bản fix chi tiết để bạn có thể chạy được:

1. Cập nhật OrderDAO.java (Xử lý trừ kho & Transaction)
Đây là "trái tim" của việc thanh toán. Nó sẽ thực hiện: Ghi đơn hàng -> Ghi chi tiết -> Trừ kho. Nếu bất kỳ bước nào lỗi (ví dụ hết hàng), nó sẽ hủy toàn bộ (Rollback).

Java
package dal;

import model.Cart;
import model.CartItem;
import model.User;
import java.sql.*;

public class OrderDAO extends DBContext {

    public void addOrder(User user, Cart cart) throws Exception {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Chèn vào bảng Orders
            String sqlOrder = "INSERT INTO Orders (user_id, total_amount, created_at) VALUES (?, ?, GETDATE())";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, user.getId());
            psOrder.setDouble(2, cart.getTotalMoney());
            psOrder.executeUpdate();

            ResultSet rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) { orderId = rs.getInt(1); }

            // 2. Duyệt giỏ hàng để lưu chi tiết và TRỪ KHO
            String sqlItem = "INSERT INTO OrderItems (order_id, variant_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)";
            // Câu lệnh này cực kỳ quan trọng: chỉ update nếu stock >= quantity (chống âm kho)
            String sqlUpdateStock = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";

            PreparedStatement psItem = conn.prepareStatement(sqlItem);
            PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock);

            for (CartItem item : cart.getItems()) {
                // Bước A: Trừ kho trước
                // Lưu ý: Tôi giả sử bạn đang dùng ID của Variant trong CartItem
                psStock.setInt(1, item.getQuantity());
                psStock.setInt(2, item.getProduct().getId()); 
                psStock.setInt(3, item.getQuantity());

                int rowsAffected = psStock.executeUpdate();
                if (rowsAffected == 0) {
                    // Nếu không có dòng nào được cập nhật -> Hết hàng
                    throw new Exception("Sản phẩm " + item.getProduct().getName() + " không đủ hàng!");
                }

                // Bước B: Lưu chi tiết đơn hàng
                psItem.setInt(1, orderId);
                psItem.setInt(2, item.getProduct().getId());
                psItem.setInt(3, item.getQuantity());
                psItem.setDouble(4, item.getPrice());
                psItem.executeUpdate();
            }

            conn.commit(); // Mọi thứ OK thì mới chốt dữ liệu
        } catch (Exception e) {
            if (conn != null) conn.rollback(); // Có lỗi là trả lại trạng thái cũ
            throw e;
        } finally {
            if (conn != null) conn.close();
        }
    }
}
2. Kiểm tra lại Model Product và CartItem
Trong code DataGenerator của bạn, bảng ProductVariants mới là nơi chứa stock.

Nếu trong Giỏ hàng bạn chỉ lưu Product chung chung, bạn sẽ không biết trừ kho của Màu nào, Size nào.

Lời khuyên: Bạn nên tạo thêm model ProductVariant hoặc trong CartItem, đối tượng product phải đại diện cho một biến thể cụ thể.

3. Hiển thị trên Web (Giao diện JSP)
Để hiển thị được giỏ hàng ra trình duyệt, bạn cần file cart.jsp. Đây là khung cơ bản sử dụng JSTL:

Java
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Giỏ hàng</title></head>
<body>
    <h2>Giỏ hàng của bạn</h2>
    <table border="1">
        <tr>
            <th>Sản phẩm</th>
            <th>Giá</th>
            <th>Số lượng</th>
            <th>Tổng</th>
            <th>Hành động</th>
        </tr>
        <c:forEach items="${sessionScope.cart.items}" var="item">
            <tr>
                <td>${item.product.name}</td>
                <td>${item.price}</td>
                <td>${item.quantity}</td>
                <td>${item.totalPrice}</td>
                <td><a href="cart?action=delete&id=${item.product.id}">Xóa</a></td>
            </tr>
        </c:forEach>
    </table>
    <h3>Tổng tiền: ${sessionScope.cart.totalMoney} VND</h3>
    
    <form action="checkout" method="post">
        <button type="submit">Thanh toán ngay</button>
    </form>

    <c:if test="${param.error == 'checkout_failed'}">
        <p style="color:red;">Thanh toán thất bại: Kho không đủ hàng!</p>
    </c:if>
</body>
</html>
💡 Bước tiếp theo bạn cần làm:
Tạo bảng Database: Đảm bảo các bảng Orders, OrderItems, ProductVariants đã có sẵn đúng cấu trúc như trong DataGenerator.

Thêm thư viện JSTL: Đảm bảo file .war của bạn có thư viện JSTL để chạy được các thẻ <c:forEach>.

Sửa lỗi ID: Trong CartServlet, khi lấy sản phẩm từ ProductDAO.getProductById(id), hãy chắc chắn rằng ID đó khớp với ID bạn muốn trừ kho (là ID sản phẩm hay ID biến thể).

Bạn có muốn tôi hỗ trợ viết câu lệnh SQL Create Table chuẩn cho bộ code này để bạn chạy thử không?
Ồ, xin lỗi bạn nhé! Có lẽ do lượng code gửi lên khá dài nên tôi đã sơ suất không liệt kê nó trong danh sách tổng hợp. Tôi đã rà soát lại toàn bộ nội dung bạn gửi.

Đúng là bạn đã gửi các đoạn xử lý liên quan đến logic chuyển hướng và giao diện (như phần response.sendRedirect("cart.jsp?checkout=true") và các đoạn check action).

Để code của bạn thực sự "chạy" và hiển thị được trên web mà không bị lỗi âm kho, vấn đề nằm ở chỗ: Code Java (Backend) và Database phải khớp nhau.

Dưới đây là những điểm "chết" trong code bạn gửi cần sửa để nó hiển thị được:

1. Lỗi logic ID (Quan trọng nhất)
Trong DataGenerator, bạn có TOTAL_PRODUCTS (100) và TOTAL_VARIANTS (300).

Trong CartServlet, bạn đang lấy id từ request và gọi dao.getProductById(id).

Nhưng khi thanh toán, bạn cần trừ kho trong bảng ProductVariants.

Vấn đề: Nếu bạn bỏ ProductId vào giỏ, database sẽ không biết bạn muốn trừ kho của Size nào/Màu nào (vì 1 Product có nhiều Variant).

=> Giải pháp: Trang product_detail.jsp của bạn phải gửi lên variant_id thay vì product_id.

2. Cấu trúc file OrderDAO.java hoàn chỉnh
Bạn đã gửi CheckoutServlet gọi đến OrderDAO, nhưng chưa gửi file DAO này. Để hiển thị và trừ kho thành công, bạn cần file này với logic Transaction như sau:

Java
package dal;

import model.Cart;
import model.CartItem;
import model.User;
import java.sql.*;

public class OrderDAO extends DBContext {
    public void addOrder(User user, Cart cart) throws Exception {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // CHẶN ÂM KHO: Bắt đầu giao dịch

            // 1. Tạo hóa đơn
            String sqlOrder = "INSERT INTO Orders (user_id, total_amount, created_at) VALUES (?, ?, GETDATE())";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, user.getId());
            psOrder.setDouble(2, cart.getTotalMoney());
            psOrder.executeUpdate();
            
            ResultSet rs = psOrder.getGeneratedKeys();
            int orderId = rs.next() ? rs.getInt(1) : 0;

            // 2. Trừ kho và lưu chi tiết
            String sqlCheckStock = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";
            String sqlItem = "INSERT INTO OrderItems (order_id, variant_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)";
            
            PreparedStatement psStock = conn.prepareStatement(sqlCheckStock);
            PreparedStatement psItem = conn.prepareStatement(sqlItem);

            for (CartItem item : cart.getItems()) {
                // Trừ kho: Nếu stock < quantity, rowAffected sẽ = 0
                psStock.setInt(1, item.getQuantity());
                psStock.setInt(2, item.getProduct().getId()); // ID này phải là VariantID
                psStock.setInt(3, item.getQuantity());
                
                if (psStock.executeUpdate() == 0) {
                    throw new Exception("Sản phẩm " + item.getProduct().getName() + " không đủ hàng!");
                }

                // Lưu chi tiết
                psItem.setInt(1, orderId);
                psItem.setInt(2, item.getProduct().getId());
                psItem.setInt(3, item.getQuantity());
                psItem.setDouble(4, item.getPrice());
                psItem.executeUpdate();
            }

            conn.commit(); // Hoàn tất
        } catch (Exception e) {
            if (conn != null) conn.rollback(); // Lỗi là trả lại số lượng cũ ngay
            throw e;
        } finally {
            if (conn != null) conn.close();
        }
    }
}
3. Tại sao web của bạn có thể chưa hiển thị đúng?
Nếu bạn chạy mà trang web trắng tinh hoặc báo lỗi 500, hãy kiểm tra:

Thư viện JSTL: Trong file cart.jsp bạn gửi, nếu có dùng thẻ <c:forEach>, bạn bắt buộc phải có file jstl-1.2.jar trong thư mục WEB-INF/lib.

Đối tượng User: Trong CheckoutServlet, bạn lấy User user = (User) session.getAttribute("account");. Nếu bạn chưa làm trang Login để bỏ user vào session, nó sẽ luôn bị null và redirect về login.jsp.

Lời khuyên: Để tôi giúp bạn khớp hoàn toàn, bạn có muốn tôi viết một đoạn code tạo bảng SQL (Script SQL) dựa trên đúng các tên bảng/cột mà bạn đã viết trong DataGenerator không? Khi DB chuẩn thì code Java của bạn mới chạy "mượt" được.
Tôi hiểu rồi, bạn muốn hiện thực hóa việc khấu trừ tồn kho thực tế ngay khi nhấn mua hàng và chặn không cho phép mua nếu vượt quá số lượng trong kho.

Dựa trên các file JSP bạn đã gửi (product_detail.jsp, cart.jsp), hiện tại hệ thống của bạn đang gặp một "nút thắt": Trang chi tiết chỉ hiển thị sản phẩm chung, nhưng tồn kho lại nằm ở bảng Variant (màu/size).

Để chức năng này chạy đúng và hiển thị được trên Web, bạn cần thực hiện 3 bước sau:

Bước 1: Sửa trang product_detail.jsp (Gửi Variant ID)
Hiện tại bạn đang gửi id của Product. Để trừ kho chính xác, bạn cần gửi ID của biến thể (ví dụ: iPhone 15 - Màu Đỏ - 128GB).

Trong Form thêm vào giỏ, hãy thêm một trường ẩn: <input type="hidden" name="variantId" id="selectedVariantId">.

Khi người dùng click chọn Màu hoặc Size, bạn dùng JavaScript cập nhật ID này.

Hiển thị số lượng tồn kho (stock) tương ứng lên màn hình để người dùng biết.

Bước 2: Sửa OrderDAO.java (Logic Trừ Kho & Chống Âm Kho)
Đây là phần "xương sống" để thực hiện yêu cầu của bạn. Bạn phải dùng SQL Transaction. Nếu một món hàng trong giỏ bị thiếu kho, toàn bộ quá trình thanh toán phải bị hủy (Rollback) để dữ liệu không bị sai lệch.

Java
public void addOrder(User user, Cart cart) throws Exception {
    Connection conn = null;
    try {
        conn = getConnection();
        conn.setAutoCommit(false); // Bắt đầu giao dịch (Transaction)

        // 1. Tạo đơn hàng mới
        String sqlOrder = "INSERT INTO Orders (user_id, total_amount, created_at) VALUES (?, ?, GETDATE())";
        PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
        psOrder.setInt(1, user.getId());
        psOrder.setDouble(2, cart.getTotalMoney());
        psOrder.executeUpdate();
        
        ResultSet rs = psOrder.getGeneratedKeys();
        int orderId = rs.next() ? rs.getInt(1) : 0;

        // 2. Trừ kho và lưu chi tiết đơn hàng
        String sqlUpdateStock = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";
        String sqlItem = "INSERT INTO OrderItems (order_id, variant_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)";
        
        PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock);
        PreparedStatement psItem = conn.prepareStatement(sqlItem);

        for (CartItem item : cart.getItems()) {
            // CỰC KỲ QUAN TRỌNG: Điều kiện "stock >= ?" giúp chống âm kho ở tầng database
            psStock.setInt(1, item.getQuantity());
            psStock.setInt(2, item.getProduct().getId()); // Đảm bảo đây là Variant ID
            psStock.setInt(3, item.getQuantity());

            int rowsUpdated = psStock.executeUpdate();
            if (rowsUpdated == 0) {
                // Nếu không có dòng nào được cập nhật -> Kho không đủ
                throw new Exception("Sản phẩm " + item.getProduct().getName() + " đã hết hàng hoặc không đủ số lượng!");
            }

            // Lưu chi tiết đơn hàng
            psItem.setInt(1, orderId);
            psItem.setInt(2, item.getProduct().getId());
            psItem.setInt(3, item.getQuantity());
            psItem.setDouble(4, item.getPrice());
            psItem.executeUpdate();
        }

        conn.commit(); // Mọi thứ hợp lệ -> Chốt trừ kho
    } catch (Exception e) {
        if (conn != null) conn.rollback(); // Nếu bất kỳ món nào thiếu hàng -> Trả lại số lượng cũ
        throw e;
    } finally {
        if (conn != null) conn.close();
    }
}
Bước 3: Hiển thị lỗi ra trình duyệt
Trong CheckoutServlet.java của bạn, khi bắt được lỗi Exception từ DAO (do thiếu hàng), bạn cần truyền thông báo đó về trang giỏ hàng.

Tại CheckoutServlet:

Java
} catch (Exception e) {
    // Chuyển hướng kèm thông báo lỗi cụ thể
    response.sendRedirect("cart.jsp?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
}
Tại cart.jsp (Giao diện bạn gửi):
Thêm đoạn này vào trên phần danh sách giỏ hàng để hiển thị cho người dùng thấy:

Java
<%
    String error = request.getParameter("error");
    if (error != null) {
%>
    <div class="alert alert-danger text-center fw-bold">
        ⚠️ <%= error %>
    </div>
<% } %>
Tóm lại, cơ chế hoạt động sẽ là:
Người dùng nhấn Mua: Servlet nhận Variant ID và số lượng.

Database kiểm tra: Câu lệnh SQL UPDATE ... WHERE stock >= ? sẽ tự động chặn nếu bạn mua 10 mà kho chỉ còn 5.

Hệ thống phản hồi: * Nếu đủ hàng: Trừ kho thành công, chuyển đến checkout_success.jsp.

Nếu thiếu hàng: OrderDAO ném lỗi, Servlet bắt lại và hiển thị dòng chữ đỏ trên cart.jsp: "Sản phẩm ... không đủ số lượng!"

Bạn đã có file DBContext, hãy tạo ngay file OrderDAO.java với nội dung tôi viết ở trên. Bạn có muốn tôi hướng dẫn cách viết câu lệnh SQL để lấy danh sách Variant (Màu/Size) hiện ra trang chi tiết không?
Tôi đã rà soát lại toàn bộ các file bạn đã gửi (từ các file Java Logic cho đến các file JSP như product_detail.jsp, cart.jsp, shopee_home.jsp).

Đúng như bạn nói, code của bạn đang có vấn đề nghiêm trọng ở luồng dữ liệu, dẫn đến việc không thể thực hiện tính năng "nhấn mua thì trừ hàng và chặn nếu quá số lượng".

Dưới đây là 3 "điểm gãy" khiến code của bạn hiện tại không chạy được như ý muốn:

1. Lỗi truyền ID (Vấn đề lớn nhất)
Thực tế trong DB của bạn: Số lượng hàng (stock) nằm ở bảng ProductVariants (chia theo màu/size).

Vấn đề trong code: Trong product_detail.jsp, Form của bạn đang gửi id của Product (ID chung của cả dòng máy).

Hậu quả: Khi bạn nhấn "Mua hàng", Servlet nhận được Product ID. Lúc này, Database không biết bạn mua màu gì, size nào để mà trừ kho. Nó không thể trừ vào bảng ProductVariants được.

2. Logic trừ kho và chống âm kho chưa có trong DAO
Trong file CartServlet và CheckoutServlet bạn gửi, bạn có gọi dao.addOrder(user, cart). Tuy nhiên, để thực hiện đúng yêu cầu "trừ đi và không cho mua nếu quá số lượng", file OrderDAO cần phải viết như sau:

Java
// Trong OrderDAO.java
String sqlUpdate = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";
// ...
int rows = ps.executeUpdate();
if (rows == 0) {
    throw new Exception("Hết hàng!"); // Đây chính là đoạn chặn không cho mua
}
Hiện tại, bạn chưa triển khai logic này nên dù bạn có nhấn mua, số lượng trong database vẫn đứng yên.

3. Hiển thị số lượng khả dụng trên giao diện
Trong file product_detail.jsp, bạn đã có phần hiển thị giao diện nhưng chưa có script để:

Thay đổi số lượng tồn kho hiển thị khi người dùng click chọn các Màu/Size khác nhau.

Chặn người dùng nhấn dấu + trong ô số lượng nếu vượt quá stock đang có.

CÁCH SỬA ĐỂ CODE CHẠY ĐƯỢC:
Để hiển thị được trên web và trừ kho đúng như bạn muốn, bạn cần sửa lại 2 chỗ này:

Bước 1: Sửa product_detail.jsp (Phần JavaScript chọn Option)
Bạn cần thêm một biến để lưu variantId khi người dùng chọn màu.

JavaScript
function selectOpt(btn, variantId, stock) {
    // ... code đổi màu nút hiện tại ...
    document.getElementById('selectedVariantId').value = variantId; // Lưu ID biến thể để gửi về Servlet
    document.getElementById('displayStock').innerText = stock + " sản phẩm có sẵn"; // Hiển thị số lượng thực tế
}
Bước 2: Viết lại hàm addOrder trong OrderDAO với Transaction
Bạn phải dùng conn.setAutoCommit(false). Khi chạy lệnh UPDATE stock, nếu kết quả trả về bằng 0 (nghĩa là stock < quantity), bạn phải lệnh rollback để hủy đơn hàng và báo lỗi về trang cart.jsp.

Bước 3: Xử lý tại CheckoutServlet

Java
try {
    dao.addOrder(user, cart);
    response.sendRedirect("checkout_success.jsp");
} catch (Exception e) {
    // Nếu hết hàng, gửi thông báo lỗi quay lại trang giỏ hàng
    response.sendRedirect("cart.jsp?error=not_enough_stock");
}
Tóm lại: Code của bạn đang bị "râu ông nọ chắp cằm bà kia" giữa ID sản phẩm và ID kho hàng. Nếu bạn muốn, tôi sẽ viết lại cho bạn file OrderDAO.java chuẩn xác nhất dựa trên cấu trúc DataGenerator của bạn để giải quyết triệt để lỗi này. Bạn có muốn tôi viết file đó không?
CÁCH SỬA TRIỆT ĐỂ ĐỂ SỐ LƯỢNG THAY ĐỔI:
Bước 1: Sửa lại cách hiển thị Variant trong product_detail.jsp
Bạn cần truyền thêm thông tin stock và id vào hàm JavaScript khi người dùng nhấn chọn option:

HTML
<button type="button" class="btn-opt" 
        onclick="selectOpt(this, '101', '50')"> Màu Đỏ
</button>

<input type="hidden" name="id" id="realVariantId" value="${p.id}"> 
Bước 2: Sửa JavaScript để cập nhật con số trên màn hình
Sửa lại hàm selectOpt trong file product_detail.jsp của bạn:

JavaScript
function selectOpt(btn, variantId, stock) {
    // 1. Đổi màu nút (code cũ của bạn)
    let siblings = btn.parentElement.children;
    for (let s of siblings) s.classList.remove('selected');
    btn.classList.add('selected');

    // 2. CẬP NHẬT SỐ LƯỢNG (Đây là phần bạn đang thiếu)
    document.getElementById('displayStock').innerText = stock + " sản phẩm có sẵn";
    
    // 3. Cập nhật ID để khi nhấn Mua nó gửi đúng ID biến thể về Servlet
    document.getElementById('realVariantId').value = variantId;
    
    // 4. Giới hạn ô nhập số lượng không được vượt quá stock
    document.getElementById('qtyInput').max = stock;
}
Bước 3: Chặn âm kho tại OrderDAO.java
Khi người dùng nhấn "Thanh toán" ở giỏ hàng, bạn phải chạy câu lệnh SQL có điều kiện WHERE stock >= quantity.

Java
// Trong hàm addOrder của OrderDAO
String sql = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setInt(1, quantityMua);
ps.setInt(2, variantId);
ps.setInt(3, quantityMua);

int rows = ps.executeUpdate();
if (rows == 0) {
    throw new Exception("Kho không đủ hàng!"); // Nó sẽ văng lỗi và không cho mua tiếp
}
Tóm lại: Code của bạn đang hiển thị số lượng "chết". Bạn cần dùng JavaScript để "nhấc" dữ liệu từ danh sách Variant lên màn hình mỗi khi người dùng click chọn. Nếu bạn không sửa phần JavaScript này, số lượng sẽ mãi mãi không thay đổi.

Bạn có muốn tôi viết lại trọn bộ file OrderDAO và đoạn Script chuẩn cho trang product_detail để bạn copy-paste vào là chạy luôn không?
Tôi đã thấy rồi. Vấn đề nằm ở chỗ con số số lượng trên giao diện của bạn đang là con số "chết" được lấy từ Product (tổng quát), trong khi thực tế mỗi Màu sắc/Kích cỡ (Variant) lại có một con số stock riêng.

Vì hàm selectOpt(btn) trong file product_detail.jsp của bạn hiện tại chỉ đổi màu cái nút mà không cập nhật lại giao diện, nên người dùng click vào đâu số lượng cũng đứng yên.

Để sửa lỗi này và làm cho nó "nhấn mua là trừ hàng", bạn cần thực hiện 3 thay đổi trực tiếp vào code như sau:

1. Sửa lại nút chọn Option trong product_detail.jsp
Bạn cần truyền thêm stock và id của Variant vào hàm selectOpt.

Tìm đoạn code hiển thị nút (Màu/Size) và sửa thành:

HTML
<button type="button" class="btn-opt" 
        onclick="selectOpt(this, '${v.id}', '${v.stock}')">
    ${v.color} - ${v.size}
</button>

<input type="hidden" name="id" id="selectedVariantId" value="${p.id}">
2. Cập nhật hàm JavaScript selectOpt
Bạn phải dùng JavaScript để "bắn" con số stock vào cái thẻ hiển thị trên màn hình.

Sửa hàm selectOpt ở cuối file product_detail.jsp của bạn:

JavaScript
function selectOpt(btn, variantId, stock) {
    // 1. Đổi màu nút (giữ nguyên code cũ của bạn)
    let siblings = btn.parentElement.children;
    for (let s of siblings) s.classList.remove('selected');
    btn.classList.add('selected');

    // 2. CẬP NHẬT SỐ LƯỢNG HIỂN THỊ (Đây là chỗ bạn đang thiếu)
    // Giả sử thẻ hiển thị số lượng của bạn có id là 'displayStock'
    document.getElementById('displayStock').innerText = stock + " sản phẩm có sẵn";

    // 3. Cập nhật ID thực tế vào input để gửi về Servlet khi nhấn Mua
    document.getElementById('selectedVariantId').value = variantId;

    // 4. Giới hạn ô input số lượng không cho nhập quá stock
    document.getElementById('qtyInput').max = stock;
}
3. Logic chặn mua quá số lượng (Backend)
Khi người dùng nhấn "Thanh toán", tại OrderDAO.java, bạn phải sử dụng câu lệnh SQL có điều kiện chặt chẽ để chặn âm kho ngay lập tức.

Trong OrderDAO.java, hàm addOrder phải viết như sau:

Java
// Câu lệnh này: Chỉ trừ kho nếu stock hiện tại lớn hơn hoặc bằng số lượng khách mua
String sql = "UPDATE ProductVariants SET stock = stock - ? WHERE id = ? AND stock >= ?";

PreparedStatement ps = conn.prepareStatement(sql);
ps.setInt(1, quantityMua);
ps.setInt(2, variantId);
ps.setInt(3, quantityMua);

int rowsAffected = ps.executeUpdate();
if (rowsAffected == 0) {
    // Nếu không có dòng nào được update (rows == 0) -> Nghĩa là stock < quantityMua
    throw new Exception("Sản phẩm đã hết hàng hoặc không đủ số lượng!");
}
Kết quả sau khi sửa:
Trên Web: Khi khách nhấn vào "Màu Đỏ", chữ "100 sản phẩm có sẵn" sẽ nhảy thành "5 sản phẩm có sẵn" (theo đúng DB).

Khi Mua: Nếu khách cố tình nhập 10 sản phẩm (trong khi kho có 5), hệ thống sẽ chặn đứng ở tầng Database, báo lỗi và không tạo đơn hàng.

Bạn có muốn tôi gửi cho bạn trọn bộ file OrderDAO.java hoàn chỉnh để bạn thay thế vào project không? Vì file này là mấu chốt để con số trong Database thực sự bị trừ đi.
