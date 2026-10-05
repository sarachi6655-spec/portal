class SampleModel {
  final int sampleId;
  final String limsId;
  final String clientName;
  final String sampleName;
  final String sampleCategory;
  final String sampleStatus;
  final String requestId;
  final String testDueDate;
  final String logDate;
  final String sampleComments;
  final String analystStatus;
  final String sampleType;
  final String workOrderNo;
  final String sampleContainer;

  SampleModel({
    required this.sampleId,
    required this.limsId,
    required this.clientName,
    required this.sampleName,
    required this.sampleCategory,
    required this.sampleStatus,
    required this.requestId,
    required this.testDueDate,
    required this.logDate,
    required this.sampleComments,
    required this.analystStatus,
    this.sampleType = '',
    this.workOrderNo = '',
    this.sampleContainer = '',
  });

  int get id => sampleId;

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    return SampleModel(
      sampleId: int.tryParse(json['sampleId']?.toString() ?? '0') ?? 0,
      limsId: json['limsId']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      sampleName: json['sampleName']?.toString() ?? '',
      sampleCategory: json['sampleCategory']?.toString() ?? '',
      sampleStatus: json['sampleStatus']?.toString() ?? 'Pending',
      requestId: json['requestId']?.toString() ?? '',
      testDueDate: json['testDueDate']?.toString() ?? '',
      logDate: json['logDate']?.toString() ?? '',
      sampleComments: json['sampleComments']?.toString() ?? '',
      analystStatus: json['analystStatus']?.toString() ?? json['sampleStatus']?.toString() ?? '',
      sampleType: json['sampleType']?.toString() ?? '',
      workOrderNo: json['workOrderNo']?.toString() ?? '',
      sampleContainer: json['sampleContainer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'sampleId': sampleId,
    'limsId': limsId,
    'clientName': clientName,
    'sampleName': sampleName,
    'sampleCategory': sampleCategory,
    'sampleStatus': sampleStatus,
    'requestId': requestId,
    'testDueDate': testDueDate,
    'logDate': logDate,
    'sampleComments': sampleComments,
    'analystStatus': analystStatus,
    'sampleType': sampleType,
    'workOrderNo': workOrderNo,
    'sampleContainer': sampleContainer,
  };
}
