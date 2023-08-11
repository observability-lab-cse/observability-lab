
using System.Text;
using System.Text.Json;
using Azure.Messaging.EventHubs.Processor;
using Azure.Messaging.EventHubs;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Logging;

namespace DeviceManager
{
    class EventHubReceiverService
    {
        private readonly BlobContainerClient _storageClient;
        private readonly EventProcessorClient _processor;
        private readonly ILogger<EventHubReceiverService> _logger;
        private string _baseUrl;


        public EventHubReceiverService(
            string? storageConnectionString,
            string? blobContainerName,
            string? eventHubsConnectionString,
            string? eventHubName,
            string? consumerGroup,
            string? baseUrl,
            ILogger<EventHubReceiverService> logger)
        {
            ArgumentNullException.ThrowIfNull(storageConnectionString);
            ArgumentNullException.ThrowIfNull(blobContainerName);
            ArgumentNullException.ThrowIfNull(eventHubsConnectionString);
            ArgumentNullException.ThrowIfNull(eventHubName);
            ArgumentNullException.ThrowIfNull(consumerGroup);
            ArgumentNullException.ThrowIfNull(baseUrl);
            _logger = logger;
            _baseUrl = baseUrl;
            _storageClient = new BlobContainerClient(storageConnectionString, blobContainerName);
            _processor = new EventProcessorClient(_storageClient, consumerGroup, eventHubsConnectionString, eventHubName);

            _processor.ProcessEventAsync += ProcessEventHandler;
            _processor.ProcessErrorAsync += ProcessErrorHandler;
        }
        private async Task<HttpResponseMessage?> UpdateDeviceData(DeviceMessage deviceMessage)
        {
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    var requestBody = JsonSerializer.Serialize(new
                    {
                        value = deviceMessage.temp,
                        status = "IN_USE"
                    });
                    _logger.LogInformation($"Update device {deviceMessage.deviceId} with message {requestBody} calling {_baseUrl}/devices/names/{deviceMessage.deviceId}");
                    var requestBodyContent = new StringContent(requestBody, Encoding.UTF8, "application/json");
                    HttpResponseMessage response = await client.PutAsync($"{_baseUrl}/devices/names/{deviceMessage.deviceId}", requestBodyContent);

                    if (response.IsSuccessStatusCode)
                    {
                        string responseBody = await response.Content.ReadAsStringAsync();
                        _logger.LogInformation(responseBody);
                    }
                    else
                    {
                        _logger.LogWarning($"Request failed with status code {response.StatusCode}");
                    }
                    return response;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"An error occurred: {ex.Message}");
                    return null;
                }
            }
        }
        public async Task<HttpResponseMessage?> ProcessEventHandler(ProcessEventArgs eventArgs)
        {
            var messageBody = Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray());
            _logger.LogInformation($"Received event: {messageBody}");
            var message = JsonSerializer.Deserialize<DeviceMessage>(messageBody);
            var response = await UpdateDeviceData(message);
            // TODO: Checkpointing per message is not recommended.
            // This is a temporal solution. Also should we do anything when the response is not successful?
            await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
            return response;
        }

        public Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
        {
            _logger.LogError($"\tPartition '{eventArgs.PartitionId}': {eventArgs.Exception.Message}");
            return Task.CompletedTask;
        }

        public async Task StartProcessingAsync()
        {
            _logger.LogInformation("Start processing messages async...");
            await _processor.StartProcessingAsync();
        }

        public async Task StopProcessingAsync()
        {
            _logger.LogInformation("Stop processing messages.");
            await _processor.StopProcessingAsync();
        }

    }
}