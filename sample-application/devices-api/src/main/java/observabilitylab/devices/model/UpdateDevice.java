package observabilitylab.devices.model;

public class UpdateDevice {

    private Double value;

    private DeviceStatus status;

    public UpdateDevice(Double value, DeviceStatus status) {
        this.value = value;
        this.status = status;
    }

    public UpdateDevice(Double value) {
        this.value = value;
    }

    public Double getValue() {
        return value;
    }

    public DeviceStatus getStatus() {
        return status;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public void setStatus(DeviceStatus status) {
        this.status = status;
    }
    @Override
    public String toString() {
        return "UpdateDevice [value=" + value + ", status=" + status + "]";
    }
}
