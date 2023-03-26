package observabilitylab.devices.model;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;
import org.springframework.data.annotation.Id;

@Container(containerName = "devicesContainer")
public class Device {
    @PartitionKey
    @Id
    private final String id;

    public Device(String id) {
        this.id = id;
    }
}
