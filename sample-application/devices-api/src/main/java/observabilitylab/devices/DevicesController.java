package observabilitylab.devices;

import java.util.List;

import observabilitylab.devices.model.Device;
import observabilitylab.devices.model.DeviceStatus;
import observabilitylab.devices.model.UpdateDevice;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/devices")
public class DevicesController {

    @Autowired
    private DevicesRepository repository;

    @GetMapping
    public ResponseEntity<List<Device>> getDevices() {
        List<Device> devices = repository.findAll();
        if (devices == null) {
            return new ResponseEntity<List<Device>>(devices, HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<List<Device>>(devices, HttpStatus.OK);

    }

    @PostMapping()
    @ResponseStatus(HttpStatus.CREATED)
    public Device createDevice(@RequestBody String name) {
        Device device = new Device(name);
        return repository.save(device);
    }

    @PutMapping("/{id}")
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<Device> updateDevice(@PathVariable("id") String id, @RequestBody UpdateDevice updateDevice) {
        Device device = repository.getDeviceById(id);

        if (device == null) {
            return new ResponseEntity<Device>((Device)null, HttpStatus.NOT_FOUND);
        }

        device.setValue(updateDevice.getValue());
        device.setStatus(updateDevice.getStatus());
        repository.save(device);
        return new ResponseEntity<Device>(device, HttpStatus.OK);
    }


    @GetMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<Device> getDeviceById(@PathVariable("id") String id) {
        Device device = repository.getDeviceById(id);

        if (device == null) {
            return new ResponseEntity<Device>((Device)null, HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<Device>(device, HttpStatus.OK);

    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public void deleteDeviceById(@PathVariable("id") String id) {
        repository.deleteDeviceById(id);
    }
}
