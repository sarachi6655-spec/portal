class MonthlySampleAnalytics {
  final String month;
  final String shortMonth;
  final int total;
  final int completed;
  final int pending;
  final Map<String, int> customSeries;

  const MonthlySampleAnalytics({
    required this.month,
    required this.shortMonth,
    required this.total,
    required this.completed,
    required this.pending,
    this.customSeries = const {},
  });

  factory MonthlySampleAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlySampleAnalytics(
      month: json['month']?.toString() ?? '',
      shortMonth: json['shortMonth']?.toString() ?? json['month']?.toString() ?? '',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      completed: int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'month': month,
    'shortMonth': shortMonth,
    'total': total,
    'completed': completed,
    'pending': pending,
  };
}
