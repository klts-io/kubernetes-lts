# kubepatch

## Checkout to the specified patch release

Defined in the [./releases.yml](https://github.com/DaoCloud-OpenSource/kubepatch/blob/master/releases.yml)

``` bash
make v1.18.18-lts.0
```

## Build

### Build image

``` bash
make build-image
```

[Images artifacts](https://github.com/orgs/DaoCloud-OpenSource/packages?repo_name=kubepatch)

### Build client and server

``` bash
make build-client
make build-server
```

[Binaries artifacts](https://github.com/DaoCloud-OpenSource/kubepatch/releases)

### Official patch release

[patch release](https://kubernetes.io/releases/patch-releases/)
