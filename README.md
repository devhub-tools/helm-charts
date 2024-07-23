# DevHub

Instructions for running self hosted install of DevHub. Currently only k8s install is supported, reach out to support@devhub.sh if you would like additional methods supported.

*Requires Enterprise plan.*

## Installation

1. Setup a postgres database and take note of credentials.

1. create k8s secret

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: devhub-config
      namespace: devhub
    type: Opaque
    data:
      ### REQUIRED ###

      CLOAK_KEY_V1: # 32 random bytes base64 encoded (used for encrypting senstive fields in the database)
      DB_HOSTNAME:
      DB_USERNAME:
      DB_PASSWORD:
      DB_SSL: "false" # set to "true" if you want to enable SSL
      LICENSE_KEY: # use api key created in first step
      SECRET_KEY_BASE: # generate random secure value

      # GitHub app credentials
      GITHUB_CLIENT_ID:
      GITHUB_CLIENT_SECRET:
      GITHUB_WEBHOOK_SECRET:
      GITHUB_PRIVATE_KEY:

      # Linear app credentials
      LINEAR_CLIENT_ID:
      LINEAR_CLIENT_SECRET:
      LINEAR_WEBHOOK_SECRET:

      ### OPTIONAL ###

      # Database SSL (if enabled)
      ca.cert:
      client.key:
      client.cert:
    ```

1. Install with helm

    ```bash
    # make sure to use helm 3.8.0 or later, or set `export HELM_EXPERIMENTAL_OCI=1`
    helm install devhub oci://ghcr.io/devhub-tools/helm-charts/devhub \
      --version x.x.x \
      --namespace devhub
    ```
