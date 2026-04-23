# Extracting C4 from a codebase

When the user hands you a repo rather than a description, the problem is reversed: the architecture exists, latent, in the code — your job is to surface it. This reference is a set of heuristics for finding the Systems, Containers, and Components that are already there.

Three ground rules:

1. **Cite evidence.** For every element, note the file(s) that justify it. Anything uncited is a guess — flag it as such.
2. **Prefer existing artefacts.** If the repo has an architecture doc, an ADR, a diagram, a README section — read it first. Your output should reconcile with it, not reinvent it.
3. **Start broad, zoom on request.** Produce Context + Container first. Only go to Component if asked, or if a container is substantial enough to warrant decomposition.

## 1. Find the system boundary

One repo is usually one **software system**. Monorepos break this rule — they can contain several deployable products. Look for:

- A single root-level `README.md` describing the whole thing → one system.
- Multiple top-level packages each with their own `README.md` and deploy pipeline → possibly multiple systems.
- A monorepo tool config (`nx.json`, `turbo.json`, `pnpm-workspace.yaml`, `lerna.json`, `rush.json`, `WORKSPACE` / `BUILD` for Bazel, `go.work`) → read the workspace graph to see which directories are independently deployable.

When a repo is clearly one system, the repo's name (or the main package name) is usually the system name.

## 2. Find the containers

Containers are **separately-deployable units**. Look for evidence of deployment independence:

### Build / package manifests at the root(s)

| Signal | Likely container |
|---|---|
| `package.json` with a `start` script and a web framework dep (express, next, fastify, nest, remix, astro) | Node web app |
| `package.json` with `react-scripts`, `vite`, `webpack`, `parcel` and no server dep | SPA |
| `package.json` with `expo`, `react-native`, `ionic` | Mobile app |
| `pom.xml` / `build.gradle(.kts)` with `spring-boot-starter-web` | Spring Boot service |
| `go.mod` + `main.go` at a subdirectory root | Go service/worker |
| `Cargo.toml` with `[[bin]]` | Rust service/worker |
| `requirements.txt` / `pyproject.toml` with `flask`/`django`/`fastapi` | Python web app |
| `requirements.txt` with `celery`/`rq`/`dramatiq` | Python worker |
| `Gemfile` with `rails`/`sinatra` | Ruby web app |
| `*.csproj` with `Microsoft.AspNetCore` | ASP.NET Core |
| `Dockerfile` without a co-located build manifest | Still a container — read the Dockerfile's `ENTRYPOINT`/`CMD` |

Each distinct deployable unit is one container.

### Compose / orchestration files

`docker-compose.yml`, `docker-compose.*.yml`, `compose.yaml`:
- Each `services:` entry is a container.
- Each `volumes:` entry is usually *not* a container (storage for a container).
- External databases/caches referenced as services (postgres, redis, rabbitmq) are containers.

Kubernetes (`k8s/`, `manifests/`, `kustomize/`, `helm/`):
- `Deployment`, `StatefulSet`, `DaemonSet`, `CronJob`, `Job` resources → containers.
- `Service` resources → usually not containers themselves (they route to pods).
- `Ingress` → infrastructure node on the Deployment diagram, not a C4 container.

### Serverless / managed runtimes

- `serverless.yml` / `serverless/` — each `functions:` entry is a container.
- AWS CDK / Pulumi / Terraform — look for `aws_lambda_function`, `aws_ecs_service`, `aws_ecs_task_definition`, `google_cloud_run_service`, `azurerm_function_app`, `azurerm_app_service`.
- `fly.toml`, `render.yaml`, `app.yaml` (App Engine), `Procfile` (Heroku) — each service/process definition is a container.

### Database schemas

A database schema that your system *owns* is a container. Evidence:
- ORM config files (`knexfile.js`, `prisma/schema.prisma`, `sequelize-cli`, `alembic.ini`, `schema.rb`, `ecto_migrations/`, `*.edmx`).
- Migration directories (`migrations/`, `db/migrate/`, `priv/repo/migrations/`).
- Table definition SQL files (`schema.sql`, `ddl/*.sql`).

If the repo talks to a DB it doesn't own (e.g. a shared enterprise DB), that's an **external system** on the Context diagram or an **external container** on the Container diagram.

### Message brokers, caches, object stores

Look for client library imports and connection strings:

| Tech | Imports / config |
|---|---|
| Kafka | `kafkajs`, `confluent-kafka`, `sarama`, `spring-kafka`; `KAFKA_BROKERS` env var |
| RabbitMQ | `amqplib`, `pika`, `rabbitmq-client`; `AMQP_URL` |
| Redis | `ioredis`, `redis-py`, `go-redis`, `StackExchange.Redis`; `REDIS_URL` |
| S3 / blob | AWS SDK (`s3`, `@aws-sdk/client-s3`), Azure Storage SDK, GCS SDK |
| Elasticsearch / OpenSearch | `@elastic/elasticsearch`, `opensearch-py` |

If you own the topic/bucket/index, it's a container. If you don't (it's provided by another team's system), the broker/bucket as a whole is either an external system or a shared infrastructure node on the Deployment diagram.

## 3. Find the external systems

Signals:

- **Third-party SDKs** — `stripe`, `twilio`, `@sendgrid/mail`, `plaid`, `auth0`, `okta-sdk`, `google-cloud-*`, `@slack/web-api`, `pagerduty`, `datadog`, `segment`, `mixpanel`.
- **Named hostnames** in config/env — `.env*`, `config/default.yml`, `application.yml`. Strip internal hostnames (same cluster/org) and keep external ones.
- **OAuth / OIDC / SAML** config — auth providers you depend on.
- **Webhook URLs** — incoming webhooks from external systems.
- **Email** — SMTP servers, SendGrid, SES, Mailgun.
- **Analytics / telemetry** — external observability backends.
- **Payment processors, CRM, helpdesk** — the usual "we don't build this, we rent it" systems.

