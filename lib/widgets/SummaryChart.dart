import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/seizure/models/summary_model.dart';

class SummaryChart extends StatelessWidget {
  final SummaryModel summary;
  const SummaryChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final maxValue = summary.chartValues.isEmpty
      ? 1.0
      : (summary.chartValues.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r * Responsive.scale(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Seizure Frequency',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp * Responsive.scale(context),
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                summary.chartMetric,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 14.sp * Responsive.scale(context),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h * Responsive.scale(context)),
          SizedBox(
            height: 200.h * Responsive.scale(context),
            child: BarChart(
              BarChartData(
                maxY: maxValue,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
            
                        if (index < 0 || index >= summary.chartLabels.length) {
                          return const SizedBox();
                        }
            
                        return Padding(
                          padding:EdgeInsets.only(
                            top: 5.h * Responsive.scale(context),
                          ),
                          child: Text(
                            summary.chartLabels[index],
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 12.sp * Responsive.scale(context),
                              color: Theme.of(context).colorScheme.tertiary
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            
                barGroups: List.generate(
                  summary.chartValues.length,
                  (index) {
                    final value = summary.chartValues[index];
            
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          width: 30.w * Responsive.scale(context),
                          borderRadius: BorderRadius.circular(10.r * Responsive.scale(context),
                          ),
            
                          color: value == 0
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)
                            : Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}