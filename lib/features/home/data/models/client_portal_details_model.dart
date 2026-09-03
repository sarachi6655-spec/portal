import '../../../../core/constants/api_constants.dart';

class ClientModel {
  final String name;
  final String link;
  final String iconUrl;

  ClientModel({
    required this.name,
    required this.link,
    required this.iconUrl,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    final path = json['clientIcon_FilePath']?.toString() ?? '';
    final file = json['clientIcon_FileName']?.toString() ?? '';
    final url = file.isNotEmpty
        ? Uri.encodeFull('${ApiConstants.diagnosticAttachmentUrl}$path$file')
        : '';

    return ClientModel(
      name: json['clientName']?.toString() ?? '',
      link: json['clientLink']?.toString() ?? '',
      iconUrl: url,
    );
  }
}

class ServiceItemModel {
  final String title;
  final String content;
  final String iconUrl;
  final String link;

  ServiceItemModel({
    required this.title,
    required this.content,
    required this.iconUrl,
    required this.link,
  });

  factory ServiceItemModel.fromData({
    required String title,
    required String content,
    required String path,
    required String file,
    required String link,
  }) {
    final url = file.isNotEmpty
        ? Uri.encodeFull('${ApiConstants.diagnosticAttachmentUrl}$path$file')
        : '';
    return ServiceItemModel(
      title: title,
      content: content,
      iconUrl: url,
      link: link,
    );
  }
}

class ClientPortalDetailsModel {
  // Hero Slider 1
  final String boxOneHeaderOne;
  final String boxOneHeaderTwo;
  final String boxoneContent;
  final String boxoneLink;
  final String sliderImage1;

  // Hero Slider 2 & 3
  final String boxTwoHeaderOne;
  final String boxTwoHeaderTwo;
  final String boxTwoContent;
  final String boxTwoLink;
  final String sliderImage2;

  final String boxThreeHeaderOne;
  final String boxThreeHeaderTwo;
  final String boxThreeContent;
  final String boxThreeLink;
  final String sliderImage3;

  // Logos
  final String headerLogo;
  final String footerLogo;

  // Block 1 Highlights (4 Stat boxes)
  final String blockOneBoxOneTitle;
  final String blockOneBoxOneContent;
  final String blockOneBoxOneIcon;
  final String blockOneBoxOneLink;

  final String blockOneBoxTwoTitle;
  final String blockOneBoxTwoContent;
  final String blockOneBoxTwoIcon;
  final String blockOneBoxTwoLink;

  final String blockOneBoxThreeTitle;
  final String blockOneBoxThreeContent;
  final String blockOneBoxThreeIcon;
  final String blockOneBoxThreeLink;

  final String blockOneBoxFourTitle;
  final String blockOneBoxFourContent;
  final String blockOneBoxFourIcon;
  final String blockOneBoxFourLink;

  // Block 2 & 3
  final String blockTwoHeader;
  final String blockTwoContent;
  final String blockTwoImage;
  final String blockTwoLink;

  final String blockThreeHeader;
  final String blockThreeContent;
  final String blockThreeImage;
  final String blockThreeLink;

  // Block 4 Services (8 Service Cards)
  final String blockFourHeaderOne;
  final String blockFourHeaderTwo;
  final List<ServiceItemModel> services;

  // Block 5 Video & Showcase
  final String blockFiveTitle;
  final String blockFiveContent;
  final String blockFiveVideoLink;
  final String blockFiveHeader;

  // Clients
  final List<ClientModel> clients;

  // Contact Info & Social
  final String mobile;
  final String email;
  final String address;
  final String facebook;
  final String instagram;
  final String linkedIn;
  final String youTube;
  final String gPlus;
  final String pinterest;

  ClientPortalDetailsModel({
    required this.boxOneHeaderOne,
    required this.boxOneHeaderTwo,
    required this.boxoneContent,
    required this.boxoneLink,
    required this.sliderImage1,
    required this.boxTwoHeaderOne,
    required this.boxTwoHeaderTwo,
    required this.boxTwoContent,
    required this.boxTwoLink,
    required this.sliderImage2,
    required this.boxThreeHeaderOne,
    required this.boxThreeHeaderTwo,
    required this.boxThreeContent,
    required this.boxThreeLink,
    required this.sliderImage3,
    required this.headerLogo,
    required this.footerLogo,
    required this.blockOneBoxOneTitle,
    required this.blockOneBoxOneContent,
    required this.blockOneBoxOneIcon,
    required this.blockOneBoxOneLink,
    required this.blockOneBoxTwoTitle,
    required this.blockOneBoxTwoContent,
    required this.blockOneBoxTwoIcon,
    required this.blockOneBoxTwoLink,
    required this.blockOneBoxThreeTitle,
    required this.blockOneBoxThreeContent,
    required this.blockOneBoxThreeIcon,
    required this.blockOneBoxThreeLink,
    required this.blockOneBoxFourTitle,
    required this.blockOneBoxFourContent,
    required this.blockOneBoxFourIcon,
    required this.blockOneBoxFourLink,
    required this.blockTwoHeader,
    required this.blockTwoContent,
    required this.blockTwoImage,
    required this.blockTwoLink,
    required this.blockThreeHeader,
    required this.blockThreeContent,
    required this.blockThreeImage,
    required this.blockThreeLink,
    required this.blockFourHeaderOne,
    required this.blockFourHeaderTwo,
    required this.services,
    required this.blockFiveTitle,
    required this.blockFiveContent,
    required this.blockFiveVideoLink,
    required this.blockFiveHeader,
    required this.clients,
    required this.mobile,
    required this.email,
    required this.address,
    required this.facebook,
    required this.instagram,
    required this.linkedIn,
    required this.youTube,
    required this.gPlus,
    required this.pinterest,
  });

