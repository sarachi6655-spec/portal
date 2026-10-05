import '../../../../core/constants/api_constants.dart';

/// Represents an individual test parameter or analyte result under a COA Report
class CoaTestParameterModel {
  final String parameterId;
  final String parameterName;
  final String testMethod;
  final String specification;
  final String result;
  final String unit;
  final String status;
  final String remarks;
  final String analyst;

  CoaTestParameterModel({
    required this.parameterId,
    required this.parameterName,
    required this.testMethod,
    required this.specification,
    required this.result,
    required this.unit,
    required this.status,
    this.remarks = '',
    this.analyst = '',
  });

  factory CoaTestParameterModel.fromJson(Map<String, dynamic> json) {
    return CoaTestParameterModel(
      parameterId: json['parameterId']?.toString() ??
          json['testId']?.toString() ??
          json['id']?.toString() ??
          '',
      parameterName: json['parameterName']?.toString() ??
          json['testName']?.toString() ??
          json['parameter']?.toString() ??
          json['test']?.toString() ??
          json['analyte']?.toString() ??
          'Standard Test',
      testMethod: json['testMethod']?.toString() ??
          json['method']?.toString() ??
          json['standard']?.toString() ??
          'ISO / Standard Method',
      specification: json['specification']?.toString() ??
          json['testLimits']?.toString() ??
          json['limits']?.toString() ??
          json['spec']?.toString() ??
          json['standardLimit']?.toString() ??
          '-',
      result: json['result']?.toString() ??
          json['observedValue']?.toString() ??
          json['value']?.toString() ??
          json['testResult']?.toString() ??
          '-',
      unit: json['unit']?.toString() ??
          json['uom']?.toString() ??
          json['sampleQtyUnit']?.toString() ??
          '',
      status: json['status']?.toString() ??
          json['resultStatus']?.toString() ??
          json['compliance']?.toString() ??
          'Pass',
      remarks: json['remarks']?.toString() ?? json['comment']?.toString() ?? '',
      analyst: json['analyst']?.toString() ?? json['testedBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'parameterId': parameterId,
        'parameterName': parameterName,
        'testMethod': testMethod,
        'specification': specification,
        'result': result,
        'unit': unit,
        'status': status,
        'remarks': remarks,
        'analyst': analyst,
      };

  bool get isPass {
    final lower = status.toLowerCase();
    return lower.contains('pass') ||
        lower.contains('conform') ||
        lower.contains('compliant') ||
        lower.contains('ok') ||
        lower.contains('within');
  }
}

/// Represents an official Certificate of Analysis Report
class CoaReportItemModel {
  final String coaId;
  final String certificateNo;
  final String reportNumber;
  final String reportType;
  final String reportName;
  final String fileName;
  final String filePath;
  final String generatedDate;
  final String reportStatus;
  final String reportDate;
  final String issueDate;
  final String authorizedBy;
  final String status;
  final String downloadUrl;
  final String sampleDescription;
  final List<CoaTestParameterModel> parameters;

  CoaReportItemModel({
    required this.coaId,
    required this.certificateNo,
    this.reportNumber = '',
    this.reportType = '',
    this.reportName = '',
    this.fileName = '',
    this.filePath = '',
    this.generatedDate = '',
    this.reportStatus = '',
    required this.reportDate,
    required this.issueDate,
    required this.authorizedBy,
    required this.status,
    required this.downloadUrl,
    this.sampleDescription = '',
    required this.parameters,
  });

  factory CoaReportItemModel.fromJson(Map<String, dynamic> json) {
    List<CoaTestParameterModel> params = [];
    final rawParams = json['parameters'] ??
        json['tests'] ??
        json['testResults'] ??
        json['details'] ??
        json['items'] ??
        json['children'];

    if (rawParams is List) {
      params = rawParams
          .whereType<Map<String, dynamic>>()
          .map((p) => CoaTestParameterModel.fromJson(p))
          .toList();
    }

    final repNum = json['reportNumber']?.toString() ??
        json['report_number']?.toString() ??
        json['reportNo']?.toString() ??
        json['report_no']?.toString() ??
        '';
    final repType = json['reportType']?.toString() ??
        json['report_type']?.toString() ??
        '';
    final repName = json['reportName']?.toString() ??
        json['report_name']?.toString() ??
        '';
    final fName = json['fileName']?.toString() ??
        json['file_name']?.toString() ??
        json['filename']?.toString() ??
        json['FileName']?.toString() ??
        '';
    final fPath = json['filePath']?.toString() ??
        json['file_path']?.toString() ??
        json['filepath']?.toString() ??
        json['FilePath']?.toString() ??
        '';
    final genDate = json['generatedDate']?.toString() ??
        json['generated_date']?.toString() ??
        '';
    final repStatus = json['reportStatus']?.toString() ??
        json['report_status']?.toString() ??
        '';

    final certNo = json['certificateNo']?.toString() ??
        json['certificate_no']?.toString() ??
        json['coaNumber']?.toString() ??
        json['coa_number']?.toString() ??
        json['reportNo']?.toString() ??
        json['report_no']?.toString() ??
        json['certificateNumber']?.toString() ??
        json['certificate_number']?.toString() ??
        (repNum.isNotEmpty ? 'Report #$repNum' : (fName.isNotEmpty ? fName : 'COA-${json['coaId'] ?? json['coa_id'] ?? "GEN"}'));

    final repDate = genDate.isNotEmpty
        ? genDate
        : (json['reportDate']?.toString() ??
            json['report_date']?.toString() ??
            json['issueDate']?.toString() ??
            json['issue_date']?.toString() ??
            json['testDueDate']?.toString() ??
            json['logDate']?.toString() ??
            '');

    final issDate = genDate.isNotEmpty
        ? genDate
        : (json['issueDate']?.toString() ??
            json['issue_date']?.toString() ??
            json['reportDate']?.toString() ??
            json['report_date']?.toString() ??
            json['releasedDate']?.toString() ??
            '');

    final st = repStatus.isNotEmpty
        ? repStatus
        : (json['status']?.toString() ??
            json['coaStatus']?.toString() ??
            json['coa_status']?.toString() ??
            'Generated');

    final explicitUrl = json['downloadUrl']?.toString() ??
        json['download_url']?.toString() ??
        json['reportUrl']?.toString() ??
        json['report_url']?.toString() ??
        json['attachmentUrl']?.toString() ??
        json['attachment_url']?.toString() ??
        json['fileUrl']?.toString() ??
        json['file_url']?.toString() ??
        '';

    final effectiveUrl = explicitUrl.isNotEmpty
        ? explicitUrl
        : buildCoaPdfUrl(fPath, fName);

    return CoaReportItemModel(
      coaId: json['coaId']?.toString() ??
          json['reportId']?.toString() ??
          (repNum.isNotEmpty ? repNum : (json['id']?.toString() ?? '')),
      certificateNo: certNo,
      reportNumber: repNum,
      reportType: repType,
      reportName: repName,
      fileName: fName,
      filePath: fPath,
      generatedDate: genDate,
      reportStatus: repStatus,
      reportDate: repDate,
      issueDate: issDate,
      authorizedBy: json['authorizedBy']?.toString() ??
          json['approvedBy']?.toString() ??
          json['signatory']?.toString() ??
          '',
      status: st,
      downloadUrl: effectiveUrl,
      sampleDescription: json['sampleDescription']?.toString() ?? repName,
      parameters: params,
    );
  }

  /// Builds the server PDF URL:
  /// e.g. https://diagnostic.revollims.com/applicationFiles///home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA/Test Report-54.pdf
  static String buildCoaPdfUrl(String filePath, String fileName) {
    final cleanFile = fileName.trim();
    if (cleanFile.isEmpty) return '';
    const prefix = ApiConstants.coaFileBaseUrl;
    final cleanPath = filePath.trim();
    final pathPart = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;
    final separator = (pathPart.isNotEmpty && !pathPart.endsWith('/')) ? '/' : '';
    return '$prefix$pathPart$separator$cleanFile';
  }

  /// Returns the effective PDF URL for this report
  String get resolvedPdfUrl {
    if (downloadUrl.isNotEmpty && downloadUrl.startsWith('http')) {
      if (downloadUrl.contains('103.182.211.230:5048')) {
        return downloadUrl.replaceAll('http://103.182.211.230:5048', 'https://diagnostic.revollims.com');
      }
      if (downloadUrl.contains('erplx.revollims.com/applicationFiles')) {
        return downloadUrl.replaceAll('https://erplx.revollims.com', 'https://diagnostic.revollims.com');
      }
      if (downloadUrl.contains('https://diagnostics.revollims.com')) {
        return downloadUrl.replaceAll('https://diagnostics.revollims.com', 'https://diagnostic.revollims.com');
      }
      return downloadUrl;
    }
    return buildCoaPdfUrl(filePath, fileName);
  }

  Map<String, dynamic> toJson() => {
        'coaId': coaId,
        'certificateNo': certificateNo,
        'reportNumber': reportNumber,
        'reportType': reportType,
        'reportName': reportName,
        'fileName': fileName,
        'filePath': filePath,
        'generatedDate': generatedDate,
        'reportStatus': reportStatus,
        'reportDate': reportDate,
        'issueDate': issueDate,
        'authorizedBy': authorizedBy,
        'status': status,
        'downloadUrl': downloadUrl,
        'sampleDescription': sampleDescription,
        'parameters': parameters.map((p) => p.toJson()).toList(),
      };
}

/// Represents the top-level tree node (Sample / Batch) containing one or more COA Reports
class CoaSampleNodeModel {
  final String id;
  final String limsId;
  final String sampleId;
  final String sampleName;
  final String clientName;
  final String sampleCategory;
  final String sampleType;
  final String requestId;
  final String logDate;
  final String testDueDate;
  final String sampleStatus;
  final String coaStatus;
  final List<CoaReportItemModel> reports;

  CoaSampleNodeModel({
    required this.id,
    required this.limsId,
    required this.sampleId,
    required this.sampleName,
    required this.clientName,
    required this.sampleCategory,
    required this.sampleType,
    required this.requestId,
    required this.logDate,
    required this.testDueDate,
    required this.sampleStatus,
    required this.coaStatus,
    required this.reports,
  });

  /// Flattens all test parameters across all reports for this sample
  List<CoaTestParameterModel> get allParameters {
    final List<CoaTestParameterModel> list = [];
    for (final r in reports) {
      list.addAll(r.parameters);
    }
    return list;
  }

  int get totalTestsCount => allParameters.length;

  int get passedTestsCount => allParameters.where((p) => p.isPass).length;

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();

    if (limsId.toLowerCase().contains(q)) return true;
    if (sampleName.toLowerCase().contains(q)) return true;
    if (clientName.toLowerCase().contains(q)) return true;
    if (sampleCategory.toLowerCase().contains(q)) return true;
    if (sampleType.toLowerCase().contains(q)) return true;
    if (requestId.toLowerCase().contains(q)) return true;
    if (sampleStatus.toLowerCase().contains(q)) return true;
    if (coaStatus.toLowerCase().contains(q)) return true;

    for (final report in reports) {
      if (report.certificateNo.toLowerCase().contains(q)) return true;
      if (report.reportNumber.toLowerCase().contains(q)) return true;
      if (report.reportType.toLowerCase().contains(q)) return true;
      if (report.reportName.toLowerCase().contains(q)) return true;
      if (report.fileName.toLowerCase().contains(q)) return true;
      if (report.filePath.toLowerCase().contains(q)) return true;
      if (report.authorizedBy.toLowerCase().contains(q)) return true;
      if (report.status.toLowerCase().contains(q)) return true;
      if (report.reportStatus.toLowerCase().contains(q)) return true;
      for (final param in report.parameters) {
        if (param.parameterName.toLowerCase().contains(q)) return true;
        if (param.testMethod.toLowerCase().contains(q)) return true;
        if (param.result.toLowerCase().contains(q)) return true;
      }
    }
    return false;
  }

  factory CoaSampleNodeModel.fromJson(Map<String, dynamic> json) {
    List<CoaReportItemModel> parsedReports = [];
    final rawReports = json['reports'] ??
        json['coaReports'] ??
        json['certificates'] ??
        json['children'];

    if (rawReports is List && rawReports.isNotEmpty) {
      parsedReports = rawReports
          .whereType<Map<String, dynamic>>()
          .map((r) => CoaReportItemModel.fromJson(r))
          .toList();
    } else {
      parsedReports.add(
        CoaReportItemModel.fromJson(json),
      );
    }

    final limsId = json['limsId']?.toString() ??
        json['lims_id']?.toString() ??
        json['LIMS_ID']?.toString() ??
        json['limsid']?.toString() ??
        '';
    final sampleId = json['sampleId']?.toString() ??
        json['sample_id']?.toString() ??
        json['SAMPLE_ID']?.toString() ??
        '';
    final id = (limsId.isNotEmpty) ? limsId : (sampleId.isNotEmpty ? sampleId : 'NODE_${json.hashCode}');

    return CoaSampleNodeModel(
      id: id,
      limsId: limsId,
      sampleId: sampleId,
      sampleName: json['sampleName']?.toString() ?? json['sample_name']?.toString() ?? 'Laboratory Sample',
      clientName: json['clientName']?.toString() ?? json['client_name']?.toString() ?? 'Client',
      sampleCategory: json['sampleCategory']?.toString() ?? json['sample_category']?.toString() ?? 'General',
      sampleType: json['sampleType']?.toString() ?? json['sample_type']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? json['request_id']?.toString() ?? '',
      logDate: json['logDate']?.toString() ?? json['log_date']?.toString() ?? '',
      testDueDate: json['testDueDate']?.toString() ?? json['test_due_date']?.toString() ?? '',
      sampleStatus: json['sampleStatus']?.toString() ?? json['sample_status']?.toString() ?? 'Complete',
      coaStatus: json['coaStatus']?.toString() ??
          json['coa_status']?.toString() ??
          json['status']?.toString() ??
          (parsedReports.isNotEmpty ? parsedReports.first.status : 'Released'),
      reports: parsedReports,
    );
  }

  /// Parses a generic API response into a list of CoaSampleNodeModel
  static List<CoaSampleNodeModel> parseList(dynamic raw) {
    if (raw == null) return [];

    List<dynamic> items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final potentialKeys = [
        'data',
        'reports',
        'coaReports',
        'coa_reports',
        'samples',
        'sampleList',
        'sample_list',
        'certificates'
      ];
      for (final key in potentialKeys) {
        if (raw[key] is List) {
          items = raw[key] as List;
          break;
        }
      }
      if (items.isEmpty && raw['data'] is Map<String, dynamic>) {
        final inner = raw['data'] as Map<String, dynamic>;
        for (final key in potentialKeys) {
          if (inner[key] is List) {
            items = inner[key] as List;
            break;
          }
        }
      }
    }

    if (items.isEmpty) return [];

    // Check if the items are already hierarchical or flat records sharing limsId
    final parsed = <CoaSampleNodeModel>[];
    final Map<String, List<Map<String, dynamic>>> groupedBySample = {};

    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final limsId = item['limsId']?.toString() ??
            item['lims_id']?.toString() ??
            item['LIMS_ID']?.toString() ??
            item['limsid']?.toString() ??
            item['sampleId']?.toString() ??
            item['sample_id']?.toString() ??
            '';
        final hasChildReports = item['reports'] != null || item['coaReports'] != null || item['coa_reports'] != null;

        if (hasChildReports || limsId.isEmpty) {
          parsed.add(CoaSampleNodeModel.fromJson(item));
        } else {
          // Group flat records by sample LIMS ID
          groupedBySample.putIfAbsent(limsId, () => []).add(item);
        }
      }
    }

    // Process grouped flat records into hierarchical nodes
    groupedBySample.forEach((limsId, rows) {
      if (rows.isEmpty) return;
      final first = rows.first;

      // Check whether rows represent individual COA Reports (e.g. with reportNumber, fileName, filePath, reportType)
      // or individual test parameters (e.g. with testName, parameterName, method, specification)
      final bool areReports = rows.any((r) =>
          r.containsKey('reportNumber') ||
          r.containsKey('fileName') ||
          r.containsKey('filePath') ||
          r.containsKey('reportType'));

      List<CoaReportItemModel> reportsList = [];

      if (areReports) {
        reportsList = rows.map((r) => CoaReportItemModel.fromJson(r)).toList();
      } else {
        final params = rows.map((r) => CoaTestParameterModel.fromJson(r)).toList();
        final report = CoaReportItemModel(
          coaId: first['coaId']?.toString() ?? first['reportId']?.toString() ?? '1',
          certificateNo: first['certificateNo']?.toString() ??
              first['coaNumber']?.toString() ??
              'COA-$limsId',
          reportDate: first['reportDate']?.toString() ?? first['logDate']?.toString() ?? '',
          issueDate: first['issueDate']?.toString() ?? '',
          authorizedBy: first['authorizedBy']?.toString() ?? 'Chief Analyst',
          status: first['coaStatus']?.toString() ?? first['sampleStatus']?.toString() ?? 'Released',
          downloadUrl: first['downloadUrl']?.toString() ?? '',
          sampleDescription: first['sampleDescription']?.toString() ?? '',
          parameters: params,
        );
        reportsList = [report];
      }

      final reportType = first['reportType']?.toString() ?? '';
      final reportName = first['reportName']?.toString() ?? '';
      final sampleName = first['sampleName']?.toString() ??
          (reportName.isNotEmpty ? '$reportName #$limsId' : 'Sample $limsId');
      final clientName = first['clientName']?.toString() ?? '';
      final sampleCategory = first['sampleCategory']?.toString() ?? reportType;
      final sampleType = first['sampleType']?.toString() ?? reportType;
      final genDate = first['generatedDate']?.toString() ?? first['logDate']?.toString() ?? '';
      final coaStatus = first['reportStatus']?.toString() ??
          first['coaStatus']?.toString() ??
          (reportsList.isNotEmpty ? reportsList.first.status : 'Generated');

      parsed.add(
        CoaSampleNodeModel(
          id: limsId,
          limsId: limsId,
          sampleId: first['sampleId']?.toString() ?? limsId,
          sampleName: sampleName,
          clientName: clientName,
          sampleCategory: sampleCategory,
          sampleType: sampleType,
          requestId: first['requestId']?.toString() ?? 'REQ-$limsId',
          logDate: genDate,
          testDueDate: first['testDueDate']?.toString() ?? genDate,
          sampleStatus: first['sampleStatus']?.toString() ?? 'Complete',
          coaStatus: coaStatus,
          reports: reportsList,
        ),
      );
    });

    return parsed;
  }
}
