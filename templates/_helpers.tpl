{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "invox.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "invox.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "invox.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "invox.labels" -}}
helm.sh/chart: {{ include "invox.chart" . }}
{{ include "invox.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: atxinvox
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "invox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "invox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "invox.serviceAccountName" -}}
{{- $serviceAccount := .Values.serviceAccount | default dict -}}
{{- if $serviceAccount.create | default true -}}
{{- default (include "invox.fullname" .) $serviceAccount.name -}}
{{- else -}}
{{- default "default" $serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Image name
*/}}
{{- define "invox.image" -}}
{{- $registry := .Values.image.registry | default "ghcr.io" -}}
{{- $namespace := .Values.image.namespace | default "varkrish" -}}
{{- $name := .Values.image.name | default .Chart.Name -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | default "latest" -}}
{{- if .Values.image.registry -}}
{{- printf "%s/%s/%s:%s" $registry $namespace $name $tag -}}
{{- else -}}
{{- $repo := .Values.image.repository | default "ghcr.io/varkrish" -}}
{{- printf "%s/%s:%s" $repo $name $tag -}}
{{- end -}}
{{- end -}}

{{/*
Container ports
*/}}
{{- define "invox.containerPorts" -}}
{{- if .Values.service.ports }}
ports:
{{- range .Values.service.ports }}
- name: {{ .name | default "http" }}
  containerPort: {{ .containerPort }}
  protocol: {{ .protocol | default "TCP" }}
{{- end }}
{{- else }}
ports:
- name: http
  containerPort: 8000
  protocol: TCP
{{- end }}
{{- end -}}

{{/*
Environment variables from ConfigMaps
*/}}
{{- define "invox.envFromConfigMaps" -}}
{{- if .Values.envFrom.configMaps }}
{{- range .Values.envFrom.configMaps }}
- configMapRef:
    name: {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Environment variables from Secrets
*/}}
{{- define "invox.envFromSecrets" -}}
{{- if .Values.envFrom.secrets }}
{{- range .Values.envFrom.secrets }}
- secretRef:
    name: {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
EnvFrom block
*/}}
{{- define "invox.envFrom" -}}
{{- $envFrom := .Values.envFrom | default dict -}}
{{- if or $envFrom.configMaps $envFrom.secrets }}
envFrom:
{{- if $envFrom.configMaps }}
{{- range $envFrom.configMaps }}
- configMapRef:
    name: {{ . }}
{{- end }}
{{- end }}
{{- if $envFrom.secrets }}
{{- range $envFrom.secrets }}
- secretRef:
    name: {{ . }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Liveness probe
*/}}
{{- define "invox.livenessProbe" -}}
{{- if .Values.probes.liveness.enabled }}
livenessProbe:
  httpGet:
    path: {{ .Values.probes.liveness.path }}
    port: {{ .Values.probes.liveness.port | default "http" }}
    scheme: {{ .Values.probes.liveness.scheme | default "HTTP" | upper }}
  initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds | default 30 }}
  periodSeconds: {{ .Values.probes.liveness.periodSeconds | default 10 }}
  timeoutSeconds: {{ .Values.probes.liveness.timeoutSeconds | default 5 }}
  successThreshold: {{ .Values.probes.liveness.successThreshold | default 1 }}
  failureThreshold: {{ .Values.probes.liveness.failureThreshold | default 3 }}
{{- end }}
{{- end -}}

{{/*
Readiness probe
*/}}
{{- define "invox.readinessProbe" -}}
{{- if .Values.probes.readiness.enabled }}
readinessProbe:
  httpGet:
    path: {{ .Values.probes.readiness.path }}
    port: {{ .Values.probes.readiness.port | default "http" }}
    scheme: {{ .Values.probes.readiness.scheme | default "HTTP" | upper }}
  initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds | default 5 }}
  periodSeconds: {{ .Values.probes.readiness.periodSeconds | default 10 }}
  timeoutSeconds: {{ .Values.probes.readiness.timeoutSeconds | default 5 }}
  successThreshold: {{ .Values.probes.readiness.successThreshold | default 1 }}
  failureThreshold: {{ .Values.probes.readiness.failureThreshold | default 3 }}
{{- end }}
{{- end -}}

