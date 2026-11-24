# Formsflow.ai Offline Queue

NATS JetStream, the queue for offline form submissions (encrypted on disk with `jetstreamKey`), and the **forms-flow-queue-init** Job that creates or updates its streams and the worker's consumers.

## Introduction

This chart bootstraps a forms-flow-queue deployment on a [Kubernetes](https://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager. It is one of the
offline forms charts; see the install order below.

## Installing the Chart

```console
helm upgrade --install forms-flow-queue forms-flow-queue -n NAMESPACE \
  --set jetstreamKey=$(openssl rand -hex 32)
```

The init Job (`templates/queue-init-job.yaml`, settings in `templates/queue-init-configmap.yaml`)
is a Helm hook (`post-install`, `post-upgrade`): it runs again after every
install and upgrade of this chart, once the queue is up. It runs the webapi
image (`init.image`); `init.enabled: false` turns it off.

`nats.conf` (in `templates/configmap.yaml`) gives each component its own
NATS user with only the subjects it needs; their passwords come from the
forms-flow-ai Secret.

Never lose or change `jetstreamKey` once forms are stored. The volume is kept when the release is removed (`helm.sh/resource-policy: keep`).

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

