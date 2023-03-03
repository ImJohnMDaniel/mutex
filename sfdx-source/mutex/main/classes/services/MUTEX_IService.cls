public interface MUTEX_IService
{
    void turnMutexOn(String jobName);
    void turnMutexOff(String jobName);
    void setupMutexForJob( MUTEX_ServiceParameters params );
    void setupMutexForJobIfNeeded( MUTEX_ServiceParameters params );
}
