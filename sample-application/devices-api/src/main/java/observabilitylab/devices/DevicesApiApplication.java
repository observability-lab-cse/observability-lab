package observabilitylab.devices;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import org.springframework.scheduling.annotation.EnableScheduling;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@SpringBootApplication
@EnableScheduling
@EnableSwagger2
public class DevicesApiApplication {

	public static void main(String[] args) {
		try {
			SpringApplication.run(DevicesApiApplication.class, args);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

    @Bean
   	public Docket productApi() {
      return new Docket(DocumentationType.SWAGGER_2).select()
         .apis(RequestHandlerSelectors.basePackage("observabilitylab.devices")).build();
   	}
}
