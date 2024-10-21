package observabilitylab.devices;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import observabilitylab.devices.model.DeviceJob;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface JobsRepository extends CosmosRepository<DeviceJob, String> {

    List<DeviceJob> findAll();
    DeviceJob getDeviceJobById(String id);
    void deleteDeviceJobById(String id);
    DeviceJob save(DeviceJob job);
}
