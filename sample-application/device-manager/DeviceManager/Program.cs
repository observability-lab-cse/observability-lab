using System.Text;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Diagnostics;

namespace DeviceManager
{
    internal class Program
    {
        static async Task Main(string[] args)
        {

            var serviceCollection = new ServiceCollection();

            // Configure logging
            serviceCollection.AddLogging(builder =>
            {
                builder.AddConsole();
            });

            var serviceProvider = serviceCollection.BuildServiceProvider();

            var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
            logger.LogInformation("Telemetry generator started.");


            var storageConnectionString = Environment.GetEnvironmentVariable("STORAGE_CONNECTION_STRING");
            var blobContainerName = Environment.GetEnvironmentVariable("BLOB_CONTAINER_NAME");

            var eventHubsConnectionString = Environment.GetEnvironmentVariable("EVENTHUBS_CONNECTION_STRING");
            var eventHubName = Environment.GetEnvironmentVariable("EVENTHUB_NAME");
            var consumerGroup = Environment.GetEnvironmentVariable("CONSUMER_GROUP");


            var storageClient = new BlobContainerClient(storageConnectionString, blobContainerName);
            var processor = new EventProcessorClient(storageClient, consumerGroup, eventHubsConnectionString, eventHubName);

            processor.ProcessEventAsync += MessageHandler.ProcessEventHandler;
            processor.ProcessErrorAsync += MessageHandler.ProcessErrorHandler;

            // Start the processing
            await processor.StartProcessingAsync();

            // Wait for 30 seconds for the events to be processed
            await Task.Delay(TimeSpan.FromSeconds(30));

            // Stop the processing
            await processor.StopProcessingAsync();
        }

   
    }
}