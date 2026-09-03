class SampleDetailModel {
  final String limsId;
  final String jobNo;
  final String clientId;
  final String sampleId;
  final String sampleCategory;
  final String sampleName;
  final String sampleType;
  final String subType;
  final bool isDeltaCheck;
  final String orderNo;
  final String workOrderNo;
  final String testLimits;
  final String testDueDate;
  final String logDate;
  final String loggedBy;
  final String specType;
  final String samplingDueDate;
  final String inspectionDueDate;
  final String resultEntryDate;
  final String resultEnteredBy;
  final String sampleStatus;
  final String receivedDate;
  final String referenceNo;
  final String sampleQuantity;
  final String sampleQtyUnit;
  final String sampleContainer;
  final String productionDate;
  final String expiryDate;
  final String sampleNature;
  final String sampleComments;
  final String requestId;
  final String remarks;
  final String patientName;
  final String patientCode;
  final String cprNo;
  final String hidNo;
  final String doctorName;
  final String samplerAsg;
  final String invoiceReference;
  final String invoiceStatus;
  final String informConsent;
  final String requestDate;
  final String spcCollectionDate;
  final String testAddOnDate;
  final String responsibleLab;
  final String branch;
  final String department;

  SampleDetailModel({
    required this.limsId,
    required this.jobNo,
    required this.clientId,
    required this.sampleId,
    required this.sampleCategory,
    required this.sampleName,
    required this.sampleType,
    required this.subType,
    required this.isDeltaCheck,
    required this.orderNo,
    required this.workOrderNo,
    required this.testLimits,
    required this.testDueDate,
    required this.logDate,
    required this.loggedBy,
    required this.specType,
    required this.samplingDueDate,
    required this.inspectionDueDate,
    required this.resultEntryDate,
    required this.resultEnteredBy,
    required this.sampleStatus,
    required this.receivedDate,
    required this.referenceNo,
    required this.sampleQuantity,
    required this.sampleQtyUnit,
    required this.sampleContainer,
    required this.productionDate,
    required this.expiryDate,
    required this.sampleNature,
    required this.sampleComments,
    required this.requestId,
    required this.remarks,
    required this.patientName,
    required this.patientCode,
    required this.cprNo,
    required this.hidNo,
    required this.doctorName,
    required this.samplerAsg,
    required this.invoiceReference,
    required this.invoiceStatus,
    required this.informConsent,
    required this.requestDate,
    required this.spcCollectionDate,
    required this.testAddOnDate,
    required this.responsibleLab,
    required this.branch,
    required this.department,
  });

  factory SampleDetailModel.fromJson(Map<String, dynamic> json) {
    return SampleDetailModel(
      limsId: json['limsId']?.toString() ?? '',
      jobNo: json['jobNo']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      sampleId: json['sampleId']?.toString() ?? '',
      sampleCategory: json['sampleCategory']?.toString() ?? '',
      sampleName: json['sampleName']?.toString() ?? '',
      sampleType: json['sampleType']?.toString() ?? '',
      subType: json['subType']?.toString() ?? '',
      isDeltaCheck: json['isDeltaCheck'] == true || json['isDeltaCheck'] == 1 || json['isDeltaCheck'] == '1',
      orderNo: json['orderNo']?.toString() ?? '',
      workOrderNo: json['workOrderNo']?.toString() ?? '',
      testLimits: json['testLimits']?.toString() ?? '',
      testDueDate: json['testDueDate']?.toString() ?? '',
      logDate: json['logDate']?.toString() ?? '',
      loggedBy: json['loggedBy']?.toString() ?? '',
      specType: json['specType']?.toString() ?? '',
      samplingDueDate: json['samplingDueDate']?.toString() ?? '',
      inspectionDueDate: json['inspectionDueDate']?.toString() ?? '',
      resultEntryDate: json['resultEntryDate']?.toString() ?? '',
      resultEnteredBy: json['resultEnteredBy']?.toString() ?? '',
      sampleStatus: json['sampleStatus']?.toString() ?? '',
      receivedDate: json['receivedDate']?.toString() ?? '',
      referenceNo: json['referenceNo']?.toString() ?? '',
      sampleQuantity: json['sampleQuantity']?.toString() ?? '',
      sampleQtyUnit: json['sampleQtyUnit']?.toString() ?? '',
      sampleContainer: json['sampleContainer']?.toString() ?? '',
      productionDate: json['productionDate']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      sampleNature: json['sampleNature']?.toString() ?? '',
      sampleComments: json['sampleComments']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
      patientCode: json['patientCode']?.toString() ?? '',
      cprNo: json['cprNo']?.toString() ?? '',
      hidNo: json['hidNo']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? '',
      samplerAsg: json['samplerAsg']?.toString() ?? '',
      invoiceReference: json['invoiceReference']?.toString() ?? '',
      invoiceStatus: json['invoiceStatus']?.toString() ?? '',
      informConsent: json['informConsent']?.toString() ?? '',
      requestDate: json['requestDate']?.toString() ?? '',
      spcCollectionDate: json['spcCollectionDate']?.toString() ?? '',
      testAddOnDate: json['testAddOnDate']?.toString() ?? '',
      responsibleLab: json['responsibleLab']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
    );
  }
}
