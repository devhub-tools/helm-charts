# devhub

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flag) ![AppVersion: v1.3.23](https://img.shields.io/badge/AppVersion-v1.3.23-informational?style=flag)

Instructions for running self hosted install of DevHub. Currently only k8s install is supported, reach out to support@devhub.tools if you would like additional methods supported.

**Homepage:** <https://devhub.tools>

## Installation

1. Install with helm

    ```bash
    helm repo add devhub https://devhub.github.io/helm-charts

    helm install devhub devhub/devhub \
      --set devhub.host=devhub.example.com \
      --version 2.0.0 \
      --namespace devhub
    ```

1. Setup ingress

    You can use a Traefik ingressroute by setting `ingressRoute.enabled=true` if you have Traefik installed, otherwise configure your traffic
    to connect to http://devhub.devhub.svc.cluster.local on port 80.

### Define Postgres Database

1. Create a secret with the database connection information

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: devhub-config
      namespace: devhub
    type: Opaque
    data:
      ### REQUIRED ###
      DB_HOSTNAME:
      DB_USERNAME:
      DB_PASSWORD:
      DB_SSL: "false" # set to `true` if you want to enable SSL

      ### OPTIONAL ###
      # Database SSL (if enabled)
      ca.cert:
      client.key:
      client.cert:
    ```

1. Install helm with the postgres flag disabled

    ```bash
    helm repo add devhub https://devhub.github.io/helm-charts

    helm install devhub devhub/devhub \
      --set devhub.existingSecret=devhub-config \
      --set devhub.host=devhub.example.com \
      --set postgresql.enabled=false \
      --version 2.0.0 \
      --namespace devhub
    ```

### Using Agents

1. When using agents you need to make sure to define a shared encryption key for all deployments.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: devhub-config
      namespace: devhub
    type: Opaque
    data:
      SHARED_ENCRYPTION_KEY: # 32 random bytes base64 encoded
    ```

1. Create another helm installation and set the agent flag

    ```bash
    helm repo add devhub https://devhub.github.io/helm-charts

    helm install devhub-agent devhub/devhub \
      --set devhub.existingSecret=devhub-config \
      --set devhub.host=devhub.example.com \
      --set devhub.agent=true \
      --set postgresql.enabled=false \
      --version 2.0.0 \
      --namespace devhub
    ```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| devhub.agent | bool | `false` | Set to true if setting up an agent. |
| devhub.auth.emailHeader | string | `""` | Allows authenticating users with an auth proxy that forwards a header with the users email, for example X-Forwarded-Email. If set this is the only way users can login. |
| devhub.existingSecretName | string | `""` | See instructions for setting up secret to override application config. |
| devhub.host | string | `"devhub.example.com"` | The hostname of your devhub instance. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/devhub-tools/devhub"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingressRoute.enabled | bool | `false` | If you have Traefik installed in your cluster you can configure an IngressRoute: https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroute |
| ingressRoute.tls | object | `{}` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgresql.auth.database | string | `"devhub"` |  |
| postgresql.auth.existingSecret | string | `"internal-secrets"` |  |
| postgresql.auth.secretKeys.adminPasswordKey | string | `"DB_PASSWORD"` |  |
| postgresql.enabled | bool | `true` | Set to false to use an external database. See instructions to configure the connection with `devhub.existingSecretName`. |
| queryParser.image.pullPolicy | string | `"IfNotPresent"` |  |
| queryParser.image.repository | string | `"ghcr.io/devhub-tools/query-parser"` |  |
| queryParser.image.tag | string | `"v1.0.0"` |  |
| replicaCount | int | `1` |  |
| requestTracer.image.pullPolicy | string | `"IfNotPresent"` |  |
| requestTracer.image.repository | string | `"ghcr.io/devhub-tools/request-tracer"` |  |
| requestTracer.image.tag | string | `"v1.0.0"` |  |
| resources | object | `{}` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)