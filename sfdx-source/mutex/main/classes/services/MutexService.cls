public inherited sharing class MutexService 
{
    private static IMutexService instance = null;

    private static IMutexService service()
    {
        if (mock_service != null)
            return mock_service;

        if (instance == null)
            instance = new MutexServiceImpl();

        return instance;
    }

    public static void turnMutexOn(String jobName)
    {
        service().turnMutexOn(jobName);
    }

    public static void turnMutexOff(String jobName)
    {
        service().turnMutexOff(jobName);
    }

    public static void setupMutexForJob( String jobName, System.Type asyncClassToRun )
    {
        service().setupMutexForJob(jobName, asyncClassToRun);
    }

    public static void setupMutexForJob( String jobName, System.Type asyncClassToRun, Integer batchSize )
    {
        service().setupMutexForJob(jobName, asyncClassToRun, batchSize);
    }

    public static void setupMutexForJobIfNeeded( String jobName, System.Type asyncClassToRun, Integer batchSize )
    {
        service().setupMutexForJobIfNeeded(jobName, asyncClassToRun, batchSize);
    }

    /*-----------------------------------------------------------------
     *    Mocking functionality for testing
     *    TODO: Replace with framework functionality when available.
     *-----------------------------------------------------------------*/

    private static IMutexService mock_service = null;

    @TestVisible
    private static void setMock(IMutexService mock)
    {
        mock_service = mock;
    }
}
