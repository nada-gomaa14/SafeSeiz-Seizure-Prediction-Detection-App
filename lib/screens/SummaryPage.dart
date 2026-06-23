import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/notify.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/report.dart';
import 'package:safeseiz/user/medical/information/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_states.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/SummaryChart.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: 60.h * Responsive.scale(context),
        title: Text(
          'Summary',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 25.sp * Responsive.scale(context),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h * Responsive.scale(context)), 
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w * Responsive.scale(context), vertical: 5.h * Responsive.scale(context)),
            child: Divider(
              color: Theme.of(context).colorScheme.tertiary,
              thickness: 1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SeizureCubit, SeizureStates>(
          listener: (context, state) {
            if (state is SeizureErrorState) {
              log(state.error);
              notify(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is SeizureLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              );
            }
            final profileCubit = context.read<ProfileCubit>();
            final medicalCubit = context.read<MedicalCubit>();
            final medicationCubit = context.read<MedicationCubit>();
            final seizureCubit = context.read<SeizureCubit>();
            final stats = seizureCubit.getSummaryStats();
            final filteredSeizures = seizureCubit.getFilteredSeizures();

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.0.w * Responsive.scale(context),
                vertical: 10.0.h * Responsive.scale(context)
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
                      child: SegmentedButton<String>(
                        expandedInsets: EdgeInsets.zero,
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
                            ),
                          ),
                          textStyle: WidgetStateProperty.all(
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 16.sp * Responsive.scale(context),
                            ),
                          ),
                          padding: WidgetStateProperty.all (
                            EdgeInsets.all(20.r * Responsive.scale(context)),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.primary;
                              }
                              return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15);
                            }
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.secondary;
                              }
                              return Theme.of(context).colorScheme.primary;
                            },
                          ),
                          side: const WidgetStatePropertyAll(BorderSide.none)
                        ),
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: 'week',
                            label: Text(
                              'Week',
                              style: TextStyle(
                                fontWeight: seizureCubit.reportType == 'week'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              ),
                            ),
                          ),
                          ButtonSegment(
                            value: 'month',
                            label: Text(
                              'Month',
                              style: TextStyle(
                                fontWeight: seizureCubit.reportType == 'month'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              ),
                            ),
                          ),
                          ButtonSegment(
                            value: 'sixMonths',
                            label: Text(
                              '6 Months',
                              style: TextStyle(
                                fontWeight: seizureCubit.reportType == 'sixMonths'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              ),
                            ),
                          ),
                        ], 
                        selected: {seizureCubit.reportType},
                        onSelectionChanged: (selection) {
                          seizureCubit.updateReportType(selection.first);
                        },
                      ),
                    ),
                    SizedBox(height: 20.0.h * Responsive.scale(context)),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              context, 
                              isPrimary: true, 
                              title: 'Total', 
                              data: stats.totalSeizures, 
                              metric: stats.hasSeizures
                                ? (seizureCubit.reportType == 'week'
                                  ? 'this week'
                                  : seizureCubit.reportType == 'month'
                                    ? 'this month'
                                    : 'last 6 months')
                                : '',
                            ),
                          ),
                          SizedBox(width: 10.0.w * Responsive.scale(context)),
                          Expanded(
                            child: _buildSummaryCard(
                              context, 
                              title: 'Avg Duration', 
                              data: stats.averageDuration, 
                              metric: stats.hasSeizures
                                ? 'per event'
                                : '',
                            ),
                          ),
                          SizedBox(width: 10.0.w * Responsive.scale(context)),
                          Expanded(
                            child: _buildSummaryCard(
                              context, 
                              title: 'Last seizure', 
                              data: stats.lastSeizure, 
                              metric: stats.lastSeizureMetric,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0.h * Responsive.scale(context)),
                    SummaryChart(summary: stats),
                    SizedBox(height: 20.0.h * Responsive.scale(context)),
                    CustomButton(
                      text: 'Export Report',
                      onTap: () async {
                        try {
                          if (profileCubit.profile == null || medicalCubit.medical == null) {
                            notify(context, 'Unable to generate report. Try again later.');
                            return;
                          }
                          late final SeizureReportData report;

                          if (seizureCubit.reportType == 'week') {
                            report = ReportBuilder.weekly(
                              profile: profileCubit.profile!,
                              medical: medicalCubit.medical!,
                              medications: medicationCubit.medications,
                              seizures: filteredSeizures,
                              summary: stats,
                            );
                          } else if (seizureCubit.reportType == 'month') {
                            report = ReportBuilder.monthly(
                              profile: profileCubit.profile!,
                              medical: medicalCubit.medical!,
                              medications: medicationCubit.medications,
                              seizures: filteredSeizures,
                              summary: stats,
                            );
                          } else {
                            report = ReportBuilder.multiMonth(
                              profile: profileCubit.profile!,
                              medical: medicalCubit.medical!,
                              medications: medicationCubit.medications,
                              seizures: filteredSeizures,
                              summary: stats,
                            );
                          }

                          await shareSeizureReport(report);
                        } catch (e) {
                          notify(context, 'Failed to export report.');
                        }
                      }, 
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildSummaryCard (BuildContext context, {bool isPrimary = false, required String title, required String data, required String metric}) {
    final backgroundColor = isPrimary
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15);
    
    final textColor = isPrimary
      ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75)
      : Theme.of(context).colorScheme.primary;

    final dataColor = isPrimary
      ? Theme.of(context).colorScheme.secondary
      : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r * Responsive.scale(context)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp * Responsive.scale(context),
              color: textColor,
            ),
          ),
          SizedBox(height: 10.h *Responsive.scale(context)),
          Text(
            data,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 16.sp * Responsive.scale(context),
              color: dataColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h *Responsive.scale(context)),
          Text(
            metric,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp * Responsive.scale(context),
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}