# devhub

![Version: 2.42.2](https://img.shields.io/badge/Version-2.42.2-informational?style=flag) ![AppVersion: v2.42.2](https://img.shields.io/badge/AppVersion-v2.42.2-informational?style=flag)

Instructions for running self hosted install of Devhub/QueryDesk. Currently only k8s install is supported, reach out to support@querydesk.com if you would like additional methods supported.

**Homepage:** <https://querydesk.com>

## Installation

1. Create a secret with the required application config

    | Key | Description |
    |-----|-------------|
    | `CLOAK_KEY_V1` | A base64 encoded 32 byte random value. Used as an encryption key for field level encryption. |
    | `SECRET_KEY_BASE` | A base64 encoded 64 byte random value. Used for signing cookies. |
    | `SIGNING_KEY` | A base64 encoded ECDSA private key using the prime256v1 curve. Used for signing JWT tokens. |

    The following example shows how to generate these values and create the secret using kubectl:

    ```bash
    CLOAK_KEY_V1=$(openssl rand -base64 32 | base64)
    SECRET_KEY_BASE=$(openssl rand -hex 64 | base64)
    SIGNING_KEY=$(openssl ecparam -name prime256v1 -genkey -noout | openssl ec 2>/dev/null | base64)

    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: config
      namespace: devhub
    data:
      CLOAK_KEY_V1: $CLOAK_KEY_V1
      SECRET_KEY_BASE: $SECRET_KEY_BASE
      SIGNING_KEY: $SIGNING_KEY
    EOF
    ```

1. Setup ingress

    You can use a Traefik ingressroute by setting `ingressRoute.enabled=true` if you have Traefik installed, otherwise configure your traffic
    to route to http://devhub.devhub.svc.cluster.local on port 80.

1. Setup a database

    See the docs below to either use a pre-configured database or your own.

1. Install with helm

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    # see below for different installation options
    ```

### Use a pre-configured database

1. Install the CloudNativePG operator and wait for it to be ready.

    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts

    helm upgrade --install cnpg \
      --namespace cnpg-system \
      --create-namespace \
      cnpg/cloudnative-pg

    kubectl rollout status deployment --watch -n cnpg-system cnpg-cloudnative-pg
    ```

1. Enable the postgresql setting to create a database.

    ```bash
    helm install devhub devhub/devhub \
      --set devhub.host=devhub.example.com \
      --set postgresql.enabled=true \
      --version 2.42.2 \
      --namespace devhub \
      --create-namespace
    ```

### Bring your own database

1. Ensure the wal_level is set to logical in your database and that the database user has replication permissions.

    ```sql
    ALTER SYSTEM SET wal_level='logical';
    ALTER USER devhub WITH REPLICATION;
    ```

    You must also restart your database for the changes to take effect.

1. Create a secret with the database connection information.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: postgres-app # if you use a different name, you must set the `devhub.database.secret`
      namespace: devhub
    data:
      host: ...
      user: ...
      password: ...
    ```

    ```bash
    helm install devhub devhub/devhub \
      --set devhub.host=devhub.example.com \
      --version 2.42.2 \
      --namespace devhub \
      --create-namespace
    ```

### Configure OIDC

OIDC can be configured in the app under Settings, or declaratively through the chart.

Add these keys to the application config secret. The first three are required, if any of them are
missing the settings are ignored.

| Key | Description |
|-----|-------------|
| `OIDC_DISCOVERY_DOCUMENT_URI` | The discovery document URI of your identity provider, for example `https://accounts.google.com/.well-known/openid-configuration`. |
| `OIDC_CLIENT_ID` | The client ID issued by your identity provider. |
| `OIDC_CLIENT_SECRET` | The client secret issued by your identity provider. |
| `OIDC_GROUPS_CLAIM` | Optional. The claim listing a user's groups, which Devhub turns into managed roles. Defaults to `roles`. |
| `OIDC_SCOPES` | Optional. Space-separated scopes requested at login. Must always include `openid`. Defaults to `openid email`. |

When the required keys are set they take precedence over anything configured in the app, and the OIDC
settings page becomes read-only so it is clear the values are managed by the helm chart.

Configure your identity provider with a redirect URI of `https://devhub.example.com/auth/oidc/callback`.

#### Group membership

There is no standard claim for group membership, so which one to read depends on your provider:

| Provider | `OIDC_GROUPS_CLAIM` | Notes |
|----------|---------------------|-------|
| Microsoft Entra ID | `roles` (the default) | App Roles from the app registration manifest. Entra's `groups` claim sends group object IDs rather than names, so it would create a role per ID. |
| Okta | `groups` | Configured per application. Depending on your setup the `groups` scope has to be requested as well, by setting `OIDC_SCOPES` to `openid email groups`. |

The values of the claim are used as role names, and the roles they create are managed by the identity
provider: a user who is no longer in a group loses the matching role the next time they log in.

Devhub only receives a user's name if `profile` is among the requested scopes, so set `OIDC_SCOPES` to
`openid email profile` if you want names rather than just email addresses.

### Using Agents

Agents are a secondary install that connect to the main instance. This allows your main instance to connect into other networks.

1. Create an agent in your main instance and download the config: https://devhub.example.com/settings/agents

1. Create a secret with the provided agent config

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: agent-config
      namespace: devhub
    data:
      agent-config.json: ... # the agent config you downloaded
    ```

1. Install the helm chart inside your destination network

    ```bash
    helm install devhub-agent devhub/devhub \
      --set devhub.host=devhub.example.com \
      --set devhub.agent=true \
      --set devhub.secret=agent-config \
      --version 2.42.2 \
      --namespace devhub
    ```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| devhub.agent | bool | `false` | Set to true if setting up an agent. |
| devhub.auth.emailHeader | string | `""` | Allows authenticating users with an auth proxy that forwards a header with the users email, for example X-Forwarded-Email. If set this is the only way users can login. |
| devhub.auth.groupsHeader | string | `""` | If authenticating with an auth proxy you can configure a header that can be used to add roles to the user. |
| devhub.database.secret | string | `"postgres-app"` | Secret name that contains the database connection details. Must have `host`, `user`, and `password`. May contain `dbname` and `port` (defaults to 5432). |
| devhub.database.ssl.caSecret | string | `"postgres-ca"` | Secret name that contains the database CA cert. Must have `ca.crt`. |
| devhub.database.ssl.clientCertSecret | string | `""` | Secret name that contains the database client cert. Must have both `tls.crt` and `tls.key`. |
| devhub.database.ssl.mode | string | `"disabled"` | Use `require` or `verify` to enable SSL. Disabled by default. |
| devhub.host | string | `"devhub.example.com"` | The hostname of your devhub instance. |
| devhub.proxy.tls.secret | string | `""` | Secret name that contains the TLS certs to be served by the proxy. Must have both `tls.crt` and `tls.key`. |
| devhub.secret | string | `"config"` | Secret name that contains the application config. See full docs for required keys. |
| extraEnvVars | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/devhub-tools/devhub"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingressRoute.enabled | bool | `false` | If you have Traefik installed in your cluster you can configure an IngressRoute: https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroute |
| ingressRoute.tls | object | `{}` |  |
| networkPolicy.create | bool | `false` | Set to true to create a network policy (disabled by default). An example network policy is provided in the values.yaml file. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgresql.cluster.affinity | object | `{}` |  |
| postgresql.cluster.backup | object | `{}` |  |
| postgresql.cluster.instances | int | `2` |  |
| postgresql.cluster.name | string | `"postgres"` |  |
| postgresql.cluster.primaryUpdateMethod | string | `"switchover"` |  |
| postgresql.cluster.primaryUpdateStrategy | string | `"unsupervised"` |  |
| postgresql.cluster.resources.limits.memory | string | `"1Gi"` |  |
| postgresql.cluster.resources.requests.cpu | string | `"20m"` |  |
| postgresql.cluster.sharedBuffers | string | `"256MB"` |  |
| postgresql.cluster.storage.size | string | `"10Gi"` |  |
| postgresql.cluster.storage.storageClass | string | `""` |  |
| postgresql.enabled | bool | `false` | Set to true to use a pre-configured database. The CloudNativePG operator is required. Please see the docs for configuration options: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-Cluster. |
| postgresql.scheduledBackup.enabled | bool | `false` | Set to true to enable scheduled backups. You must also provide the required configuration in `postgresql.cluster.backup`. |
| postgresql.scheduledBackup.schedule | string | `"0 0 0 * * *"` | The cron schedule for the backup. Defaults to daily. See docs for more information: https://pkg.go.dev/github.com/robfig/cron#hdr-CRON_Expression_Format |
| queryParser.image.pullPolicy | string | `"IfNotPresent"` |  |
| queryParser.image.repository | string | `"ghcr.io/devhub-tools/query-parser"` |  |
| replicaCount | int | `1` |  |
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