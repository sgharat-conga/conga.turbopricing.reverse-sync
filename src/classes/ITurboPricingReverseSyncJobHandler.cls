public interface ITurboPricingReverseSyncJobHandler {
    
    String getRequestDataSoql(TurboPricingReverseSyncJobData job);
    // No dml is allowed in this method
	List<HttpRequest> createSyncRequests(TurboPricingReverseSyncJobData job, List<sobject> data);
    
    void processSyncResponse(TurboPricingReverseSyncJobData job, List<HttpRequest> requests, List<HttpResponse> data);
}