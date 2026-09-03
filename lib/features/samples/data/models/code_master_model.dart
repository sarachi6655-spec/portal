class CodeMasterModel {
  final String id;
  final String name;

  CodeMasterModel({
    required this.id,
    required this.name,
  });

  factory CodeMasterModel.fromJson(Map<String, dynamic> json) {
    return CodeMasterModel(
      id: (json['codeMasterId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class SampleMasterItemModel {
  final String referenceId;
  final String code;
  final String name;
  final String sampleType;
  final String subType;

  SampleMasterItemModel({
    required this.referenceId,
    required this.code,
    required this.name,
    required this.sampleType,
    required this.subType,
  });

  factory SampleMasterItemModel.fromJson(Map<String, dynamic> json) {
    return SampleMasterItemModel(
      referenceId: (json['referenceId'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sampleType: (json['sampleType'] ?? '').toString(),
      subType: (json['subType'] ?? '').toString(),
    );
  }
}
