// TODO : Prefix all Mutex related work with MUTEX_
public interface MUTEX_IDomain 
    extends IApplicationSObjectDomain
{
    void turnMutexOn( String jobName, IApplicationSObjectUnitOfWork uow );
    void turnMutexOff( String jobName, IApplicationSObjectUnitOfWork uow );
}
