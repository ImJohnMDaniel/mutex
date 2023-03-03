public with sharing class MUTEX_TestDummyQueueable 
    implements Queueable
{
    public static final String MUTEX_JOB_ID_DUMMY_QUEUEABLE = 'UnitTestDummyQueueable';

    /**
     * updates MUTEX_TestDummyQueueable record JobStatus__c to Mutex.STATUS_CODES.INACTIVE.name() 
     */
    public void execute(QueueableContext context) 
    {
        system.debug('Queue Job launched');
        
        MUTEX_Service.turnMutexOff( MUTEX_JOB_ID_DUMMY_QUEUEABLE );
    }
}
