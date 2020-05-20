@isTest
private class MutexTest {

    @isTest
    private static void givenValidQueueApexUpdateLaunchJobTurnsStatusOFF()
    {
        String jobName = MutexTestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE;

        MutexService.setupMutexForJob( jobName, MutexTestDummyQueueable.class );
        
        Test.startTest();
        
        MutexService.turnMutexOn(jobName);
        
        Test.stopTest();
        
        Mutex__c recQuery = [select JobStatus__c from Mutex__c where JobId__c = :MutexTestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE limit 1];
        
        // check if MutexDummyQueueable updated the Status
        system.assertEquals(Mutex.STATUS_CODES.INACTIVE.name(), recQuery.JobStatus__c, MutexTestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE + ' failed to update');
    } 

    @isTest
    private static void givenValidBatchApexUpdateLaunchJobTurnsStatusOFF()
    {
        String jobName = MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH;

        MutexService.setupMutexForJob( jobName, MutexTestDummyBatchable.class, 1 );

        Test.startTest();
        
        MutexService.turnMutexOn(jobName);
        
        Test.stopTest();
        
        Mutex__c recQuery = [select JobStatus__c from Mutex__c where JobId__c = :MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH limit 1];
        
        // check if MutexDummyBatch updated the Status
        system.assertEquals(Mutex.STATUS_CODES.INACTIVE.name(), recQuery.JobStatus__c, MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH + ' failed to update');
    }

    @isTest
    private static void givenValidBatchApexNullBatchUpdateLaunchJobTurnsStatusOFF()
    {
        String jobName = MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH;

        MutexService.setupMutexForJob( jobName, MutexTestDummyBatchable.class, null );

        Test.startTest();
        
        MutexService.turnMutexOn(jobName);
        
        Test.stopTest();
        
        Mutex__c recQuery = [select JobStatus__c from Mutex__c where JobId__c =: MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH limit 1];
        
        // check if MutexDummyBatch updated the Status
        system.assertEquals(Mutex.STATUS_CODES.INACTIVE.name(), recQuery.JobStatus__c, MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH + ' failed to update');
    }

    @isTest
    private static void givenMultipleRecordsUpdateLaunchJobTurnsStatusOFF()
    {
        MutexService.setupMutexForJob( MutexTestDummyQueueable.MUTEX_JOB_ID_DUMMY_QUEUEABLE, MutexTestDummyQueueable.class);
        MutexService.setupMutexForJob( MutexTestDummyBatchable.MUTEX_JOB_ID_DUMMY_BATCH, MutexTestDummyBatchable.class, 1 );

        Test.startTest();
        
        List<Mutex__c> mutexlist = [select Id, AsyncClassName__c, JobId__c, JobStatus__c from Mutex__c];

        System.assert( mutexlist.size() == 2 );
        
        mutexlist[0].JobStatus__c = Mutex.STATUS_CODES.ACTIVE.name();
        mutexlist[1].JobStatus__c = Mutex.STATUS_CODES.ACTIVE.name();
        
        update mutexlist;
        
        Test.stopTest();

        List<Mutex__c> verificationList = [select Id, AsyncClassName__c, JobId__c, JobStatus__c from Mutex__c];

        System.assert( verificationList.size() == 2 );

        // check if MutexDummyQueueable updated the Status
        system.assertEquals(Mutex.STATUS_CODES.INACTIVE.name(), verificationList[0].JobStatus__c, verificationList[0].AsyncClassName__c + ' Mutex record failed to update');

        // check if MutexDummyBatch updated the Status 
        system.assertEquals(Mutex.STATUS_CODES.INACTIVE.name(), verificationList[1].JobStatus__c, verificationList[1].AsyncClassName__c + ' Mutex record failed to update');
    } 

    @isTest
    private static void givenNoJobNameSetupMutexJob()
    {
        Test.startTest();

        MutexService.setupMutexForJob( null, MutexTestDummyQueueable.class);

        Test.stopTest();

        System.assert([Select id from Mutex__c].isEmpty(), 'There are Mutex__c records where there should not be.');
    }

    @isTest
    private static void givenNoJobNameTurnMutexOn()
    {
        Test.startTest();

        MutexService.turnMutexOn( null );

        Test.stopTest();

        System.assert(true, 'I like pepperoni');
    }

    @isTest
    private static void givenNoJobNameTurnMutexOff()
    {
        Test.startTest();

        MutexService.turnMutexOff( null );

        Test.stopTest();

        System.assert(true, 'I like pepperoni');
    }

    @isTest
    private static void givenNoJobNamesSelectByJobName()
    {
        Test.startTest();

        List<Mutex__c> records = MutexServiceImpl.selectByJobName( null );

        Test.stopTest();

        System.assert(records.isEmpty(), 'The MutexService.selectByJobName() returned records even though the job name was null.');
    }

    @isTest
    private static void givenNoJobNameFindMutexByJobName()
    {
        Test.startTest();

        Mutex__c record = new Mutex( new List<Mutex__c>() ).findMutexByJobName( null );

        Test.stopTest();

        System.assert( record == null, 'The Mutex.findMutexByJobName() returned a record even though the job name was null.');
    }

    @IsTest
    private static void setupMutexForJobIfNeeded_JobnameAbsent()
    {
        Test.startTest();

        MutexService.setupMutexForJobIfNeeded('HelloWorldMutex', MutexTestDummyBatchable.class, 1);

        Test.stopTest();

        System.assertEquals(1, [select id, name from mutex__c].size());
    }

    @IsTest
    private static void setupMutexForJobIfNeeded_JobnameExists()
    {
        String jobName = 'HelloWorldMutex';

        MutexService.setupMutexForJob(jobName, MutexTestDummyBatchable.class, 1);

        Test.startTest();

        MutexService.setupMutexForJobIfNeeded(jobName, MutexTestDummyBatchable.class, 1);

        Test.stopTest();

        System.assertEquals(1, [select id, JobId__c from mutex__c].size());
    }
}