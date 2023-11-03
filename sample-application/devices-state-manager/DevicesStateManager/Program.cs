using DevicesStateManager;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;
var consumerGroup = configuration.GetValue<string>("CONSUMER_GROUP");
var blobContainerName = configuration.GetValue<string>("BLOB_CONTAINER_NAME");
var storageConnectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING");
var eventHubConnectionString = configuration.GetValue<string>("EVENT_HUB_CONNECTION_STRING");
var eventHubName = configuration.GetValue<string>("EVENT_HUB_NAME");
var deviceApiUrl = configuration.GetValue<string>("DEVICE_API_URL");

builder.Services.AddHostedService(provider =>
    {
        var logger = provider.GetRequiredService<ILogger<EventHubReceiverService>>();
        return new EventHubReceiverService(
            storageConnectionString,
            blobContainerName,
            eventHubConnectionString,
            eventHubName,
            consumerGroup,
            deviceApiUrl,
            logger);
    });

builder.Services.AddHealthChecks()
    .AddCheck("Sample", () => HealthCheckResult.Healthy("A healthy result."));

var app = builder.Build();
app.MapHealthChecks("/health");
await app.RunAsync();