{{/*
Resources
*/}}
{{- define "invox.resources" -}}
{{- if .Values.resources }}
resources:
  {{- if .Values.resources.limits }}
  limits:
    {{- if .Values.resources.limits.cpu }}
    cpu: {{ .Values.resources.limits.cpu }}
    {{- end }}
    {{- if .Values.resources.limits.memory }}
    memory: {{ .Values.resources.limits.memory }}
    {{- end }}
  {{- end }}
  {{- if .Values.resources.requests }}
  requests:
    {{- if .Values.resources.requests.cpu }}
    cpu: {{ .Values.resources.requests.cpu }}
    {{- end }}
    {{- if .Values.resources.requests.memory }}
    memory: {{ .Values.resources.requests.memory }}
    {{- end }}
  {{- end }}
{{- else }}
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
{{- end }}
{{- end -}}

{{/*
Complete deployment template
*/}}
{{- define "invox.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "invox.fullname" . }}
  labels:
    {{- include "invox.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount | default 1 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "invox.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "invox.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "invox.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: {{ include "invox.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" }}
          {{- include "invox.containerPorts" . | nindent 10 }}
          {{- include "invox.livenessProbe" . | nindent 10 }}
          {{- include "invox.readinessProbe" . | nindent 10 }}
          {{- include "invox.resources" . | nindent 10 }}
          {{- if .Values.env }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          {{- end }}
          {{- include "invox.envFrom" . | nindent 10 }}
          {{- if .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml .Values.volumeMounts | nindent 12 }}
          {{- end }}
      {{- if .Values.volumes }}
      volumes:
        {{- toYaml .Values.volumes | nindent 8 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end -}}

{{/*
Service template
*/}}
{{- define "invox.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "invox.fullname" . }}
  labels:
    {{- include "invox.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  ports:
    {{- if .Values.service.ports }}
    {{- range .Values.service.ports }}
    - port: {{ .port }}
      targetPort: {{ .targetPort | default .name | default "http" }}
      protocol: {{ .protocol | default "TCP" }}
      name: {{ .name | default "http" }}
    {{- end }}
    {{- else }}
    - port: {{ .Values.service.port | default 80 }}
      targetPort: http
      protocol: TCP
      name: http
    {{- end }}
  selector:
    {{- include "invox.selectorLabels" . | nindent 4 }}
{{- end -}}

{{/*
ServiceAccount template
*/}}
{{- define "invox.serviceAccount" -}}
{{- $serviceAccount := .Values.serviceAccount | default dict -}}
{{- if $serviceAccount.create | default true }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "invox.serviceAccountName" . }}
  labels:
    {{- include "invox.labels" . | nindent 4 }}
  {{- with $serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ $serviceAccount.automount | default true }}
{{- end -}}
{{- end -}}

{{/*
HPA template
*/}}
{{- define "invox.hpa" -}}
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "invox.fullname" . }}
  labels:
    {{- include "invox.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "invox.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
{{- end -}}

{{/*
Ingress template
*/}}
{{- define "invox.ingress" -}}
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "invox.fullname" . -}}
{{- $svcPort := .Values.service.port | default 80 -}}
{{- if and .Values.ingress.className (not (hasKey .Values.ingress.annotations "kubernetes.io/ingress.class")) }}
  {{- $_ := set .Values.ingress.annotations "kubernetes.io/ingress.class" .Values.ingress.className}}
{{- end }}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "invox.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if and .Values.ingress.className (semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion) }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- if and .pathType (semverCompare ">=1.18-0" $.Capabilities.KubeVersion.GitVersion) }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              {{- if semverCompare ">=1.19-0" $.Capabilities.KubeVersion.GitVersion }}
              service:
                name: {{ $fullName }}
                port:
                  number: {{ $svcPort }}
              {{- else }}
              serviceName: {{ $fullName }}
              servicePort: {{ $svcPort }}
              {{- end }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end -}}

{{/*
All-in-one template that includes common microservice resources
*/}}
{{- define "invox.microservice" -}}
{{- $serviceAccount := .Values.serviceAccount | default dict -}}
{{- if $serviceAccount.create | default true }}
{{- include "invox.serviceAccount" . }}
---
{{- end }}
{{ include "invox.deployment" . }}
---
{{ include "invox.service" . }}
{{- if .Values.autoscaling.enabled }}
---
{{ include "invox.hpa" . }}
{{- end }}
{{- if .Values.ingress.enabled }}
---
{{ include "invox.ingress" . }}
{{- end }}
{{- end -}}
