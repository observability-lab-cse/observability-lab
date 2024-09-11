package observabilitylab.devices.model;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.GeneratedValue;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;
import org.springframework.data.annotation.Id;


@Container(containerName = "jobsContainer", ru = "400")
public class DeviceJob {

    @GeneratedValue
    @Id
    @PartitionKey
    private String id;

    private String deviceId;
    private String status;


    public DeviceJob(String deviceId) {
        this.deviceId = deviceId;
        this.status = JobStatus.NEW;
    }

    public DeviceJob(String id, String deviceId, String status) {
        this.id = id;
        this.deviceId = deviceId;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Device [id=" + id + ", deviceId=" + deviceId + "]";
    }

    public class JobStatus {
        public static final String NEW = "NEW";
        public static final String IN_PROGRESS = "IN_PROGRESS";
        public static final String COMPLETED = "COMPLETED";
        public static final String FAILED = "FAILED";
    }
}
