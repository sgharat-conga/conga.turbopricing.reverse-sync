/**
 *    TPSyncLineItemRelatedListsHandler
 *    
 *    @2020 Conga Inc. All rights reserved.
 */
public class TPSyncLineItemRelatedListsHandler  implements ITurboPricingReverseSyncJobHandler{
    // constants
    public static final String TP_URL_PROTOCOL = 'https://';
    public static final String TP_URL_PATH1 = '/pricing/carts/';
    public static final String TP_URL_PATH2 = '/lines?includeAdjustments=true&includePriceBreakup=true&includeUsageTiers=true';
    public static final String TP_URL_QUERY_PARAM_PAGE_NUMBER = 'pageNumber';
    public static final String TP_URL_QUERY_PARAM_PAGE_SIZE = 'pageSize';
    public static final String REL_NAME_ADJUSTMENT_LINE_ITEMS = 'Apttus_Config2__AdjustmentLineItems__r';
    public static final String REL_NAME_PRICE_BREAKUPS = 'Apttus_Config2__PriceBreakups__r';
    public static final String REL_NAME_USAGE_TIERS = 'Apttus_Config2__UsagePriceTiers__r';
    public static final String RESPONSE_PROP_CART = 'CartResponse';
    public static final String RESPONSE_PROP_TOTAL_LINES_COUNT = 'TotalLines';
    public static final String RESPONSE_PROP_LINES_ITEMS = 'Apttus_Config2__LineItems__r';
    public static final String PROP_NAME_LINE_ITEM_ID = 'Apttus_Config2__LineItemId__c';
    public static final String TP_CUSTOM_SETTING_NAME = 'LightsaberServiceUrl';
    
    
	public String getRequestDataSoql(TurboPricingReverseSyncJobData job){
        return '';  
    }
    
    public List<HttpRequest> CreateSyncRequests(TurboPricingReverseSyncJobData jobData, List<sobject> data){
        if(jobData == null || jobData.job ==null){
            return new List<HttpRequest>();
        }
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(getTurboPricingEndpointUrl() + TP_URL_PATH1 + jobData.cartId + TP_URL_PATH2 + '&'+ TP_URL_QUERY_PARAM_PAGE_NUMBER +'='+jobData.PageNumber+'&' + TP_URL_QUERY_PARAM_PAGE_SIZE + '='+jobData.PageSize);
        request.setMethod(jobData.job.EndpointHttpMethod__c);
        request.setHeader('Authorization', 'Bearer ' +UserInfo.getSessionId());
        request.setHeader('TenantId', UserInfo.getOrganizationId());
        request.setHeader('Content-Type', 'application/json');
        return new List<HttpRequest>{ request };
    }
    
