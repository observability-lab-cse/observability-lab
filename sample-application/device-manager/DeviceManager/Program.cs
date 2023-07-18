using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace DeviceManager
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

            var serviceProvider = serviceCollection.BuildServiceProvider();

            var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
            logger.LogInformation("Telemetry generator started.");

            // this is temporary to avoid the module from restarting
            while (true) {}
        }
    }
}