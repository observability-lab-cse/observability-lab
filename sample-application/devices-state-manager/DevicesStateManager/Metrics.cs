using System.Diagnostics.Metrics;

namespace DevicesStateManager
{
    public class Metrics
    {
        private Counter<int> DeviceUpdatesCounter { get; }

        public string MetricName { get; }

        public Metrics(string meterName = "DevicesStateManager")
        {
            var meter = new Meter(meterName);
            MetricName = meterName;
            DeviceUpdatesCounter = meter.CreateCounter<int>("device-updates", "Device");
        }

        public void AddDeviceUpdate() => DeviceUpdatesCounter.Add(1);
    }
}
