{{/*
Expand the name of the chart.
*/}}
{{- define "Devhub.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "Devhub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "Devhub.labels" -}}
helm.sh/chart: {{ include "Devhub.chart" . }}
{{ include "Devhub.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "Devhub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "Devhub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "Devhub.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default "devhub" .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
