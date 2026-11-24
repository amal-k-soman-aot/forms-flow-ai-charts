# Formsflow.ai Offline Bridge

Receives offline form submissions from devices (HTTP JSON on 5010 and gRPC on 50051, through forms-flow-edge only) and puts them on the queue.

## Introduction

This chart bootstraps a forms-flow-bridge deployment on a [Kubernetes](https://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager. It is one of the
offline forms charts; see the install order below.

## Installing the Chart

```console
helm upgrade --install forms-flow-bridge forms-flow-bridge -n NAMESPACE
```

The pod waits for the `forms-flow-queue-init` and `forms-flow-objectstore-init`
Jobs before it starts (`waitForInitJobs`: `kubectl wait` with the chart's own
ServiceAccount and Role). Set `waitForInitJobs.jobs: []` to start without waiting.

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

