Flow Checkout & Voucher
OK, mình làm riêng trọn gói phần “Flow Checkout & Voucher” để bạn giao cho 1 người trong nhóm là dùng được ngay 👌
(đúng kiểu thầy/cô hỏi là bảo vệ được)

FLOW CHECKOUT & VOUCHER

(Phần của 1 thành viên trong nhóm)

1. Mục tiêu chức năng

Xử lý đặt hàng (Checkout)

Áp dụng Flash Sale + Voucher

Đảm bảo:

Tính giá đúng

Không áp dụng sai voucher

Không tạo đơn khi hết hàng

2. Các loại khuyến mãi trong hệ thống
2.1 Flash Sale

Áp dụng trực tiếp lên Product Variant

Giảm giá trước khi tính voucher

Có giới hạn thời gian và số lượng

2.2 Voucher
Loại	Đặc điểm
Voucher Shop	Áp dụng cho sản phẩm của 1 shop
Voucher Sàn	Áp dụng toàn đơn
Free ship	Có thể gộp

👉 Thứ tự áp dụng (rất quan trọng)

Flash Sale

Voucher Shop

Voucher Sàn

3. FLOWCHART: CHECKOUT & VOUCHER (CHI TIẾT)
Flow tổng quát
┌──────────────────┐
│ User Click       │
│ Checkout         │
└───────┬──────────┘
        ↓
┌────────────────────────┐
│ Kiểm tra đăng nhập     │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Lấy Cart từ Session    │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Cart rỗng?             │
└───────┬─────────┬──────┘
        │Yes      │No
        ↓         ↓
   [Dừng]   ┌────────────────────────┐
            │ Tính giá gốc từng item  │
            └───────┬────────────────┘
                    ↓
┌────────────────────────┐
│ Áp dụng Flash Sale     │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Áp dụng Voucher Shop   │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Áp dụng Voucher Sàn    │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Tính Final Amount      │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Xác nhận đặt hàng      │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ BEGIN TRANSACTION      │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Khóa kho Variant       │
│ (SELECT FOR UPDATE)    │
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Stock đủ?              │
└───────┬─────────┬──────┘
        │No       │Yes
        ↓         ↓
 [ROLLBACK]   [Trừ kho]
                    ↓
             [Tạo Order]
                    ↓
               [COMMIT]

4. FLOW TÍNH VOUCHER (CHUYÊN SÂU – ĂN ĐIỂM)
Flow áp dụng Voucher
┌────────────────────────┐
│ Người dùng nhập voucher│
└───────┬────────────────┘
        ↓
┌────────────────────────┐
│ Voucher tồn tại?       │
└───────┬─────────┬──────┘
        │No       │Yes
        ↓         ↓
 [Bỏ qua]  ┌────────────────────────┐
           │ Voucher còn hiệu lực?  │
           └───────┬─────────┬──────┘
                   │No       │Yes
                   ↓         ↓
              [Bỏ qua] ┌────────────────────────┐
                       │ Đủ min order value?   │
                       └───────┬─────────┬──────┘
                               │No       │Yes
                               ↓         ↓
                          [Bỏ qua] ┌────────────────────────┐
                                   │ Tính discount          │
                                   └───────┬────────────────┘
                                           ↓
                                   [Áp dụng (có max cap)]
mermaid

Tuyệt 👍 dưới đây là MERMAID CHUẨN cho Flow Checkout & Voucher.
Bạn copy dán trực tiếp vào Mermaid Live / draw.io (Mermaid) là render được ngay.

1️⃣ FLOW CHECKOUT & VOUCHER (MERMAID)
flowchart TD
    A[User click Checkout] --> B{Đã đăng nhập?}
    B -- No --> B1[Chuyển tới Login]
    B -- Yes --> C[Lấy Cart từ Session]

    C --> D{Cart rỗng?}
    D -- Yes --> D1[Dừng Checkout]
    D -- No --> E[Tính giá gốc từng sản phẩm]

    E --> F[Áp dụng Flash Sale]
    F --> G[Áp dụng Voucher Shop]
    G --> H[Áp dụng Voucher Sàn]

    H --> I[Tính Final Amount]
    I --> J[User xác nhận đặt hàng]

    J --> K[BEGIN TRANSACTION]
    K --> L[Khóa kho Product Variant<br/>(SELECT FOR UPDATE)]

    L --> M{Stock đủ?}
    M -- No --> N[ROLLBACK<br/>Thông báo hết hàng]
    M -- Yes --> O[Trừ kho Variant]

    O --> P[Tạo Order + Order Items]
    P --> Q[COMMIT]
    Q --> R[Đặt hàng thành công]

