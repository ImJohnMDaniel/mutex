trigger Mutex on Mutex__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{       
    fflib_SObjectDomain.triggerHandler(MUTEX_Domain.class);
}