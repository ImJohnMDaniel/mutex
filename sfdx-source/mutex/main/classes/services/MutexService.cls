public inherited sharing class MutexService 
{
    private static IMutexService service()
    {
        return (IMutexService) Application.Service.newInstance(IMutexService.class);
    }

    public static void turnMutexOn(String jobName)
    {
        service().turnMutexOn(jobName);
    }

    public static void turnMutexOff(String jobName)
    {
        service().turnMutexOff(jobName);
    }

    public static void setupMutexForJob( MutexServiceParameters params )
    {
        service().setupMutexForJob(params);
    }

    public static void setupMutexForJobIfNeeded( MutexServiceParameters params )
    {
        service().setupMutexForJobIfNeeded(params);
    }
}
