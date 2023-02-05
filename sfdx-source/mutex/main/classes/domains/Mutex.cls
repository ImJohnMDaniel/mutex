public with sharing class Mutex 
	// extends ApplicationSObjectDomain
	implements IMutex 
{
	public enum STATUS_CODES { ACTIVE, INACTIVE }

	private static final Integer DEFAULT_BATCH_CHUNK_SIZE = 25;
	private List<Mutex__c> records = new List<Mutex__c>();

	public static IMutex newInstance(List<Mutex__c> records) 
    {
        return (IMutex) new Mutex(records);
    }

	public Mutex(List<Mutex__c> sObjectList) 
	{
		// super(sObjectList);
		this.records = sObjectList == null ? new List<Mutex__c>() : sObjectList;
	}

	public static void triggerHandler()
	{
		if ( Trigger.isAfter && Trigger.isUpdate ) 
		{
			new Mutex( Trigger.new ).onAfterUpdate( Trigger.oldMap );
		}
	}

	// public class Constructor implements fflib_SObjectDomain.IConstructable 
	// {
	// 	public fflib_SObjectDomain construct(List<sObject> sObjectList) 
	// 	{
	// 		return new Mutex(sObjectList);
	// 	}
	// }

	//public override void onAfterUpdate(Map<Id,SObject> existingRecords) // version to use when enabled for fflib/at4dx
	public void onAfterUpdate(Map<Id,SObject> existingRecords)
	{
		launchJob(existingRecords);
	}

	@TestVisible
	private Mutex__c findMutexByJobName( String jobName )
	{
		if ( String.isNotBlank(jobName) )
		{
			for ( Mutex__c mutexRecord : records )
			{
				if (jobName.equalsIgnoreCase(mutexRecord.JobId__c))
				{
					return mutexRecord;
				}
			}
		}

		return null;
	}

	public void turnMutexOn( String jobName, fflib_ISObjectUnitOfWork uow )
	{
		Mutex__c mutexRecord = findMutexByJobName(jobName);

		if ( mutexRecord != null )
		{
			uow.registerDirty( switchOn( mutexRecord ) );
		}
	}

    public void turnMutexOff( String jobName, fflib_ISObjectUnitOfWork uow )
	{
		Mutex__c mutexRecord = findMutexByJobName(jobName);

		if ( mutexRecord != null )
		{
			uow.registerDirty( switchOff( mutexRecord ) );
		}
	}

	private Mutex__c switchOff( Mutex__c mutexRecord )
	{
		mutexRecord.JobStatus__c = STATUS_CODES.INACTIVE.name();
		return mutexRecord;
	}

	private Mutex__c switchOn( Mutex__c mutexRecord )
	{
		mutexRecord.JobStatus__c = STATUS_CODES.ACTIVE.name();
		return mutexRecord;
	}

	/*
	 * Launch Queueable or Batchable based on Status change from OFF to ON and for all cases do nothing
	 */
	private void launchJob (Map<Id,SObject> oldRecMap)
	{
		Mutex__c oldRec = Null;

		if (records != Null) 
		{
			fflib_ISObjectUnitOfWork uowMutex = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

			Boolean batchExecutionHasFailed = false;

			for (Mutex__c rec : (List<Mutex__c>) records) 
			{
				oldRec = (Mutex__c) oldRecMap.get(rec.Id);

				// system.debug('newRec:'+rec.JobStatus__c);
				// system.debug('oldRec:'+oldRec.JobStatus__c);
			
				if (rec.JobStatus__c != oldRec.JobStatus__c 
					&& String.isNotBlank(rec.AsyncClassName__c)
			   		&& STATUS_CODES.ACTIVE.name().equalsIgnoreCase(rec.JobStatus__c)) 
				{
					Type classType = Type.forName( rec.AsyncClassName__c );
				
					if ( classType.newInstance() instanceof Queueable & ! System.isQueueable() )
					{
						Queueable queueableInstance = (Queueable)classType.newInstance();
						System.enqueueJob(queueableInstance);
					} 
					else if (classType.newInstance() instanceof Database.Batchable<sObject>) 
					{
						Database.Batchable<sObject> batchName = (Database.Batchable<sObject>)classType.newInstance();

						String jobID = Database.executeBatch( batchName, rec.BatchSize__c == null ? DEFAULT_BATCH_CHUNK_SIZE : rec.BatchSize__c.intValue());
					
						//exception loging for flex queue locking
						if ( jobID.startsWith('000') ) //000xxxxxxxxxxxx should be returned when Batch job fails to acquire lock.
						{ 
							//resetting the Mutex flag to OFF
												
							uowMutex.registerDirty( switchOff( rec ) );
							batchExecutionHasFailed = true;
						}
					}
				}
			}

			if ( batchExecutionHasFailed ) 
			{
				uowMutex.commitWork(); //This is a potential recursive trigger scenario..but since we are doing status = off, it should not trigger Mutex further. 
			}
		}
	}
}
