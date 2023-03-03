public with sharing class MUTEX_TestDummyBatchable 
    implements Database.Batchable<sObject>
{
    public static final String MUTEX_JOB_ID_DUMMY_BATCH = 'UnitTestDummyBatch';

    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String query = 'select id, ' + Mutex__c.AsyncClassName__c + ', ' + Mutex__c.JobStatus__c 
                        + ' from ' + Mutex__c.SObjectType 
                        + ' where ' + Mutex__c.AsyncClassName__c + ' = \'' + MUTEX_TestDummyBatchable.class + '\'';
        System.debug('MUTEX_TestDummyBatchable query = ' + query);
        return Database.getQueryLocator( query );
    }
    
    public void execute(Database.BatchableContext bc, List<Mutex__c> scope)
    {
        // process each batch of records
        system.debug('Batch Job launched');
    }
    
    /* 
     * updates MutexDummyBatch record JobStatus__c to Mutex.STATUS_CODES.INACTIVE.name() 
     */
    public void finish(Database.BatchableContext bc)
    {
        // Query here to see if there are other records to process
        // If there are still records to process, then execute...
            // MUTEX_Service.turnMutexOn( MUTEX_JOB_ID_DUMMY_BATCH );
        // otherwise
            MUTEX_Service.turnMutexOff( MUTEX_JOB_ID_DUMMY_BATCH );
    }
}
