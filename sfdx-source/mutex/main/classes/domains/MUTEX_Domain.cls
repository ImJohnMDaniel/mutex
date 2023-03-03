public with sharing class MUTEX_Domain 
	extends ApplicationSObjectDomain
	implements MUTEX_IDomain 
{
	public enum STATUS_CODES { ACTIVE, INACTIVE }

	private static final Integer DEFAULT_BATCH_CHUNK_SIZE = 25;

	public static MUTEX_IDomain newInstance(List<Mutex__c> records) 
    {
        return (MUTEX_IDomain) new MUTEX_Domain(records);
    }

	public MUTEX_Domain(List<Mutex__c> sObjectList) 
	{
		super(sObjectList);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable 
	{
		public fflib_SObjectDomain construct(List<sObject> sObjectList) 
		{
			return new MUTEX_Domain(sObjectList);
		}
	}

	public override void onAfterUpdate(Map<Id,SObject> existingRecords)
	{
		launchJob(existingRecords);
	}

	@TestVisible
	private Mutex__c findMutexByJobName( String jobName )
	{
		if ( String.isNotBlank(jobName) )
		{
			for ( Mutex__c mutexRecord : (List<Mutex__c>) this.records )
			{
				if (jobName.equalsIgnoreCase(mutexRecord.JobId__c))
				{
					return mutexRecord;
				}
			}
		}

		return null;
	}

	public void turnMutexOn( String jobName, IApplicationSObjectUnitOfWork uow )
	{
		Mutex__c mutexRecord = findMutexByJobName(jobName);

		if ( mutexRecord != null )
		{
			System.debug('Turning MUTEX on for jobName: \'' + jobName + '\' (Mutex__c.Id: ' + mutexRecord.Id + ')');
			uow.registerDirty( switchOn( mutexRecord ) );
		}
		else 
		{
			System.debug('Request for MUTEX to turn on jobName: \'' + jobName + '\' was not successful.  No MUTEX job found with that name.');	
		}
	}

    public void turnMutexOff( String jobName, IApplicationSObjectUnitOfWork uow )
	{
		Mutex__c mutexRecord = findMutexByJobName(jobName);

		if ( mutexRecord != null )
		{
			System.debug('Turning MUTEX off for jobName: \'' + jobName + '\' (Mutex__c.Id: ' + mutexRecord.Id + ')');
			uow.registerDirty( switchOff( mutexRecord ) );
		}
		else 
		{
			System.debug('Request for MUTEX to turn off jobName: \'' + jobName + '\' was not successful.  No MUTEX job found with that name.');	
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
			IApplicationSObjectUnitOfWork uowMutex = new ApplicationSObjectUnitOfWork(new List<Schema.SObjectType> { Mutex__c.sObjectType });

			Boolean batchExecutionHasFailed = false;

			for (Mutex__c rec : (List<Mutex__c>) this.records) 
			{
				oldRec = (Mutex__c) oldRecMap.get(rec.Id);

				System.debug('rec.JobStatus__c: ' + rec.JobStatus__c);
				System.debug('oldRec.JobStatus__c: ' + oldRec.JobStatus__c);
			
				if (rec.JobStatus__c != oldRec.JobStatus__c 
					&& String.isNotBlank(rec.AsyncClassName__c)
			   		&& STATUS_CODES.ACTIVE.name().equalsIgnoreCase(rec.JobStatus__c)) 
				{
					Type classType = Type.forName( rec.AsyncClassName__c );
				
					if ( classType == null )
					{
						continue;
					}
					if ( classType.newInstance() instanceof Queueable & ! System.isQueueable() )
					{
						Queueable queueableInstance = (Queueable)classType.newInstance();

						if ( queueableInstance instanceOf MUTEX_IParameterable )
						{
							((MUTEX_IParameterable)queueableInstance).setSerializedParameter(rec.ParametersSerialized__c);
						}

						System.enqueueJob(queueableInstance);
					} 
					else if (classType.newInstance() instanceof Database.Batchable<sObject>) 
					{
						Database.Batchable<sObject> batchInstance = (Database.Batchable<sObject>)classType.newInstance();

						if ( batchInstance instanceOf MUTEX_IParameterable )
						{
							((MUTEX_IParameterable)batchInstance).setSerializedParameter(rec.ParametersSerialized__c);
						}

						String jobID = Database.executeBatch( batchInstance, rec.BatchSize__c == null ? DEFAULT_BATCH_CHUNK_SIZE : rec.BatchSize__c.intValue());
					
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