  factory ClientPortalDetailsModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    String buildUrl(dynamic path, dynamic file) {
      if (file == null || file.toString().isEmpty || file.toString() == 'null') return '';
      final p = (path == null || path.toString() == 'null') ? '' : path.toString();
      final f = file.toString();
      return Uri.encodeFull('${ApiConstants.diagnosticAttachmentUrl}$p$f');
    }

    final p1 = payload['BoxoneImageID_FilePath']?.toString();
    final f1 = payload['BoxoneImageID_FileName']?.toString();
    final p2 = payload['BoxTwoImageID_FilePath']?.toString();
    final f2 = payload['BoxTwoImageID_FileName']?.toString();
    final p3 = payload['BoxThreeImageID_FilePath']?.toString();
    final f3 = payload['BoxThreeImageID_FileName']?.toString();

    final hlp = payload['HeaderLogo_FilePath']?.toString();
    final hlf = payload['HeaderLogo_FileName']?.toString();
    final flp = payload['FooterLogo_FilePath']?.toString();
    final flf = payload['FooterLogo_FileName']?.toString();

    final b2p = payload['BlockTwoImage_FilePath']?.toString();
    final b2f = payload['BlockTwoImage_FileName']?.toString();
    final b3p = payload['BlockThreeImage_FilePath']?.toString();
    final b3f = payload['BlockThreeImage_FileName']?.toString();

    final b1b1p = payload['BlockOneBoxOneIcon_FilePath']?.toString();
    final b1b1f = payload['BlockOneBoxOneIcon_FileName']?.toString();
    final b1b2p = payload['BlockOneBoxTwoIcon_FilePath']?.toString();
    final b1b2f = payload['BlockOneBoxTwoIcon_FileName']?.toString();
    final b1b3p = payload['BlockoneBoxThreeIcon_FilePath']?.toString();
    final b1b3f = payload['BlockoneBoxThreeIcon_FileName']?.toString();
    final b1b4p = payload['BlockoneBoxFourIcon_FilePath']?.toString();
    final b1b4f = payload['BlockoneBoxFourIcon_FileName']?.toString();

    // 8 Services from Block 4
    final services = <ServiceItemModel>[
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxOneTitle']?.toString() ?? '',
        content: payload['BlockFourBoxOneContent']?.toString() ?? '',
        path: payload['BlockFourBoxOneIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxOneIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxOneLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxTwoTitle']?.toString() ?? '',
        content: payload['BlockFourBoxTwoContent']?.toString() ?? '',
        path: payload['BlockFourBoxTwoIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxTwoIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxTwoLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxThreeTitle']?.toString() ?? '',
        content: payload['BlockFourBoxThreeContent']?.toString() ?? '',
        path: payload['BlockFourBoxThreeIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxThreeIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxThreeLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxFourTitle']?.toString() ?? '',
        content: payload['BlockFourBoxFourContent']?.toString() ?? '',
        path: payload['BlockFourBoxFourIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxFourIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxFourLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxFiveTitle']?.toString() ?? '',
        content: payload['BlockFourBoxFiveContent']?.toString() ?? '',
        path: payload['BlockFourBoxFiveIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxFiveIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxFiveLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxSixTitle']?.toString() ?? '',
        content: payload['BlockFourBoxSixContent']?.toString() ?? '',
        path: payload['BlockFourBoxSixIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxSixIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxSixLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxSevenTitle']?.toString() ?? '',
        content: payload['BlockFourBoxSevenContent']?.toString() ?? '',
        path: payload['BlockFourBoxSevenIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxSevenIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxSevenLink']?.toString() ?? '',
      ),
      ServiceItemModel.fromData(
        title: payload['BlockFourBoxEightTitle']?.toString() ?? '',
        content: payload['BlockFourBoxEightContent']?.toString() ?? '',
        path: payload['BlockFourBoxEightIcon_FilePath']?.toString() ?? '',
        file: payload['BlockFourBoxEightIcon_FileName']?.toString() ?? '',
        link: payload['BlockFourBoxEightLink']?.toString() ?? '',
      ),
    ];

