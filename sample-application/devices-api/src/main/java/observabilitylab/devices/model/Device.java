package observabilitylab.devices.model;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.GeneratedValue;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;
import org.springframework.data.annotation.Id;


@Container(containerName = "devicesContainer", ru = "400")
public class Device {

    @GeneratedValue
    @Id
    @PartitionKey
    private String id;

    private String name;

    private Double value;

    private Status status;

    public Device(String name) {
        this.name = name;
        this.status = Status.NEW;
    }

    public Device(String name, Double value, Status status)
    {
        this.name = name;
        this.value = value;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Double getValue() {
        return value;
    }

    public Status getStatus() {
        return status;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public void setStatus(Status status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return "Device [id=" + id + ", name=" + name + "]";
    }

    enum Status {
        NEW,
        IN_USE,
        ERROR
    }
}
