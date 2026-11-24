# Changelog
## 8.5.0
### Added
  New chart: Redis (service redis-exporter), moved out of chart
  forms-flow-ai (values section redisExporter). Same image, command,
  redis.conf, ports, probes, resources and volume (redis-data, 2Gi).

### Changed (compared with forms-flow-ai's redisExporter)
  - Values are at the top level (image, redisConfig, persistence, ...).
  - replicaCount is used (redisExporter.replicaCounts was ignored).
  - Selector labels use this release: app.kubernetes.io/instance=redis-exporter.
  - A ServiceAccount; the pod restarts when redis.conf changes.
