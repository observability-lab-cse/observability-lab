using DevicesStateManager;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

using var host = Host.CreateDefaultBuilder(args)
        .ConfigureServices((hostContext, services) =>
        {
            var configuration = hostContext.Configuration;
            var consumerGroup = configuration.GetValue<string>("CONSUMER_GROUP");
            var blobContainerName = configuration.GetValue<string>("BLOB_CONTAINER_NAME");
            var storageConnectionString = configuration.GetValue<string>("STORAGE_CONNECTION_STRING");
            var eventHubConnectionString = configuration.GetValue<string>("EVENT_HUB_CONNECTION_STRING");
            var eventHubName = configuration.GetValue<string>("EVENT_HUB_NAME");
            var deviceApiUrl = configuration.GetValue<string>("DEVICE_API_URL");
            var otlpEndpoint = configuration.GetValue<string>("OTEL_EXPORTER_OTLP_ENDPOINT");
            
            var metrics = new Metrics();

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
                    logger,
                    metrics);
            });


            _ = services.AddOpenTelemetry().WithMetrics(opts => opts
                .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("DevicesStateManager"))
                .AddMeter(metrics.MetricName)
                .AddAspNetCoreInstrumentation()
                .AddRuntimeInstrumentation()
                .AddProcessInstrumentation()
                .AddOtlpExporter(opts =>
                {
                    opts.Endpoint = new Uri(otlpEndpoint);
                })
            );
        })
        .Build();

await host.RunAsync();