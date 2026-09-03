class ApiConstants {
  static const String baseUrl = 'https://erplx.revollims.com/erp';
  static const String attachmentBaseUrl = 'https://lnxmanufacturing.revollims.com/attachment/';
  static const String diagnosticAttachmentUrl = 'https://diagnostic.revollims.com/attachment/';

  // Default header values
  static const String defaultSiteId = 'MANULIMS';
  static const String defaultAppUser = 'CLIENT';
  static const String defaultUserRole = 'ADMIN';

  // Endpoints
  static const String portalLogin = '/portal-login';
  static const String getCompanyInfo = '/get-company-info';
  static const String getPortalSamples = '/get-portal-samples';
  static const String getPortalSampleDetails = '/get-portal-sample-details';
  static const String getCodeMasters = '/get-code-masters';
  static const String getSampleMastersByCategory = '/get-sample-masters-by-sample-category';
  static const String integratePortalSample = '/integrate-portal-sample';
  static const String clientPortalDetails = '/client-portal-details';
}
