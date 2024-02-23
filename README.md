# .NET 8 and ubi8-FIPS SSL Error

The following SSL error originally appeared when hosting a simple .NET 8 WebApi
in a ubi8 container, running on a FIPS-mandated OpenShift Cluster:

```
$ curl -kv https://localhost:8089/weatherforecast
* processing: https://localhost:8089/weatherforecast
*   Trying [::1]:8089...
* Connected to localhost (::1) port 8089
* ALPN: offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS alert, no application protocol (632):
* OpenSSL/3.1.1: error:0A000460:SSL routines::reason(1120)
* Closing connection
curl: (35) OpenSSL/3.1.1: error:0A000460:SSL routines::reason(1120)
```

The issue would appear only when running the container in FIPS mode on OpenShift,
with successful execution when running the same container locally/in a non-FIPS environment.

## Recreating the SSL Error Locally

I was able to recreate this issue in local-built images on a non-FIPS enabled host.

The following images were built on a Fedora 39 host
with `podman` and `podman-compose` *(with Podman Desktop to monitor pods)*.

Below lists several images:
* `ubi8.containerfile` - base `ubi8` image for .NET 8
* `wa1.containerfile` - image for running **WebApplication1** on `ubi8`
  * The error manifests here when FIPS mode is mandated for OpenSSL in the container.
* `wa1-jammy.containerfile` - image for running **WebApplication1** on the Microsoft .NET Ubuntu base image.
  * this can be run successfully both with & without FIPS.
* `wa1-bookworm.containerfile` - image for running **WebApplication1** on the Microsoft .NET Debian base image.
  * this can be run successfully both with & without FIPS.

Below lists the steps to recreate the SSL error locally in a `ubi8` container,
with FIPS enforced through env variable `OPENSSL_FORCE_FIPS_MODE=1`. 

### Generate Certs

To generate sample certs, run this in the root project folder

```sh
./openssl-certs.sh
```

### Build `ubi8` Base Image

```sh
podman build -f ./ubi8.containerfile -t net8-ubi8 .
```

This will set container-appropriate .NET environment variables and then install the **.NET 8 SDK** through `dnf`.

### Build App Images

Commands used to build each app image.
  
**NOTE:** FIPS is set using environment variables in the `docker-compose.yaml` file, so we build FIPS-agnostic images here.

#### `wa1.containerfile`

```sh
podman build -f ./wa1.containerfile -t wa1-ubi8:0.0.1 .
```

#### `wa1-jammy.containerfile`

```sh
podman build -f ./wa1-jammy.containerfile -t wa1-jammy:0.0.1 .
```

#### `wa1-bookworm.containerfile`

```sh
podman build -f ./wa1-bookworm.containerfile -t wa1-bookworm:0.0.1 .
```

### Run the App Images

The images can be simultaneously run by executing `podman-compose up`,
which will use the included `docker-compose.yaml` file.

Four containers will be spawned, with the `./certs/` folder mounted:
* `wa1` - **Working WebApi**
  * *no FIPS*
* `wa1-fips` - **Broken WebApi** with the above error manifesting
  * *with FIPS EnvVar*
* `wa1-jammy` - **Working WebApi**
  * *with FIPS EnvVar*
* `wa1-bkwrm` - **Working WebApi**
  * *with FIPS EnvVar*

### Curl the Endpoints

The containers can be accessed via curl, with `wa1-fips` experiencing
the above SSL error, and the others being successful:

```sh
curl -kv https://localhost:<8087|8088|8089|8090>/WeatherForecast
```