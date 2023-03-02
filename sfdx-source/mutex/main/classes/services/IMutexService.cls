public interface IMutexService
{
    void turnMutexOn(String jobName);
    void turnMutexOff(String jobName);
    void setupMutexForJob( MutexServiceParameters params );
    void setupMutexForJobIfNeeded( MutexServiceParameters params );
}
