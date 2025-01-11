# DevHub

Instructions for running self hosted install of DevHub. Currently only k8s install is supported, reach out to support@devhub.tools if you would like additional methods supported.

## Installation

1. Setup a postgres database and take note of credentials.

1. Create a private GitHub app `https://github.com/organizations/${GITHUB_ORG}/settings/apps/new`
    1. callback url: `https://devhub.example.com/auth/github/callback`
    1. setup url `https://devhub.example.com/github-setup`
    1. webhook url: `https://devhub.example.com/webhook/github`
    1. generate webhook secret and save it
    1. Permissions needed for metrics: contents read, deployments read, pull requests read

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
      DB_SSL: "false" # set to `true` if you want to enable SSL
      SECRET_KEY_BASE: # generate random secure value

      # GitHub app credentials (for sign in)
      GITHUB_CLIENT_ID:
      GITHUB_CLIENT_SECRET:

      ### OPTIONAL ###

      # Database SSL (if enabled)
      ca.cert:
      client.key:
      client.cert:

      # GitHub app credentials (for metric syncing and TerraDesk triggers)
      GITHUB_WEBHOOK_SECRET:
      GITHUB_PRIVATE_KEY:

      # Linear app credentials (for metric syncing)
      LINEAR_CLIENT_ID:
      LINEAR_CLIENT_SECRET:
      LINEAR_WEBHOOK_SECRET:

      # if configuring agents
      SHARED_ENCRYPTION_KEY: # 32 random bytes base64 encoded (used for encrypting communication between the server and agents)

      # if configuring workload identity with Google Cloud
      GOOGLE_PRIVATE_KEY: # generate a private key with `openssl genrsa -out privkey.pem 3072`
    ```

1. Install with helm

    ```bash
    # make sure to use helm 3.8.0 or later, or set `export HELM_EXPERIMENTAL_OCI=1`
    helm install devhub oci://ghcr.io/devhub-tools/helm-charts/devhub \
      --set devhub.host=devhub.example.com \
      --version x.x.x \
      --namespace devhub
    ```
