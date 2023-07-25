using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;


namespace DeviceManager
{
    internal class Program
    {
        static async Task Main(string[] args)
        {
            var configuration = new ConfigurationBuilder().AddEnvironmentVariables()
                                                        .Build();
            var consumerGroup =  configuration.GetValue<string>("CONSUMER_GROUP");
            var storageConnectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING");
            var blobContainerName = configuration.GetValue<string>("BLOB_CONTAINER_NAME"); 
            var eventHubsConnectionString = configuration.GetValue<string>("EVENTHUBS_CONNECTION_STRING");
            var eventHubName = configuration.GetValue<string>("EVENTHUB_NAME");
            
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