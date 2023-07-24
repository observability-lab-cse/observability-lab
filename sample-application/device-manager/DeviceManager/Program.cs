using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;


namespace DeviceManager
{
    internal class Program
    {
        static async Task Main(string[] args)
        {
            // TODO: bind them as configs
            var storageConnectionString = Environment.GetEnvironmentVariable("STORAGE_CONNECTION_STRING");
            var blobContainerName = Environment.GetEnvironmentVariable("BLOB_CONTAINER_NAME");

            var eventHubsConnectionString = Environment.GetEnvironmentVariable("EVENTHUBS_CONNECTION_STRING");
            var eventHubName = Environment.GetEnvironmentVariable("EVENTHUB_NAME");
            var consumerGroup = Environment.GetEnvironmentVariable("CONSUMER_GROUP");

            var serviceCollection = new ServiceCollection();
            // Configure logging 
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
                    eventHubsConnectionString,
                    eventHubName,
                    consumerGroup,
                    logger);
            });

            var serviceProvider = serviceCollection.BuildServiceProvider();

            var eventHubReceiverService = serviceProvider.GetRequiredService<EventHubReceiverService>();

            await eventHubReceiverService.StartProcessingAsync();

            await Task.Delay(TimeSpan.FromSeconds(30));

            await eventHubReceiverService.StopProcessingAsync();
        }

    }
}