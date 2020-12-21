/**
 *    TPSyncLIneItemRelatedListsTests
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
@IsTest
public class TPSyncLIneItemRelatedListsTests {
    public static Apttus_Config2__ProductConfiguration__c cart;
    public static Apttus_Config2__LineItem__c line1;
    public static Apttus_Config2__LineItem__c line2;
    public static TurboPricingReverseSyncJobData jobData;
    
    @isTest
    public static void verify_adjustmentLineItemsSync(){
        // arrange
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
            
        
        Test.startTest();
        
        // setup mock
		List<Apttus_Config2__LineItem__c> lines = new List<Apttus_Config2__LineItem__c>();
		lines.add(line1);
		lines.add(line2);
        Test.setMock(HttpCalloutMock.class, new TurboPricingCalloutMockForAdjustmentLineItems(lines, jobData));
        
        // act
        System.enqueueJob(new TurboPricingReverseSyncQueueable(jobData));
        
        // stop test
        Test.stopTest();
        
        // assure
        List<Apttus_Config2__AdjustmentLineItem__c> adjLines = [Select Id,
																		Apttus_Config2__LineItemId__c,
																		Apttus_Config2__Type__c,
																		Apttus_Config2__LineType__c,
																		Apttus_Config2__BenefitQuantity__c,
																		Apttus_Config2__AdjustmentType__c,
																		Apttus_Config2__AdjustmentAmount__c,
																		Apttus_Config2__AdjustmentAppliesTo__c,
																		Apttus_Config2__IncentiveAdjustmentAmount__c,
																		Apttus_Config2__PriceRuleId__c,
																		Apttus_Config2__PriceRuleEntryId__c,
																		Apttus_Config2__LineNumber__c,
                                                                		CurrencyIsoCode
                                                                FROM  Apttus_Config2__AdjustmentLineItem__c 
                                                                WHERE Apttus_Config2__LineItemId__c = : line1.Id];
        System.assertEquals(2, adjLines.size());
        System.assertEquals(line1.Id, adjLines.get(0).Apttus_Config2__LineItemId__c);
        System.assertEquals('Price Rule', adjLines.get(0).Apttus_Config2__Type__c);
        System.assertEquals('Auto', adjLines.get(0).Apttus_Config2__LineType__c);
        System.assertEquals(1, adjLines.get(0).Apttus_Config2__BenefitQuantity__c);
        System.assertEquals('Markup Amount', adjLines.get(0).Apttus_Config2__AdjustmentType__c);
        System.assertEquals(10, adjLines.get(0).Apttus_Config2__AdjustmentAmount__c);
        System.assertEquals('Base Price', adjLines.get(0).Apttus_Config2__AdjustmentAppliesTo__c);
        System.assertEquals(10, adjLines.get(0).Apttus_Config2__IncentiveAdjustmentAmount__c);
        System.assertEquals('a3t3i000000CrBLAA0', adjLines.get(0).Apttus_Config2__PriceRuleId__c);
        System.assertEquals('a3s3i000000bAuKAAU', adjLines.get(0).Apttus_Config2__PriceRuleEntryId__c);
        System.assertEquals(1, adjLines.get(0).Apttus_Config2__LineNumber__c);
        System.assertEquals('USD', adjLines.get(0).CurrencyIsoCode);
    }
	
	@isTest
    public static void verify_priceBreakupSync(){
        // arrange
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
            
        
        Test.startTest();
        
        // setup mock
        Test.setMock(HttpCalloutMock.class, new TurboPricingCalloutMockForPriceBreakups(line1, jobData));
        
        // act
        System.enqueueJob(new TurboPricingReverseSyncQueueable(jobData));
        
        // stop test
        Test.stopTest();
        
        // assure
        List<Apttus_Config2__PriceBreakup__c> relatedDataLines = [Select Id,
																		Apttus_Config2__LineItemId__c,
																		Apttus_Config2__BreakupType__c,
																		Apttus_Config2__Sequence__c,
																		Apttus_Config2__RelatedProductId__c,
																		Apttus_Config2__RelatedQuantity__c,
																		Apttus_Config2__RelatedSellingFrequency__c,
																		Apttus_Config2__RelatedSellingTerm__c,
																		Apttus_Config2__RelatedStartDate__c,
																		Apttus_Config2__RelatedEndDate__c,
																		Apttus_Config2__RelatedChargeType__c,
																		Apttus_Config2__RelatedListPrice__c,
																		Apttus_Config2__RelatedBasePrice__c,
																		Apttus_Config2__RelatedExtendedPrice__c,
																		Apttus_Config2__RelatedNetPrice__c,
																		Apttus_Config2__NetUnitPrice__c
                                                                FROM  Apttus_Config2__PriceBreakup__c 
                                                                WHERE Apttus_Config2__LineItemId__c = : line1.Id];
        System.assertEquals(1, relatedDataLines.size());
        System.assertEquals(line1.Id, relatedDataLines.get(0).Apttus_Config2__LineItemId__c);
        System.assertEquals('Related Price', relatedDataLines.get(0).Apttus_Config2__BreakupType__c);
        System.assertEquals(1, relatedDataLines.get(0).Apttus_Config2__Sequence__c);
        System.assertEquals('01t3i000004M747AAC', relatedDataLines.get(0).Apttus_Config2__RelatedProductId__c);
        System.assertEquals(1, relatedDataLines.get(0).Apttus_Config2__RelatedQuantity__c);
        System.assertEquals('Monthly', relatedDataLines.get(0).Apttus_Config2__RelatedSellingFrequency__c);
        System.assertEquals(12, relatedDataLines.get(0).Apttus_Config2__RelatedSellingTerm__c);
        System.assertEquals('Standard Price', relatedDataLines.get(0).Apttus_Config2__RelatedChargeType__c);
        System.assertEquals(200, relatedDataLines.get(0).Apttus_Config2__RelatedListPrice__c);
        System.assertEquals(208, relatedDataLines.get(0).Apttus_Config2__RelatedBasePrice__c);
    }
    
    private static void createTestData(){
        // create cart
        cart = new Apttus_Config2__ProductConfiguration__c();
        cart.Name = 'test cart';
        cart.CurrencyIsoCode = 'USD';
        insert cart;
        
        // create line item 1
        line1 = new Apttus_Config2__LineItem__c();
        line1.Apttus_Config2__ConfigurationId__c = cart.Id;
        line1.Apttus_Config2__ItemSequence__c = 1;
        line1.Apttus_Config2__LineNumber__c = 1;
        line1.Apttus_Config2__PrimaryLineNumber__c = 1;
        line1.Apttus_Config2__ChargeType__c = 'Standard Price';
        line1.Apttus_Config2__StartDate__c = Date.newInstance(2020, 10, 1);
        line1.Apttus_Config2__EndDate__c = Date.newInstance(2020, 10, 31);
        insert line1;
		
		// create line item 2
        line2 = new Apttus_Config2__LineItem__c();
        line2.Apttus_Config2__ConfigurationId__c = cart.Id;
        line2.Apttus_Config2__ItemSequence__c = 1;
        line2.Apttus_Config2__LineNumber__c = 2;
        line2.Apttus_Config2__PrimaryLineNumber__c = 2;
        line2.Apttus_Config2__ChargeType__c = 'Standard Price';
        line2.Apttus_Config2__StartDate__c = Date.newInstance(2020, 10, 1);
        line2.Apttus_Config2__EndDate__c = Date.newInstance(2020, 10, 31);
        insert line2;
        
        // create custom metadata
        Apttus_Base2__TurboEngineAdminProperties__c m1 = new Apttus_Base2__TurboEngineAdminProperties__c();
        m1.Apttus_Base2__ServiceUrl__c = 'https://turboengine.conga.com';
        m1.Name = TPSyncLineItemRelatedListsHandler.TP_CUSTOM_SETTING_NAME;
        insert m1;
    }
    
    public class TurboPricingCalloutMockForAdjustmentLineItems implements HttpCalloutMock{
		private Apttus_Config2__LineItem__c line1;
		private Apttus_Config2__LineItem__c line2;
        private TurboPricingReverseSyncJobData jobData;
		public TurboPricingCalloutMockForAdjustmentLineItems(List<Apttus_Config2__LineItem__c> lines, TurboPricingReverseSyncJobData jobData){
			this.line1 = lines.get(0);
			this.line2 = lines.get(1);
            this.jobData = jobData;
		}
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('https://turboengine.conga.com/pricing/carts/' + cart.Id + '/lines?includeAdjustments=true&includePriceBreakup=true&includeUsageTiers=true&pageNumber=1&pageSize='+ jobData.PageSize, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // create mock response
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(getMockResponse());
            res.setStatusCode(200);
            return res;
        }
        
        private string getMockResponse(){
            Map<String,object> result = new Map<string,object>();
            Map<String,object> cartResponse = new Map<string,object>();
            List<Map<String,object>> lineItems = new List<Map<string,object>>();
            Map<String,object> line1 = new Map<string,object>();
            line1.put('Id', this.line1.Id);
            List<Map<String,object>> adjLines = new List<Map<string,object>>();
            Map<String,object> adjLine1 = new Map<string,object>();
            adjLine1.put('Digest', '3f13f7ac238cdd3e47fd41ef633a991530727f1ac2056150c3c2b6e2e3bf53c3');
            adjLine1.put('Apttus_Config2__LineItemId__c', this.line1.Id);
			adjLine1.put('Apttus_Config2__Type__c', 'Price Rule');
			adjLine1.put('Apttus_Config2__LineType__c', 'Auto');
			adjLine1.put('Apttus_Config2__BenefitQuantity__c', 1);
			adjLine1.put('Apttus_Config2__AdjustmentType__c', 'Markup Amount');
			adjLine1.put('Apttus_Config2__AdjustmentAmount__c', 10);
			adjLine1.put('Apttus_Config2__AdjustmentAppliesTo__c', 'Base Price');
			adjLine1.put('Apttus_Config2__IncentiveAdjustmentAmount__c', 10.0);
			adjLine1.put('Apttus_Config2__PriceRuleId__c', 'a3t3i000000CrBLAA0');
			adjLine1.put('Apttus_Config2__PriceRuleEntryId__c', 'a3s3i000000bAuKAAU');
			adjLine1.put('Apttus_Config2__LineNumber__c', 1);
            adjLine1.put('CurrencyIsoCode', 'USD');
			
			Map<String,object> adjLine2 = new Map<string,object>();
            adjLine2.put('Digest', '3f13f7ac238cdd3e47fd41ef633a991530727f1ac2056150c3c2b6e2e3bf53c3');
            adjLine2.put('Apttus_Config2__LineItemId__c', this.line1.Id);
			adjLine2.put('Apttus_Config2__Type__c', 'Price Rule');
			adjLine2.put('Apttus_Config2__LineType__c', 'Auto');
			adjLine2.put('Apttus_Config2__BenefitQuantity__c', 1);
			adjLine2.put('Apttus_Config2__AdjustmentType__c', 'Markup Amount');
			adjLine2.put('Apttus_Config2__AdjustmentAmount__c', 20);
			adjLine2.put('Apttus_Config2__AdjustmentAppliesTo__c', 'Base Price');
			adjLine2.put('Apttus_Config2__IncentiveAdjustmentAmount__c', 20.0);
			adjLine2.put('Apttus_Config2__PriceRuleId__c', 'a3t3i000000CrBLAA0');
			adjLine2.put('Apttus_Config2__PriceRuleEntryId__c', 'a3s3i000000bAuKAAU');
			adjLine2.put('Apttus_Config2__LineNumber__c', 1);
            adjLine2.put('CurrencyIsoCode', 'USD');
			
			adjLines.add(adjLine1);
			adjLines.add(adjLine2);
			line1.put('Apttus_Config2__AdjustmentLineItems__r', adjLines);
			lineItems.add(line1);
			
			// line 2
			Map<String,object> line2 = new Map<string,object>();
            line2.put('Id', this.line2.Id);
			lineItems.add(line2);
			cartResponse.put('Apttus_Config2__LineItems__r', lineItems);
			result.put('CartResponse', cartResponse);
			result.put(TPSyncLineItemRelatedListsHandler.RESPONSE_PROP_TOTAL_LINES_COUNT, lineItems.size());
			
			return Json.serialize(result);
        }
    } 
	
	public class TurboPricingCalloutMockForPriceBreakups implements HttpCalloutMock{
		private Apttus_Config2__LineItem__c line;
        private TurboPricingReverseSyncJobData jobData;
		public TurboPricingCalloutMockForPriceBreakups(Apttus_Config2__LineItem__c line, TurboPricingReverseSyncJobData jobData){
			this.line = line;
            this.jobData = jobData;
		}
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('https://turboengine.conga.com/pricing/carts/' + cart.Id + '/lines?includeAdjustments=true&includePriceBreakup=true&includeUsageTiers=true&pageNumber=1&pageSize='+ jobData.PageSize, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // create mock response
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(getMockResponse());
            res.setStatusCode(200);
            return res;
        }
        
        private string getMockResponse(){
            Map<String,object> result = new Map<string,object>();
            Map<String,object> cartResponse = new Map<string,object>();
            List<Map<String,object>> lineItems = new List<Map<string,object>>();
            Map<String,object> line = new Map<string,object>();
            line.put('Id', this.line.Id);
            List<Map<String,object>> relatedDataLines = new List<Map<string,object>>();
            Map<String,object> relatedData1 = new Map<string,object>();
            relatedData1.put('Digest', '3f13f7ac238cdd3e47fd41ef633a991530727f1ac2056150c3c2b6e2e3bf53c3');
            relatedData1.put('Apttus_Config2__LineItemId__c', this.line.Id);
			relatedData1.put('Apttus_Config2__BreakupType__c', 'Related Price');
			relatedData1.put('Apttus_Config2__Sequence__c', 1);
			relatedData1.put('Apttus_Config2__RelatedProductId__c', '01t3i000004M747AAC');
			relatedData1.put('Apttus_Config2__RelatedQuantity__c', 1.0);
			relatedData1.put('Apttus_Config2__RelatedSellingFrequency__c', 'Monthly');
			relatedData1.put('Apttus_Config2__RelatedSellingTerm__c', 12.0);
			relatedData1.put('Apttus_Config2__RelatedStartDate__c', 1577836800000l);
			relatedData1.put('Apttus_Config2__RelatedEndDate__c', 1609372800000l);
			relatedData1.put('Apttus_Config2__RelatedChargeType__c', 'Standard Price');
			relatedData1.put('Apttus_Config2__RelatedListPrice__c', 200.0);
			relatedData1.put('Apttus_Config2__RelatedBasePrice__c', 208.00);
			relatedData1.put('Apttus_Config2__RelatedExtendedPrice__c', 2496.00);
			relatedData1.put('Apttus_Config2__RelatedNetPrice__c', 2496.00);
			relatedData1.put('Apttus_Config2__NetUnitPrice__c', 208.00);
			
			relatedDataLines.add(relatedData1);			
			line.put('Apttus_Config2__PriceBreakups__r', relatedDataLines);
			lineItems.add(line);
			cartResponse.put('Apttus_Config2__LineItems__r', lineItems);
			result.put('CartResponse', cartResponse);
			result.put(TPSyncLineItemRelatedListsHandler.RESPONSE_PROP_TOTAL_LINES_COUNT, lineItems.size());
			return Json.serialize(result);
        }
    } 
}