# Invox Service Deploy - Helm Library Chart

A Helm library chart for deploying ATXINVOX microservices in a standardized way.

## Overview

This library chart provides reusable templates for deploying the following ATXINVOX microservices:
- `auth-service` - Authentication and authorization service
- `file-metadata-service` - File metadata management service
- `signup-service` - User registration service
- `storage-service` - File storage service

All services are deployed from GHCR (GitHub Container Registry) using the standardized base image.

## Usage

As a library chart, this chart cannot be deployed directly. Instead, it provides templates that other charts can include.

### Creating a Service Chart

1. Create a new Helm chart for your service:
   ```bash
   helm create my-service-chart
   ```

2. Add this library as a dependency in `Chart.yaml`:
   ```yaml
   dependencies:
     - name: invox-service-deploy
       version: "0.1.0"
       repository: "file://../invox-service-deploy"
   ```

3. Update dependencies:
   ```bash
   helm dependency update
   ```

4. Replace the default templates with a single template that uses the library:

   **templates/all.yaml:**
   ```yaml
   {{ include "invox.microservice" . }}
   ```

5. Configure your service in `values.yaml`:

   ```yaml
   image:
     name: auth-service  # or file-metadata-service, signup-service, storage-service
     tag: latest

   service:
     ports:
       - name: http
         port: 80
         containerPort: 8000
         targetPort: http

   probes:
     liveness:
       enabled: true
       path: /health
     readiness:
       enabled: true
       path: /health

   envFrom:
     configMaps:
       - common-config
     secrets:
       - database-secret

   resources:
     limits:
       cpu: 500m
       memory: 512Mi
     requests:
       cpu: 250m
       memory: 256Mi
   ```

### Available Templates

This library provides the following templates:

#### Individual Resource Templates
- `invox.deployment` - Kubernetes Deployment
- `invox.service` - Kubernetes Service
- `invox.serviceAccount` - Kubernetes ServiceAccount
- `invox.hpa` - Horizontal Pod Autoscaler
- `invox.ingress` - Kubernetes Ingress

#### Helper Templates
- `invox.name` - Generate service name
- `invox.fullname` - Generate full qualified name
- `invox.labels` - Common labels
- `invox.selectorLabels` - Pod selector labels
- `invox.image` - Image name with registry
- `invox.resources` - Resource limits and requests
- `invox.envFrom` - Environment from ConfigMaps/Secrets
- `invox.livenessProbe` - Liveness probe configuration
- `invox.readinessProbe` - Readiness probe configuration

#### All-in-One Template
- `invox.microservice` - Complete microservice deployment (deployment, service, optional ingress, HPA, serviceAccount)

## Configuration Options

### Image Configuration
```yaml
image:
  registry: ghcr.io            # Container registry
  namespace: varkrish          # Registry namespace
  name: auth-service           # Service image name
  tag: latest                  # Image tag
  pullPolicy: IfNotPresent     # Pull policy
```

### Service Configuration
```yaml
service:
  type: ClusterIP
  ports:
    - name: http
      port: 80
      containerPort: 8000
      targetPort: http
      protocol: TCP
```

### Probes Configuration
```yaml
probes:
  liveness:
    enabled: true
    path: /health
    port: http
    initialDelaySeconds: 30
    periodSeconds: 10
  readiness:
    enabled: true
    path: /health
    port: http
    initialDelaySeconds: 5
    periodSeconds: 10
```

### Environment Configuration
```yaml
env:
  - name: DATABASE_URL
    value: "postgresql://..."

envFrom:
  configMaps:
    - common-config
    - service-specific-config
  secrets:
    - database-secret
    - api-keys
```

### Autoscaling Configuration
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Ingress Configuration
```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: auth.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: auth-tls
      hosts:
        - auth.example.com
```

## Examples

### Deploying Auth Service

**Chart.yaml:**
```yaml
apiVersion: v2
name: auth-service
description: ATXINVOX Authentication Service
type: application
version: 0.1.0
appVersion: latest

dependencies:
  - name: invox-service-deploy
    version: "0.1.0"
    repository: "file://../invox-service-deploy"
```

**values.yaml:**
```yaml
image:
  name: auth-service
  tag: latest

service:
  ports:
    - name: http
      port: 80
      containerPort: 8000

probes:
  liveness:
    path: /health
  readiness:
    path: /health

envFrom:
  configMaps:
    - auth-config
  secrets:
    - auth-secrets

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

**templates/all.yaml:**
```yaml
{{ include "invox.microservice" . }}
```

## Development

To modify this library chart:

1. Edit the templates in `templates/_helpers.tpl`
2. Update the `values.yaml` to add new configuration options
3. Test with a consumer chart
4. Update this README with any new features

## Dependencies

All services use:
- GHCR authentication via `ghcr-secret` imagePullSecret
- Standardized base image from `ghcr.io/varkrish/frappe-microservice-lib`
- Common labels with `app.kubernetes.io/part-of: atxinvox`