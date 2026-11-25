{{/*
forms-flow-offline-worker helpers, in the style of forms-flow-api. Objects are named with
common.names.fullname: the release name when it contains the chart name
(install the release as "forms-flow-offline-worker"), or fullnameOverride.
*/}}

{{/* The objects' name. */}}
{{- define "forms-flow-offline-worker.name" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Labels for objects other than the Deployment (ConfigMaps, Jobs, ...).
Usage: {{ include "forms-flow-offline-worker.labels" (dict "name" "<object name>" "component" "x" "context" $) }}
An object named other than the chart (an init Job) gets its own
app.kubernetes.io/name, so its pods are not selected by the Service.
*/}}
{{- define "forms-flow-offline-worker.labels" -}}
{{- $custom := .context.Values.commonLabels | default dict -}}
{{- if ne .name (include "common.names.fullname" .context) -}}
{{- $custom = merge (dict "app.kubernetes.io/name" .name) $custom -}}
{{- end -}}
{{ include "common.labels.standard" (dict "customLabels" $custom "context" .context) }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{/* Create the name of the service account to use. */}}
{{- define "forms-flow-offline-worker.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/* Return the proper forms-flow-offline-worker image name. */}}
{{- define "forms-flow-offline-worker.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Another image (init containers, Jobs). Usage: {{ include "forms-flow-offline-worker.images.image" (dict "image" .Values.busybox.image "context" $) }} */}}
{{- define "forms-flow-offline-worker.images.image" -}}
{{ include "common.images.image" (dict "imageRoot" .image "global" .context.Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names (the Deployment's images). */}}
{{- define "forms-flow-offline-worker.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.waitForInitJobs.image) "context" $) -}}
{{- end -}}

{{/* imagePullSecrets for other images. Usage: {{ include "forms-flow-offline-worker.pullSecrets" (dict "images" (list .Values.image) "context" $) | nindent 6 }} */}}
{{- define "forms-flow-offline-worker.pullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" .images "context" .context) -}}
{{- end -}}

{{/*
An env var read from the forms-flow-ai ConfigMap / Secret (formsflow.configmap / formsflow.secret).
Usage: {{ include "forms-flow-offline-worker.aiConfig" (list "NATS_URL" "OFFLINE_NATS_URL" $) }}
*/}}
{{- define "forms-flow-offline-worker.aiConfig" -}}
{{- $ctx := index . 2 -}}
- name: {{ index . 0 }}
  valueFrom: {configMapKeyRef: {name: {{ $ctx.Values.formsflow.configmap | quote }}, key: {{ index . 1 }}}}
{{- end -}}

{{- define "forms-flow-offline-worker.aiSecret" -}}
{{- $ctx := index . 2 -}}
- name: {{ index . 0 }}
  valueFrom: {secretKeyRef: {name: {{ $ctx.Values.formsflow.secret | quote }}, key: {{ index . 1 }}}}
{{- end -}}

{{/*
Init container: waits until the init Jobs (waitForInitJobs.jobs:
forms-flow-queue-init, forms-flow-objectstore-init) are gone. They are Helm
hooks of charts forms-flow-queue and forms-flow-objectstore, and Helm removes
each one once it succeeds (a failed Job stays, so the pod keeps waiting).
A Job that is not there counts as done: install forms-flow-queue and
forms-flow-objectstore first (helm install waits for their Jobs).
*/}}
{{- define "forms-flow-offline-worker.waitForInitJobs" -}}
{{- with .Values.waitForInitJobs.jobs -}}
{{- $w := $.Values.waitForInitJobs -}}
- name: wait-for-init-jobs
  {{- /* Not on Docker Hub: global.imageRegistry is not applied. */}}
  image: {{ include "common.images.image" (dict "imageRoot" $w.image "global" (dict)) }}
  imagePullPolicy: {{ $w.image.pullPolicy }}
  command: ["kubectl"]
  args:
    - wait
    - --namespace={{ include "common.names.namespace" $ }}
    - --for=delete
    - --timeout={{ $w.timeout }}
    {{- range $.Values.waitForInitJobs.jobs }}
    - job/{{ . }}
    {{- end }}
  resources: {{- toYaml $w.resources | nindent 4 }}
{{- end }}
{{- end -}}
