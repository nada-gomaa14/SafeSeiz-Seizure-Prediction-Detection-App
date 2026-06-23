class SummaryModel {
  final String totalSeizures;
  final String averageDuration;
  final String lastSeizure;
  final String lastSeizureMetric;
  final bool hasSeizures;
  final List<String> chartLabels;
  final List<int> chartValues;
  final String chartMetric;

  const SummaryModel({
    required this.totalSeizures,
    required this.averageDuration,
    required this.lastSeizure,
    required this.lastSeizureMetric,
    required this.hasSeizures,
    required this.chartLabels,
    required this.chartValues,
    required this.chartMetric,
  });
}