# The same example in Structurizr DSL

The Internet Banking System modelled as a single Structurizr DSL workspace. Define once, render many views — Context, Container, Component, Deployment, Dynamic — automatically kept consistent.

Structurizr is Simon Brown's own tool and the most complete expression of the C4 philosophy: **the model is the source of truth; diagrams are generated views**.

## workspace.dsl

```
workspace "Big Bank plc" "The software systems and people of Big Bank plc." {

    model {
        customer          = person "Personal Banking Customer" "A customer of the bank with personal bank accounts."
        customerService   = person "Customer Service Staff" "Handles inbound customer calls."
        backOfficeStaff   = person "Back Office Staff" "Administers bank accounts."

        enterprise "Big Bank plc" {

            mailSystem        = softwareSystem "E-mail System" "The internal Microsoft Exchange e-mail system." "Existing System"
            mainframe         = softwareSystem "Mainframe Banking System" "Stores all of the core banking information about customers, accounts, transactions, etc." "Existing System"
            customerService_sw = softwareSystem "Customer Service System" "Allows staff to record customer interactions." "Existing System"
            backOffice        = softwareSystem "Back Office System" "Allows back office staff to administer accounts." "Existing System"
            atm               = softwareSystem "ATM" "Allows customers to withdraw cash." "Existing System"

            internetBanking = softwareSystem "Internet Banking System" "Lets customers view accounts and make payments." {

                webApp   = container "Web Application" "Delivers static content and the Internet banking SPA." "Java, Spring MVC"
                spa      = container "Single-Page Application" "Provides all banking features in the browser." "JavaScript, Angular" "Web Browser"
                mobileApp = container "Mobile App" "Provides limited banking on phones." "C#, Xamarin" "Mobile App"
                api      = container "API Application" "Provides banking functionality via JSON/HTTPS." "Java, Spring MVC"
                db       = container "Database" "User registrations, hashed creds, access logs." "Relational DBMS Schema" "Database" {

                    signIn       = component "Sign In Controller" "Handles sign-in." "Spring MVC Rest Controller"
                    accounts     = component "Accounts Summary Controller" "Returns account summaries." "Spring MVC Rest Controller"
                    reset        = component "Reset Password Controller" "Handles password reset." "Spring MVC Rest Controller"
                    security     = component "Security Component" "Sign-in, password-change logic." "Spring Bean"
                    mfFacade     = component "Mainframe Facade" "Wraps the mainframe." "Spring Bean"
                    mailFacade   = component "E-mail Component" "Sends e-mails." "Spring Bean"

                    signIn      -> security   "Uses"
                    reset       -> security   "Uses"
                    reset       -> mailFacade "Uses"
                    accounts    -> mfFacade   "Uses"
                    security    -> db         "Reads/writes" "JDBC"
                    mfFacade    -> mainframe  "Calls" "XML/HTTPS"
                    mailFacade  -> mailSystem "Sends e-mails via" "SMTP"
                }
            }
        }

        # system-level relationships
        customer  -> internetBanking "Views accounts, makes payments using"
        customer  -> atm             "Withdraws cash using"
        customer  -> customerService "Asks questions to" "Telephone"

        internetBanking -> mainframe  "Reads/writes via"
        internetBanking -> mailSystem "Sends e-mails via"
        atm             -> mainframe  "Uses"
        customerService_sw -> mainframe "Reads from"
        backOffice      -> mainframe  "Reads/writes"
        mailSystem      -> customer   "Sends e-mails to"

        # container-level
        customer  -> webApp    "Visits bigbank.com using" "HTTPS"
        customer  -> spa       "Views balances and makes payments"
        customer  -> mobileApp "Views balances and makes payments"

        webApp    -> spa        "Delivers to the browser"
        spa       -> api        "Makes API calls to" "JSON/HTTPS"
        mobileApp -> api        "Makes API calls to" "JSON/HTTPS"
        api       -> db         "Reads/writes" "JDBC"
        api       -> mailSystem "Sends e-mails via" "SMTP"
        api       -> mainframe  "Calls" "XML/HTTPS"

        # deployment
        live = deploymentEnvironment "Live" {

            deploymentNode "Customer's mobile device" "iOS or Android" {
                containerInstance mobileApp
            }

            deploymentNode "Customer's computer" "Windows or macOS" {
                deploymentNode "Web Browser" "Chrome, Firefox, Safari, Edge" {
                    containerInstance spa
                }
            }

            deploymentNode "Big Bank plc — AWS" "Amazon Web Services" {

                deploymentNode "ap-southeast-2 — apps" "EC2 Auto Scaling Group, c5.large, 2 instances" {
                    deploymentNode "Apache Tomcat 9" "" {
                        containerInstance webApp
                    }
                    deploymentNode "Apache Tomcat 9" "" {
                        containerInstance api
                    }
                }

                deploymentNode "Amazon RDS" "Multi-AZ PostgreSQL 15" {
                    containerInstance db
                }
            }

            deploymentNode "Big Bank plc — on-prem" "Company data centre" {
                deploymentNode "bigbank-mf-001" "IBM zSeries" "" {
                    softwareSystemInstance mainframe
                }
                deploymentNode "bigbank-mx-001" "Microsoft Exchange 2019" "" {
                    softwareSystemInstance mailSystem
                }
            }
        }
    }

    views {
        systemLandscape "Landscape" {
            include *
            autoLayout
        }

        systemContext internetBanking "Context" {
            include *
            autoLayout
        }

        container internetBanking "Containers" {
            include *
            autoLayout
        }

        component api "APIComponents" {
            include *
            autoLayout
        }

        dynamic api "ResetPassword" "Reset password flow" {
            spa      -> reset      "Submits e-mail address to" "JSON/HTTPS"
            reset    -> security   "Calls isEmailRegistered() on"
            security -> db         "Selects user data from" "JDBC"
            reset    -> mailFacade "Calls sendResetPasswordLink() on"
            mailFacade -> mailSystem "Sends reset link via e-mail via" "SMTP"
            autoLayout
        }

        deployment internetBanking "Live" "LiveDeployment" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                shape Person
                background #08427B
                color #ffffff
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
        }

        theme default
    }
}
```

## Why use this over a single Mermaid diagram

- **One source of truth.** Edit a container's technology once; every view that shows it updates.
- **Automatic Component ↔ Container ↔ Context consistency.** Structurizr knows the hierarchy.
- **Multiple views** of the same model (Context, Container, Component, Dynamic, Deployment, Landscape) without redrawing.
- **Exports to Mermaid, PlantUML, draw.io, Ilograph** — the DSL is a model; the renderers are plug-ins.
- **Diff-friendly** — plain-text in version control.

## How to render

**Structurizr Lite** (local, Docker):
```
docker run -it --rm -p 8080:8080 -v $PWD:/usr/local/structurizr structurizr/lite
```
Open `http://localhost:8080` — it picks up `workspace.dsl` from the mounted directory.

**Structurizr CLI** (export):
```
structurizr-cli export -workspace workspace.dsl -format mermaid -output ./exports/
structurizr-cli export -workspace workspace.dsl -format plantuml -output ./exports/
```

**Structurizr on-demand**: https://structurizr.com, paid SaaS.

## The trade-off

DSL has a steeper onramp than inline Mermaid. Not worth it for a one-off README diagram. Very worth it for teams that maintain architecture docs alongside code, across multiple systems, over years.
