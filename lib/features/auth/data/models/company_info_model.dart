import '../../../../core/constants/api_constants.dart';

class CompanyInfoModel {
  final String website;
  final String email;
  final String headerDescription;
  final String backgroundImage;
  final String logo;
  final String smallLogo;

  CompanyInfoModel({
    required this.website,
    required this.email,
    required this.headerDescription,
    required this.backgroundImage,
    required this.logo,
    required this.smallLogo,
  });

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    final info = json['companyInfo'] ?? json;
    return CompanyInfoModel(
      website: info['website'] ?? 'www.revolsolutions.com',
      email: info['email'] ?? 'sales@revollims.com',
      headerDescription: info['headerDescription'] ?? 'Revol LIMS - AI Powered Laboratory Information Management System',
      backgroundImage: info['backgroundImage'] ?? '',
      logo: info['logo'] ?? '',
      smallLogo: info['smallLogo'] ?? '',
    );
  }

  String get backgroundUrl {
    if (backgroundImage.isEmpty) return '';
    if (backgroundImage.startsWith('http')) return backgroundImage;
    return '${ApiConstants.attachmentBaseUrl}$backgroundImage';
  }

  String get logoUrl {
    if (logo.isEmpty) return '';
    if (logo.startsWith('http')) return logo;
    return '${ApiConstants.attachmentBaseUrl}$logo';
  }

  String get smallLogoUrl {
    if (smallLogo.isEmpty) return '';
    if (smallLogo.startsWith('http')) return smallLogo;
    return '${ApiConstants.attachmentBaseUrl}$smallLogo';
  }
}
