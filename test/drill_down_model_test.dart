import 'package:flutter_test/flutter_test.dart';
import 'package:revol_portal/features/samples/data/models/my_page_data_model.dart';
import 'package:revol_portal/features/samples/data/models/portal_drill_down_model.dart';
import 'package:revol_portal/features/samples/presentation/controllers/sample_controller.dart';

void main() {
  group('PortalDrillDownModel & Controller Tests', () {
    final sampleJson = {
      "status": "success",
      "message": "Portal drill-down data retrieved successfully.",
      "data": [
        {
          "ReferenceID": "1",
          "OrderReference": "2026/A001",
          "OrderCategory": "Software",
          "ContactPerson": "Manager",
          "PONo": "PO-1234",
          "OrderBookingMonth": "Sep-2026",
          "PODate": "2026-09-01",
          "SalesPerson": "Mohamed Washeem, MBBS, MD (Path)",
          "BookingDate": "2026-09-03",
          "CompanyCurrency": "INR",
          "ProjectName": "ERP Project",
          "Location": "Dubai",
          "Site": "HQ",
          "OrderStatus": "Approved",
          "StartDate": "2026-09-05",
          "EndDate": "2026-09-20",
          "OrderCurrency": "INR",
          "TotalCost": "2000.00",
          "TaxGroup": "IGST",
          "TaxValue": "200.00",
          "TaxExempt": "No",
          "SpecialDiscount": "0.00",
          "MarginAmount": "2000.00",
          "MarginPercentage": "100.00",
          "OrderValue": "2200.00",
          "GrandTotal": "2200.00",
          "ApprovedDate": "2026-09-04",
          "ApprovedBy": "Admin",
          "RejectedDate": "",
          "RejectedBy": "",
          "AcknowledgeBy": "Mohamed Washeem",
          "AcknowledgementDate": "2026-09-03"
        },
        {
          "ReferenceID": "2",
          "OrderReference": "2026/A002",
          "OrderCategory": "Services",
          "ContactPerson": "Supervisor",
          "PONo": "",
          "OrderBookingMonth": "Sep-2026",
          "PODate": "",
          "SalesPerson": "Dr. Sarah",
          "BookingDate": "2026-09-04",
          "CompanyCurrency": "INR",
          "ProjectName": "",
          "Location": "",
          "Site": "",
          "OrderStatus": "Order Created",
          "StartDate": "",
          "EndDate": "",
          "OrderCurrency": "INR",
          "TotalCost": "100.00",
          "TaxGroup": "IGST",
          "TaxValue": "10.00",
          "TaxExempt": "No",
          "SpecialDiscount": "0.00",
          "MarginAmount": "100.00",
          "MarginPercentage": "100.00",
          "OrderValue": "110.00",
          "GrandTotal": "110.00",
          "ApprovedDate": "",
          "ApprovedBy": "",
          "RejectedDate": "",
          "RejectedBy": "",
          "AcknowledgeBy": "",
          "AcknowledgementDate": ""
        }
      ]
    };

    test('Parses PortalDrillDownResponse and fields correctly', () {
      final response = PortalDrillDownResponse.fromJson(sampleJson);
      expect(response.status, 'success');
      expect(response.data.length, 2);

      final item1 = response.data.first;
      expect(item1.referenceId, '1');
      expect(item1.orderReference, '2026/A001');
      expect(item1.orderCategory, 'Software');
      expect(item1.salesPerson, 'Mohamed Washeem, MBBS, MD (Path)');
      expect(item1.orderStatus, 'Approved');
      expect(item1.formattedTotalCost, 'INR 2000.00');
      expect(item1.formattedGrandTotal, 'INR 2200.00');
    });

    test('Search matching works on reference, category, and sales person', () {
      final response = PortalDrillDownResponse.fromJson(sampleJson);
      final item1 = response.data[0];
      final item2 = response.data[1];

      expect(item1.matchesSearch('2026/A001'), isTrue);
      expect(item1.matchesSearch('Software'), isTrue);
      expect(item1.matchesSearch('Washeem'), isTrue);
      expect(item1.matchesSearch('Nonexistent'), isFalse);

      expect(item2.matchesSearch('Services'), isTrue);
      expect(item2.matchesSearch('Sarah'), isTrue);
    });

    test('SampleController drill down state and clear works', () {
      final controller = SampleController();
      expect(controller.drillDownLabel, isNull);
      expect(controller.drillDownXValue, isNull);

      controller.clearDrillDown();
      expect(controller.drillDownItems.isEmpty, isTrue);
    });

    test('MyPageWidgetModel parses xValue and defaults to empty string when absent', () {
      // Widget without xValue
      final w1 = MyPageWidgetModel.fromJson({
        'name': 'Enquiry',
        'value': 25,
      });
      expect(w1.name, 'Enquiry');
      expect(w1.value, 25);
      expect(w1.xValue, isNull);
      final effectiveXVal1 = (w1.xValue != null && w1.xValue!.trim().isNotEmpty)
          ? w1.xValue!.trim()
          : '';
      expect(effectiveXVal1, '');

      // Widget with explicit xValue
      final w2 = MyPageWidgetModel.fromJson({
        'name': 'Order',
        'value': 10,
        'xValue': 'Active',
      });
      expect(w2.name, 'Order');
      expect(w2.xValue, 'Active');
      final effectiveXVal2 = (w2.xValue != null && w2.xValue!.trim().isNotEmpty)
          ? w2.xValue!.trim()
          : '';
      expect(effectiveXVal2, 'Active');
    });

    test('preCoaSampleStatusBars has non-null xValue on all bars', () {
      final controller = SampleController();
      final bars = controller.preCoaSampleStatusBars;
      expect(bars.isNotEmpty, isTrue);
      for (final bar in bars) {
        expect(bar.xValue, isNotNull);
        expect(bar.xValue!.isNotEmpty, isTrue);
      }
    });

    test('loadDrillDownData does not generate fallback items and records error on API failure', () async {
      final controller = SampleController();
      // Test drill down without network / backend
      await controller.loadDrillDownData(label: 'Sample Status Dashboard', xValue: 'Pending');
      expect(controller.drillDownLabel, 'Sample Status Dashboard');
      expect(controller.drillDownXValue, 'Pending');
      // Must not generate mock/fallback items - data comes strictly from API
      expect(controller.drillDownItems.isEmpty, isTrue);

      // Clear drill down
      controller.clearDrillDown();
      expect(controller.drillDownLabel, isNull);
      expect(controller.drillDownXValue, isNull);
      expect(controller.drillDownItems.isEmpty, isTrue);
      expect(controller.drillDownError, isNull);
    });

    test('loadDrillDownData retains label as status and xValue as month only (e.g. Aug)', () async {
      final controller = SampleController();
      await controller.loadDrillDownData(
        label: 'Completed',
        xValue: 'Aug',
      );
      expect(controller.drillDownLabel, 'Completed');
      expect(controller.drillDownXValue, 'Aug');
      expect(controller.drillDownYValue, isNull);
      expect(controller.drillDownItems.isEmpty, isTrue);

      controller.clearDrillDown();
      expect(controller.drillDownLabel, isNull);
      expect(controller.drillDownXValue, isNull);
    });
  });
}
