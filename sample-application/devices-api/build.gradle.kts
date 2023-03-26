plugins {
	java
	id("org.springframework.boot") version "2.7.10"
	id("io.spring.dependency-management") version "1.1.0"
}

group = "observabilitylab"
java.sourceCompatibility = JavaVersion.VERSION_17

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.boot:spring-boot-autoconfigure")
	// https://mvnrepository.com/artifact/com.azure.spring/spring-cloud-azure-starter-data-cosmos
	implementation("com.azure.spring:spring-cloud-azure-starter-data-cosmos:4.6.0")

}

tasks.withType<Test> {
	useJUnitPlatform()
}

tasks.jar {
	manifest.attributes["Main-Class"] = "observabilitylab.devices.DevicesApiApplication"
}

