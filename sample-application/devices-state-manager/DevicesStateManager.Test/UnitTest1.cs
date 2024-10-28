using System.Text.Json;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using System.Net;
using System.Text;
using Moq;
using Azure.Messaging.EventHubs;
using Microsoft.Extensions.Logging;

namespace DevicesStateManager.Tests
{
    public class EventHubReceiverServiceTests
    {
        private readonly Mock<ILogger<EventHubReceiverService>> _loggerMock;
        private readonly Mock<BlobContainerClient> _blobContainerClientMock;
        private readonly Mock<EventProcessorClient> _eventProcessorClientMock;
        private readonly EventHubReceiverService _service;
        private readonly CancellationToken _cancellationToken = CancellationToken.None;
        private readonly string _baseUrl = "http://localhost";

        public EventHubReceiverServiceTests()
        {
            _loggerMock = new Mock<ILogger<EventHubReceiverService>>();
            _blobContainerClientMock = new Mock<BlobContainerClient>();
            _eventProcessorClientMock = new Mock<EventProcessorClient>(_blobContainerClientMock.Object, "consumerGroup", "eventHubsConnectionString", "eventHubName");

            _service = new EventHubReceiverService(
                "storageConnectionString",
                "blobContainerName",
                "eventHubsConnectionString",
                "eventHubName",
                "consumerGroup",
                _baseUrl,
                _loggerMock.Object);
        }

        [Fact]
        public async Task StartAsync_CallsStartProcessingAsync()
        {
            await _service.StartAsync(_cancellationToken);
            _eventProcessorClientMock.Verify(p => p.StartProcessingAsync(_cancellationToken), Times.Once);
        }

        [Fact]
        public async Task StopAsync_CallsStopProcessingAsync()
        {
            await _service.StopAsync(_cancellationToken);
            _eventProcessorClientMock.Verify(p => p.StopProcessingAsync(_cancellationToken), Times.Once);
        }

        [Fact]
        public async Task ProcessEventHandler_ValidMessage_UpdatesDeviceData()
        {
            var deviceMessage = new DeviceMessage { deviceId = "device1", temp = 25.0f };
            var eventData = new EventData(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(deviceMessage)));
            var eventArgs = new ProcessEventArgs(null, eventData, null, _cancellationToken);

            var httpClientMock = new Mock<HttpClient>();
            httpClientMock.Setup(client => client.PutAsync(It.IsAny<string>(), It.IsAny<HttpContent>()))
                .ReturnsAsync(new HttpResponseMessage(HttpStatusCode.OK));

            await _service.ProcessEventHandler(eventArgs);

            _loggerMock.Verify(logger => logger.LogInformation(It.IsAny<string>()), Times.AtLeastOnce);
        }
    }
}