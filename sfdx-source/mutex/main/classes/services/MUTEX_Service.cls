public inherited sharing class MUTEX_Service 
{
    private static MUTEX_IService service()
    {
        return (MUTEX_IService) Application.Service.newInstance(MUTEX_IService.class);
    }

    public static void turnMutexOn(String jobName)
    {
        service().turnMutexOn(jobName);
    }

    public static void turnMutexOff(String jobName)
    {
        service().turnMutexOff(jobName);
    }

    public static void setupMutexForJob( MUTEX_ServiceParameters params )
    {
        service().setupMutexForJob(params);
    }

    public static void setupMutexForJobIfNeeded( MUTEX_ServiceParameters params )
    {
        service().setupMutexForJobIfNeeded(params);
    }
}
