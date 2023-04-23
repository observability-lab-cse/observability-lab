package observabilitylab.devices;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DevicesApiApplication {

	public static void main(String[] args) {
		try {
			SpringApplication.run(DevicesApiApplication.class, args);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
