using DevicesStateManager;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

using var host = Host.CreateDefaultBuilder(args)
        .ConfigureServices((hostContext, services) =>
        {
            var configuration = hostContext.Configuration;
            var consumerGroup = configuration.GetValue<string>("CONSUMER_GROUP");
            var blobContainerName = configuration.GetValue<string>("BLOB_CONTAINER_NAME");
            var storageConnectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING");
            var eventHubConnectionString = configuration.GetValue<string>("EVENT_HUB_CONNECTION_STRING");
            var eventHubName = configuration.GetValue<string>("EVENT_HUB_NAME");
            var deviceApiUrl = configuration.GetValue<string>("DEVICE_API_URL");

            services.AddHostedService(provider =>
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
        })
        .Build();

await host.RunAsync();