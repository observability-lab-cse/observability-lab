
using System.Text;
using System.Text.Json;
using Azure.Messaging.EventHubs.Processor;
using Azure.Messaging.EventHubs;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Hosting;

namespace DevicesStateManager
{
    class EventHubReceiverService: IHostedService
    {
        private readonly BlobContainerClient _storageClient;
        private readonly EventProcessorClient _processor;
        private readonly ILogger<EventHubReceiverService> _logger;
        private readonly string _baseUrl;
        private readonly Metrics _metrics;


        public EventHubReceiverService(
            string? storageConnectionString,
            string? blobContainerName,
            string? eventHubsConnectionString,
            string? eventHubName,
            string? consumerGroup,
            string? baseUrl,
            ILogger<EventHubReceiverService> logger,
            Metrics metrics)
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

            _metrics = metrics;
        }

        private async Task<HttpResponseMessage?> UpdateDeviceData(DeviceMessage deviceMessage)
        {
            using HttpClient client = new();
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
                    _metrics.AddDeviceUpdate();
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
        public async Task ProcessEventHandler(ProcessEventArgs eventArgs)
        {

            var messageBody = Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray());
            _logger.LogInformation($"Received event: {messageBody}");
            try
            {
                var message = JsonSerializer.Deserialize<DeviceMessage>(messageBody);
                
                if (message != null)
                {
                    await UpdateDeviceData(message);
                    await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
                }
                else
                {
                    _logger.LogError("Empty message, unable to call Device API.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"An error occurred: {ex.Message}");
            }
        }

        public Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
        {
            _logger.LogError($"\tPartition '{eventArgs.PartitionId}': {eventArgs.Exception.Message}");
            return Task.CompletedTask;
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Start processing messages async...");
            return _processor.StartProcessingAsync(cancellationToken);
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Stop processing messages.");
            return _processor.StopProcessingAsync(cancellationToken);
        }
    }
}