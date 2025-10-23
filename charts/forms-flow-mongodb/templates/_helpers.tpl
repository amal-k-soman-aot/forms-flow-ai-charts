{{/*
Expand the name of the chart.
*/}}
{{- define "forms-flow-mongodb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "forms-flow-mongodb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "forms-flow-mongodb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "forms-flow-mongodb.labels" -}}
helm.sh/chart: {{ include "forms-flow-mongodb.chart" . }}
{{ include "forms-flow-mongodb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "forms-flow-mongodb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "forms-flow-mongodb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "forms-flow-mongodb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "forms-flow-mongodb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
{{/*
Return the list of custom users to create during the initialization (string format)
*/}}
{{- define "forms-flow-mongodb.customUsers" -}}
    {{- $customUsers := list -}}
    {{- if .Values.auth.username -}}
        {{- $customUsers = append $customUsers .Values.auth.username }}
    {{- end }}
    {{- range .Values.auth.usernames }}
        {{- $customUsers = append $customUsers . }}
    {{- end }}
    {{- printf "%s" (default "" (join "," $customUsers)) -}}
{{- end -}}

{{/*
Return the list of passwords for the custom users (string format)
*/}}
{{- define "forms-flow-mongodb.customPasswords" -}}
    {{- $customPasswords := list -}}
    {{- if .Values.auth.password -}}
        {{- $customPasswords = append $customPasswords .Values.auth.password }}
    {{- end }}
    {{- range .Values.auth.passwords }}
        {{- $customPasswords = append $customPasswords . }}
    {{- end }}
    {{- printf "%s" (default "" (join "," $customPasswords)) -}}
{{- end -}}

{{/*
Return the list of custom databases to create during the initialization (string format)
*/}}
{{- define "forms-flow-mongodb.customDatabases" -}}
    {{- $customDatabases := list -}}
    {{- if .Values.auth.database -}}
        {{- $customDatabases = append $customDatabases .Values.auth.database }}
    {{- end }}
    {{- range .Values.auth.databases }}
        {{- $customDatabases = append $customDatabases . }}
    {{- end }}
    {{- printf "%s" (default "" (join "," $customDatabases)) -}}
{{- end -}}

{{/*
Create a default mongo service name which can be overridden.
*/}}
{{- define "forms-flow-mongodb.service.nameOverride" -}}
    {{- if and .Values.service .Values.service.nameOverride -}}
        {{- print .Values.service.nameOverride -}}
    {{- else -}}
        {{- if eq .Values.architecture "replicaset" -}}
            {{- printf "%s-headless" (include "forms-flow-mongodb.fullname" .) -}}
        {{- else -}}
            {{- printf "%s" (include "forms-flow-mongodb.fullname" .) -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created for MongoDB&reg;
*/}}
{{- define "forms-flow-mongodb.createConfigmap" -}}
{{- if and .Values.configuration (not .Values.existingConfigmap) }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}
