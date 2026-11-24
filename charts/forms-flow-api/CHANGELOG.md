# Changelog
## 8.5.0
### Added
  Offline forms env variables, read from the forms-flow-ai ConfigMap

    OFFLINE_ENABLED
    OFFLINE_AUTO_SYNC_ENABLED
    OFFLINE_WORKER_PUBLIC_KEY
    OFFLINE_WORKER_KEY_ID
    OFFLINE_CUSTOM_SUBMISSION_ENABLED

### Changed
  Process engine calls go through forms-flow-process-gateway: BPM_API_URL
  is forms-flow-ai's PROCESS_GATEWAY_SERVICE_URL (was BPM_API_SERVICE_URL,
  Camunda directly). Added BPM_API_URL_PREFIX (forms-flow-ai BPM_API_URL_PREFIX).

## 8.4.0 (2026-04-14)

### Added
  Added env variables

    AI_FORM_GENERATION_LIMIT_TRIAL
    AI_FORM_GENERATION_LIMIT_PAID
    OPENAI_API_KEY