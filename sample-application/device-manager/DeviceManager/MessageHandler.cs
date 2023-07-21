
using System.Text;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Diagnostics;

namespace DeviceManager
{
    class MessageHandler
    {
        private static ActivitySource source = new ActivitySource("Sample.DistributedTracing", "1.0.0");
        private static async Task<HttpResponseMessage> UpdateDeviceData(DeviceMessage deviceMessage)
        {
            using (Activity activity = source.StartActivity("Update device data"))
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
                        Console.WriteLine($"An error occurred: {ex.Message}");
                        return null;
                    }
                }

            }
        }
        public static async Task<Task> ProcessEventHandler(ProcessEventArgs eventArgs)
        {
            using (Activity activity = source.StartActivity("Receive device data"))
            {
                // Write the body of the event to the console window
                var messageBody = Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray());
                Console.WriteLine("\tReceived event: {0}", messageBody);
                var message = JsonConvert.DeserializeObject<DeviceMessage>(messageBody);
                await UpdateDeviceData(message);
            }
            return Task.CompletedTask;
        }

        public static Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
        {
            Console.WriteLine($"\tPartition '{eventArgs.PartitionId}': an unhandled exception was encountered. This was not expected to happen.");
            Console.WriteLine(eventArgs.Exception.Message);
            return Task.CompletedTask;
        }

    }
}