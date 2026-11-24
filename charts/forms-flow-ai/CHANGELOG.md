# Changelog
## 8.5.0
### Added
  Offline forms settings shared by more than one component (charts
  forms-flow-queue, forms-flow-objectstore, forms-flow-bridge,
  forms-flow-edge, forms-flow-offline-worker, forms-flow-queue-ui, and the
  web app, API, gateway and BPM), one values section per component:
  "forms-flow-web.offline", "forms-flow-queue", "forms-flow-objectstore",
  "forms-flow-bridge", "forms-flow-edge", "forms-flow-offline-worker" and
  "forms-flow-queue-ui".

  ConfigMap:

    OFFLINE_ENABLED
    OFFLINE_AUTO_SYNC_ENABLED
    OFFLINE_BUNDLES_ENABLED
    OFFLINE_MAX_HOURS
    OFFLINE_EDGE_URL
    OFFLINE_NETWORK_GOOD_MS
    OFFLINE_NETWORK_SLOW_MS
    OFFLINE_NETWORK_UNSTABLE_FAILURES
    OFFLINE_NETWORK_PROBE_TIMEOUT_MS
    OFFLINE_CONFIRMED_KEPT_HOURS
    OFFLINE_METADATA_BATCH_MAX_BYTES
    OFFLINE_METADATA_BATCH_MAX_COUNT
    OFFLINE_DATA_BATCH_MAX_BYTES
    OFFLINE_DATA_BATCH_MAX_COUNT
    OFFLINE_CUSTOM_SUBMISSION_ENABLED
    OFFLINE_WORKER_CLIENT_ID
    OFFLINE_WORKER_KEY_ID
    OFFLINE_WORKER_PUBLIC_KEY
    OFFLINE_ON_BEHALF_LEEWAY_S
    OFFLINE_REPLAY_REDIS_URL
    OFFLINE_TRACE_ENABLED
    OFFLINE_QUEUE_MAX_HOURS
    OFFLINE_QUEUE_MAX_WAIT_DAYS
    OFFLINE_NATS_URL
    OFFLINE_STORE_ENDPOINT_URL
    OFFLINE_STORE_BUCKET
    OFFLINE_STORE_REGION
    OFFLINE_STORE_ROOT_USER

  Secret:

    OFFLINE_NATS_SETUP_PASSWORD
    OFFLINE_NATS_BRIDGE_PASSWORD
    OFFLINE_NATS_WORKER_PASSWORD
    OFFLINE_NATS_VIEWER_PASSWORD
    OFFLINE_STORE_ROOT_PASSWORD
    OFFLINE_STORE_BRIDGE_SECRET
    OFFLINE_STORE_WORKER_SECRET

### Added (process gateway)
  ConfigMap keys for forms-flow-process-gateway (values section
  "forms-flow-process-gateway": path, apiPrefix, service), read by the API,
  admin, web app and offline worker

    PROCESS_GATEWAY_URL           https://<web host>/gatewayapi
    PROCESS_GATEWAY_SERVICE_URL   http://forms-flow-process-gateway:8000
    BPM_API_URL_PREFIX            /api/v1

### Changed
  CHATBOT_URL is now https://<web host>/webapi/conversations (was the
  removed forms-flow-data-analysis' /analysis/conversations).

### Removed
  Redis (StatefulSet, Service and ConfigMap "redis-exporter", values section
  redisExporter): it is now chart redis-exporter. Before upgrading an
  existing install, see that chart's README ("Moving an existing install").
  CHATBOT_SERVICE_URL. It pointed at the removed forms-flow-data-analysis
  (its values were gone, so the chart did not render without --set) and no
  chart read it.

## 8.4.0 (2025-04-14)
### Added
  Support for custom environment variables in configmap template.

  Added env variables in config and secret
    USER_NAME_DISPLAY_CLAIM 
    ENABLE_COMPACT_FORM_VIEW
    FORMIO_DB_NAME
    CHROME_DRIVER_TIMEOUT
    CONFIGURE_LOGS
    AI_FORM_GENERATION_LIMIT_TRIAL
    AI_FORM_GENERATION_LIMIT_PAID
    OPENAI_API_KEY

