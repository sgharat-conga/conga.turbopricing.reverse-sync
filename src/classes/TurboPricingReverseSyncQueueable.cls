/**
 *    TurboPricingReverseSyncQueueable
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
public class TurboPricingReverseSyncQueueable implements Queueable, Database.AllowsCallouts {
    // reverse sync job data
    TurboPricingReverseSyncJobData jobData;
    
    // Job handler
    private ITurboPricingReverseSyncJobHandler requestHandler;
    
    public TurboPricingReverseSyncQueueable(TurboPricingReverseSyncJobData jobData){
        this.jobData = jobData;
        requestHandler = GetInstance(jobData.job.JobHandlerClass__c);
    }
    
	public void execute(QueueableContext context) {
    	
        // create requests
    	List<HttpRequest> requests = requestHandler.CreateSyncRequests(jobData, null);
        
        Http http = new Http();
        
        // list to collect response
        List<HttpResponse> responses = new List<HttpResponse>();
        
        // We can control the number callouts by using batchSize parameter
        // Thus making callout in 'for' loop does not necessarily always hit the apex callout limit
        for(HttpRequest request : requests){
            HttpResponse res = http.send(request);
            
            if(res.getStatusCode() != 200){
                throw new TurboPricingReverseSyncJobException(res.getBody());
            }
            
            responses.add(res);
        }
        
        // process TP response
        requestHandler.processSyncResponse(jobData, requests, responses);
        
    	// if needed rescheule itself
        if(jobData.TotalSize!=null && (jobData.PageNumber * jobData.PageSize) < jobData.TotalSize){
            jobData.PageNumber = jobData.PageNumber + 1;
            System.enqueueJob(new TurboPricingReverseSyncQueueable(jobData));
            return;
        }
    }
    
    private ITurboPricingReverseSyncJobHandler GetInstance(string handlerName){
        Type handlerType = Type.forName(handlerName);

        if(handlerType == null){
            throw new TurboPricingReverseSyncJobException('Invalid handler ['+ handlerName +'] configured on reverse-sync job');
        }
        
        if(!(handlerType.newInstance() instanceof ITurboPricingReverseSyncJobHandler)){
            throw new TurboPricingReverseSyncJobException('Failed to instantiate configured handler ['+ handlerName +']');
        }

        ITurboPricingReverseSyncJobHandler instance = (ITurboPricingReverseSyncJobHandler)handlerType.newInstance();

        return instance;
    }
}