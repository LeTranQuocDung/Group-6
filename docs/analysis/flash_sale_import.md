# DESIGN DOCUMENT: FLASH SALE & IMPORT MODULE

## 1. Flowchart: Flash Sale Purchase (Synchronous Processing)
Describes the processing flow when multiple users purchase simultaneously. The most important step is **Lock Stock**.

```mermaid
flowchart TD
    Start([Start]) --> Request[/User clicks Buy Now/]
    Request --> CheckTime{Check sale time?}
    
    CheckTime -- Not started/Ended --> ErrorTime[Error: Wrong time slot] --> End([End])
    CheckTime -- Open --> CheckStock{Check inventory?}
    
    CheckStock -- Out of stock 0 --> OutOfStock[Error: Out of stock] --> End
    CheckStock -- In stock >0 --> LockStock[🔥 LOCK RECORD DB LOCK]
    
    LockStock --> DoubleCheck{Double check}
    DoubleCheck -- Out Race condition --> Rollback[Cancel transaction] --> End
    DoubleCheck -- Available --> CreateOrder[Create order]
    
    CreateOrder --> UpdateStock[Deduct stock & Update Sold] --> Commit[Commit Transaction]
    Commit --> Success[Success: Purchase completed] --> End
```

## 2. Flowchart: Import Products from CSV
Describes the product import process from CSV file with error handling.

```mermaid
flowchart TD
    Start([Admin Upload CSV]) --> CheckFormat{Valid .csv format?}
    CheckFormat -- Invalid --> ErrorFile[File Error] --> End([End])
    CheckFormat -- Valid --> InitLog[Create Import Log]
    
    InitLog --> ReadFile[Read each row]
    ReadFile --> Validate{Data valid?}
    
    Validate -- Invalid Missing/Bad data --> WriteError[Write Error Log & Skip] --> NextRow
    
    Validate -- Valid --> SaveDB[(Save to Database)] --> NextRow
    
    NextRow{More rows?} -- Yes --> ReadFile
    NextRow -- No --> Summary[Summary: Success/Failed] 
    Summary --> UpdateLog[Update Log Status] --> End
```

