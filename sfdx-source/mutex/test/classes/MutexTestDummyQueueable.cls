public with sharing class MutexTestDummyQueueable 
    implements Queueable
{
    public static final String MUTEX_JOB_ID_DUMMY_QUEUEABLE = 'UnitTestDummyQueueable';

    /**
     * updates MutexTestDummyQueueable record JobStatus__c to Mutex.STATUS_CODES.INACTIVE.name() 
     */
    public void execute(QueueableContext context) 
    {
        system.debug('Queue Job launched');
        
        MutexService.turnMutexOff( MUTEX_JOB_ID_DUMMY_QUEUEABLE );
    }
}
