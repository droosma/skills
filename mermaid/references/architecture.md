# Architecture diagram (architecture-beta)

Use for cloud / infrastructure topology with icons. Newer than C4; better icon support, weaker for formal architecture modelling.

For software architecture in the C4 sense, prefer `C4Container` / `C4Component`.

## Header

```
architecture-beta
```

The `-beta` suffix is required (upstream is still stabilising).

## Four building blocks

1. **Groups** — containers for organising (cloud regions, VPCs, logical zones)
2. **Services** — the leaf nodes (DBs, servers, functions, etc.)
3. **Edges** — connections with directional anchors
4. **Junctions** — 4-way split points for routing complex edges

## Groups

```
group <id>(<icon>)[<label>] [in <parent>]
```

Example:
```
group api_zone(cloud)[Public API Zone]
group db_zone(cloud)[Private Data Zone]
group aws(cloud)[AWS ap-southeast-2]

group vpc_app(cloud)[VPC app-prod] in aws
```

Nesting via `in <parent>`.

## Services

```
service <id>(<icon>)[<label>] [in <parent>]
```

Examples:
```
service api(server)[API] in api_zone
service db(database)[Postgres] in db_zone
service s3(disk)[Uploads Bucket] in aws
service lambda(server)[Background Worker] in aws
```

### Built-in icons

`cloud`, `database`, `disk`, `internet`, `server`.

### Iconify icons (200k+ available)

Use the `"iconify:prefix:name"` form:
```
service redis("logos:redis")[Cache]
service auth("mdi:shield-account")[Auth]
```

Browse sets at https://icon-sets.iconify.design/.

## Edges

Directional anchors on each end: `T` (top), `B` (bottom), `L` (left), `R` (right).

```
<from>:<anchor> --- <anchor>:<to>         # plain line
<from>:<anchor> <-- <anchor>:<to>         # arrow in
<from>:<anchor> --> <anchor>:<to>         # arrow out
<from>:<anchor> <--> <anchor>:<to>        # bidirectional
```

Examples:
```
db:L -- R:api
api:T --> B:client
lb:B --> T:api
```

### Group-to-group edges

Use `{group}` on the side that's a group:
```
vpc_app{group}:R --> L:vpc_db{group}
```

### Edge labels

Not supported in `architecture-beta` at time of writing. Use a text annotation near the diagram or switch to C4/flowchart if labels are essential.

## Junctions

Connect three or more edges at a single point:
```
junction junc1 [in api_zone]

api:R --- L:junc1
junc1:T --- B:cache
junc1:R --- L:db
```

## Full example

```mermaid
architecture-beta
    group internet(internet)[Internet]
    group aws(cloud)[AWS ap-southeast-2]

    group vpc_pub(cloud)[Public Subnet] in aws
    group vpc_priv(cloud)[Private Subnet] in aws

    service user(server)[User] in internet
    service cdn("logos:aws-cloudfront")[CloudFront] in aws
    service alb("logos:aws-elb")[ALB] in vpc_pub
    service api(server)[API] in vpc_priv
    service db(database)[Postgres RDS] in vpc_priv
    service s3(disk)[S3 Static Assets] in aws
    service lambda("logos:aws-lambda")[Worker] in aws

    user:R --> L:cdn
    cdn:B --> T:alb
    cdn:B --> T:s3
    alb:B --> T:api
    api:R --> L:db
    api:B --> T:lambda
    lambda:L --> R:db
```

## Gotchas

- **`-beta` is part of the keyword.** `architecture` alone is a parse error.
- **Icon name in parens without brackets for the label**: `service id(icon)[label]`. Easy to reverse the order.
- **Iconify names are quoted**: `service r("logos:redis")[Cache]` — the quotes are required for strings with colons.
- **Anchors are 1 letter, no colon padding**: `api:R --> L:db` (not `api :R`).
- **No edge labels**. If you need labels, use flowchart or C4.
- **GitHub may lag** on `-beta` diagrams. Verify on the actual target renderer.
- **Layout is heuristic.** Re-order declarations to influence it; there is no direction keyword.
