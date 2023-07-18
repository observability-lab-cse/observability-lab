using System.Text;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

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

            processor.ProcessEventAsync += ProcessEventHandler;
            processor.ProcessErrorAsync += ProcessErrorHandler;

            // Start the processing
            await processor.StartProcessingAsync();

            // Wait for 30 seconds for the events to be processed
            await Task.Delay(TimeSpan.FromSeconds(30));

            // Stop the processing
            await processor.StopProcessingAsync();
        }

        private static async Task<HttpResponseMessage> UpdateDeviceData(DeviceMessage deviceMessage)
        {  
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    var baseUrl = Environment.GetEnvironmentVariable("DEVICE_API_URL");
                    var requestBody = JsonConvert.SerializeObject(new
                    {
                        value = deviceMessage.temp,
                        status = "IN_USE"
                    });

                    var requestBodyContent = new StringContent(requestBody, Encoding.UTF8, "application/json");
                    HttpResponseMessage response = await client.PutAsync($"{baseUrl}/devices/names/{deviceMessage.deviceId}", requestBodyContent);

                    if (response.IsSuccessStatusCode)
                    {
                        string responseBody = await response.Content.ReadAsStringAsync();
                        Console.WriteLine(responseBody);
                    }
                    else
                    {
                        Console.WriteLine($"Request failed with status code {response.StatusCode}");
                    }
                    return response;
                }
                catch (Exception ex)
                {
                    // Handle any exceptions
                    Console.WriteLine($"An error occurred: {ex.Message}");
                    return null;
                }

            }
        }
        private static async Task<Task> ProcessEventHandler(ProcessEventArgs eventArgs)
        {
            // Write the body of the event to the console window
            var messageBody = Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray());
            Console.WriteLine("\tReceived event: {0}", messageBody);
            var message = JsonConvert.DeserializeObject<DeviceMessage>(messageBody);
            await UpdateDeviceData(message);
            return Task.CompletedTask;
        }

        private static Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
        {
            Console.WriteLine($"\tPartition '{eventArgs.PartitionId}': an unhandled exception was encountered. This was not expected to happen.");
            Console.WriteLine(eventArgs.Exception.Message);
            return Task.CompletedTask;
        }

    }
}