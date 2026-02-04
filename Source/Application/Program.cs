using System.Diagnostics.Metrics;
using Application;
using OpenTelemetry;
using OpenTelemetry.Metrics;

using var _ = Sdk.CreateMeterProviderBuilder()
    .AddMeter("sample")
    .AddConsoleExporter()
    .ConfigureServices(services => services.Configure<MetricReaderOptions>(options =>
    {
        options.PeriodicExportingMetricReaderOptions.ExportIntervalMilliseconds = 1000;
    }))
    .Build();

var meter = new Meter("sample");

var conveyorProcessedCounter = Metrics.CreateWarehouseConveyorProcessed(meter);

var rnd = new Random(1024);

await Task.Factory.StartNew(
        async () =>
        {
            while (true)
            {
                var itemType = rnd.Next(4) switch
                {
                    0 => WarehouseItemType.Box,
                    1 => WarehouseItemType.Pallet,
                    2 => WarehouseItemType.Envelope,
                    _ => WarehouseItemType.Unknown,
                };

                conveyorProcessedCounter.Add(
                    1,
                    new Metrics.WarehouseConveyorProcessedTags
                    {
                        WarehouseConveyorId = "Central101",
                        WarehouseItemType = itemType,
                    });

                await Task.Delay(1000);
            }
        }, TaskCreationOptions.LongRunning)
    .Unwrap();