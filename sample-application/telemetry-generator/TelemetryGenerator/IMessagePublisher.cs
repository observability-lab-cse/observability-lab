namespace TelemetryGenerator
{
    /// <summary>
    /// Exposes the functionality of publishing messages with MQTT.
    /// </summary>
    public interface IMessagePublisher
    {
        /// <summary>
        /// Publishes an MQTT message.
        /// </summary>
        /// <param name="message">The message to publish.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        public Task PublishMessage(string message, CancellationToken cancellationToken);
    }
}
