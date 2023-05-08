FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /SampleApp

COPY . ./
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0

EXPOSE 8090
ENV ASPNETCORE_URLS=http://*:8090

WORKDIR /SampleApp
COPY --from=build-env /SampleApp/out .
ENTRYPOINT ["dotnet", "SampleApp.dll"]