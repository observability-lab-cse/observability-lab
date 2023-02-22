package observabilitylab.devices.api;

import observabilitylab.devices.model.Device;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
public class DevicesController {

    @GetMapping(value = "/devices")
    public List<Device> getDevices() {

        return new ArrayList<>();
    }

}
