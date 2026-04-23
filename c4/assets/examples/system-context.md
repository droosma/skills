# System Context — example

Scope: one bank customer, one system in focus (Internet Banking System), two external systems.

From *Visualising Software Architecture*, chapter 6.

## The modelling (the C4 part)

| Element | Type | Description |
|---|---|---|
| Personal Banking Customer | Person | A customer of the bank with personal bank accounts. |
| Internet Banking System | Software System (in focus) | Allows customers to view information about their bank accounts and make payments. |
| E-mail System | Software System (external) | The internal Microsoft Exchange e-mail system. |
| Mainframe Banking System | Software System (external) | Stores all of the core banking information about customers, accounts, transactions, etc. |

| From | To | Description |
|---|---|---|
| Personal Banking Customer | Internet Banking System | Views account balances, and makes payments using |
| Internet Banking System | E-mail System | Sends e-mails using |
| Internet Banking System | Mainframe Banking System | Gets account information from, and makes payments using |
| E-mail System | Personal Banking Customer | Sends e-mails to |

No technology detail, no protocols, no internal structure. This is all a non-technical stakeholder needs to understand the scope.

## Mermaid rendering

```mermaid
C4Context
    title System Context diagram for Internet Banking System

    Person(customer, "Personal Banking Customer", "A customer of the bank with personal bank accounts.")

    System(banking, "Internet Banking System", "Allows customers to view information about their bank accounts and make payments.")

    System_Ext(mail, "E-mail System", "The internal Microsoft Exchange e-mail system.")
    System_Ext(mainframe, "Mainframe Banking System", "Stores all of the core banking information about customers, accounts, transactions, etc.")

    Rel(customer, banking, "Views account balances, and makes payments using")
    Rel(banking, mail, "Sends e-mails using")
    Rel(banking, mainframe, "Gets account information from, and makes payments using")
    Rel(mail, customer, "Sends e-mails to")

    UpdateRelStyle(customer, banking, $offsetY="-30")
    UpdateRelStyle(banking, mail, $offsetX="-40", $offsetY="-20")
    UpdateRelStyle(banking, mainframe, $offsetX="-40")
    UpdateRelStyle(mail, customer, $offsetX="-80", $offsetY="-20")
```

For the same model in Structurizr DSL, PlantUML C4, or other formats, see `../../references/output-formats.md`.
