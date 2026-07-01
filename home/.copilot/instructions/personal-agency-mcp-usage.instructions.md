# Personal instructions: Agency MCP usage

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
