# Formsflow.ai Process Gateway

forms-flow-process-gateway sits between formsflow.ai and the process engines
(Camunda by default, `configuration.adapters`). It checks the user's Keycloak
token and passes process requests on to the engine. It also accepts the
offline worker's "on behalf of" tokens, so forms filled in offline can start
processes when they are synced.

## Introduction

This chart bootstraps a forms-flow-process-gateway deployment on a
[Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh)
package manager. It is laid out like chart forms-flow-api: the gateway
container plus an nginx sidecar that serves it under `/gatewayapi/` on port
8080, which the Ingress points to.

Most settings come from chart **forms-flow-ai**'s ConfigMap and Secret
(`formsflow.configmap`, `formsflow.secret`): Keycloak and token checks, the
web/API/admin URLs (allowed origins), the Camunda URL, the BPM client and the
WebSocket key. Install or upgrade forms-flow-ai first.

The API, admin, web app and offline worker call the process engine through
this gateway, using forms-flow-ai's `PROCESS_GATEWAY_SERVICE_URL` (in the
cluster), `PROCESS_GATEWAY_URL` (the web app, `https://<web host>/gatewayapi`)
and `BPM_API_URL_PREFIX` (`/api/v1`), set in its values section
`forms-flow-process-gateway`. Its `service.name` and `path` must match this
chart's name and `proxyPath`.

## Installing the Chart

```console
helm upgrade --install forms-flow-process-gateway forms-flow-process-gateway -n NAMESPACE \
  --set ingress.ingressClassName=INGRESS_CLASS --set ingress.hostname=HOSTNAME
```

`HOSTNAME` is the web app's host: the web app calls the gateway at
`https://HOSTNAME/gatewayapi/`. With the AWS ALB controller set
`ingress.path="/gatewayapi/*"`.

## Offline forms

The gateway checks the offline worker's "on behalf of" tokens with these
forms-flow-ai ConfigMap keys (values section `forms-flow-offline-worker`):

| Env variable                 | forms-flow-ai value                           |
|------------------------------|-----------------------------------------------|
| `OFFLINE_WORKER_CLIENT_ID`   | `forms-flow-offline-worker.clientid`          |
| `OFFLINE_WORKER_PUBLIC_KEY`  | `forms-flow-offline-worker.publicKey`         |
| `OFFLINE_ON_BEHALF_LEEWAY_S` | `forms-flow-offline-worker.onBehalfLeewayS`   |
| `OFFLINE_REPLAY_REDIS_URL`   | `forms-flow-offline-worker.replayRedisUrl`    |

With an empty `publicKey` no "on behalf of" token is accepted. Running more
than one copy (`replicaCount`, `autoscaling`) needs `replayRedisUrl`, so the
copies share the check that each token is used only once.

## Parameters

| Name                          | Description                                                                 | Value                                      |
|-------------------------------|-----------------------------------------------------------------------------|--------------------------------------------|
| `image.repository`            | Gateway image                                                               | `formsflow/forms-flow-process-gateway-ee`  |
| `image.tag`                   | Image tag                                                                   | `v7.3.1`                                   |
| `image.pullSecrets`           | Pull secrets (the -ee image is private)                                     | `[forms-flow-ai-auth]`                     |
| `formsflow.configmap`         | forms-flow-ai ConfigMap name                                                | `forms-flow-ai`                            |
| `formsflow.secret`            | forms-flow-ai Secret name                                                   | `forms-flow-ai`                            |
| `camundaBaseUrlKey`           | forms-flow-ai key for `CAMUNDA_BASE_URL` (`BPM_API_URL` or `BPM_API_SERVICE_URL`) | `BPM_API_URL`                        |
| `configuration.fastapiEnv`    | `FASTAPI_ENV`                                                               | `production`                               |
| `configuration.workers`       | `FORMSFLOW_PROCESS_GATEWAY_WORKERS` (uvicorn workers)                       | `1`                                        |
| `configuration.forwardedAllowIps` | `FORWARDED_ALLOW_IPS`                                                   | `*`                                        |
| `configuration.logLevel`      | `LOG_LEVEL`                                                                 | `INFO`                                     |
| `configuration.engineConfigFile` | `ENGINE_CONFIG_FILE`                                                     | `/app/config/gateway_config.yaml`          |
| `configuration.adapters`      | `GATEWAY_ADAPTERS`                                                          | `camunda`                                  |
| `configuration.camundaUrlPrefix` | `CAMUNDA_URL_PREFIX`                                                     | `/engine-rest-ext/v1`                      |
| `proxyPath`                   | Path nginx serves the gateway under (stripped before passing on)            | `/gatewayapi`                              |
| `maxSizePayload`              | Largest request body nginx accepts                                          | `50m`                                      |
| `ingress.enabled`             | Create the Ingress                                                          | `true`                                     |
| `ingress.hostname`            | The web app's host                                                          | `forms-flow-web.local`                     |
| `ingress.path`                | Ingress path                                                                | `/gatewayapi`                              |
| `ingress.servicePort`         | Service port the Ingress sends to (nginx)                                   | `8080`                                     |
| `extraEnvVars`                | Extra env variables, e.g. `JWT_OIDC_TIMEOUT_S`, `LOG_FORMAT`                | `[]`                                       |
| `resources`                   | Gateway container requests and limits                                       | see values.yaml                            |
| `livenessProbe`, `readinessProbe` | Probes on `GET /health`                                                 | enabled                                    |
| `autoscaling.enabled`         | Create a HorizontalPodAutoscaler                                            | `false`                                    |
| `pdb.create`                  | Create a PodDisruptionBudget                                                | `true`                                     |

The other parameters (scheduling, security contexts, extra volumes,
sidecars, service) are the same as in chart forms-flow-api.
