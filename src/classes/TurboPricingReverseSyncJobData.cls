public class TurboPricingReverseSyncJobData {
    public CongaTurboPricingReverseSyncJob__mdt job{get;set;}
    public String cartId{get;set;}
    public Map<String,String> keyToIdMap {get; set;}
    public Integer PageNumber {get; set;}
    public Integer PageSize { get; set; }
    public Integer TotalSize { get; set; }
    
    public TurboPricingReverseSyncJobData(){
        keyToIdMap = new Map<string,string>();
    }
}