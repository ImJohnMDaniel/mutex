public class MutexServiceParameters 
{
    public String jobName { get; private set; }
    public System.Type asyncClassToRun { get; private set; }
    public Integer batchSize { get; private set; }
    public IMutexParameters initializationParameters { get; private set; }
    public Integer queueableDelay { get; private set; }

    public MutexServiceParameters setJobName(String jobName)
    {
        this.jobName = jobName;
        return this;
    }

    public MutexServiceParameters setAsyncClassToRun(System.Type asyncClassToRun)
    {
        this.asyncClassToRun = asyncClassToRun;
        return this;
    }
    
    public MutexServiceParameters setBatchSize(Integer batchSize)
    {
        this.batchSize = batchSize;
        return this;
    }

    public MutexServiceParameters setQueueableDelay(Integer queueableDelay)
    {
        this.queueableDelay = queueableDelay;
        return this;
    }

    public MutexServiceParameters setInitializationParameters(IMutexParameters initializationParameters)
    {
        this.initializationParameters = initializationParameters;
        return this;
    }
}