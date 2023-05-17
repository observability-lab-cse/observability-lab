package observabilitylab.devices.model;

import org.springframework.data.annotation.Id;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;

@Container(containerName = "devicesContainer", ru = "400")
public class Device {

    @PartitionKey
    @Id
    private String id;

    public Device(String id) {
        this.id = id;
    }

    public Device() {
    }

    public String getId() {
        return id;
    }
    
    @Override
    public String toString() {
        return "Device [id=" + id + "]";
    }

}
