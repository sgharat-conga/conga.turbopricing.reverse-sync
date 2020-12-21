/**
 *    TPSyncLineItemRelatedListsHandlerTests
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
@IsTest
public class TPSyncLineItemRelatedListsHandlerTests {
	
	@isTest
    public static void verify_getRequestDataSoql_invalid(){
		// arrange
		TPSyncLineItemRelatedListsHandler instance = new TPSyncLineItemRelatedListsHandler();
		
		// act - 1
		String result = instance.getRequestDataSoql(null);
		
		// assure
		System.assertEquals('', result);
		
		// act - 2
		result = instance.getRequestDataSoql(new TurboPricingReverseSyncJobData());
		
		// assure
		System.assertEquals('', result);
	}
	
	@isTest
    public static void verify_CreateSyncRequests_invalid(){
		// arrange
		TPSyncLineItemRelatedListsHandler instance = new TPSyncLineItemRelatedListsHandler();
		
		// act - 1
		List<HttpRequest> result = instance.CreateSyncRequests(null, null);
		
		// assure
		System.assertNotEquals(null, result);
        
        // act - 2
		result = instance.CreateSyncRequests(new TurboPricingReverseSyncJobData(), null);
		
		// assure
		System.assertEquals(0, result.size());
	}
}