@isTest
private class MUTEX_ServiceTest {

    @isTest
    private static void givenValidQueueApexUpdateLaunchJobTurnsStatusOFF()
    {
        String jobName = MUTEX_TestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE;

        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters()
                                            .setAsyncClassToRun(MUTEX_TestDummyQueueable.class)
                                            .setJobName(jobName) );
        
        Test.startTest();
        
        MUTEX_Service.turnMutexOn(jobName);
        
        Test.stopTest();
        
        Mutex__c recQuery = [select JobStatus__c from Mutex__c where JobId__c = :MUTEX_TestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE limit 1];
        
        // check if MutexDummyQueueable updated the Status
        system.assertEquals(MUTEX_Domain.STATUS_CODES.INACTIVE.name(), recQuery.JobStatus__c, MUTEX_TestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE + ' failed to update');
    } 

    @isTest
    private static void givenValidBatchApexUpdateLaunchJobTurnsStatusOFF()
    {
        String jobName = MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH;

        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters()
                                            .setAsyncClassToRun(MUTEX_TestDummyBatchable.class)
                                            .setBatchSize(1)
                                            .setJobName(jobName) );

        Test.startTest();
        
        MUTEX_Service.turnMutexOn(jobName);
        
        Test.stopTest();
        
        Mutex__c recQuery = [select JobStatus__c from Mutex__c where JobId__c = :MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH limit 1];
        
        // check if MutexDummyBatch updated the Status
        system.assertEquals(MUTEX_Domain.STATUS_CODES.INACTIVE.name(), recQuery.JobStatus__c, MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH + ' failed to update');
    }

    @isTest
    private static void givenValidBatchApexNullBatchUpdateLaunchJobTurnsStatusOFF()
    {
        String jobName = MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH;

        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters()
                                                .setAsyncClassToRun(MUTEX_TestDummyBatchable.class)
                                                .setJobName(jobName) );

        Test.startTest();
        
        MUTEX_Service.turnMutexOn(jobName);
        
        Test.stopTest();
        
        Mutex__c recQuery = [select JobStatus__c from Mutex__c where JobId__c = :MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH limit 1];
        
        // check if MutexDummyBatch updated the Status
        system.assertEquals(MUTEX_Domain.STATUS_CODES.INACTIVE.name(), recQuery.JobStatus__c, MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH + ' failed to update');
    }

    @isTest
    private static void givenMultipleRecordsUpdateLaunchJobTurnsStatusOFF()
    {
        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters()
                                                .setAsyncClassToRun(MUTEX_TestDummyQueueable.class)
                                                .setJobName(MUTEX_TestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE) );
        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters()
                                                .setAsyncClassToRun(MUTEX_TestDummyBatchable.class)
                                                .setJobName(MUTEX_TestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH)
                                                .setBatchSize(1) );

        Test.startTest();
        
        List<Mutex__c> mutexlist = [select Id, AsyncClassName__c, JobId__c, JobStatus__c from Mutex__c];

        System.assert( mutexlist.size() == 2 );
        
        mutexlist[0].JobStatus__c = MUTEX_Domain.STATUS_CODES.ACTIVE.name();
        mutexlist[1].JobStatus__c = MUTEX_Domain.STATUS_CODES.ACTIVE.name();
        
        update mutexlist;
        
        Test.stopTest();

        List<Mutex__c> verificationList = [select Id, AsyncClassName__c, JobId__c, JobStatus__c from Mutex__c];

        System.assert( verificationList.size() == 2 );

        // check if MutexDummyQueueable updated the Status
        system.assertEquals(MUTEX_Domain.STATUS_CODES.INACTIVE.name(), verificationList[0].JobStatus__c, verificationList[0].AsyncClassName__c + ' Mutex record failed to update');

        // check if MutexDummyBatch updated the Status 
        system.assertEquals(MUTEX_Domain.STATUS_CODES.INACTIVE.name(), verificationList[1].JobStatus__c, verificationList[1].AsyncClassName__c + ' Mutex record failed to update');
    } 

    @isTest
    private static void givenNoJobNameSetupMutexJob()
    {
        Test.startTest();

        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters().setAsyncClassToRun(MUTEX_TestDummyQueueable.class) );

        Test.stopTest();

        System.assert([Select id from Mutex__c].isEmpty(), 'There are Mutex__c records where there should not be.');
    }

    @isTest
    private static void givenNoJobNameTurnMutexOn()
    {
        Test.startTest();

        MUTEX_Service.turnMutexOn( null );

        Test.stopTest();

        System.assert(true, 'I like pepperoni');
    }

    @isTest
    private static void givenNoJobNameTurnMutexOff()
    {
        Test.startTest();

        MUTEX_Service.turnMutexOff( null );

        Test.stopTest();

        System.assert(true, 'I like pepperoni');
    }

    @isTest
    private static void givenNoJobNamesSelectByJobName()
    {
        Test.startTest();

        List<Mutex__c> records = MUTEX_ServiceImpl.selectByJobName( null );

        Test.stopTest();

        System.assert(records.isEmpty(), 'The MUTEX_Service.selectByJobName() returned records even though the job name was null.');
    }

    @isTest
    private static void givenNoJobNameFindMutexByJobName()
    {
        Test.startTest();

        Mutex__c record = new MUTEX_Domain( new List<Mutex__c>() ).findMutexByJobName( null );

        Test.stopTest();

        System.assert( record == null, 'The MUTEX_Domain.findMutexByJobName() returned a record even though the job name was null.');
    }

    @IsTest
    private static void setupMutexForJobIfNeeded_JobnameAbsent()
    {
        Test.startTest();

        MUTEX_Service.setupMutexForJobIfNeeded( new MUTEX_ServiceParameters()
                                                        .setAsyncClassToRun(MUTEX_TestDummyBatchable.class)
                                                        .setJobName('HelloWorldMutex')
                                                        .setBatchSize(1));

        Test.stopTest();

        System.assertEquals(1, [select id, name from mutex__c].size());
    }

    @IsTest
    private static void setupMutexForJobIfNeeded_JobnameExists()
    {
        String jobName = 'HelloWorldMutex';

        MUTEX_Service.setupMutexForJob( new MUTEX_ServiceParameters()
                                            .setAsyncClassToRun(MUTEX_TestDummyBatchable.class)
                                            .setJobName(jobName)
                                            .setBatchSize(1));

        Test.startTest();

        MUTEX_Service.setupMutexForJobIfNeeded(new MUTEX_ServiceParameters()
                                                    .setAsyncClassToRun(MUTEX_TestDummyBatchable.class)
                                                    .setJobName(jobName)
                                                    .setBatchSize(1));

        Test.stopTest();

        System.assertEquals(1, [select id, JobId__c from mutex__c].size());
    }
}