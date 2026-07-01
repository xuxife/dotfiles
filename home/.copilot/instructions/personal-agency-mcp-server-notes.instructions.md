# Personal instructions: Agency MCP server notes

Per-server notes:
- **ado** requires `-- --org msazure`.
- **kusto** is native/fast; pass `cluster_uri` + `database` in call args.
  Common AKS clusters: `akshuba.centralus` / `akshubb.westus3` (db `AKSprod`),
  `aksccplogs.centralus` (db `AKSccplogs`), `aksinfra.centralus` (`AKSinfra`),
  `azcore.centralus` (`Fa`, `Crp`), `armprodgbl.eastus` (`ARMProd`),
  `icmcluster` (`IcmDataWarehouse`), `aksminfradm.centralus` (`AKSmetrics`).
- For **icm**, prefer the live `icm` server over backfilled Kusto.

When a task clearly needs one of these (incidents, Kusto, ADO, Graph, etc.),
just call it via `amcp` rather than asking me to wire up MCP config.
