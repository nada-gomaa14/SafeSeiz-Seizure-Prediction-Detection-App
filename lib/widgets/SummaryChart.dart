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
    final highestValue = summary.chartValues.isEmpty
      ? 0.0
      : (summary.chartValues.reduce((a, b) => a > b ? a : b)).toDouble();

    final maxY = highestValue + 1;
    final interval = highestValue <= 5 ? 1.0 :
      highestValue <= 10 ? 2.0 :
      highestValue <= 20 ? 5.0 :
      10.0;

    final nonZeroValues = summary.chartValues.where((v) => v > 0).toList();
    final average = nonZeroValues.isEmpty
      ? 0.0
      : nonZeroValues.reduce((a, b) => a + b) / nonZeroValues.length;

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
          SizedBox(height: 20.h * Responsive.scale(context)),
          SizedBox(
            height: 250.h * Responsive.scale(context),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) {
                    if (value == 0) {
                      return FlLine(color: Colors.transparent);
                    }

                    return FlLine(
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [6, 4],
                    );
                  }
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 12.sp * Responsive.scale(context),
                              color: Theme.of(context).colorScheme.tertiary
                            ),
                          ),
                        );
                      }
                    ),
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
            
                          color: value < average
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.75)
                            : Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    );
                  },
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: average,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      strokeWidth: 2,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: average > 0,
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(left: 5.w * Responsive.scale(context)),                
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12.sp * Responsive.scale(context),
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold
                        ),
                        labelResolver: (_) => 'Avg: ${average.toStringAsFixed(1)}',
                      )
                    ),
                    HorizontalLine(
                      y: highestValue,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      strokeWidth: 2,
                      label: HorizontalLineLabel(
                        show: highestValue > 0,
                        alignment: (highestValue - average).abs() < 0.5
                          ? Alignment.topLeft
                          : Alignment.topRight,        
                        padding: EdgeInsets.only(left: 5.w * Responsive.scale(context)),                
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12.sp * Responsive.scale(context),
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold
                        ),
                        labelResolver: (_) => 'Max: ${highestValue.toInt()}',
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}