    public void ProcessSyncResponse(TurboPricingReverseSyncJobData job, List<HttpRequest> requests, List<HttpResponse> data){
        if(job == null || job.job == null || data == null || data.size() == 0){
            return;
        }
        
        Map<string,Map<string,object>> lineItemAsMapById = new Map<string,Map<string,object>>();
        
        for(HttpResponse response : data){
            Map<string,object> res = (Map<string,object>)Json.deserializeUntyped(response.getBody());
            
            if(res == null){
                continue;
            }
            
            Map<string,object> cartResponse = (Map<string,object>)res.get(RESPONSE_PROP_CART);
            job.TotalSize = (Integer)res.get(RESPONSE_PROP_TOTAL_LINES_COUNT);
            
            if(cartResponse == null){
                continue;
            }
            
            List<object> lineItems = (List<object>)cartResponse.get(RESPONSE_PROP_LINES_ITEMS);
                
            for(object line : lineItems){
                Map<string,object> lineAsMap = (Map<String,object>)line;
                lineItemAsMapById.put((String)lineAsMap.get('Id'), lineAsMap);
            }
        }
		
        List<Apttus_Config2__AdjustmentLineItem__c> adjustmentLineItems = (List<Apttus_Config2__AdjustmentLineItem__c>)extractRelatedList(lineItemAsMapById, Apttus_Config2__AdjustmentLineItem__c.sObjectType, REL_NAME_ADJUSTMENT_LINE_ITEMS, PROP_NAME_LINE_ITEM_ID);
        List<Apttus_Config2__UsagePriceTier__c> usagePriceTiers = (List<Apttus_Config2__UsagePriceTier__c>)extractRelatedList(lineItemAsMapById, Apttus_Config2__UsagePriceTier__c.sObjectType, REL_NAME_USAGE_TIERS, PROP_NAME_LINE_ITEM_ID);
        List<Apttus_Config2__PriceBreakup__c> priceBreakups = (List<Apttus_Config2__PriceBreakup__c>)extractRelatedList(lineItemAsMapById, Apttus_Config2__PriceBreakup__c.sObjectType, REL_NAME_PRICE_BREAKUPS, PROP_NAME_LINE_ITEM_ID);
        
        // delete adjustment line items
        delete [SELECT Id FROM Apttus_Config2__AdjustmentLineItem__c WHERE Apttus_Config2__LineItemId__c IN :lineItemAsMapById.keyset()];
        
        // add adjustment line items
		insert adjustmentLineItems;
        
        // delete usage tiers
        delete [SELECT Id FROM Apttus_Config2__UsagePriceTier__c WHERE Apttus_Config2__LineItemId__c IN :lineItemAsMapById.keyset()];
        
        // add usage tiers
		insert usagePriceTiers;
        
        // delete price breakup
        delete [SELECT Id FROM Apttus_Config2__PriceBreakup__c WHERE Apttus_Config2__LineItemId__c IN :lineItemAsMapById.keyset()];
        
        // add price breakup
		insert priceBreakups;
        
    }
    
    private List<sobject> extractRelatedList(Map<string,Map<string,object>> lineItemAsMapById, Schema.sObjectType sobjectToken, string relPropName, string lineItemIdPropName){
        List<sobject> result = new List<sobject>();
        Map<String,Schema.SObjectField> fieldTokens = sobjectToken.getDescribe().fields.getMap();
        for(string lineItemId : lineItemAsMapById.keyset()){
            Map<string,object> lineItemAsMap = lineItemAsMapById.get(lineItemId);
            List<object> adjLines = (List<object>)lineItemAsMap.get(relPropName);
            
            if(adjLines == null){
                continue;
            }
            
            for(object adjAsObj : adjLines){
                sobject adjLine = convertToSObject((Map<string,object>)adjAsObj, sobjectToken, fieldTokens);
                adjLine.put(lineItemIdPropName, lineItemId);
                result.add(adjLine);
            }
        }
        return result;
    }
    
    private sobject convertToSObject(Map<string,object> data, Schema.sObjectType sobjectToken, Map<String,Schema.SObjectField> fieldTokens){
        data.Remove('Digest');
        data.Remove('ExternalId');
        sobject result = sobjectToken.newSObject();
        for(String field : data.keyset()){
            if(fieldTokens.get(field).getDescribe().getType() == Schema.DisplayType.DATE){
          		result.put(field, DateTime.newInstance((Long)data.get(field)).date()); 
            }
            else{
            	result.put(field, data.get(field));    
            }
        }
        return result;
    }
    
    private string getTurboPricingEndpointUrl(){
		Apttus_Base2__TurboEngineAdminProperties__c tpSettings = Apttus_Base2__TurboEngineAdminProperties__c.getValues(TP_CUSTOM_SETTING_NAME);
		if(tpSettings == null || tpSettings.Apttus_Base2__ServiceUrl__c == null){
			throw new TurboPricingReverseSyncJobException('No Turbo API Url is configured. Use Apttus_Base2__TurboEngineAdminProperties__c custom setting to do that');
		}
		
		return tpSettings.Apttus_Base2__ServiceUrl__c;
    }
}