# DevHub

Instructions for running self hosted install of DevHub. Currently only k8s install is supported, reach out to support@devhub.tools if you would like additional methods supported.

## Installation

1. Install with helm

    ```bash
    # make sure to use helm 3.8.0 or later, or set `export HELM_EXPERIMENTAL_OCI=1`
    helm install devhub oci://ghcr.io/devhub-tools/helm-charts/devhub \
      --set devhub.host=devhub.example.com \
      --version 2.0.0 \
      --namespace devhub
    ```

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
    helm install devhub-agent oci://ghcr.io/devhub-tools/helm-charts/devhub \
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
    helm install devhub-agent oci://ghcr.io/devhub-tools/helm-charts/devhub \
      --set devhub.existingSecret=devhub-config \
      --set devhub.host=devhub.example.com \
      --set devhub.agent=true \
      --set postgresql.enabled=false \
      --version 2.0.0 \
      --namespace devhub
    ```