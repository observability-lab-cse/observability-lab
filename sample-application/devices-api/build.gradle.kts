plugins {
	java
	id("org.springframework.boot") version "2.7.8"
	id("io.spring.dependency-management") version "1.1.0"
}

group = "observabilitylab"
java.sourceCompatibility = JavaVersion.VERSION_17

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
}

tasks.withType<Test> {
	useJUnitPlatform()
}

tasks.jar {
	manifest.attributes["Main-Class"] = "observabilitylab.devices.DevicesApiApplication"
}

