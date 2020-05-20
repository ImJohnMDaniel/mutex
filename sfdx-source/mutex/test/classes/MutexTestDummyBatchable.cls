public with sharing class MutexTestDummyBatchable 
    implements Database.Batchable<sObject>
{
    public static final String MUTEX_JOB_ID_DUMMY_BATCH = 'UnitTestDummyBatch';

    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String query = 'select id, ' + Mutex__c.AsyncClassName__c + ', ' + Mutex__c.JobStatus__c 
                        + ' from ' + Mutex__c.SObjectType 
                        + ' where ' + Mutex__c.AsyncClassName__c + ' = \'' + MutexTestDummyBatchable.class + '\'';
        System.debug('MutexTestDummyBatchable query = ' + query);
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
        MutexService.turnMutexOff( MUTEX_JOB_ID_DUMMY_BATCH );
    }
}
