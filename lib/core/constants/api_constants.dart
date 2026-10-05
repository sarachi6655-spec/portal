class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://erplx.revollims.com/erp',
  );
  static const String attachmentBaseUrl = 'https://diagnostic.revollims.com/attachment/';
  static const String diagnosticAttachmentUrl = 'https://diagnostic.revollims.com/attachment/';
  static const String coaFileBaseUrl = 'https://diagnostic.revollims.com/applicationFiles///';

  // Default header values
  static const String defaultSiteId = 'DIAGTEST';
  static const String defaultAppUser = 'EDITOR';
  static const String defaultUserRole = 'ADMIN';
  static const String defaultPortalUserId = 'pwumqC1I9VMYc+aHifKgeg';
  static const String defaultPortalToken = clientPortalDetailsToken;

  // Endpoints
  static const String portalLogin = '/portal-login';
  static const String getCompanyInfo = '/get-company-info';
  static const String getPortalSamples = '/get-portal-samples';
  static const String getSampleWidgets = '/get-sample-widgets';
  static const String getPortalSampleDetails = '/get-portal-sample-details';
  static const String getPortalMyPageData = '/get-portal-my-page-data';
  static const String getPortalDrillDownData = '/get-portal-drill-down-data';
  static const String getCodeMasters = '/get-code-masters';
  static const String getSampleMastersByCategory = '/get-sample-masters-by-sample-category';
  static const String integratePortalSample = '/integrate-portal-sample';
  static const String getCoaReports = '/get-coa-reports';
  static const String clientPortalDetails = '/client-portal-details';
  static const String clientPortalDetailsUrl = String.fromEnvironment(
    'CLIENT_PORTAL_DETAILS_URL',
    defaultValue: 'https://erplx.revollims.com/erp/client-portal-details',
  );
  static const String clientServices = '/client-services';
  static const String clientServicesUrl = String.fromEnvironment(
    'CLIENT_SERVICES_URL',
    defaultValue: 'https://erplx.revollims.com/erp/client-services',
  );
  static const String clientPortalDetailsToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJSVkwiLCJpYXQiOjE3ODc3MzczNTEsImF1ZCI6ImFwcF91c2VycyIsImp0aSI6IkRJQUdURVNUIiwic3ViIjoiUE9SVEFMIiwicm9sZXMiOlsiVklFV0VSIl0sInNpdGVJZCI6IkRJQUdURVNUIiwiYmFzZVVybCI6IiJ9.chiKe8KyvBDRieSS-7an__E2vvvNzzWJDNAUOHH7-Mg';
  static const String clientPortalSiteId = 'DIAGTEST';
  static const String clientPortalAppUser = 'PORTAL';

  // Create Session
  static const String createSessionUrl = String.fromEnvironment(
    'CREATE_SESSION_URL',
    defaultValue: 'https://erplx.revollims.com/CreateSession',
  );
  static const String sessionOrigin = 'https://erplx.revollims.com/';
}
