public inherited sharing class MUTEX_ServiceImpl
    implements MUTEX_IService
{
    public void turnMutexOn(String jobName)
    {
    	if ( String.isBlank(jobName) )
        {
            return;
        }

        IApplicationSObjectUnitOfWork uow = new ApplicationSObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        MUTEX_IDomain mutexDomain = MUTEX_Domain.newInstance( selectByJobName( new List<String>{ jobName }) );

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

        MUTEX_IDomain mutexDomain = MUTEX_Domain.newInstance( selectByJobName( new List<String>{ jobName }) );

        mutexDomain.turnMutexOff(jobName, uow);

        uow.commitWork();
    }

    public void setupMutexForJob( MUTEX_ServiceParameters params )
    {
        if ( String.isBlank(params.jobName) || params.asyncClassToRun == null )
        {
            return;
        }

        IApplicationSObjectUnitOfWork uow = new ApplicationSObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

        Mutex__c rec = new Mutex__c();

        rec.AsyncClassName__c = params.asyncClassToRun.getName();
        rec.JobId__c = params.jobName;
        rec.JobStatus__c = MUTEX_Domain.STATUS_CODES.INACTIVE.name();

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

    public void setupMutexForJobIfNeeded( MUTEX_ServiceParameters params )
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
