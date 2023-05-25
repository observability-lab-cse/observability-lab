using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace TelemetryGenerator
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var serviceCollection = new ServiceCollection();

            // Configure logging
            serviceCollection.AddLogging(builder =>
            {
                builder.AddConsole();
            });

            serviceCollection.AddSingleton<IMessagePublisher, MessagePublisher>();

            var serviceProvider = serviceCollection.BuildServiceProvider();

            var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
            logger.LogInformation("Telemetry generator started.");
        }
    }
}