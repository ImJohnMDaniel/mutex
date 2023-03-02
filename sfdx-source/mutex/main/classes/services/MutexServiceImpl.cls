public inherited sharing class MutexServiceImpl
    implements IMutexService
{
    public void turnMutexOn(String jobName)
    {
    	if ( String.isBlank(jobName) )
        {
            return;
        }

        IApplicationSObjectUnitOfWork uow = new ApplicationSObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

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

        IApplicationSObjectUnitOfWork uow = new ApplicationSObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        IMutex mutexDomain = Mutex.newInstance( selectByJobName( new List<String>{ jobName }) );

        mutexDomain.turnMutexOff(jobName, uow);

        uow.commitWork();
    }

    public void setupMutexForJob( MutexServiceParameters params )
    {
        if ( String.isBlank(params.jobName) || params.asyncClassToRun == null )
        {
            return;
        }

        IApplicationSObjectUnitOfWork uow = new ApplicationSObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        Mutex__c rec = new Mutex__c();

        rec.AsyncClassName__c = params.asyncClassToRun.getName();
        rec.JobId__c = params.jobName;
        rec.JobStatus__c = Mutex.STATUS_CODES.INACTIVE.name();

        if (params.batchSize != null)
        {
            rec.BatchSize__c = params.batchSize;
        }
        
        if (params.initializationParameters != null)
        {
            rec.ParametersSerialized__c = JSON.serialize(params.initializationParameters);
        }

        uow.registerNew(rec);

        uow.commitWork();
    }

    public void setupMutexForJobIfNeeded( MutexServiceParameters params )
    {
        if (selectByJobName(new List<String>{params.jobName}).isEmpty())
        {
            setupMutexForJob(params);
        }
    }

    @TestVisible
    private static List<Mutex__c> selectByJobName(List<String> jobNames)
    {
        return jobNames != null 
                ? [select Id, Name, JobId__c, AsyncClassName__c, JobStatus__c, ParametersSerialized__c from Mutex__c where JobId__c in :jobNames] 
                : new List<Mutex__c>();
    }
}
