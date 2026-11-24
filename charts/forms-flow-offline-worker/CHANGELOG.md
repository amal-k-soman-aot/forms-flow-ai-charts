# Changelog
## 8.5.0

### Added
  New chart for offline form submissions: forms-flow-offline-worker.
  Shared settings are read from the forms-flow-ai ConfigMap and Secret
  (see forms-flow-ai 8.5.0).
  Process engine calls go through forms-flow-process-gateway: BPM_API_URL
  is forms-flow-ai's PROCESS_GATEWAY_SERVICE_URL, with BPM_API_URL_PREFIX.

