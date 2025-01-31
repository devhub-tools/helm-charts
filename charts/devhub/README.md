# devhub

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flag) ![AppVersion: v1.3.23](https://img.shields.io/badge/AppVersion-v1.3.23-informational?style=flag)

Instructions for running self hosted install of Devhub. Currently only k8s install is supported, reach out to support@devhub.tools if you would like additional methods supported.

**Homepage:** <https://devhub.tools>

## Installation

1. Install with helm

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub devhub/devhub \
      --set devhub.host=devhub.example.com \
      --version 2.0.0 \
      --namespace devhub
    ```

1. Setup ingress

    You can use a Traefik ingressroute by setting `ingressRoute.enabled=true` if you have Traefik installed, otherwise configure your traffic
    to connect to http://devhub.devhub.svc.cluster.local on port 80.

### Define Postgres Database

1. Create a secret with the database connection information and provide the details in a values.yaml file (see full values available below).

    ```yaml
    devhub:
      host: devhub.example.com
      postgresql:
        enabled: false
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
    ```

1. Install helm with the postgres flag disabled

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub devhub/devhub \
      -f values.yaml \
      --version 2.0.0 \
      --namespace devhub
    ```

### Using Agents

Agents are a secondary install that connect to the main instance. This allows your main instance to connect into other networks.

1. When using agents you need to make sure to define a shared encryption key for all installs.

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
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub-agent devhub/devhub \
      --set devhub.host=devhub.example.com \
      --set devhub.agent=true \
      --set postgresql.enabled=false \
      --set devhub.sharedEncryptionKey.existingSecret.name=devhub-config \
      --set devhub.sharedEncryptionKey.existingSecret.key=SHARED_ENCRYPTION_KEY \
      --version 2.0.0 \
      --namespace devhub
    ```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| devhub.agent | bool | `false` | Set to true if setting up an agent. |
| devhub.auth.emailHeader | string | `""` | Allows authenticating users with an auth proxy that forwards a header with the users email, for example X-Forwarded-Email. If set this is the only way users can login. |
| devhub.databaseConfig | object | `{"caCert":{},"clientCert":{},"clientKey":{},"encryptionKey":{"key":"CLOAK_KEY_V1","secret":"internal-secrets"},"host":{"key":"DB_HOSTNAME","secret":"internal-secrets"},"name":{"key":"DB_NAME","secret":"internal-secrets"},"password":{"key":"DB_PASSWORD","secret":"internal-secrets"},"port":{"key":"DB_PORT","secret":"internal-secrets"},"ssl":{"mode":"disabled"},"user":{"key":"DB_USERNAME","secret":"internal-secrets"}}` | See instructions for setting up secret to override application config. |
| devhub.databaseConfig.caCert | object | `{}` | Secret name and key that contains the CA cert. |
| devhub.databaseConfig.clientCert | object | `{}` | Secret name and key that contains the client cert. |
| devhub.databaseConfig.clientKey | object | `{}` | Secret name and key that contains the client private key. |
| devhub.databaseConfig.encryptionKey | object | `{"key":"CLOAK_KEY_V1","secret":"internal-secrets"}` | The database encryption key is automatically generated for you, but if you want to create your own it must be a 32 byte base64 encoded string. This can't be changed after install otherwise you will lose all encrypted data. |
| devhub.databaseConfig.encryptionKey.key | string | `"CLOAK_KEY_V1"` | The key inside the specified secret to load the encryption key from. |
| devhub.databaseConfig.encryptionKey.secret | string | `"internal-secrets"` | The secret that contains the database encryption key. |
| devhub.databaseConfig.host | object | `{"key":"DB_HOSTNAME","secret":"internal-secrets"}` | Secret name and key that contains the database host. |
| devhub.databaseConfig.name | object | `{"key":"DB_NAME","secret":"internal-secrets"}` | Secret name and key that contains the database name (defaults to `devhub`). |
| devhub.databaseConfig.password | object | `{"key":"DB_PASSWORD","secret":"internal-secrets"}` | Secret name and key that contains the database password. |
| devhub.databaseConfig.port | object | `{"key":"DB_PORT","secret":"internal-secrets"}` | Secret name and key that contains the database port (defaults to `5432`). |
| devhub.databaseConfig.ssl.mode | string | `"disabled"` | Use `require` or `verify` to enable SSL. Disabled by default. |
| devhub.databaseConfig.user | object | `{"key":"DB_USERNAME","secret":"internal-secrets"}` | Secret name and key that contains the database user. |
| devhub.host | string | `"devhub.example.com"` | The hostname of your devhub instance. |
| devhub.sharedEncryptionKey.existingSecret | object | `{}` | Set to true to use an existing secret for the shared encryption key. |
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