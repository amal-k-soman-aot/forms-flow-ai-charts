# Changelog
## 8.5.0
### Added
  New chart, laid out like forms-flow-api: the gateway, an nginx sidecar
  serving it under /gatewayapi/, Service, Ingress, ServiceAccount, PDB and HPA.

  Offline forms env variables, read from the forms-flow-ai ConfigMap

    OFFLINE_WORKER_CLIENT_ID
    OFFLINE_WORKER_PUBLIC_KEY
    OFFLINE_ON_BEHALF_LEEWAY_S
    OFFLINE_REPLAY_REDIS_URL
