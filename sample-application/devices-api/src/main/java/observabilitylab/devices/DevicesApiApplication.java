package observabilitylab.devices;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class DevicesApiApplication extends SpringBootServletInitializer {

	public static void main(String[] args) {
		try {
			SpringApplication.run(DevicesApiApplication.class, args);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
