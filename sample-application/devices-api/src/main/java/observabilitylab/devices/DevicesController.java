package observabilitylab.devices;

import java.util.List;

import observabilitylab.devices.model.Device;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
    public List<Device> getDevices() {
        return repository.findAll();
    }

    @PutMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Device addOrUpdateDevice(@RequestBody Device device) {
        return repository.save(device);
    }
    
    @GetMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public Device getDeviceById(@PathVariable("id") String id){
        return repository.getDeviceById(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public void deleteDeviceById(@PathVariable("id") String id){
        repository.deleteDeviceById(id);
    }
}
