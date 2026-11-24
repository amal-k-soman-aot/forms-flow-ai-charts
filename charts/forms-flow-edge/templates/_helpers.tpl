{{/*
forms-flow-edge helpers, in the style of forms-flow-api. Objects are named with
common.names.fullname: the release name when it contains the chart name
(install the release as "forms-flow-edge"), or fullnameOverride.
*/}}

{{/* The objects' name. */}}
{{- define "forms-flow-edge.name" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Labels for objects other than the Deployment (ConfigMaps, Jobs, ...).
Usage: {{ include "forms-flow-edge.labels" (dict "name" "<object name>" "component" "x" "context" $) }}
An object named other than the chart (an init Job) gets its own
app.kubernetes.io/name, so its pods are not selected by the Service.
*/}}
{{- define "forms-flow-edge.labels" -}}
{{- $custom := .context.Values.commonLabels | default dict -}}
{{- if ne .name (include "common.names.fullname" .context) -}}
{{- $custom = merge (dict "app.kubernetes.io/name" .name) $custom -}}
{{- end -}}
{{ include "common.labels.standard" (dict "customLabels" $custom "context" .context) }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{/* Create the name of the service account to use. */}}
{{- define "forms-flow-edge.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/* Return the proper forms-flow-edge image name. */}}
{{- define "forms-flow-edge.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper nginx sidecar image name. */}}
{{- define "forms-flow-edge.nginx.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.ExtraContainer.image "global" .Values.global) }}
{{- end -}}

{{/* Another image (init containers, Jobs). Usage: {{ include "forms-flow-edge.images.image" (dict "image" .Values.busybox.image "context" $) }} */}}
{{- define "forms-flow-edge.images.image" -}}
{{ include "common.images.image" (dict "imageRoot" .image "global" .context.Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names (the Deployment's images). */}}
{{- define "forms-flow-edge.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.ExtraContainer.image) "context" $) -}}
{{- end -}}

{{/* imagePullSecrets for other images. Usage: {{ include "forms-flow-edge.pullSecrets" (dict "images" (list .Values.image) "context" $) | nindent 6 }} */}}
{{- define "forms-flow-edge.pullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" .images "context" .context) -}}
{{- end -}}

{{/*
An env var read from the forms-flow-ai ConfigMap / Secret (formsflow.configmap / formsflow.secret).
Usage: {{ include "forms-flow-edge.aiConfig" (list "NATS_URL" "OFFLINE_NATS_URL" $) }}
*/}}
{{- define "forms-flow-edge.aiConfig" -}}
{{- $ctx := index . 2 -}}
- name: {{ index . 0 }}
  valueFrom: {configMapKeyRef: {name: {{ $ctx.Values.formsflow.configmap | quote }}, key: {{ index . 1 }}}}
{{- end -}}

{{- define "forms-flow-edge.aiSecret" -}}
{{- $ctx := index . 2 -}}
- name: {{ index . 0 }}
  valueFrom: {secretKeyRef: {name: {{ $ctx.Values.formsflow.secret | quote }}, key: {{ index . 1 }}}}
{{- end -}}

{{/* Ingress annotations: ingress.annotations plus commonAnnotations. */}}
{{- define "forms-flow-edge.ingressAnnotations" -}}
{{- $merged := include "common.tplvalues.merge" (dict "values" (list .Values.ingress.annotations .Values.commonAnnotations) "context" .) -}}
{{- if and $merged (ne $merged "{}") }}
annotations: {{- include "common.tplvalues.render" (dict "value" $merged "context" .) | nindent 2 }}
{{- end }}
{{- end -}}
