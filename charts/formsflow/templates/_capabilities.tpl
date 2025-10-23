{{/*
Return the target Kubernetes version
*/}}
{{- define "formsflow.capabilities.kubeVersion" -}}
{{- default (default .Capabilities.KubeVersion.Version .Values.kubeVersion) ((.Values.global).kubeVersion) -}}
{{- end -}}

{{/*
Return true if the apiVersion is supported
Usage:
{{ include "formsflow.capabilities.apiVersions.has" (dict "version" "batch/v1" "context" $) }}
*/}}
{{- define "formsflow.capabilities.apiVersions.has" -}}
{{- $providedAPIVersions := default .context.Values.apiVersions ((.context.Values.global).apiVersions) -}}
{{- if and (empty $providedAPIVersions) (.context.Capabilities.APIVersions.Has .version) -}}
    {{- true -}}
{{- else if has .version $providedAPIVersions -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "formsflow.capabilities.policy.apiVersion" -}}
{{- print "policy/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "formsflow.capabilities.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for job.
*/}}
{{- define "formsflow.capabilities.job.apiVersion" -}}
{{- print "batch/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cronjob.
*/}}
{{- define "formsflow.capabilities.cronjob.apiVersion" -}}
{{- print "batch/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for daemonset.
*/}}
{{- define "formsflow.capabilities.daemonset.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "formsflow.capabilities.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}
{{- define "formsflow.capabilities.statefulset.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "formsflow.capabilities.ingress.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for RBAC resources.
*/}}
{{- define "formsflow.capabilities.rbac.apiVersion" -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for CRDs.
*/}}
{{- define "formsflow.capabilities.crd.apiVersion" -}}
{{- print "apiextensions.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for APIService.
*/}}
{{- define "formsflow.capabilities.apiService.apiVersion" -}}
{{- print "apiregistration.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "formsflow.capabilities.hpa.apiVersion" -}}
{{- $kubeVersion := include "formsflow.capabilities.kubeVersion" .context -}}
{{- print "autoscaling/v2" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Vertical Pod Autoscaler.
*/}}
{{- define "formsflow.capabilities.vpa.apiVersion" -}}
{{- $kubeVersion := include "formsflow.capabilities.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.25-0" $kubeVersion) -}}
{{- print "autoscaling/v1beta2" -}}
{{- else -}}
{{- print "autoscaling/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if PodSecurityPolicy is supported
*/}}
{{- define "formsflow.capabilities.psp.supported" -}}
{{- $kubeVersion := include "formsflow.capabilities.kubeVersion" . -}}
{{- if or (empty $kubeVersion) (semverCompare "<1.25-0" $kubeVersion) -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if AdmissionConfiguration is supported
*/}}
{{- define "formsflow.capabilities.admissionConfiguration.supported" -}}
{{- $kubeVersion := include "formsflow.capabilities.kubeVersion" . -}}
  {{- true -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for AdmissionConfiguration.
*/}}
{{- define "formsflow.capabilities.admissionConfiguration.apiVersion" -}}
{{- $kubeVersion := include "formsflow.capabilities.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.25-0" $kubeVersion) -}}
{{- print "apiserver.config.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "apiserver.config.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodSecurityConfiguration.
*/}}
{{- define "formsflow.capabilities.podSecurityConfiguration.apiVersion" -}}
{{- $kubeVersion := include "formsflow.capabilities.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.25-0" $kubeVersion) -}}
{{- print "pod-security.admission.config.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "pod-security.admission.config.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if the used Helm version is 3.3+.
A way to check the used Helm version was not introduced until version 3.3.0 with .Capabilities.HelmVersion, which contains an additional "{}}"  structure.
This check is introduced as a regexMatch instead of {{ if .Capabilities.HelmVersion }} because checking for the key HelmVersion in <3.3 results in a "interface not found" error.
**To be removed when the catalog's minimun Helm version is 3.3**
*/}}
{{- define "formsflow.capabilities.supportsHelmVersion" -}}
{{- if regexMatch "{(v[0-9])*[^}]*}}$" (.Capabilities | toString ) }}
  {{- true -}}
{{- end -}}
{{- end -}}