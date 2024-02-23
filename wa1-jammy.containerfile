FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy

RUN apt-get -y install openssl

WORKDIR /app
COPY "./WebApplication1" .
RUN rm -rf ./bin && rm -rf ./obj

RUN dotnet publish ./WebApplication1.csproj -o /app/publish

WORKDIR /app/publish
ENTRYPOINT [ "dotnet", "WebApplication1.dll" ]