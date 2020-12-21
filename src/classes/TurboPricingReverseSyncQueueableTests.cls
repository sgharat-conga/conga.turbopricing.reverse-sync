/**
 *    TurboPricingReverseSyncQueueableTests
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
@IsTest
public class TurboPricingReverseSyncQueueableTests {
	
	@isTest
    public static void verify_blankHandler(){
		// arrange
		CongaTurboPricingReverseSyncJob__mdt job = [SELECT Id,BatchSize__c,EndpointHttpMethod__c,EndpointURL__c,IsActive__c,JobHandlerClass__c,LastRunTime__c,Sequence__c,JobType__c
                                                    FROM CongaTurboPricingReverseSyncJob__mdt 
                                                    WHERE IsActive__c = true AND DeveloperName = 'LineItemRelatedLists' 
                                                    ORDER BY Sequence__c LIMIT 1];
		TurboPricingReverseSyncJobData jobData = new TurboPricingReverseSyncJobData();
		jobData.cartId = 'cart-id1';
		jobData.job = job;
		jobData.PageNumber = 1;
		jobData.PageSize = (Integer)job.BatchSize__c;
		job.JobHandlerClass__c = 'InvalidClassName';
		
		// act
		try{
			TurboPricingReverseSyncQueueable result = new TurboPricingReverseSyncQueueable(jobData);
		}
		catch(TurboPricingReverseSyncJobException ex){
			System.assert(ex.getMessage().contains('Invalid handler'), 'Error message of caught exception is not as expected');
			return;
		}
		
		System.assert(false, 'This should not be executed');
	}
    
    @isTest
    public static void verify_IncorrectHandler(){
		// arrange
		CongaTurboPricingReverseSyncJob__mdt job = [SELECT Id,BatchSize__c,EndpointHttpMethod__c,EndpointURL__c,IsActive__c,JobHandlerClass__c,LastRunTime__c,Sequence__c,JobType__c
                                                    FROM CongaTurboPricingReverseSyncJob__mdt 
                                                    WHERE IsActive__c = true AND DeveloperName = 'LineItemRelatedLists' 
                                                    ORDER BY Sequence__c LIMIT 1];
		TurboPricingReverseSyncJobData jobData = new TurboPricingReverseSyncJobData();
		jobData.cartId = 'cart-id1';
		jobData.job = job;
		jobData.PageNumber = 1;
		jobData.PageSize = (Integer)job.BatchSize__c;
		job.JobHandlerClass__c = 'TurboPricingReverseSyncJobData';
		
		// act
		try{
			TurboPricingReverseSyncQueueable result = new TurboPricingReverseSyncQueueable(jobData);
		}
		catch(TurboPricingReverseSyncJobException ex){
			System.assert(ex.getMessage().contains('Failed to instantiate configured handler'), 'Error message of caught exception is not as expected');
			return;
		}
		
		System.assert(false, 'This should not be executed');
	}
}