2️⃣ FLOW ÁP DỤNG VOUCHER (MERMAID)
flowchart TD
    A[User nhập Voucher] --> B{Voucher tồn tại?}
    B -- No --> X[Bỏ qua Voucher]
    B -- Yes --> C{Còn hiệu lực?}

    C -- No --> X
    C -- Yes --> D{Đạt min order value?}

    D -- No --> X
    D -- Yes --> E[Tính discount]

    E --> F{Có max discount?}
    F -- Yes --> G[Áp dụng giới hạn giảm giá]
    F -- No --> H[Áp dụng toàn bộ]

    G --> I[Voucher hợp lệ]
    H --> I
cho tôi class diagram nữa

OK 👍 mình đưa CLASS DIAGRAM bằng MERMAID – bản an toàn nhất, đã giảm ký tự lỗi, không dấu, dùng chuẩn classDiagram (ổn định hơn flowchart).

👉 Phù hợp nộp cho OOP / CNPM / Java / UML

✅ CLASS DIAGRAM – E-COMMERCE (MERMAID)

👉 Copy nguyên khối

classDiagram
    class User {
        int userId
        string username
        string email
        string password
    }

    class Shop {
        int shopId
        string shopName
        float rating
    }

    class Product {
        int productId
        string name
        float basePrice
        string status
    }

    class ProductVariant {
        int variantId
        string size
        string color
        float price
        int stock
    }

    class Cart {
        int cartId
        datetime createdAt
    }

    class CartItem {
        int cartItemId
        int quantity
    }

    class Order {
        int orderId
        float totalAmount
        float discountAmount
        float finalAmount
        string status
    }

    class OrderItem {
        int orderItemId
        float price
        int quantity
    }

    class Voucher {
        int voucherId
        string code
        string type
        float value
        float minOrder
        float maxDiscount
    }

    User "1" --> "1" Cart
    User "1" --> "0..*" Order
    User "1" --> "0..*" Shop

    Shop "1" --> "0..*" Product
    Product "1" --> "0..*" ProductVariant

    Cart "1" --> "0..*" CartItem
    CartItem "*" --> "1" ProductVariant

    Order "1" --> "0..*" OrderItem
    OrderItem "*" --> "1" ProductVariant

    Order "0..*" --> "0..*" Voucher
dùng file md
📄 FILE .md HOÀN CHỈNH (BẠN COPY DÙNG LUÔN)

👉 Tạo file:

checkout_voucher.md

✏️ NỘI DUNG FILE checkout_voucher.md
# Flow Checkout & Voucher

## 1. Checkout Flow

```mermaid
graph TD
    A[Checkout] --> B{Login}
    B -->|No| B1[Go Login]
    B -->|Yes| C[Get Cart]

    C --> D{Empty Cart}
    D -->|Yes| D1[Stop]
    D -->|No| E[Calc Base Price]

    E --> F[Apply Flash Sale]
    F --> G[Apply Shop Voucher]
    G --> H[Apply Platform Voucher]

    H --> I[Calc Final Amount]
    I --> J[Confirm Order]

    J --> K[Begin Transaction]
    K --> L[Lock Stock]

    L --> M{Stock OK}
    M -->|No| N[Rollback]
    M -->|Yes| O[Update Stock]

    O --> P[Create Order]
    P --> Q[Commit]
    Q --> R[Success]
```

---

## 2. Voucher Apply Flow

```mermaid
graph TD
    A[Input Voucher] --> B{Exist}
    B -->|No| X[Ignore]
    B -->|Yes| C{Valid}

    C -->|No| X
    C -->|Yes| D{Min Order OK}

    D -->|No| X
    D -->|Yes| E[Calc Discount]

    E --> F{Has Max Cap}
    F -->|Yes| G[Apply Cap]
    F -->|No| H[Apply Discount]

    G --> I[Voucher OK]
    H --> I
```

---

## 3. Class Diagram - Checkout Module

```mermaid
classDiagram
    class Cart {
        int cartId
        getItems()
    }

    class CartItem {
        int quantity
    }

    class ProductVariant {
        int variantId
        float price
        int stock
    }

    class Voucher {
        string code
        string type
        float value
    }

    class Order {
        int orderId
        float finalAmount
        create()
    }

    class CheckoutService {
        calculatePrice()
        applyVoucher()
        createOrder()
    }

    Cart "1" --> "0..*" CartItem
    CartItem "*" --> "1" ProductVariant
    Order "1" --> "0..*" ProductVariant
    CheckoutService --> Cart
    CheckoutService --> Order
    CheckoutService --> Voucher
```

---
