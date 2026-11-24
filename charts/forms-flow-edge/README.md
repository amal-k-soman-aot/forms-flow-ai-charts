# Formsflow.ai Offline Edge

Envoy, the devices' only door for offline form submissions: checks the sign-in token, turns gRPC-Web into gRPC and answers CORS for the web app. An nginx sidecar serves it under `/envoy` on the web host, like forms-flow-api's `/webapi`; `/envoy/healthz` is the load balancer's health check (Envoy's `/ready`).

## Introduction

This chart bootstraps a forms-flow-edge deployment on a [Kubernetes](https://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager. It is one of the
offline forms charts; see the install order below.

## Installing the Chart

```console
helm upgrade --install forms-flow-edge forms-flow-edge -n NAMESPACE \
  --set ingress.ingressClassName=INGRESS_CLASS --set ingress.hostname=forms-flow-web-NAMESPACE.DOMAIN
```

The web app reaches it at forms-flow-ai's `OFFLINE_EDGE_URL` (the web host
plus `forms-flow-edge.path`, `/envoy` by default): keep `ingress.path` the same.
`trustedHops` is the number of proxies in front of Envoy (1 behind the ALB).

### AWS Load Balancer Controller

```yaml
ingress:
  ingressClassName: alb
  hostname: forms-flow-web-NAMESPACE.DOMAIN
  pathSuffix: "/*"
  annotations:
    alb.ingress.kubernetes.io/group.name: ...
    alb.ingress.kubernetes.io/certificate-arn: ...
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443},{"HTTP":80}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/healthcheck-path: /envoy/healthz
    alb.ingress.kubernetes.io/success-codes: "200"
```

## Offline forms: install order

The offline components are separate charts. Settings they share with each
other and with the web app, API, gateway and BPM live in chart
**forms-flow-ai** (one values section per component: `forms-flow-web.offline`,
`forms-flow-queue`, `forms-flow-objectstore`, `forms-flow-bridge`, `forms-flow-edge`,
`forms-flow-offline-worker`, `forms-flow-queue-ui`),
whose ConfigMap and Secret they read. Install them in this order:

1. `forms-flow-ai` (with those sections, including the passwords and secrets)
2. `forms-flow-queue` (runs the `forms-flow-queue-init` Job, removed once it succeeds)
3. `forms-flow-objectstore` (runs the `forms-flow-objectstore-init` Job, removed once it succeeds)
4. `forms-flow-bridge`, `forms-flow-offline-worker` (they wait until both init Jobs have succeeded)
5. `forms-flow-edge`
6. `forms-flow-queue-ui` (optional)

