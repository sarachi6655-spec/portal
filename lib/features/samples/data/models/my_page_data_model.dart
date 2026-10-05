import 'sample_analytics_model.dart';

class MyPageDataModel {
  final List<MyPageWidgetModel> widgets;
  final DashboardChartModel? sampleStatusDashboard;
  final DashboardChartModel? sampleAnalyticsDashboard;
  final DashboardChartModel? ordersDashboard;
  final DashboardChartModel? paymentsDashboard;

  MyPageDataModel({
    required this.widgets,
    this.sampleStatusDashboard,
    this.sampleAnalyticsDashboard,
    this.ordersDashboard,
    this.paymentsDashboard,
  });

  factory MyPageDataModel.fromJson(Map<String, dynamic> json) {
    final rawWidgets = json['widgets'];
    final List<MyPageWidgetModel> widgetList = [];
    if (rawWidgets is List) {
      for (final item in rawWidgets) {
        if (item is Map<String, dynamic>) {
          widgetList.add(MyPageWidgetModel.fromJson(item));
        }
      }
    }

    DashboardChartModel? parseChart(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return DashboardChartModel.fromJson(raw);
      }
      return null;
    }

    return MyPageDataModel(
      widgets: widgetList,
      sampleStatusDashboard: parseChart(json['sampleStatusDashboard']),
      sampleAnalyticsDashboard: parseChart(json['sampleAnalyticsDashboard']),
      ordersDashboard: parseChart(json['ordersDashboard']),
      paymentsDashboard: parseChart(json['paymentsDashboard']),
    );
  }

  // Helper to safely lookup a widget value by name
  num getWidgetValue(String name, {num defaultValue = 0}) {
    for (final w in widgets) {
      if (w.name.toLowerCase() == name.toLowerCase()) {
        return w.value;
      }
    }
    return defaultValue;
  }
}

class MyPageWidgetModel {
  final String name;
  final num value;
  final String? xValue;
  final String? label;

  MyPageWidgetModel({
    required this.name,
    required this.value,
    this.xValue,
    this.label,
  });

  factory MyPageWidgetModel.fromJson(Map<String, dynamic> json) {
    num parsedValue = 0;
    final val = json['value'];
    if (val is num) {
      parsedValue = val;
    } else if (val != null) {
      parsedValue = num.tryParse(val.toString()) ?? 0;
    }

    final rawXValue = json['xValue'] ?? json['xvalue'] ?? json['x_value'] ?? json['XValue'];
    final rawLabel = json['label'] ?? json['name'];

    return MyPageWidgetModel(
      name: json['name']?.toString() ?? '',
      value: parsedValue,
      xValue: rawXValue?.toString(),
      label: rawLabel?.toString(),
    );
  }
}

class DashboardChartModel {
  final String chartName;
  final List<ChartSeriesItemModel> series;

  DashboardChartModel({
    required this.chartName,
    required this.series,
  });

  factory DashboardChartModel.fromJson(Map<String, dynamic> json) {
    final rawSeries = json['series'];
    final List<ChartSeriesItemModel> seriesList = [];
    if (rawSeries is List) {
      for (final item in rawSeries) {
        if (item is Map<String, dynamic>) {
          seriesList.add(ChartSeriesItemModel.fromJson(item));
        }
      }
    }

    return DashboardChartModel(
      chartName: json['chartName']?.toString() ?? '',
      series: seriesList,
    );
  }

  num get totalValue {
    num total = 0;
    for (final item in series) {
      total += item.yValue;
    }
    return total;
  }

  /// Converts monthly series (Completed, Pending, Total, and multiple dynamic categories) into MonthlySampleAnalytics
  List<MonthlySampleAnalytics> toMonthlyAnalytics() {
    final Map<String, ({int total, int completed, int pending, String shortMonth, Map<String, int> custom})> map = {};
    for (final s in series) {
      final month = s.xValue.trim();
      if (month.isEmpty) continue;
      final current = map[month] ?? (
        total: 0,
        completed: 0,
        pending: 0,
        shortMonth: month.contains('-') ? month.split('-').first : month,
        custom: <String, int>{},
      );

      final val = s.yValue.toInt();
      final lbl = s.label.trim();
      final lower = lbl.toLowerCase();
      final customMap = Map<String, int>.from(current.custom);

      if (lower.contains('complete')) {
        map[month] = (total: current.total, completed: val, pending: current.pending, shortMonth: current.shortMonth, custom: customMap);
      } else if (lower.contains('pend')) {
        map[month] = (total: current.total, completed: current.completed, pending: val, shortMonth: current.shortMonth, custom: customMap);
      } else if (lower.contains('total')) {
        map[month] = (total: val, completed: current.completed, pending: current.pending, shortMonth: current.shortMonth, custom: customMap);
      } else {
        customMap[lbl] = val;
        map[month] = (total: current.total, completed: current.completed, pending: current.pending, shortMonth: current.shortMonth, custom: customMap);
      }
    }

    return map.entries.map((e) {
      final sumSegments = e.value.completed + e.value.pending + e.value.custom.values.fold<int>(0, (a, b) => a + b);
      final total = e.value.total > 0 ? e.value.total : sumSegments;
      return MonthlySampleAnalytics(
        month: e.key,
        shortMonth: e.value.shortMonth,
        total: total,
        completed: e.value.completed,
        pending: e.value.pending,
        customSeries: e.value.custom,
      );
    }).toList();
  }
}

class ChartSeriesItemModel {
  final String label;
  final String xValue;
  final num yValue;

  ChartSeriesItemModel({
    required this.label,
    required this.xValue,
    required this.yValue,
  });

  factory ChartSeriesItemModel.fromJson(Map<String, dynamic> json) {
    num parsedY = 0;
    final y = json['yValue'];
    if (y is num) {
      parsedY = y;
    } else if (y != null) {
      parsedY = num.tryParse(y.toString()) ?? 0;
    }

    return ChartSeriesItemModel(
      label: json['label']?.toString() ?? '',
      xValue: json['xValue']?.toString() ?? '',
      yValue: parsedY,
    );
  }
}
