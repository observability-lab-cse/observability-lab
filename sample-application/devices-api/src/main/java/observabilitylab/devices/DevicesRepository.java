package observabilitylab.devices;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import observabilitylab.devices.model.Device;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DevicesRepository extends CosmosRepository<Device, String> {

    List<Device> findAll();
}
