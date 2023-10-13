package observabilitylab.devices;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;

import static org.springframework.http.HttpStatus.OK;
import static org.springframework.web.bind.annotation.RequestMethod.GET;
import static org.springframework.web.bind.annotation.RequestMethod.HEAD;

@Controller
class HealthCheckController {

    @ResponseStatus(OK)
    @RequestMapping(value = "/health", method = GET)
    public void health() {
    }

}