# crossplane-secret-sync

This roject contains a Helm chart allowing you to synchronize secrets from the [Crossplane](https://crossplane.io/) control plane into another cluster using the Crossplane [Helm provider](https://github.com/crossplane-contrib/provider-helm).

This serves as workaround for the lacking feature of patching from `Secrets` in Crossplane XRs.
See also issue [2772](https://github.com/crossplane/crossplane/issues/2772).

## Usage

Todo

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
