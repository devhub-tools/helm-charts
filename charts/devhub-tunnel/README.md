# devhub-tunnel

![Version: 2.44.1](https://img.shields.io/badge/Version-2.44.1-informational?style=flag) ![AppVersion: v2.44.1](https://img.shields.io/badge/AppVersion-v2.44.1-informational?style=flag)

Runs a Devhub Tunnel, which lets Devhub reach databases and the Kubernetes API in a network it cannot connect to directly. The Tunnel only makes outbound connections.

**Homepage:** <https://querydesk.com>

A Tunnel is a small program that runs inside your network and connects out to Devhub. Devhub uses it for two things:

- Opening a TCP connection to a host and port, for example a database.
- Sending requests to the Kubernetes API of the cluster the Tunnel runs in, using the Tunnel's service account. TerraDesk uses this to run its jobs.

With Kubernetes access on, the chart creates a Service that TerraDesk runner jobs in the namespace use to send their plan file to Devhub through the Tunnel. With it off, the Tunnel listens on no port and there is no Service.

Devhub accepts one instance of a Tunnel at a time, so the chart runs one pod and replaces it by stopping the old pod first. Create a second Tunnel in Devhub if you need one in another place.

## Installation

1. Create a Tunnel in Devhub and download its config: https://devhub.example.com/settings/tunnels

    You must be a super admin. The config is a JSON file with the Tunnel's id, the Devhub endpoint and a token.

1. Create a secret from the config file

    ```bash
    kubectl create namespace devhub-tunnel

    kubectl create secret generic devhub-tunnel-config \
      --from-file=config.json=./config.json \
      --namespace devhub-tunnel
    ```

    The key must be `config.json`. If you use a different secret name, set `config.existingSecret`.

1. Install with helm

    ```bash
    helm repo add devhub https://devhub-tools.github.io/helm-charts

    helm install devhub-tunnel devhub/devhub-tunnel \
      --version 2.44.1 \
      --namespace devhub-tunnel
    ```

    The Tunnel shows as online in Settings > Tunnels once it connects.

Keep the chart on the same version as your Devhub install.

### Kubernetes access

By default the chart creates a Role and RoleBinding in the release namespace. They let the Tunnel's service account manage the jobs, pods, pod logs and secrets that TerraDesk needs to run plans and applies. TerraDesk runs its jobs in the Tunnel's namespace. The jobs send their plan file to the Tunnel's Service in that namespace, and the Tunnel relays it to Devhub, so the jobs need no route to Devhub of their own.

If the Tunnel is only used to reach databases, turn Kubernetes access off:

```bash
helm install devhub-tunnel devhub/devhub-tunnel \
  --set kubernetes.enabled=false \
  --version 2.44.1 \
  --namespace devhub-tunnel
```

No Role or RoleBinding is created and the service account token is not mounted into the pod.

### Private certificate authority

If Devhub is served with a certificate from a private certificate authority, give the Tunnel the CA cert to trust.

```bash
kubectl create secret generic devhub-ca \
  --from-file=ca.crt=./ca.crt \
  --namespace devhub-tunnel

helm install devhub-tunnel devhub/devhub-tunnel \
  --set caSecret.name=devhub-ca \
  --version 2.44.1 \
  --namespace devhub-tunnel
```

Set `caSecret.key` if the cert is stored under a key other than `ca.crt`.

### Upgrades and restarts

The chart stops the old pod before it starts the new one, because Devhub accepts one instance of a Tunnel at a time. The old pod gets 30 seconds to finish open connections after it is asked to stop, and anything still open then ends with it. If Devhub restarts, the Tunnel reconnects within a few seconds.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| caSecret.key | string | `"ca.crt"` | Key in the secret that holds the PEM encoded CA cert. |
| caSecret.name | string | `""` | Secret name that contains a CA cert to trust when connecting to Devhub. Only needed if Devhub is served under a private certificate authority. |
| config.existingSecret | string | `"devhub-tunnel-config"` | Secret name that contains the Tunnel config downloaded from Settings > Tunnels. Must have `config.json`. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/devhub-tools/devhub-tunnel"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| kubernetes.enabled | bool | `true` | Lets Devhub reach the Kubernetes API of this cluster through the Tunnel's service account, which TerraDesk needs to run jobs. Set to false if the Tunnel is only used to reach databases. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| resources | object | `{}` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsGroup | int | `65532` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `65532` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| serviceAccount.annotations | object | `{}` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
