/**
 *    TurboPricingReverseSyncWebhookController
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
@RestResource(urlMapping = '/reverse-sync')
global class TurboPricingReverseSyncWebhookController {
    
    @HttpPost
    global static string initiateReverseSync(InitiateReverseSyncRequest request){
        
        // if required data is not present then return
        if(request == null || string.isBlank(request.cartId)){
            return 'Invalid input';
        }
        
        return startReverseSync(request.cartId);
        
    }
    
    private static String startReverseSync(string cartId){
        // Query custom metadata and as per that start reverse sync jobs
        CongaTurboPricingReverseSyncJob__mdt job = [SELECT Id,BatchSize__c,EndpointHttpMethod__c,EndpointURL__c,IsActive__c,JobHandlerClass__c,LastRunTime__c,Sequence__c,JobType__c
                                                    FROM CongaTurboPricingReverseSyncJob__mdt 
                                                    WHERE IsActive__c = true
                                                    ORDER BY Sequence__c LIMIT 1];
        if(job == null){
            throw new TurboPricingReverseSyncJobException('No custom metadata is configured');
        }
        
        if(job.JobType__c == 'Queueable'){
            TurboPricingReverseSyncJobData jobData = new TurboPricingReverseSyncJobData();
            jobData.cartId = cartId;
            jobData.job = job;
            jobData.PageNumber = 1;
            jobData.PageSize = (Integer)job.BatchSize__c;
            return System.enqueueJob(new TurboPricingReverseSyncQueueable(jobData));
        }
     
        return null;
    }
    
    global class InitiateReverseSyncRequest{
        global string cartId{get;set;}
    }
}