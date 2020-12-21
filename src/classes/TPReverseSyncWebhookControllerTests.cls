/**
 *    TPReverseSyncWebhookControllerTests
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
@IsTest
public class TPReverseSyncWebhookControllerTests {
    public static Apttus_Config2__ProductConfiguration__c cart;
    public static Apttus_Config2__LineItem__c line1;
    public static Apttus_Config2__LineItem__c line2;
    public static TurboPricingReverseSyncJobData jobData;
    
	@isTest
    public static void verify_invalidInput(){
		
		// arrange
		TurboPricingReverseSyncWebhookController.InitiateReverseSyncRequest request = new TurboPricingReverseSyncWebhookController.InitiateReverseSyncRequest();
		
		// act 1 - null
		String result = TurboPricingReverseSyncWebhookController.initiateReverseSync(null);
		
		// assure
		System.assertEquals('Invalid input', result);
		
		// act 2 - empty
		result = TurboPricingReverseSyncWebhookController.initiateReverseSync(request);
		
		// assure
		System.assertEquals('Invalid input', result);
    }
    
    @isTest
    public static void verify_validInput(){
		
        createTestData();
        
        CongaTurboPricingReverseSyncJob__mdt job = [SELECT Id,BatchSize__c,EndpointHttpMethod__c,EndpointURL__c,IsActive__c,JobHandlerClass__c,LastRunTime__c,Sequence__c,JobType__c
                                                    FROM CongaTurboPricingReverseSyncJob__mdt 
                                                    WHERE IsActive__c = true AND DeveloperName = 'LineItemRelatedLists' 
                                                    ORDER BY Sequence__c LIMIT 1];
													
		jobData = new TurboPricingReverseSyncJobData();
		jobData.cartId = cart.Id;
		jobData.job = job;
		jobData.PageNumber = 1;
		jobData.PageSize = (Integer)job.BatchSize__c;
        
		// arrange
		TurboPricingReverseSyncWebhookController.InitiateReverseSyncRequest request = new TurboPricingReverseSyncWebhookController.InitiateReverseSyncRequest();
        request.cartId = cart.Id;
		
		try{
			
			Test.startTest();
        
			// setup mock
			Test.setMock(HttpCalloutMock.class, new TurboPricingCalloutMockForNonOk(jobData));
			
			// act 1 - null
			String result = TurboPricingReverseSyncWebhookController.initiateReverseSync(request);
			
			// stop test
			Test.stopTest();
		}
		catch(TurboPricingReverseSyncJobException ex){
			System.assert(ex.getMessage().contains('Fatal'), 'exception messgae is not as expected');
            return;
		}
		
		
		// assure
		System.assert(false, 'This line should not be executed');
    }
    
    private static void createTestData(){
        // create cart
        cart = new Apttus_Config2__ProductConfiguration__c();
        cart.Name = 'test cart';
        cart.CurrencyIsoCode = 'USD';
        insert cart;
        
        // create custom metadata
        Apttus_Base2__TurboEngineAdminProperties__c m1 = new Apttus_Base2__TurboEngineAdminProperties__c();
        m1.Apttus_Base2__ServiceUrl__c = 'https://turboengine.conga.com';
        m1.Name = TPSyncLineItemRelatedListsHandler.TP_CUSTOM_SETTING_NAME;
        insert m1;
    }
	
	public class TurboPricingCalloutMockForNonOk implements HttpCalloutMock{
        public TurboPricingReverseSyncJobData jobData;
		public TurboPricingCalloutMockForNonOk(TurboPricingReverseSyncJobData jobData){
            this.jobData = jobData;
		}
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('https://turboengine.conga.com/pricing/carts/' + cart.Id + '/lines?includeAdjustments=true&includePriceBreakup=true&includeUsageTiers=true&pageNumber=1&pageSize='+ jobData.PageSize, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // create mock response
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Fatal!');
            res.setStatusCode(500);
            return res;
        }
    } 
}