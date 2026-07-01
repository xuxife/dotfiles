# Personal instructions: Agency MCP server catalog

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
