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

    
    E --> G[Apply Shop Voucher]
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

