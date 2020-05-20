public interface IMutexService
{
    void turnMutexOn(String jobName);
    void turnMutexOff(String jobName);
    void setupMutexForJob( String jobName, System.Type asyncClassToRun );
    void setupMutexForJob( String jobName, System.Type asyncClassToRun, Integer batchSize );
    void setupMutexForJobIfNeeded( String jobName, System.Type asyncClassToRun, Integer batchSize );
}
