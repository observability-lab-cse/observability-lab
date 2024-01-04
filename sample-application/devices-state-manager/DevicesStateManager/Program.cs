using DevicesStateManager;

var builder = Host.CreateDefaultBuilder(args)
    .ConfigureServices((hostContext, services) =>
    {
        var configuration = hostContext.Configuration;
        var consumerGroup = configuration.GetValue<string>("CONSUMER_GROUP");
        var blobContainerName = configuration.GetValue<string>("BLOB_CONTAINER_NAME");
        var storageConnectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING");
        var eventHubConnectionString = configuration.GetValue<string>("EVENT_HUB_CONNECTION_STRING");
        var eventHubName = configuration.GetValue<string>("EVENT_HUB_NAME");
        var deviceApiUrl = configuration.GetValue<string>("DEVICE_API_URL");

        services.AddHostedService(provider =>
        {
            var logger = provider.GetRequiredService<ILogger<EventHubReceiverService>>();
            return new EventHubReceiverService(
                storageConnectionString,
                blobContainerName,
                eventHubConnectionString,
                eventHubName,
                consumerGroup,
                deviceApiUrl,
                logger);
        });

        services.AddHealthChecks().AddCheck<CustomHealthCheck>("custom_hc");
        services.AddHostedService<TcpHealthProbeService>();

    });

var app = builder.Build();
await app.RunAsync();