Each of these is a `System_Ext` on the Context and Container diagrams.

## 4. Find the components

Components live inside a container. To find them, you need to pick one container and dig into its source.

### Per-language heuristics

**Java / Kotlin (Spring)**
- Classes annotated `@Component`, `@Service`, `@Repository`, `@RestController`, `@Controller`.
- Spring Boot auto-configuration modules.
- Top-level packages usually map to components — `com.example.orders.billing`, `com.example.orders.fulfilment`.

**Node / TypeScript**
- NestJS: `@Module` decorators. Each module is typically a component.
- Express / Fastify / Koa: route-registration files (`routes/*.ts`, `controllers/*.ts`) with clear domain names; services / repositories in matching dirs.
- Top-level `src/` directories (e.g. `src/orders`, `src/billing`) often map 1:1 to components.

**Python**
- Django: each "app" (`apps/*`, directory with `models.py`+`views.py`+`urls.py`) is a component.
- Flask / FastAPI: blueprints / routers — each `Blueprint()` or `APIRouter()` is a component.
- Plain Python: top-level packages under `src/`, each with a clear purpose.

**Go**
- Each package directory, especially those that expose a cohesive set of public types, is a candidate component.
- Standard layout: `internal/<domain>/<component>/` → components are the leaf dirs under domains.
- `cmd/<app>/main.go` identifies containers; `internal/` is where the components live.

**Ruby (Rails)**
- Rails engines (`engines/<name>/`) → component per engine.
- Otherwise, top-level directories under `app/` are too fine-grained (you rarely want "Controllers" as a component); look at domain groupings (`app/services/`, `app/domain/`, `lib/`).

**C# / .NET**
- One `.csproj` per component is a common convention.
- Within a single project, namespaces typically map to components.

**Frontend SPAs**
- Feature folders: `src/features/<feature>/`, `src/pages/<page>/`, `src/modules/<module>/`.
- Routing tree: the top-level routes often correspond to components.
- State stores (Redux slices, Zustand stores, Pinia modules) can be per-component.

### Evidence to capture per component

- **Name** — short noun phrase. "Order Intake", "Payment Gateway Adapter", "Audit Log Writer".
- **Description** — what it does in one sentence.
- **Technology** — framework/library specifics that matter. "Spring MVC REST Controller", "Apache Kafka consumer", "RxJS observable pipeline".
- **Files** — the 1–5 files that define it. Include a few line numbers if useful.
- **Outbound relationships** — other components it calls, containers it talks to (with protocol).
- **Inbound relationships** — who calls it.

### When *not* to draw a component

- **Frameworks and libraries** are technology choices, not components. Spring, React, Express, Celery — all go in the `techn` field.
- **Pure utility modules** (`lib/utils`, `shared/helpers`) rarely deserve component status. They're implementation details of the components that use them.
- **Cross-cutting concerns** (logging, metrics, auth middleware) — depends. If the concern is a dedicated subsystem with its own domain (e.g. a custom auth broker), yes. If it's `app.use(logger())`, no.

## 5. Find the relationships

For each container and each component, answer:
- **Who calls this?** — inbound relationships.
- **Who does this call?** — outbound relationships.
- **What protocol?** — for inter-container edges, always.

Evidence sources:

- **HTTP clients** — `fetch`, `axios`, `http.Client`, `RestTemplate`, `WebClient`, `OkHttpClient`, `HttpClient`, `requests`, `aiohttp`, `Faraday`. Grep for base URLs.
- **gRPC / Thrift** — client stubs (`*.pb.go`, `*_grpc.pb.go`, `*ServiceClient.java`).
- **Message producers** — look for `publish`, `send`, `produce`, `emit`, `enqueue` methods on broker clients.
- **DB access** — ORM imports and repository classes; direct connection strings.
- **Event handlers** — subscribers, listeners, consumers — `@EventListener`, `@KafkaListener`, `@RabbitListener`, Celery tasks, RQ workers, AWS Lambda event sources.

For each edge, label it with a verb phrase and (where it crosses a process) the protocol.

## 6. Separate static from runtime

When you find a flow of events in code (A publishes → B consumes → C calls → D stores), that's a candidate for a **Dynamic diagram**, not something to stuff into a Container diagram. Static diagrams show what exists; Dynamic diagrams show what happens.

## 7. Reconcile with deployment

Once you have the Container diagram, look at infra-as-code and CI/CD to build the Deployment diagram:

- Where does each container run? (EC2 / ECS / Lambda / K8s / Fargate / Cloud Run / App Service / …)
- Region / availability-zone distribution.
- Scaling — instance counts, autoscaling groups.
- Data-tier replication / failover.
- Front-door infrastructure — LBs, WAFs, CDNs.

## Checklist after extraction

- [ ] One Context diagram with the system-in-focus, all external systems, all types of users.
- [ ] One Container diagram with every deployable unit I can justify from the repo.
- [ ] Every external third-party service I could find in SDK/config dependencies.
- [ ] Every DB schema / bucket / topic the system owns.
- [ ] Every relationship labelled and protocoled.
- [ ] Assumptions and gaps flagged explicitly (`// NOTE: guessing — couldn't find evidence of how X talks to Y`).
- [ ] A Component diagram only for containers large enough to justify it (and only if asked).
