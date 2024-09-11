package observabilitylab.devices;

import java.util.List;
import observabilitylab.devices.model.Device;
import observabilitylab.devices.model.DeviceJob;
import observabilitylab.devices.model.UpdateDevice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping(path = "/devices")
public class DevicesController {

    private Logger logger = LoggerFactory.getLogger(DevicesController.class);

    @Autowired
    private DevicesRepository repository;
    @Autowired
    private JobsRepository jobsRepository;

    @GetMapping
    public ResponseEntity<List<Device>> getDevices() {
        logger.info("GET all devices called");
        List<Device> devices = repository.findAll();
        if (devices == null) {
            logger.warn("Device list is null");
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<List<Device>>(devices, HttpStatus.OK);

    }

    @GetMapping("/names/{name}")
    public ResponseEntity<Device> getDeviceByName(@PathVariable("name") String name) {
        List<Device> devices = repository.getDeviceByName(name);

        logger.info("GET device with name %s".formatted(name));
        if (devices.isEmpty()) {
            logger.warn("Device with name %s not found".formatted(name));
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Device with name %s not found".formatted(name));
        }
        return new ResponseEntity<Device>(devices.get(0), HttpStatus.OK);

    }

    @GetMapping("/{id}")
    public ResponseEntity<Device> getDeviceById(@PathVariable("id") String id) {
        Device device = repository.getDeviceById(id);
        logger.info("GET device with id %s".formatted(id));
        if (device == null) {
            logger.warn("Device with id %s not found".formatted(id));
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Device with id %s not found".formatted(id));
        }
        return new ResponseEntity<Device>(device, HttpStatus.OK);

    }

    @PostMapping()
    public ResponseEntity<Device> createDevice(@RequestBody String name) {
        List<Device> devices = repository.getDeviceByName(name);
        if (!devices.isEmpty()) {
            logger.warn("Device with name %s already exists".formatted(name));
            return new ResponseEntity<Device>((Device) null, HttpStatus.CONFLICT);
        }
        logger.info("Create device with name %s".formatted(name));
        Device newDevice = new Device(name);
        return new ResponseEntity<Device>(repository.save(newDevice), HttpStatus.CREATED);
    }

    @PutMapping("/names/{name}")
    public ResponseEntity<Device> updateDevice(@PathVariable("name") String name,
            @RequestBody UpdateDevice updateDevice) {
        List<Device> devices = repository.getDeviceByName(name);
        if (devices.isEmpty()) {
            logger.warn("Device with name %s not found".formatted(name));
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Device with name %s not found".formatted(name));
        }
        Device device = devices.get(0);
        device.setValue(updateDevice.getValue());
        device.setStatus(updateDevice.getStatus());
        repository.save(device);
        logger.info("Updated device with name %s with %s".formatted(name, updateDevice));
        return new ResponseEntity<Device>(device, HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public void deleteDeviceById(@PathVariable("id") String id) {
        logger.info("DELETE device with id %s".formatted(id));
        Device device = repository.getDeviceById(id);
        if (device == null) {
            logger.warn("Device with id %s not found".formatted(id));
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Device with id %s not found".formatted(id));
        }
        repository.deleteDeviceById(id);
    }

    @PostMapping("/jobs")
    @ResponseStatus(HttpStatus.CREATED)
    public String createJob(@RequestBody String deviceId) {
        logger.info("Create job for device with id %s".formatted(deviceId));
        Device device = repository.getDeviceById(deviceId);
        if (device == null) {
            logger.warn("Device with id %s not found".formatted(deviceId));
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Device with id %s not found".formatted(deviceId));
        }
        DeviceJob deviceJob = jobsRepository.save(new DeviceJob(deviceId));
        return deviceJob.getId();
    }

    @GetMapping("/jobs/{id}")
    @ResponseStatus(HttpStatus.OK)
    public DeviceJob getJobById(@PathVariable("id") String id) {
        logger.info("GET job with id %s".formatted(id));
        DeviceJob deviceJob = jobsRepository.getDeviceJobById(id);
        if (deviceJob == null) {
            logger.warn("Job with id %s not found".formatted(id));
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Job with id %s not found".formatted(id));
        }
        return deviceJob;
    }

}
