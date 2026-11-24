# Redis for formsflow.ai (redis-exporter)

The Redis server formsflow.ai uses, reached at `redis-exporter:6379`. Until
8.5.0 it was part of chart forms-flow-ai (values section `redisExporter`);
it is now its own chart, so it can be installed, upgraded and sized apart
from forms-flow-ai.

| Database | Used by | Set in |
|---|---|---|
| `redis://redis-exporter:6379/0` | forms-flow-analytics (Redash) | forms-flow-analytics `externalRedis` |
| `redis://redis-exporter:6379/1` | API, documents API, data layer, offline worker (`REDIS_URL`) | forms-flow-ai `redis_url` |
| `redis://redis-exporter:6379/2` | process gateway, BPM (offline worker's one-time tokens) | forms-flow-ai `forms-flow-offline-worker.replayRedisUrl` |

## Installing the Chart

```console
helm upgrade --install redis-exporter redis-exporter -n NAMESPACE
```

Install it with forms-flow-ai, before the components that use it. The
objects are named `redis-exporter` (`fullnameOverride`); the other charts'
Redis URLs use that name.

## Moving an existing install out of forms-flow-ai

An install made with forms-flow-ai before 8.5.0 has a StatefulSet, Service
and ConfigMap named `redis-exporter` that belong to the forms-flow-ai
release, and a volume `redis-data-redis-exporter-0`. Upgrading forms-flow-ai
to 8.5.0 deletes those three objects (not the volume). To move them without
losing the volume:

```console
# 1. Keep them when forms-flow-ai is upgraded
kubectl -n NAMESPACE annotate statefulset/redis-exporter service/redis-exporter configmap/redis-exporter helm.sh/resource-policy=keep
# 2. Upgrade forms-flow-ai to 8.5.0
# 3. The StatefulSet's selector cannot change: delete it (the volume stays)
kubectl -n NAMESPACE delete statefulset redis-exporter
# 4. Let this chart take over the Service and ConfigMap
kubectl -n NAMESPACE annotate service/redis-exporter configmap/redis-exporter --overwrite \
  meta.helm.sh/release-name=redis-exporter meta.helm.sh/release-namespace=NAMESPACE helm.sh/resource-policy-
kubectl -n NAMESPACE label service/redis-exporter configmap/redis-exporter --overwrite app.kubernetes.io/managed-by=Helm
# 5. Install this chart; the new pod reuses redis-data-redis-exporter-0
helm upgrade --install redis-exporter redis-exporter -n NAMESPACE
```

Redis is down between steps 3 and 5. It holds a cache, sessions and token
marks only (`appendonly no`), so nothing is lost that is not rebuilt.

## Parameters

| Name | Description | Value |
|---|---|---|
| `image.repository` | Redis image | `redis` |
| `image.tag` | Image tag | `7.4.1` |
| `fullnameOverride` | Objects' name (keep it: the Redis URLs use it) | `redis-exporter` |
| `redisConfig` | `redis.conf` | see values.yaml |
| `command` | Container command | `/conf/update-node.sh redis-server /conf/redis.conf` |
| `replicaCount` | Pods (keep 1: they are independent servers) | `1` |
| `resources` | Requests and limits | 50m/256Mi, limit 60m/512Mi |
| `persistence.enabled` | Volume for `/data` (otherwise an emptyDir) | `true` |
| `persistence.size` | Volume size | `2Gi` |
| `persistence.storageClass` | Storage class (empty: the cluster's default) | `""` |
| `livenessProbe`, `readinessProbe` | TCP on the client port; `redis-cli ping` | enabled |
| `service.ports` | `client` 6379, `gossip` 16379 | |

The scheduling, security context, extra env/volume and sidecar parameters
are the same as in chart forms-flow-api.
