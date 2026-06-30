# Personal instructions

## Branch naming

When creating new branches (including worktree branches), use the pattern:

```
xuxife/yy/mm/dd/<feature>
```

Where `yy/mm/dd` is today's date (2-digit year/month/day) and `<feature>` is a short
kebab-case description of the change.

## GitHub accounts

I have two GitHub identities and two `gh` CLI accounts authenticated locally:

| Context | MS alias | GitHub login | gh account |
|---|---|---|---|
| Work (Microsoft corp) | `xingfeixu` | `xingfeixu_microsoft` | `xingfeixu_microsoft` |
| Personal | — | `xuxife` | `xuxife` |

Rules:

- **Pick the right account per repo.** Microsoft corporate repos (e.g.
  `azure-management-and-platforms/*`, `microsoft/*`, anything under an MS
  org) → use `xingfeixu_microsoft`. Personal repos under `xuxife/*` → use
  `xuxife`.
- Check which account is active before running `gh` ops:
  ```sh
  gh auth status
  ```
- Switch with:
  ```sh
  gh auth switch -u <account>
  ```
- When @-mentioning Microsoft folks in corp-repo issues/PRs, the convention
  is `@<alias>_microsoft` (not the bare alias). Verify the handle exists
  with `gh api users/<login>` first.

## Agency MCP — call on demand, don't preload

I deliberately keep MCP servers **out of the chat context** (no live
`~/.copilot/mcp-config.json`). Instead, reach Microsoft/Azure MCP tools
**on demand** through the helper `~/.local/bin/amcp`, which spawns
`agency mcp <server>`, does the stdio handshake, runs a single call, and
exits — zero standing MCP context. Auth is silent via the azureauth cache.

Usage:

```sh
amcp tools <server>                      # list a server's tools + schemas
amcp call  <server> <tool> '<json-args>' # invoke one tool
amcp tools <server> -- <extra-args>      # pass args through to `agency mcp`
```

Examples:

```sh
amcp tools kusto
amcp tools ado -- --org msazure
amcp call icm get_incident '{"id":123456789}'
```

Per-server notes:
- **ado** requires `-- --org msazure`.
- **kusto** is native/fast; pass `cluster_uri` + `database` in call args.
  Common AKS clusters: `akshuba.centralus` / `akshubb.westus3` (db `AKSprod`),
  `aksccplogs.centralus` (db `AKSccplogs`), `aksinfra.centralus` (`AKSinfra`),
  `azcore.centralus` (`Fa`, `Crp`), `armprodgbl.eastus` (`ARMProd`),
  `icmcluster` (`IcmDataWarehouse`), `aksminfradm.centralus` (`AKSmetrics`).
- For **icm**, prefer the live `icm` server over backfilled Kusto.

Available agency MCP servers (run `agency mcp` for the authoritative list).
**Tool counts verified by `amcp tools <server>` on 2026-06-30** — all 33 below
respond; the 3 marked ⚠ need extra access grants (token rejected).

| Server | Tools | What it's for |
|---|---|---|
| `smart-dri` | 65 | SmartDRIAgent (DRI productivity) |
| `cloudbuild` | 48 | CloudBuild |
| `ecs` | 46 | Experimentation & Configuration Service |
| `top` | 43 | Teams Ops Plane incident investigation |
| `sharepoint` | 36 | M365 SharePoint |
| `teams` | 36 | M365 Teams |
| `service-tree` | 35 | ServiceTree |
| `safefly` | 33 | Azure deployment safety platform |
| `ado` | 31 | Azure DevOps (repos, PRs, work items, wiki) — needs `-- --org msazure` |
| `engage` | 30 | Viva Engage |
| `icm` | 24 | ICM incidents (live) |
| `mail` | 22 | M365 Mail |
| `dvdr` | 21 | Dynamic Vulnerability Detection & Remediation |
| `onedrive` | 19 | M365 OneDrive |
| `calendar` | 16 | M365 Calendar |
| `s360-breeze` | 14 | S360 Breeze |
| `kusto` | 13 | Kusto/ADX queries (AKS, ARM, compute telemetry) |
| `planner` | 13 | M365 Planner |
| `atlas` | 11 | MCP Server for Enterprise (Atlas) |
| `workiq` | 10 | WorkIQ |
| `enghub` | 7 | EngineeringHub (eng.ms) docs/services |
| `fluent` | 7 | Fluent |
| `bluebird` | 6 | Engineering Copilot Mini |
| `logger` | 5 | Emit App Insights events / per-session log folder |
| `m365-user` | 5 | User/manager/team/reportees via Graph |
| `mrc` | 4 | Microsoft Release Communications (M365/Azure roadmap) |
| `perf-pas` | 4 | Performance Analyzer Service (cross-MS perf) |
| `word` | 4 | M365 Word |
| `es-chat` | 3 | ES Chat |
| `graph` | 3 | Microsoft Graph (Enterprise) |
| `msft-learn` | 3 | Microsoft Learn docs |
| `watson` | 3 | Watson |
| `m365-copilot` | 1 | Search M365 content (docs, mail, sites, files, chats) |
| `change-ledger` | ⚠ 403 | Azure change tracking ledger — *needs access grant* |
| `domain-lens` | ⚠ 401 | Microsoft domains / OCDI status — *needs access grant* |
| `security-context` | ⚠ 403 | Azure Security Context — *needs access grant* |

When a task clearly needs one of these (incidents, Kusto, ADO, Graph, etc.),
just call it via `amcp` rather than asking me to wire up MCP config.
