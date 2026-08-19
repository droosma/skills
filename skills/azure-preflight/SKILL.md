---
name: azure-preflight
description: >
  Verify a working Azure / Azure DevOps auth path in the known-good order before
  doing any Azure work, instead of burning rewrites on WebFetch or az rest token
  attempts that fail. Runs read-only checks (az account show, az devops defaults,
  a cheap az devops connectivity call), reports which path works, and records the
  working method for the session and in project CLAUDE.md. Use at the start of
  any session touching Azure DevOps (wiki, work items, repos, pipelines) or Azure
  resources (cost, config, queries), when the user says "azure preflight", or
  after any az / DevOps auth error.
---

# Azure Preflight

Auth path discovery has repeatedly cost multiple rewrites per session. Do it
once, in the known-good order, before any real Azure work.

## Known-good order

1. **`az account show`** — is the CLI logged in, and to which tenant/subscription?
2. **`az devops configure -l`** — are default organization/project set?
3. **Cheap DevOps call** — `az devops project list --top 1` (uses the default
   org) to prove end-to-end DevOps connectivity.
4. For anything the `az devops` / `az repos` / `az boards` / `az pipelines`
   commands don't cover, use **`az devops invoke`** (defaults to GET) against
   the REST area/resource.

**Never** start with WebFetch against Azure portals or DevOps URLs (auth-walled,
always fails) and don't hand-build `az rest` calls with manually acquired tokens
until the CLI paths above are exhausted.

## Procedure

1. Run `preflight.ps1` (sits next to this SKILL.md — resolve it relative to the
   skill directory):

   ```powershell
   pwsh -NoProfile -File <skill-dir>/preflight.ps1
   ```

   It runs the checks above read-only and prints which path works. The correct
   tenant/subscription depends on where you run from, so **nothing is
   hardcoded** — the script discovers the *expected* context (see below),
   reports the *active* tenant, and warns on a mismatch (the usual cause of the
   browser sign-in landing on the wrong tenant).

2. **If a step fails on auth:** logging in is interactive — don't attempt it
   yourself. Ask the user to run `! az login` (and `! az devops login` if PAT
   auth is needed) in this session, then re-run the preflight. When an expected
   tenant is known, the script prints the exact `az login --tenant <id>` to run
   so the browser doesn't default to a different tenant.

3. **Record the outcome.** State the working method in one line at the start of
   the work. If the project has a CLAUDE.md and the working pattern isn't in it
   yet, add it under an "Azure access" note so no future session re-derives it.

## Context-aware tenant selection

Because a single machine's CLI often spans several tenants (e.g. one client per
tenant), the "right" tenant is per-project, never global. The preflight resolves
the expected tenant/subscription in this priority order:

1. `-Tenant` / `-Subscription` parameters on the script.
2. `AZURE_PREFLIGHT_TENANT` / `AZURE_PREFLIGHT_SUBSCRIPTION` environment vars.
3. A **`.azure-preflight.json`** file, discovered by walking up from the current
   directory to the drive root — so each repo declares its own tenant:

   ```json
   {
     "tenant": "<tenant id or domain>",
     "subscription": "<subscription id or name>",
     "devopsOrg": "https://dev.azure.com/<org>"
   }
   ```

Behaviour:

- **Expected tenant known + active tenant matches** → proceeds normally.
- **Expected tenant known + mismatch** → warns and emits the scoped
  `az login --tenant <id>` (and `az account set --subscription …`) to run; exits
  non-zero so the mismatch isn't silently ignored.
- **Nothing configured** → lists the tenants/subscriptions available in the CLI
  so the correct one is discoverable, and suggests adding a
  `.azure-preflight.json`.

Prefer committing `.azure-preflight.json` at each Azure-touching repo's root (or
setting the env vars per shell) rather than passing tenant IDs by hand.

## During the session

- Prefer read-only verbs (`show`, `list`, `get`) for research; confirm before
  any `create`/`update`/`delete`/`set`.
- If a call fails mid-session with 401/403, re-run the preflight before
  rewriting the query — expired tokens look like query bugs.
- For fan-out research (cost analysis, security posture sweeps), delegate to
  the `azure-reader` agent, telling it which auth path the preflight confirmed.
