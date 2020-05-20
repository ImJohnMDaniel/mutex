public interface IMutex 
{
    void turnMutexOn( String jobName, fflib_ISObjectUnitOfWork uow );
    void turnMutexOff( String jobName, fflib_ISObjectUnitOfWork uow );
}
