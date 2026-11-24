# Formsflow.ai Offline Worker

Takes offline form submissions from the queue and saves them with the API's code. It gets the same settings as forms-flow-api (charts forms-flow-ai and forms-flow-api) plus the offline ones.

## Introduction

This chart bootstraps a forms-flow-offline-worker deployment on a [Kubernetes](https://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager. It is one of the
offline forms charts; see the install order below.

## Installing the Chart

```console
helm upgrade --install forms-flow-offline-worker forms-flow-offline-worker -n NAMESPACE \
  --set clientSecret=... -f worker-key.yaml
```

The worker signs in with the Keycloak client forms-flow-ai `forms-flow-offline-worker.clientid`
(`clientSecret` here) and signs "on behalf of" tokens with `signingKey`, an
RSA private key (PEM, line breaks written as `\n`). Its public half is
forms-flow-ai's `forms-flow-offline-worker.publicKey`, which the API, gateway and BPM
check. Make the pair and the two values files:

```console
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out worker-private.pem
openssl pkey -in worker-private.pem -pubout -out worker-public.pem
# for this chart
printf "signingKey: '%s'\n" "$(awk 1 ORS='\\n' worker-private.pem)" > worker-key.yaml
# for forms-flow-ai (-f worker-public-key.yaml)
printf "forms-flow-offline-worker:\n  publicKey: '%s'\n" "$(awk 1 ORS='\\n' worker-public.pem)" > worker-public-key.yaml
```

Pass the keys in values files, not with `--set`/`--set-string`: those treat
`\` as an escape character and would turn the `\n` line breaks into `n`.

Like the bridge, the pod waits until both init Jobs have succeeded: Helm
removes each Job once it succeeds, and the pod waits until they are gone
(`waitForInitJobs`). A failed Job stays, so the pod keeps waiting.

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

