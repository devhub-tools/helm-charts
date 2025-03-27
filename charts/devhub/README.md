# devhub

![Version: 2.1.0](https://img.shields.io/badge/Version-2.1.0-informational?style=flag) ![AppVersion: v1.5.1](https://img.shields.io/badge/AppVersion-v1.5.1-informational?style=flag)

Instructions for running self hosted install of Devhub. Currently only k8s install is supported, reach out to support@devhub.tools if you would like additional methods supported.

**Homepage:** <https://devhub.tools>

## Installation

1. Install with helm

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub devhub/devhub \
      --set devhub.host=devhub.example.com \
      --version 2.1.0 \
      --namespace devhub \
      --create-namespace
    ```

1. Setup ingress

    You can use a Traefik ingressroute by setting `ingressRoute.enabled=true` if you have Traefik installed, otherwise configure your traffic
    to connect to http://devhub.devhub.svc.cluster.local on port 80.

### Define Postgres Database

1. Create a secret with the database connection information and provide the details in a values.yaml file (see full values available below).

    ```yaml
    devhub:
      host: devhub.example.com
      databaseConfig:
        host:
          secret: database-secret
          key: host
        user:
          secret: database-secret
          key: user
        password:
          secret: database-secret
          key: password

    postgresql:
      enabled: false
    ```

1. Install helm with the postgres flag disabled

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub devhub/devhub \
      -f values.yaml \
      --version 2.1.0 \
      --namespace devhub
    ```

### Using Agents

Agents are a secondary install that connect to the main instance. This allows your main instance to connect into other networks.

1. Create another helm installation and set the agent flag

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub-agent devhub/devhub \
      --set devhub.host=devhub.example.com \
      --set devhub.agent=true \
      --set devhub.secret=devhub-config \
      --version 2.1.0 \
      --namespace devhub
    ```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| devhub.agent | bool | `false` | Set to true if setting up an agent. |
| devhub.auth.emailHeader | string | `""` | Allows authenticating users with an auth proxy that forwards a header with the users email, for example X-Forwarded-Email. If set this is the only way users can login. |
| devhub.database.caSecret | string | `""` | Secret name that contains the database CA cert. Must have `ca.crt`. |
| devhub.database.clientCertSecret | string | `""` | Secret name that contains the database client cert. Must have both `tls.crt` and `tls.key`. |
| devhub.database.port | int | `5432` | Database connection port (defaults to `5432`). |
| devhub.database.ssl.mode | string | `"disabled"` | Use `require` or `verify` to enable SSL. Disabled by default. |
| devhub.host | string | `"devhub.example.com"` | The hostname of your devhub instance. |
| devhub.proxy.tls.secret | string | `""` | Secret name that contains the TLS certs to be served by the proxy. Must have both `tls.crt` and `tls.key`. |
| devhub.secret | string | `""` | Secret name that contains the application config. See full docs for required keys. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/devhub-tools/devhub"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingressRoute.enabled | bool | `false` | If you have Traefik installed in your cluster you can configure an IngressRoute: https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroute |
| ingressRoute.tls | object | `{}` |  |
| networkPolicy.create | bool | `false` | Set to true to create a network policy (disabled by default). |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgresql.cluster.instances | int | `2` |  |
| postgresql.cluster.name | string | `"postgres"` |  |
| postgresql.cluster.resources.limits.memory | string | `"1Gi"` |  |
| postgresql.cluster.resources.requests.cpu | string | `"20m"` |  |
| postgresql.cluster.sharedBuffers | string | `"256MB"` |  |
| postgresql.cluster.storage.size | string | `"4Gi"` |  |
| postgresql.cluster.storage.storageClass | string | `""` |  |
| postgresql.enabled | bool | `false` | Set to true to use a pre-configured CloudNativePG cluster. See instructions to configure the connection with `devhub.databaseConfig`. |
| postgresql.scheduledBackup.enabled | bool | `false` |  |
| postgresql.scheduledBackup.schedule | string | `"0 0 0 * * *"` |  |
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