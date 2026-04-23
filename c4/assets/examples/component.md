# Component — example

Scope: zoom into the "API Application" container. Show the components that live inside.

From *Visualising Software Architecture*, chapter 8.

## The modelling

### Components (in `Container_Boundary: API Application`)

| Component | Technology | Responsibility |
|---|---|---|
| Sign In Controller | Spring MVC Rest Controller | Allows users to sign in to the Internet banking system. |
| Accounts Summary Controller | Spring MVC Rest Controller | Provides customers with a summary of their bank accounts. |
| Reset Password Controller | Spring MVC Rest Controller | Allows users to reset their passwords. |
| Security Component | Spring Bean | Provides functionality related to signing in, changing passwords, etc. |
| Mainframe Banking System Facade | Spring Bean | A facade onto the mainframe banking system. |
| E-mail Component | Spring Bean | Sends e-mails to users. |

### Surrounding (simplified, for context)

Single-Page App (Container) • Mobile App (Container) • Database (Container) • E-mail System (System_Ext) • Mainframe Banking System (System_Ext)

### Relationships

| From | To | Description | Protocol |
|---|---|---|---|
| SPA | Sign In Controller | Makes API calls to | JSON/HTTPS |
| SPA | Accounts Summary Controller | Makes API calls to | JSON/HTTPS |
| SPA | Reset Password Controller | Makes API calls to | JSON/HTTPS |
| Mobile App | Sign In Controller | Makes API calls to | JSON/HTTPS |
| Mobile App | Accounts Summary Controller | Makes API calls to | JSON/HTTPS |
| Mobile App | Reset Password Controller | Makes API calls to | JSON/HTTPS |
| Sign In Controller | Security Component | Uses | — (in-process) |
| Reset Password Controller | Security Component | Uses | — |
| Reset Password Controller | E-mail Component | Uses | — |
| Accounts Summary Controller | Mainframe Banking System Facade | Uses | — |
| Security Component | Database | Reads from and writes to | JDBC |
| Mainframe Banking System Facade | Mainframe | Makes API calls to | XML/HTTPS |
| E-mail Component | E-mail System | Sends e-mails using | SMTP |

Intra-container calls (component-to-component) don't need a protocol — they're method calls in the same process.

## Mermaid rendering

```mermaid
C4Component
    title Component diagram for Internet Banking System — API Application

    Container(spa, "Single-Page Application", "JavaScript, Angular")
    Container(mobile, "Mobile App", "C#, Xamarin")
    ContainerDb(db, "Database", "Relational database schema")
    System_Ext(mail, "E-mail System", "The internal Microsoft Exchange e-mail system.")
    System_Ext(mainframe, "Mainframe Banking System", "Stores all of the core banking information about customers, accounts, transactions, etc.")

    Container_Boundary(api, "API Application") {
        Component(sign_in, "Sign In Controller", "Spring MVC Rest Controller", "Allows users to sign in to the Internet banking system.")
        Component(accounts, "Accounts Summary Controller", "Spring MVC Rest Controller", "Provides customers with a summary of their bank accounts.")
        Component(reset, "Reset Password Controller", "Spring MVC Rest Controller", "Allows users to reset their passwords.")

        Component(security, "Security Component", "Spring Bean", "Provides functionality related to signing in, changing passwords, etc.")
        Component(mf_facade, "Mainframe Banking System Facade", "Spring Bean", "A facade onto the mainframe banking system.")
        Component(mail_facade, "E-mail Component", "Spring Bean", "Sends e-mails to users.")
    }

    Rel(spa, sign_in, "Makes API calls to", "JSON/HTTPS")
    Rel(spa, accounts, "Makes API calls to", "JSON/HTTPS")
    Rel(spa, reset, "Makes API calls to", "JSON/HTTPS")
    Rel(mobile, sign_in, "Makes API calls to", "JSON/HTTPS")
    Rel(mobile, accounts, "Makes API calls to", "JSON/HTTPS")
    Rel(mobile, reset, "Makes API calls to", "JSON/HTTPS")

    Rel(sign_in, security, "Uses")
    Rel(reset, security, "Uses")
    Rel(reset, mail_facade, "Uses")
    Rel(accounts, mf_facade, "Uses")

    Rel(security, db, "Reads from and writes to", "JDBC")
    Rel(mf_facade, mainframe, "Makes API calls to", "XML/HTTPS")
    Rel(mail_facade, mail, "Sends e-mails using", "SMTP")

    UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

## Notes

- This is the Component diagram most teams *shouldn't* maintain forever. It's more volatile than the Container diagram — one refactor can invalidate it. Draw it when you need it (onboarding, design session); accept it will age.
- Controllers vs Beans reflect a layered architecture. For a hexagonal / ports-and-adapters container, you'd show ports and adapters instead. The Component diagram should reflect the *actual* architectural style of the container.
