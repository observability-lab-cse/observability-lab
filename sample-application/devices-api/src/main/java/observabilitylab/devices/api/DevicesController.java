package observabilitylab.devices.api;

import observabilitylab.devices.DevicesRepository;
import observabilitylab.devices.model.Device;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Controller
@RequestMapping(path = "/devices")
public class DevicesController {

    @Autowired
    private DevicesRepository repository;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Device> getDevices() {

        return repository.findAll();
    }

}
