using Microsoft.Extensions.Logging;
using MQTTnet;
using MQTTnet.Client;

namespace TelemetryGenerator
{
    /// <summary>
    /// Class with the functionality of publishing messages with MQTT.
    /// </summary>
    public class MessagePublisher : IMessagePublisher
    {
        private readonly ILogger<MessagePublisher> _logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="MessagePublisher"/> class.
        /// </summary>
        public MessagePublisher(ILogger<MessagePublisher> logger)
        {
            _logger = logger;
            _logger.LogDebug("MessagePublisher initialized.");
        }

        /// <inheritdoc />
        public async Task PublishMessage(string message, CancellationToken cancellationToken)
        {
            var mqttFactory = new MqttFactory();
            using (var mqttClient = mqttFactory.CreateMqttClient())
            {
                var mqttClientOptions = new MqttClientOptionsBuilder()
                    .WithTcpServer("127.0.0.1")
                    .Build();

                await mqttClient.ConnectAsync(mqttClientOptions, cancellationToken);

                var applicationMessage = new MqttApplicationMessageBuilder()
                    .WithPayload(message)
                    .Build();

                await mqttClient.PublishAsync(applicationMessage, cancellationToken);

                await mqttClient.DisconnectAsync();

                _logger.LogInformation("MQTT application message was published.");
            }

        }

    }
}
