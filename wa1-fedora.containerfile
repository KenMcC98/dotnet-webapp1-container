FROM registry.fedoraproject.org/fedora:39

ARG DOTNET_MAJOR="8"

ENV \
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    # Do not show first run text
    DOTNET_NOLOGO=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # Configure web servers to bind to port 8080 when present
    ASPNETCORE_HTTP_PORTS=8080 \
    ASPNETCORE_HTTPS_PORTS=8443 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true

RUN dnf -y install openssl dotnet-sdk-${DOTNET_MAJOR}.0.x86_64

WORKDIR /app
COPY "./WebApplication1" .
RUN rm -rf ./bin && rm -rf ./obj

RUN dotnet publish ./WebApplication1.csproj -o /app/publish

WORKDIR /app/publish
ENTRYPOINT [ "dotnet", "WebApplication1.dll" ]