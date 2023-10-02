package observabilitylab.devices;

import java.util.List;

import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import com.azure.spring.data.cosmos.repository.Query;

import observabilitylab.devices.model.Device;

@Repository
public interface DeviceRepository extends CosmosRepository<Device, String> {
    
    List<Device> findAll();
    
    Device getDeviceById(String deviceId);
    void deleteDeviceById(String deviceId);
    
    @Query(value = "select * from c where c.name = @name")
    List<Device> getDeviceByName(@Param("name") String name);
}
