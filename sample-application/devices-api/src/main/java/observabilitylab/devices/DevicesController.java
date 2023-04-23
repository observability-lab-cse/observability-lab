package observabilitylab.devices;

import observabilitylab.devices.model.Device;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping(path = "/devices")
public class DevicesController {

    @Autowired
    private DevicesRepository repository;

    @GetMapping
    public List<Device> getDevices() {
        return repository.findAll();
    }
}
