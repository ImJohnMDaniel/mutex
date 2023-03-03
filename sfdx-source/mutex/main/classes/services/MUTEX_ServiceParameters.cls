public class MUTEX_ServiceParameters 
{
    public String jobName { get; private set; }
    public System.Type asyncClassToRun { get; private set; }
    public Integer batchSize { get; private set; }
    public MUTEX_IInitializationParameters initializationParameters { get; private set; }
    public Integer queueableDelay { get; private set; }

    public MUTEX_ServiceParameters setJobName(String jobName)
    {
        this.jobName = jobName;
        return this;
    }

    public MUTEX_ServiceParameters setAsyncClassToRun(System.Type asyncClassToRun)
    {
        this.asyncClassToRun = asyncClassToRun;
        return this;
    }
    
    public MUTEX_ServiceParameters setBatchSize(Integer batchSize)
    {
        this.batchSize = batchSize;
        return this;
    }

    public MUTEX_ServiceParameters setQueueableDelay(Integer queueableDelay)
    {
        this.queueableDelay = queueableDelay;
        return this;
    }

    public MUTEX_ServiceParameters setInitializationParameters(MUTEX_IInitializationParameters initializationParameters)
    {
        this.initializationParameters = initializationParameters;
        return this;
    }
}