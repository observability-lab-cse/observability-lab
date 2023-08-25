#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["DeviceManager.csproj", "."]
RUN dotnet restore "./DeviceManager.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "DeviceManager.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DeviceManager.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ARG OTEL_VERSION=1.0.0-rc.2
ADD https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/download/v${OTEL_VERSION}/otel-dotnet-auto-install.sh otel-dotnet-auto-install.sh
RUN apt-get update && apt-get install -y unzip && apt-get install -y curl && \
    OTEL_DOTNET_AUTO_HOME="/otel-dotnet-auto" sh otel-dotnet-auto-install.sh

ENTRYPOINT ["dotnet", "DeviceManager.dll"]