    // Client List
    final rawClients = payload['clientList'] as List<dynamic>? ?? [];
    final clients = rawClients
        .where((c) => c != null && c is Map)
        .map((c) => ClientModel.fromJson(c is Map<String, dynamic> ? c : Map<String, dynamic>.from(c as Map)))
        .where((c) => c.name.trim().isNotEmpty && !['testing', 'asdj', 'test'].contains(c.name.trim().toLowerCase()))
        .toList();

    return ClientPortalDetailsModel(
      boxOneHeaderOne: payload['BoxOneHeaderOne']?.toString() ?? '',
      boxOneHeaderTwo: payload['BoxOneHeaderTwo']?.toString() ?? '',
      boxoneContent: payload['BoxoneContent']?.toString() ?? '',
      boxoneLink: payload['BoxoneLink']?.toString() ?? '',
      sliderImage1: buildUrl(p1, f1),

      boxTwoHeaderOne: payload['BoxTwoHeaderOne']?.toString() ?? '',
      boxTwoHeaderTwo: payload['BoxTwoHeaderTwo']?.toString() ?? '',
      boxTwoContent: payload['BoxTwoContent']?.toString() ?? '',
      boxTwoLink: payload['BoxTwoLink']?.toString() ?? '',
      sliderImage2: buildUrl(p2, f2),

      boxThreeHeaderOne: payload['BoxThreeHeaderOne']?.toString() ?? '',
      boxThreeHeaderTwo: payload['BoxThreeHeaderTwo']?.toString() ?? '',
      boxThreeContent: payload['BoxThreeContent']?.toString() ?? '',
      boxThreeLink: payload['BoxThreeLink']?.toString() ?? '',
      sliderImage3: buildUrl(p3, f3),

      headerLogo: buildUrl(hlp, hlf),
      footerLogo: buildUrl(flp, flf),

      blockOneBoxOneTitle: payload['BlockoneBoxOneTitle']?.toString() ?? '',
      blockOneBoxOneContent: payload['BlockOneBoxOneContent']?.toString() ?? '',
      blockOneBoxOneIcon: buildUrl(b1b1p, b1b1f),
      blockOneBoxOneLink: payload['BlockoneBoxOneLink']?.toString() ?? '',

      blockOneBoxTwoTitle: payload['BlockOneBoxTwoTitle']?.toString() ?? '',
      blockOneBoxTwoContent: payload['BlockOneBoxTwoContent']?.toString() ?? '',
      blockOneBoxTwoIcon: buildUrl(b1b2p, b1b2f),
      blockOneBoxTwoLink: payload['BlockOneBoxTwoLink']?.toString() ?? '',

      blockOneBoxThreeTitle: payload['BlockoneBoxThreeTitle']?.toString() ?? '',
      blockOneBoxThreeContent: payload['BlockoneBoxThreeContent']?.toString() ?? '',
      blockOneBoxThreeIcon: buildUrl(b1b3p, b1b3f),
      blockOneBoxThreeLink: payload['BlockoneBoxThreeLink']?.toString() ?? '',

      blockOneBoxFourTitle: payload['BlockoneBoxFourTitle']?.toString() ?? '',
      blockOneBoxFourContent: payload['BlockoneBoxFourContent']?.toString() ?? '',
      blockOneBoxFourIcon: buildUrl(b1b4p, b1b4f),
      blockOneBoxFourLink: payload['BlockoneBoxFourLink']?.toString() ?? '',

      blockTwoHeader: payload['BlockTwoHeader']?.toString() ?? '',
      blockTwoContent: payload['BlockTwoContent']?.toString() ?? '',
      blockTwoImage: buildUrl(b2p, b2f),
      blockTwoLink: payload['BlockTwoLink']?.toString() ?? '',

      blockThreeHeader: payload['BlockThreeHeader']?.toString() ?? '',
      blockThreeContent: payload['BlockThreeContent']?.toString() ?? '',
      blockThreeImage: buildUrl(b3p, b3f),
      blockThreeLink: payload['BlockThreeLink']?.toString() ?? '',

      blockFourHeaderOne: payload['BlockFourHeaderOne']?.toString() ?? 'OUR SERVICES',
      blockFourHeaderTwo: payload['BlockFourHeaderTwo']?.toString() ?? 'We provide various Directions',
      services: services,

      blockFiveTitle: payload['BlockFiveTitle']?.toString() ?? '',
      blockFiveContent: payload['BlockFiveContent']?.toString() ?? '',
      blockFiveVideoLink: payload['BlockFiveVideoLink']?.toString() ?? '',
      blockFiveHeader: payload['BlockFiveHeader']?.toString() ?? '',

      clients: clients,

      mobile: payload['Mobile']?.toString() ?? '',
      email: payload['Email']?.toString() ?? '',
      address: payload['Address']?.toString() ?? '',
      facebook: payload['Facebook']?.toString() ?? '',
      instagram: payload['Instagram']?.toString() ?? '',
      linkedIn: payload['LinkedIn']?.toString() ?? '',
      youTube: payload['YouTube']?.toString() ?? '',
      gPlus: payload['GPluse']?.toString() ?? '',
      pinterest: payload['Pinterest']?.toString() ?? '',
    );
  }
}
