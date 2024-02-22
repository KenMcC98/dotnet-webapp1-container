FROM localhost/local-net8-ubi8:0.0.1

WORKDIR /app
COPY "./WebApplication1" .

RUN dotnet publish ./WebApplication1.csproj -o /app/publish

WORKDIR /app/publish
ENTRYPOINT [ "dotnet", "WebApplication1.dll" ]