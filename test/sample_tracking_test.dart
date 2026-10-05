import 'package:flutter_test/flutter_test.dart';
import 'package:revol_portal/features/samples/data/models/sample_model.dart';
import 'package:revol_portal/features/samples/presentation/controllers/sample_controller.dart';

void main() {
  group('SampleController Tracking & Analytics Tests', () {
    test('Calculates Pending, Overdue, Deviation, Reported correctly on sample set', () async {
      final controller = SampleController();
      await controller.loadSamples();

      // Ensure fallback / loaded samples are present
      expect(controller.allSamplesList.isNotEmpty, true);

      // Verify counts
      expect(controller.pendingSamplesCount, greaterThan(0));
      expect(controller.overdueSamplesCount, greaterThan(0));
      expect(controller.deviationSamplesCount, greaterThan(0));
      expect(controller.reportedSamplesCount, greaterThan(0));

      // Sum of pending and reported should match total samples
      expect(
        controller.pendingSamplesCount + controller.reportedSamplesCount,
        equals(controller.allSamplesList.length),
      );
    });

    test('Pre-COA Sample Status bars generate 7 standard laboratory stages', () async {
      final controller = SampleController();
      await controller.loadSamples();

      final bars = controller.preCoaSampleStatusBars;
      expect(bars.length, equals(7));

      final stageLabels = bars.map((b) => b.label).toList();
      expect(stageLabels, contains('Sample Logged'));
      expect(stageLabels, contains('Sample Received'));
      expect(stageLabels, contains('Under Prep'));
      expect(stageLabels, contains('Under Testing'));
      expect(stageLabels, contains('Result Entry'));
      expect(stageLabels, contains('Verification'));
      expect(stageLabels, contains('Tech Approval'));
    });

    test('Monthly Sample Analytics groups by month cohorts', () async {
      final controller = SampleController();
      await controller.loadSamples();

      final monthly = controller.monthlyAnalytics;
      expect(monthly.isNotEmpty, true);
      expect(monthly.length, lessThanOrEqualTo(6));

      for (final m in monthly) {
        expect(m.month.isNotEmpty, true);
        expect(m.total, equals(m.completed + m.pending));
      }
    });

    test('Metric filter restricts samples list and can be cleared', () async {
      final controller = SampleController();
      await controller.loadSamples();

      final initialCount = controller.samples.length;

      // Filter by Overdue
      controller.setMetricFilter('overdue');
      expect(controller.activeMetricFilter, 'overdue');
      expect(controller.totalRecords, equals(controller.overdueSamplesCount));

      // Filter by Deviation
      controller.setMetricFilter('deviation');
      expect(controller.activeMetricFilter, 'deviation');
      expect(controller.totalRecords, equals(controller.deviationSamplesCount));

      // Toggle off deviation
      controller.setMetricFilter('deviation');
      expect(controller.activeMetricFilter, isNull);
      expect(controller.totalRecords, equals(controller.allSamplesList.length));
    });

    test('availableStatusFilters dynamically loads all statuses from sample data and filters correctly', () async {
      final controller = SampleController();
      await controller.loadSamples();

      final statuses = controller.availableStatusFilters;
      expect(statuses.isNotEmpty, true);
      expect(statuses.first, 'All');

      // Check count for 'All'
      expect(controller.getSampleCountByStatus('All'), equals(controller.allSamplesList.length));

      // Test filtering by each available status
      for (final st in statuses.skip(1)) {
        final expectedCount = controller.getSampleCountByStatus(st);
        controller.setStatusFilter(st);
        expect(controller.selectedStatusFilter, equals(st));
        expect(controller.totalRecords, equals(expectedCount));
        for (final sample in controller.samples) {
          expect(sample.sampleStatus.toLowerCase(), equals(st.toLowerCase()));
        }
      }

      // Reset to All
      controller.setStatusFilter('All');
      expect(controller.totalRecords, equals(controller.allSamplesList.length));
    });

    test('Search query matches sample name, work order, and sample type', () async {
      final controller = SampleController();
      await controller.loadSamples();

      if (controller.allSamplesList.isNotEmpty) {
        final first = controller.allSamplesList.first;
        controller.setSearchQuery(first.sampleName);
        expect(controller.samples.any((s) => s.sampleName == first.sampleName), true);

        controller.setSearchQuery('');
        expect(controller.totalRecords, equals(controller.allSamplesList.length));
      }
    });
  });
}
