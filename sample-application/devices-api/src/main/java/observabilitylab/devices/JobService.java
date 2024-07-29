package observabilitylab.devices;

import observabilitylab.devices.model.DeviceJob;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Component
public class JobService {

    private Logger logger = LoggerFactory.getLogger(JobService.class);

    @Autowired
    private JobsRepository repository;

    @Scheduled(fixedRate = 60000) // Execute every 60 seconds
    public void executeJob() {
        repository.findAll().forEach(job -> {
            Executors.newSingleThreadExecutor().submit(() -> {
                try {
                    job.setStatus(DeviceJob.JobStatus.IN_PROGRESS);
                    repository.save(job);
                    // Simulate a long-running task
                    Thread.sleep(60000);
                    logger.info("Task completed for job: " + job.getId());
                    job.setStatus(DeviceJob.JobStatus.COMPLETED);
                    repository.save(job);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    logger.error("Task was interrupted");
                    job.setStatus(DeviceJob.JobStatus.FAILED);
                    repository.save(job);
                }
            });
            logger.info("Executed job: " + job.getId() + " for device: " + job.getDeviceId());
        });
    }
}
