# Changelog
## 8.5.0
### Changed
  Process engine calls go through forms-flow-process-gateway: BPM_API_URL
  is forms-flow-ai's PROCESS_GATEWAY_SERVICE_URL (was BPM_API_SERVICE_URL,
  Camunda directly). Added BPM_API_PREFIX (forms-flow-ai BPM_API_URL_PREFIX).

## 8.4.0 (2026-05-05)

### Added

  Added env variables
    STRIPE_WEBHOOK_SECRET
    STRIPE_SECRET_KEY
    STRIPE_PUBLISHABLE_KEY
    STRIPE_PRICING_TABLE_ID
    TRIAL_PERIOD
