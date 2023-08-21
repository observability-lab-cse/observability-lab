using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration.Json;


namespace DeviceManager
{
    internal class Program
    {
        static async Task Main(string[] args)
        {
            var configuration = new ConfigurationBuilder().AddJsonFile("appsettings.json",true,true)
                                                        .AddEnvironmentVariables()
                                                        .Build();
            var consumerGroup = configuration.GetValue<string>("CONSUMER_GROUP");
            var blobContainerName = configuration.GetValue<string>("BLOB_CONTAINER_NAME");
            var storageConnectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING"); 
            var eventHubConnectionString = configuration.GetValue<string>("EVENT_HUB_CONNECTION_STRING");
            var eventHubName = configuration.GetValue<string>("EVENT_HUB_NAME");
            var deviceApiUrl = configuration.GetValue<string>("DEVICE_API_URL");

            var serviceCollection = new ServiceCollection();
            serviceCollection.AddLogging(builder =>
            {
                builder.AddConsole();
            });
            serviceCollection.AddSingleton<EventHubReceiverService>(provider =>
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

            var serviceProvider = serviceCollection.BuildServiceProvider();

            var eventHubReceiverService = serviceProvider.GetRequiredService<EventHubReceiverService>();

            await eventHubReceiverService.StartProcessingAsync();

            await Task.Delay(TimeSpan.FromSeconds(300));

            await eventHubReceiverService.StopProcessingAsync();
        }

    }
}