# Azure access

Before Azure or Azure DevOps work, confirm the auth path in the known-good
order:

1. `az account show` — CLI logged in, which tenant/subscription
2. `az devops configure -l` — default organization/project set
3. `az devops project list --top 1` — end-to-end DevOps connectivity
4. `az devops invoke` (GET) for REST areas the CLI doesn't cover

Never start with web fetches against portal/dev.azure.com URLs (auth-walled).
Use hand-built `az rest` token calls only after the CLI paths above are
exhausted. Logging in is interactive — ask the user
to run `az login` / `az devops login` themselves. (Claude Code sessions: the
`azure-preflight` skill automates the checks.)
