# Class diagram

Use for OO structure: classes, methods, inheritance, composition.

## Header

```
classDiagram
```

Optional direction:
```
classDiagram
    direction LR
```

## Classes

Implicit (from relationships) or explicit:

```
classDiagram
    class Animal
    class Dog
    Animal <|-- Dog
```

### Members

Inline with colon:
```
classDiagram
    class Vehicle
    Vehicle : +String make
    Vehicle : +int year
    Vehicle : +start() bool
```

Block form:
```
classDiagram
    class Vehicle {
        +String make
        +int year
        +start() bool
        +stop() void
    }
```

### Visibility

| Symbol | Meaning |
|---|---|
| `+` | public |
| `-` | private |
| `#` | protected |
| `~` | package / internal |

### Generics (tildes)

```
class List~T~ {
    +add(item T) void
    +get(i int) T
}

class Map~K, V~
```

### Return types

After method parentheses:
```
class Order {
    +total() Money
    +items() List~Item~
}
```

### Stereotypes / annotations

```
class AuthService {
    <<Service>>
    +authenticate(u User) Token
}

class Repository {
    <<Interface>>
}

class Currency {
    <<Enumeration>>
    USD
    EUR
    GBP
}

class AbstractBase {
    <<Abstract>>
}
```

Common stereotypes: `<<Service>>`, `<<Interface>>`, `<<Abstract>>`, `<<Enumeration>>`, `<<Value Object>>`, `<<Entity>>`, `<<DTO>>`.

## Relationships

| Syntax | UML meaning | Example |
|---|---|---|
| `A <|-- B` | B inherits from A (generalisation) | `Animal <|-- Dog` |
| `A *-- B` | composition (A owns B, lifetime-coupled) | `Car *-- Engine` |
| `A o-- B` | aggregation (A has B, independent lifetime) | `Team o-- Player` |
| `A --> B` | association (directed) | `Order --> Customer` |
| `A -- B` | association (undirected) | `Order -- LineItem` |
| `A ..> B` | dependency | `Service ..> Logger` |
| `A ..|> B` | realisation (interface impl) | `Repository ..|> UserRepo` |
| `A .. B` | link (dashed, no nav) | `A .. B` |

### Cardinality (multiplicity)

Put quoted cardinality before/after the association arrow:

```
Customer "1" --> "0..*" Order : places
Order "1" --> "1..*" LineItem : contains
```

Values: `1`, `0..1`, `1..*`, `0..*`, `*`, `n`, `0..n`, `1..n`, any literal.

### Labels on relationships

```
Student "1" --> "*" Course : enrolled_in
```

## Namespaces

```
classDiagram
    namespace Auth {
        class User
        class Token
    }
    namespace Billing {
        class Invoice
        class Payment
    }
    User --> Invoice
```

Namespaces render as enclosing boxes.

## Notes

```
note "Persistence layer"
note for User "Stores only hashed passwords"
```

## Click / interaction

```
click User href "https://example.com/docs/user" "User docs"
click Order call showOrderDetails() "Show details"
```

Requires `securityLevel: loose`.

## Styling

```
classDef important fill:#f96,stroke:#333,stroke-width:2px
class User,Order important

%% shorthand inline
class Payment:::important
```

## Full example

```mermaid
---
title: E-commerce domain model
---
classDiagram
    direction LR

    class Customer {
        +UUID id
        +String email
        +String name
        +createOrder() Order
    }

    class Order {
        +UUID id
        +Date placedOn
        +OrderStatus status
        +total() Money
        +addItem(p Product, qty int) void
    }

    class LineItem {
        +Product product
        +int quantity
        +Money unitPrice
        +subtotal() Money
    }

    class Product {
        +UUID sku
        +String name
        +Money price
    }

    class PaymentMethod {
        <<Interface>>
        +charge(amount Money) Receipt
    }

    class CreditCard {
        +String last4
        +String brand
    }

    class Receipt {
        +UUID txnId
        +Date when
    }

    Customer "1" --> "0..*" Order : places
    Order "1" *-- "1..*" LineItem : contains
    LineItem "*" --> "1" Product : of
    Order "1" --> "1" PaymentMethod : paid_with
    PaymentMethod <|.. CreditCard
    Order ..> Receipt : produces

    classDef entity fill:#e7f5ff,stroke:#1971c2
    classDef valueObject fill:#fff3bf,stroke:#927a00
    class Customer,Order,Product entity
    class LineItem,Receipt valueObject
```

## Gotchas

- **`~T~` not `<T>`** for generics — angle brackets mean something else.
- **Visibility sign is the first char of the name in inline form**: `Vehicle : +String make`. In block form it prefixes the member line.
- **Relationship direction**: `A <|-- B` means B inherits from A (arrow points to parent). It's easy to invert by mistake.
- **Labels on relationships use `:`** after the line, not `|…|`:
  ```
  A --> B : label          # OK
  A -->|label| B           # NOT the class diagram syntax
  ```
- **No `direction TB` inside a namespace** — direction is diagram-wide only.
