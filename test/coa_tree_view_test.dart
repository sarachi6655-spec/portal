import 'package:flutter_test/flutter_test.dart';
import 'package:revol_portal/features/samples/data/models/coa_report_model.dart';
import 'package:revol_portal/features/samples/presentation/controllers/sample_controller.dart';

void main() {
  group('CoaReportModel & Tree View Tests', () {
    final sampleHierarchicalJson = {
      "status": "success",
      "message": "COA reports retrieved successfully.",
      "data": [
        {
          "limsId": "LIMS-TEST-001",
          "sampleId": "1001",
          "sampleName": "Ultra Pure Water",
          "clientName": "BioGen Labs",
          "sampleCategory": "Water Testing",
          "sampleType": "Liquid",
          "requestId": "REQ-001",
          "logDate": "2026-09-10",
          "testDueDate": "2026-09-15",
          "sampleStatus": "Complete",
          "coaStatus": "COA Released",
          "reports": [
            {
              "coaId": "COA-1001",
              "certificateNo": "COA-2026-0099",
              "reportDate": "2026-09-15",
              "issueDate": "2026-09-15",
              "authorizedBy": "Dr. Sarah Jenkins",
              "status": "Released",
              "downloadUrl": "https://example.com/coa.pdf",
              "sampleDescription": "Water sample test",
              "parameters": [
                {
                  "parameterId": "P1",
                  "parameterName": "pH Value",
                  "testMethod": "ISO 10523",
                  "specification": "6.5 - 8.5",
                  "result": "7.1",
                  "unit": "pH",
                  "status": "Pass",
                  "analyst": "Analyst A"
                },
                {
                  "parameterId": "P2",
                  "parameterName": "Conductivity",
                  "testMethod": "ISO 7888",
                  "specification": "< 5.0",
                  "result": "1.2",
                  "unit": "uS/cm",
                  "status": "Pass",
                  "analyst": "Analyst B"
                }
              ]
            }
          ]
        }
      ]
    };

    final sampleFlatJson = {
      "status": "success",
      "reports": [
        {
          "limsId": "LIMS-FLAT-002",
          "sampleName": "Alloy Steel",
          "clientName": "Metal Corp",
          "sampleCategory": "Metallurgy",
          "coaNumber": "COA-2026-0150",
          "testName": "Tensile Strength",
          "method": "ASTM E8",
          "specification": "> 450",
          "result": "520",
          "unit": "MPa",
          "status": "Pass",
          "analyst": "Analyst C"
        },
        {
          "limsId": "LIMS-FLAT-002",
          "sampleName": "Alloy Steel",
          "clientName": "Metal Corp",
          "sampleCategory": "Metallurgy",
          "coaNumber": "COA-2026-0150",
          "testName": "Yield Strength",
          "method": "ASTM E8",
          "specification": "> 300",
          "result": "340",
          "unit": "MPa",
          "status": "Pass",
          "analyst": "Analyst C"
        }
      ]
    };

    test('Parses hierarchical COA response correctly', () {
      final nodes = CoaSampleNodeModel.parseList(sampleHierarchicalJson);
      expect(nodes.length, 1);

      final node = nodes.first;
      expect(node.limsId, 'LIMS-TEST-001');
      expect(node.sampleName, 'Ultra Pure Water');
      expect(node.clientName, 'BioGen Labs');
      expect(node.reports.length, 1);

      final report = node.reports.first;
      expect(report.certificateNo, 'COA-2026-0099');
      expect(report.authorizedBy, 'Dr. Sarah Jenkins');
      expect(report.parameters.length, 2);

      expect(node.totalTestsCount, 2);
      expect(node.passedTestsCount, 2);
    });

    test('Groups flat response rows into hierarchical tree nodes', () {
      final nodes = CoaSampleNodeModel.parseList(sampleFlatJson);
      expect(nodes.length, 1);

      final node = nodes.first;
      expect(node.limsId, 'LIMS-FLAT-002');
      expect(node.sampleName, 'Alloy Steel');
      expect(node.reports.length, 1);
      expect(node.reports.first.parameters.length, 2);

      final param1 = node.reports.first.parameters[0];
      final param2 = node.reports.first.parameters[1];
      expect(param1.parameterName, 'Tensile Strength');
      expect(param1.result, '520');
      expect(param2.parameterName, 'Yield Strength');
      expect(param2.result, '340');
    });

    test('matchesSearch matches on LIMS ID, sample name, COA number, and test parameters', () {
      final nodes = CoaSampleNodeModel.parseList(sampleHierarchicalJson);
      final node = nodes.first;

      expect(node.matchesSearch('LIMS-TEST'), isTrue);
      expect(node.matchesSearch('Ultra Pure'), isTrue);
      expect(node.matchesSearch('BioGen'), isTrue);
      expect(node.matchesSearch('COA-2026-0099'), isTrue);
      expect(node.matchesSearch('pH Value'), isTrue);
      expect(node.matchesSearch('ISO 7888'), isTrue);
      expect(node.matchesSearch('NonExistentTerm'), isFalse);
    });

    test('parseList loads COA reports dataset with correct LIMS ID grouping and report counts', () {
      final nodes = CoaSampleNodeModel.parseList(SampleRepository.hardcodedCoaReportsResponse);
      expect(nodes.isNotEmpty, isTrue);
      expect(nodes.length, 4); // 4 distinct samples: 202608060154, 202608060152, 202608060153, 202608080172

      final nodeMulti = nodes.firstWhere((n) => n.limsId == '202608060153');
      expect(nodeMulti.reports.length, 1);
      expect(nodeMulti.reports.first.reportNumber, '13');
      expect(nodeMulti.reports.first.fileName, 'Test Report-13.pdf');
      expect(nodeMulti.reports.first.filePath, '/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA');
      expect(nodeMulti.reports.first.generatedDate, '2026-08-06 12:32:07');
      expect(nodeMulti.reports.first.reportStatus, 'Generated');

      // Test searching by reportNumber and fileName
      expect(nodeMulti.matchesSearch('13'), isTrue);
      expect(nodeMulti.matchesSearch('Test Report-13.pdf'), isTrue);
      expect(nodeMulti.matchesSearch('Apollo COA Report'), isTrue);
    });

    test('Tree expansion, search, and status filtering with parsed API data', () {
      final controller = SampleController();
      final nodes = CoaSampleNodeModel.parseList(sampleHierarchicalJson);

      expect(nodes.length, 1);
      final node = nodes.first;

      // Expansion operations
      expect(controller.isNodeExpanded(node.id), isFalse);
      controller.toggleNodeExpanded(node.id);
      expect(controller.isNodeExpanded(node.id), isTrue);

      controller.collapseAllNodes();
      expect(controller.isNodeExpanded(node.id), isFalse);

      // Search operations
      expect(node.matchesSearch('Ultra Pure'), isTrue);
      expect(node.matchesSearch('NonExistent'), isFalse);
    });

    test('buildCoaPdfUrl constructs exact server URL with https://diagnostic.revollims.com/applicationFiles/// prefix', () {
      final url = CoaReportItemModel.buildCoaPdfUrl(
        '/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA',
        'Test Report-54.pdf',
      );
      expect(
        url,
        'https://diagnostic.revollims.com/applicationFiles///home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA/Test Report-54.pdf',
      );

      final report = CoaReportItemModel.fromJson({
        'limsId': '202608080172',
        'reportNumber': '54',
        'reportType': 'Apollo COA Report',
        'reportName': 'Test Report',
        'fileName': 'Test Report-54.pdf',
        'filePath': '/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA',
        'generatedDate': '2026-10-05 05:44:44',
        'reportStatus': 'Generated',
      });
      expect(report.resolvedPdfUrl, url);
      expect(report.downloadUrl, url);
    });
  });
}
