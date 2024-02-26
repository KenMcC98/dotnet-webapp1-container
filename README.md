# .NET 8 and ubi8-FIPS SSL Error

The following error originally occurred when trying to connect to a simple
.NET 8 WebApi, using curl or a web browser with TLSv1.3, when hosted in a pod
on a FIPS-enabled OpenShift Cluster:

```
$ curl -kv https://<openshift-url>:8089/weatherforecast
* processing: https://<openshift-url>:8089/weatherforecast
*   Trying [::1]:8089...
* Connected to <openshift-url> (::1) port 8089
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

The error would appear only when the container was in FIPS mode on OpenShift,
with successful execution when running the same container locally/in a non-FIPS environment.

A .NET 6 app did not experience this issue at all in the same scenario.

## Recreating the SSL Error Locally

I was able to recreate this issue in locally run `ubi8` and `fedora39` containers on a non-FIPS enabled host. 
The images use the distro-standard upstream OpenSSL versions from `dnf`: 

* `ubi8`: **OpenSSL 1.1.1k**
* `fedora39`: **OpenSSL 3.1.1**

All following images were built on a Fedora 39 host
with `podman` and `podman-compose` *(with Podman Desktop to monitor pods)*.

Containerfiles used:

* `wa1-fedora.containerfile`
* `wa1-ubi8.containerfile`

Below lists the steps to recreate the SSL error locally in
with FIPS enforced for OpenSSL through env variable `OPENSSL_FORCE_FIPS_MODE=1`. 

### Generate Certs

To generate sample certs, run this in the root project folder

```sh
./openssl-certs.sh
```

### Build App Images

To test the variety of scenarios, the following set of images will be built:

* `n8-wa1-ubi8`
  * *works without FIPS, **<u>error</u>** with FIPS*
* `n6-wa1-ubi8`
  * *works without FIPS, works with FIPS*
* `n8-wa1-fedora`
  * *works without FIPS, **<u>error</u>** with FIPS*
* `n6-wa1-fedora`
  * *works without FIPS, works with FIPS*
  
**NOTE:** FIPS is set using environment variables in the `docker-compose.yaml` file, so we build FIPS-agnostic images here.

#### `n8-wa1-ubi8`

```sh
podman build -f ./wa1-ubi8.containerfile -t n8-wa1-ubi8:0.0.1 --build-arg DOTNET_TARGET_VERSION="8" .
```

#### `n6-wa1-ubi8`

```sh
podman build -f ./wa1-ubi8.containerfile -t n6-wa1-ubi8:0.0.1 --build-arg DOTNET_TARGET_VERSION="6" .
```

#### `n8-wa1-fedora`

```sh
podman build -f ./wa1-fedora.containerfile -t n8-wa1-fedora:0.0.1 --build-arg DOTNET_TARGET_VERSION="8" .
```

#### `n6-wa1-fedora`

```sh
podman build -f ./wa1-fedora.containerfile -t n6-wa1-fedora:0.0.1 --build-arg DOTNET_TARGET_VERSION="6" .
```

### Run the App Images

The images can be simultaneously run by executing 

```
podman-compose up
```

This will use the included `docker-compose.yaml` file.
Five containers will be spawned, with the `./certs/` folder mounted:
* `n8-wa1-ubi8`
* *`n8-wa1-ubi8-fips` - error occurs*
* `n6-wa1-ubi8-fips`
* *`n8-wa1-fedora-fips` - error occurs*
* `n6-wa1-fedora-fips`

### Curl the Endpoints

The containers can be accessed via curl, with `n8-*-fips` containers experiencing
the above SSL error, and the others being successful:

```sh
curl -kv https://localhost:<8081|8082|8083|8084|8085>/WeatherForecast
```