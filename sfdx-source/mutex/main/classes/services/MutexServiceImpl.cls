public inherited sharing class MutexServiceImpl
    implements IMutexService
{
    public void turnMutexOn(String jobName)
    {
    	if ( String.isBlank(jobName) )
        {
            return;
        }

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        IMutex mutexDomain = Mutex.newInstance( selectByJobName( new List<String>{ jobName }) );

        mutexDomain.turnMutexOn(jobName, uow);

        uow.commitWork();
    }

    public void turnMutexOff(String jobName)
    {
    	if ( String.isBlank(jobName) )
        {
            return;
        }

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        IMutex mutexDomain = Mutex.newInstance( selectByJobName( new List<String>{ jobName }) );

        mutexDomain.turnMutexOff(jobName, uow);

        uow.commitWork();
    }

    public void setupMutexForJob( String jobName, System.Type asyncClassToRun )
    {
        setupMutexForJob(jobName, asyncClassToRun, null);
    }

    public void setupMutexForJob( String jobName, System.Type asyncClassToRun, Integer batchSize )
    {
        if ( String.isBlank(jobName) || asyncClassToRun == null )
        {
            return;
        }

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        Mutex__c rec = new Mutex__c();

        rec.AsyncClassName__c = asyncClassToRun.getName();
        rec.JobId__c = jobName;
        rec.JobStatus__c = Mutex.STATUS_CODES.INACTIVE.name();

        if (batchSize != null)
        {
            rec.BatchSize__c = batchSize;
        }
        
        uow.registerNew(rec);

        uow.commitWork();
    }

    public void setupMutexForJobIfNeeded( String jobName, System.Type asyncClassToRun, Integer batchSize )
    {
        if (selectByJobName(new List<String>{jobName}).isEmpty())
        {
            setupMutexForJob(jobName, asyncClassToRun, batchSize);
        }
    }

    @TestVisible
    private static List<Mutex__c> selectByJobName(List<String> jobNames)
    {
        return jobNames != null 
                ? [select Id, Name, JobId__c, AsyncClassName__c, JobStatus__c from Mutex__c where JobId__c in :jobNames] 
                : new List<Mutex__c>();
    }
}
