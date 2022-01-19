# crossplane-secret-sync

This roject contains a Helm chart allowing you to synchronize secrets from the [Crossplane](https://crossplane.io/) control plane into another cluster using the Crossplane [Helm provider](https://github.com/crossplane-contrib/provider-helm).

This serves as workaround for the lacking feature of patching from `Secrets` in Crossplane XRs.
See also issue [2772](https://github.com/crossplane/crossplane/issues/2772).

## Usage

```yaml
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: my-secret-sync
spec:
  forProvider:
    namespace: default
    chart:
      name: crossplane-secret-sync
      repository: https://hferentschik.github.io/crossplane-secret-sync
      version: "0.0.3"
    values:
      secrets:
        - name: my-synced-secret
          type: Opaque
          data:
            - key: my-synced-key
    set:
      - name: secrets[0].data[0].value
        valueFrom:
          secretKeyRef:
            name: my-local-secret
            namespace: default
            key: my-key
  providerConfigRef:
    name: coyote-helm-provider-config
```

## Testing locally

To see how `Secrets` get rendered you can run `helm template` locally, eg:

```sh
helm template crossplane-secret-sync charts/crossplane-secret-sync --set secrets[0].name=foo,secrets[0].type=Opaque,secrets[0].data[0].key=foo,secrets[0].data[0].value=bar
```

## Releasing

To cut a new release:

```sh
version=0.0.1 # adjust version
make helm-release VERSION=$version
```
