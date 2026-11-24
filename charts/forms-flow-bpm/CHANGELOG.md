# Changelog
## 8.5.0
### Added
  Offline forms env variables, read from the forms-flow-ai ConfigMap

    OFFLINE_WORKER_CLIENT_ID
    OFFLINE_WORKER_PUBLIC_KEY
    OFFLINE_REPLAY_REDIS_URL

### Fixed
  CAMUNDA_BPM_HISTORY_LEVEL (forms-flow-bpm ConfigMap, "audit") now reaches the container.

### Removed
  DATA_ANALYSIS_URL. It read forms-flow-ai's DATA_ANALYSIS_SERVICE_URL,
  removed with forms-flow-data-analysis, so the pod could not start.

## 8.4.0 (2026-04-14)
### Changed
  Updated Intentation in deployment yaml