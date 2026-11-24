# Formsflow.ai Offline Queue Viewer

NUI, a read-only viewer of the offline forms queue: how many forms wait in each stream and the trace of each form (never the answers). Served under `/queue` on the web host by an nginx sidecar.

## Introduction

This chart bootstraps a forms-flow-queue-ui deployment on a [Kubernetes](https://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager. It is one of the
offline forms charts; see the install order below.

## Installing the Chart

```console
helm upgrade --install forms-flow-queue-ui forms-flow-queue-ui -n NAMESPACE \
  --set ingress.ingressClassName=INGRESS_CLASS --set ingress.hostname=forms-flow-web-NAMESPACE.DOMAIN
```

It signs in to forms-flow-queue as `offline-viewer`, which may only read
counts and the trace stream. Its password is forms-flow-ai's
`forms-flow-queue-ui.natsPassword` (required for this chart).

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
    alb.ingress.kubernetes.io/healthcheck-path: /queue/healthz
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

