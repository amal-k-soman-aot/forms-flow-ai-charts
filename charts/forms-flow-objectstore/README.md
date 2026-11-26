# Formsflow.ai Offline Object Store

MinIO, the object store for offline form submissions: answers too large for a queue message (`large/`) and forms received while the queue is away (`pending/`). With the **forms-flow-objectstore-init** Job that creates the bucket, its clean-up rules and the bridge and worker users.

## Introduction

This chart bootstraps a forms-flow-objectstore deployment on a [Kubernetes](https://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager. It is one of the
offline forms charts; see the install order below.

## Installing the Chart

```console
helm upgrade --install forms-flow-objectstore forms-flow-objectstore -n NAMESPACE
```

The init Job (`templates/objectstore-init-job.yaml`, settings in
`templates/objectstore-init-configmap.yaml`) is a Helm hook (`post-install`,
`post-upgrade`): it runs again after every install and upgrade of this chart,
so changed store passwords always reach the store. It runs `/setup.sh` from
the objectstore image (or `init.image`).

The image runs as user minio (uid/gid 1000), so the volume is given to that
user. `podSecurityContext.fsGroup` does this only where the storage driver
applies it; the EFS CSI driver and NFS do not. So an init container
(`volumePermissions`, on by default, runs as root) changes the owner of
whatever in `/data` is not already 1000:1000. Without it MinIO fails on EFS
with "Unable to initialize backend: file access denied". Set
`volumePermissions.enabled=false` where root containers are not allowed.

`init.keepDays` must be more than forms-flow-ai's `forms-flow-queue.maxWaitDays` plus `maxHours` (in days); setup.sh checks it. The volume is kept when the release is removed (`helm.sh/resource-policy: keep`).

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

