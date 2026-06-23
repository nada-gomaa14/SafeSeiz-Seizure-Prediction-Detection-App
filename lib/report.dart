// ===========================================================================
// REPORT TYPES
// ===========================================================================
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:safeseiz/user/medical/information/models/medical_model.dart';
import 'package:safeseiz/user/medical/medication/models/medication_model.dart';
import 'package:safeseiz/user/profile/model/profile_model.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';
import 'package:safeseiz/user/seizure/models/summary_model.dart';

enum ReportScope {
  week,
  month,
  multiMonth,
}

// ===========================================================================
// PATIENT INFORMATION
// ===========================================================================
class PatientInfo {
  final String fullName;
  final String email;
  final String gender;
  final String dateOfBirth;

  const PatientInfo({
    required this.fullName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
  });
}

// ===========================================================================
// MEDICAL INFORMATION
// ===========================================================================
class MedicalInfo {
  final bool diagnosed;
  final String diagnosisDate;
  final String seizureFrequency;
  final String bloodType;
  final String height;
  final String weight;
  final String bmi;
  final List<String> seizureTypes;

  const MedicalInfo({
    required this.diagnosed,
    required this.diagnosisDate,
    required this.seizureFrequency,
    required this.bloodType,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.seizureTypes,
  });
}

// ===========================================================================
// EVENT MODEL
// ===========================================================================
class SeizureEvent {
  final String date;
  final String type;
  final String duration;
  final String detection;
  final String notes;

  const SeizureEvent({
    required this.date,
    required this.type,
    required this.duration,
    required this.detection,
    required this.notes,
  });
}

// ===========================================================================
// FREQUENCY CHART BUCKET
// ===========================================================================
class FrequencyBucket {
  final String label;
  final int count;

  const FrequencyBucket(
    this.label,
    this.count,
  );
}

// ===========================================================================
// MEDICATION
// ===========================================================================
class ReportMedication {
  final String name;
  final String dosage;
  final String frequency;
  final String times;

  const ReportMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
  });
}

class SeizureReportData {
  final ReportScope scope;

  final PatientInfo patient;
  final MedicalInfo medical;

  final String reportingPeriod;
  final String reportDate;

  final int totalSeizures;

  final String averageDuration;
  final String longestDuration;
  final String shortestDuration;

  final String seizureFreeStreak;
  final String timeSinceLastSeizure;

  final int autoDetectedCount;
  final int manualCount;

  final String averageFrequency;

  final List<FrequencyBucket> frequency;

  final Map<String, int> seizureTypeCounts;

  final List<SeizureEvent> recentEvents;

  final List<ReportMedication> medications;

  final String notes;

  const SeizureReportData({
    required this.scope,
    required this.patient,
    required this.medical,
    required this.reportingPeriod,
    required this.reportDate,
    required this.totalSeizures,
    required this.averageDuration,
    required this.longestDuration,
    required this.shortestDuration,
    required this.seizureFreeStreak,
    required this.timeSinceLastSeizure,
    required this.autoDetectedCount,
    required this.manualCount,
    required this.averageFrequency,
    required this.frequency,
    required this.seizureTypeCounts,
    required this.recentEvents,
    required this.medications,
    required this.notes,
  });

  int get frequencyTotal => frequency.fold(0, (sum, e) => sum + e.count);
}

class RawSeizure {
  final DateTime time;

  final Duration duration;

  final List<String> seizureTypes;

  final bool isAutoDetected;

  final String? notes;

  const RawSeizure({
    required this.time,
    required this.duration,
    required this.seizureTypes,
    required this.isAutoDetected,
    this.notes,
  });

  factory RawSeizure.fromSeizureModel(SeizureModel seizure) {
    return RawSeizure(
      time: seizure.seizureDateTime,
      duration: Duration(
        minutes: seizure.durationMinutes,
        seconds: seizure.durationSeconds,
      ),
      seizureTypes: seizure.seizureTypes,
      isAutoDetected: seizure.isAutoDetected,
      notes: seizure.notes,
    );
  }
}

ReportMedication medicationToReport(MedicationModel medication) {
  return ReportMedication(
    name: medication.name,
    dosage: medication.dosage,
    frequency: '${medication.frequency} times/day',
    times: medication.times.isEmpty
      ? '--'
      : medication.times.join(', '),
  );
}

PatientInfo profileToPatient(ProfileModel profile) {
  return PatientInfo(
    fullName: '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim().isEmpty
      ? 'Unknown'
      : '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim(),
    email: profile.email,
    gender: profile.gender ?? 'Unknown',
    dateOfBirth: profile.dob == null
      ? '--'
      : '${profile.dob!.day}/${profile.dob!.month}/${profile.dob!.year}',
  );
}

MedicalInfo medicalToInfo(MedicalModel medical) {
  return MedicalInfo(
    diagnosed: !medical.notDiagnosed,

    diagnosisDate: medical.diagnosisDate == null
      ? '--'
      : '${medical.diagnosisDate!.day}/${medical.diagnosisDate!.month}/${medical.diagnosisDate!.year}',

    seizureFrequency: medical.seizureFrequency ?? '--',

    bloodType: medical.bloodType ?? '--',

    height: medical.height == null
      ? '--'
      : '${medical.height} cm',

    weight: medical.weight == null
      ? '--'
      : '${medical.weight} kg',

    bmi: medical.bmi == null
      ? '--'
      : medical.bmi!.toStringAsFixed(1),

    seizureTypes: medical.seizureTypes,
  );
}

// ===========================================================================
// COLORS
// ===========================================================================
const PdfColor kInk = PdfColor.fromInt(0xFF1A1A1A);

const PdfColor kMuted = PdfColor.fromInt(0xFF6B7280);

const PdfColor kHair = PdfColor.fromInt(0xFFC9CFD8);

const PdfColor kFaint = PdfColor.fromInt(0xFFF1F3F5);

const PdfColor kAccent = PdfColor.fromInt(0xFF3D5A80);

const PdfColor kAccentBg = PdfColor.fromInt(0xFFEFF3F8);

class ScopeText {
  final String title;
  final String chartTitle;
  final String chartDescription;
  final String chartColumn;
  final double barWidth;

  const ScopeText({
    required this.title,
    required this.chartTitle,
    required this.chartDescription,
    required this.chartColumn,
    required this.barWidth,
  });
}

ScopeText scopeText(ReportScope scope) {
  switch (scope) {
    case ReportScope.week:
      return const ScopeText(
        title: 'Weekly Summary',
        chartTitle: 'Weekly Frequency',
        chartDescription: 'Seizures recorded during the last 7 days',
        chartColumn: 'Day',
        barWidth: 18,
      );

    case ReportScope.month:
      return const ScopeText(
        title: 'Monthly Summary',
        chartTitle: 'Monthly Frequency',
        chartDescription: 'Seizures recorded each week of the month',
        chartColumn: 'Week',
        barWidth: 26,
      );

    case ReportScope.multiMonth:
      return const ScopeText(
        title: 'Multi-Month Summary',
        chartTitle: 'Seizure Frequency',
        chartDescription: 'Seizures recorded over several months',
        chartColumn: 'Month',
        barWidth: 22,
      );
  }
}

pw.Widget titleBlock(String type) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(
        'SAFESEIZ REPORT',
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: kInk,
          letterSpacing: 2,
        ),
      ),

      pw.SizedBox(height: 6),

      pw.Text(
        '$type • Clinical Summary',
        style: pw.TextStyle(
          color: kAccent,
          fontSize: 11,
          fontStyle: pw.FontStyle.italic,
        ),
      ),

      pw.SizedBox(height: 8),

      pw.Container(
        height: 3,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(
              color: kAccent,
              width: 1.4,
            ),
            bottom: pw.BorderSide(
              color: kAccent,
              width: 0.5,
            ),
          ),
        ),
      ),
    ],
  );
}

pw.Widget section(
  int number,
  String title,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(
      top: 18,
      bottom: 6,
    ),
    child: pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '$number. ',
                style: pw.TextStyle(
                  fontSize: 13,
                  color: kAccent,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
              pw.TextSpan(
                text: title,
                style: pw.TextStyle(
                  fontSize: 13,
                  color: kInk,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 3),

        pw.Divider(
          color: kAccent,
          thickness: 0.6,
        ),
      ],
    ),
  );
}

pw.Widget keyValue(
  List<List<String>> rows,
) {
  return pw.Column(
    children: rows.map((row) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(
          vertical: 4,
        ),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: kFaint,
            ),
          ),
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: pw.Text(
                row[0],
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: kMuted,
                ),
              ),
            ),

            pw.Expanded(
              flex: 6,
              child: pw.Text(
                row[1],
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

pw.Widget patientSection(
  PatientInfo patient,
  String period,
  String date,
) {
  return keyValue([
    ['Name', patient.fullName],
    ['Email', patient.email],
    ['Gender', patient.gender],
    ['Date of Birth', patient.dateOfBirth],
    ['Reporting Period', period],
    ['Report Date', date],
  ]);
}

pw.Widget medicalSection(
  MedicalInfo medical,
) {
  return keyValue([
    [
      'Diagnosed',
      medical.diagnosed ? 'Yes' : 'No',
    ],
    [
      'Diagnosis Date',
      medical.diagnosisDate,
    ],
    [
      'Seizure Frequency',
      medical.seizureFrequency,
    ],
    [
      'Blood Type',
      medical.bloodType,
    ],
    [
      'Height',
      medical.height,
    ],
    [
      'Weight',
      medical.weight,
    ],
    [
      'BMI',
      medical.bmi,
    ],
    [
      'Medical Seizure Types',
      medical.seizureTypes.isEmpty
        ? '--'
        : medical.seizureTypes.join(', '),
    ],
  ]);
}

pw.Widget summarySection(SeizureReportData data) {
  return keyValue([
    [
      'Total Seizures',
      '${data.totalSeizures}',
    ],
    [
      'Average Duration',
      data.averageDuration,
    ],
    [
      'Longest Seizure',
      data.longestDuration,
    ],
    [
      'Shortest Seizure',
      data.shortestDuration,
    ],
    [
      'Time Since Last Seizure',
      data.timeSinceLastSeizure,
    ],
    [
      'Seizure-Free Streak',
      data.seizureFreeStreak,
    ],
    [
      'Average Frequency',
      data.averageFrequency,
    ],
  ]);
}

pw.Widget detectionSection(SeizureReportData data) {
  return keyValue([
    [
      'Automatically Detected',
      '${data.autoDetectedCount}',
    ],
    [
      'Manually Recorded',
      '${data.manualCount}',
    ],
  ]);
}

pw.Widget seizureTypesSection(Map<String, int> types) {
  if (types.isEmpty) {
    return keyValue([
      ['No seizure types recorded', '--'],
    ]);
  }

  final rows = <List<String>>[];

  for (final entry in types.entries) {
    rows.add([
      entry.key,
      '${entry.value}',
    ]);
  }

  return keyValue(rows);
}

pw.Widget chartCaption(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        color: kMuted,
        fontStyle: pw.FontStyle.italic,
      ),
    ),
  );
}

pw.Widget reportTable(List<String> headers, List<List<String>> data, Map<int, pw.TableColumnWidth> widths) {
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data,
    columnWidths: widths,

    headerStyle: pw.TextStyle(
      fontSize: 9.5,
      fontWeight: pw.FontWeight.bold,
      color: kAccent,
    ),

    headerDecoration: const pw.BoxDecoration(
      color: kAccentBg,
      border: pw.Border(
        bottom: pw.BorderSide(
          color: kAccent,
          width: 1,
        ),
      ),
    ),

    cellStyle: const pw.TextStyle(
      fontSize: 10,
      color: kInk,
    ),

    cellPadding: const pw.EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 5,
    ),

    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(
        color: kHair,
        width: 0.4,
      ),
    ),
  );
}

pw.Widget medicationTable(List<ReportMedication> medications) {
  return reportTable(
    [
      'Medication',
      'Dosage',
      'Frequency',
      'Times'
    ],
    medications.isEmpty
        ? [
            ['No medications recorded', '--', '--', '--']
          ]
        : medications.map((m) {
            return [
              m.name,
              m.dosage,
              m.frequency,
              m.times,
            ];
          }).toList(),
    {
      0: const pw.FlexColumnWidth(2),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(2),
    },
  );
}

pw.Widget eventsTable(List<SeizureEvent> events) {
  return reportTable(
    [
      'Date',
      'Type',
      'Duration',
      'Detection',
      'Notes',
    ],
    events.map((e) {
      return [
        e.date,
        e.type,
        e.duration,
        e.detection,
        e.notes,
      ];
    }).toList(),
    {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1.3),
      4: const pw.FlexColumnWidth(2.5),
    },
  );
}

pw.Widget notesSection(
  String notes,
) {
  if (notes.isNotEmpty) {
    return pw.Text(
      notes,
      style: const pw.TextStyle(
        fontSize: 11,
      ),
    );
  }

  return ruledLines(4);
}

pw.Widget ruledLines(
  int count,
) {
  return pw.Column(
    children: List.generate(
      count,
      (_) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: kHair,
              width: 0.5,
            ),
          ),
        ),
      ),
    ),
  );
}

pw.Widget disclaimer() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    color: kAccentBg,
    child: pw.Text(
      'This report is generated by SafeSeiz and is intended '
      'to support medical evaluation. It should not replace '
      'professional medical diagnosis or treatment.',
      style: const pw.TextStyle(
        fontSize: 9,
        color: kMuted,
      ),
    ),
  );
}

pw.Widget signOff() {
  pw.Widget line(String title) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 30,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: kAccent,
                  width: 0.5,
                ),
              ),
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 9,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }

  return pw.Padding(
    padding: const pw.EdgeInsets.only(
      top: 24,
    ),
    child: pw.Row(
      children: [
        line('Reviewed by physician'),

        pw.SizedBox(width: 30),

        line('Date'),
      ],
    ),
  );
}

pw.Widget footer(
  pw.Context context,
) {
  return pw.Column(
    children: [
      pw.Divider(
        color: kHair,
        thickness: 0.5,
      ),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SafeSeiz Clinical Report',
            style: const pw.TextStyle(
              fontSize: 8,
              color: kMuted,
            ),
          ),

          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: kMuted,
            ),
          ),
        ],
      ),
    ],
  );
}

double durationValue(String text) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);

  if (match == null) {
    return 0;
  }

  return double.parse(match.group(1)!);
}

List<double> ticks(double max) {
  if (max <= 0) {
    return [0, 1];
  }

  final top = max.ceil();

  int step = (top / 5).ceil();

  if (step < 1) {
    step = 1;
  }

  final values = <double>[];

  for (int i = 0; i <= top; i += step) {
    values.add(i.toDouble());
  }

  if (values.last < top) {
    values.add(top.toDouble());
  }

  return values;
}

pw.Widget barChart({required List<String> labels, required List<double> values, required double width}) {
  final double maxValue = values.isEmpty
    ? 0
    : values.reduce((a, b) => a > b ? a : b);

  return pw.Container(
    height: 150,
    padding: const pw.EdgeInsets.only(
      top: 8,
      right: 6,
    ),
    child: pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis.fromStrings(
          labels,
          marginStart: 30,
          marginEnd: 10,
          ticks: true,
          textStyle: const pw.TextStyle(
            fontSize: 8,
            color: kMuted,
          ),
        ),

        yAxis: pw.FixedAxis(
          ticks(maxValue),
          divisions: true,
          textStyle: const pw.TextStyle(
            fontSize: 8,
            color: kMuted,
          ),
        ),
      ),

      datasets: [
        pw.BarDataSet(
          width: width,
          color: kAccent,
          data: List.generate(
            values.length,
            (i) => pw.PointChartValue(i.toDouble(), values[i]),
          ),
        ),
      ],
    ),
  );
}

pw.Widget frequencyChart(SeizureReportData data, ScopeText scope) {
  return barChart(
    labels: data.frequency.map((e) => e.label).toList(),
    values: data.frequency.map((e) => e.count.toDouble()).toList(),
    width: scope.barWidth,
  );
}

pw.Widget durationChart(List<SeizureEvent> events) {
  return barChart(
    labels: events.map((e) => e.date).toList(),
    values: events.map((e) => durationValue(e.duration)).toList(),
    width: 22,
  );
}

Future<Uint8List> buildSeizureReport(
  SeizureReportData data,
) async {
  final theme = pw.ThemeData.withFont(
    base: pw.Font.helvetica(),
    bold: pw.Font.helveticaBold(),
    italic: pw.Font.helveticaOblique(),
    boldItalic: pw.Font.helveticaBoldOblique(),
  );

  final scope = scopeText(data.scope);

  final doc = pw.Document(
    theme: theme,
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,

      margin: const pw.EdgeInsets.fromLTRB(
        45,
        40,
        45,
        40,
      ),

      footer: footer,

      build: (context) {
        int sectionNumber = 0;

        final widgets = <pw.Widget>[

          // ------------------------------------------------
          // TITLE
          // ------------------------------------------------

          titleBlock(scope.title),

          // ------------------------------------------------
          // PATIENT
          // ------------------------------------------------

          section(
            ++sectionNumber,
            'Patient Information',
          ),

          patientSection(
            data.patient,
            data.reportingPeriod,
            data.reportDate,
          ),

          // ------------------------------------------------
          // MEDICAL
          // ------------------------------------------------

          section(
            ++sectionNumber,
            'Medical Information',
          ),

          medicalSection(
            data.medical,
          ),

          // ------------------------------------------------
          // SUMMARY
          // ------------------------------------------------

          section(
            ++sectionNumber,
            'Summary Statistics',
          ),

          summarySection(data),

          // ------------------------------------------------
          // DETECTION
          // ------------------------------------------------

          section(
            ++sectionNumber,
            'Detection Statistics',
          ),

          detectionSection(data),

          // ------------------------------------------------
          // TYPES
          // ------------------------------------------------

          section(
            ++sectionNumber,
            'Seizure Type Distribution',
          ),

          seizureTypesSection(
            data.seizureTypeCounts,
          ),

          // ------------------------------------------------
          // FREQUENCY CHART
          // ------------------------------------------------

          section(
            ++sectionNumber,
            scope.chartTitle,
          ),

          chartCaption(
            scope.chartDescription,
          ),

          frequencyChart(
            data,
            scope,
          ),
        ];

        // RECENT SEIZURE EVENTS
        if (data.recentEvents.isNotEmpty) {
          widgets.addAll([

            section(
              ++sectionNumber,
              'Seizure Duration',
            ),

            chartCaption(
              'Duration of recorded seizures.',
            ),

            durationChart(
              data.recentEvents,
            ),

            section(
              ++sectionNumber,
              'Recent Seizure Events',
            ),

            eventsTable(
              data.recentEvents,
            ),
          ]);
        }

        widgets.addAll([

          section(
            ++sectionNumber,
            'Current Medications',
          ),

          medicationTable(
            data.medications,
          ),

          section(
            ++sectionNumber,
            'Notes',
          ),

          notesSection(
            data.notes,
          ),

          pw.SizedBox(height: 20),

          disclaimer(),

          signOff(),
        ]);

        return widgets;
      },
    ),
  );

  return doc.save();
}

Future<void> printSeizureReport(SeizureReportData data) async {
  await Printing.layoutPdf(
    onLayout: (_) => buildSeizureReport(data),
  );
}

Future<void> shareSeizureReport(SeizureReportData data) async {
  final bytes = await buildSeizureReport(data);

  final filename = switch (data.scope) {
    ReportScope.week => 'weekly_report.pdf',
    ReportScope.month => 'monthly_report.pdf',
    ReportScope.multiMonth => 'multi_month_report.pdf',
  };

  await Printing.sharePdf(
    bytes: bytes,
    filename: filename,
  );
}

List<SeizureEvent> convertEvents(List<SeizureModel> seizures) {
  final sorted = [...seizures]
    ..sort(
      (a, b) => b.seizureDateTime.compareTo(a.seizureDateTime),
    );

  return sorted.map((s) {
    
    final totalSeconds = s.durationMinutes * 60 + s.durationSeconds;

    final minutes = totalSeconds / 60.0;

    return SeizureEvent(
      date: DateFormat('dd/MM/yyyy HH:mm').format(s.seizureDateTime),

      type: s.seizureTypes.join(', '),

      duration: '${minutes.toStringAsFixed(1)} min',

      detection: s.isAutoDetected
        ? 'Automatic'
        : 'Manual',

      notes: s.notes?.isNotEmpty == true
        ? s.notes!
        : '—',
    );
  }).toList();
}

Map<String, int> seizureTypeCounts(List<SeizureModel> seizures) {
  final result = <String, int>{};

  for (final seizure in seizures) {
    for (final type in seizure.seizureTypes) {
      result[type] = (result[type] ?? 0) + 1;
    }
  }

  return result;
}

String longestDuration(List<SeizureModel> seizures) {
  if (seizures.isEmpty) {
    return '--';
  }

  int maxSeconds = 0;

  for (final seizure in seizures) {
    final seconds = seizure.durationMinutes * 60 + seizure.durationSeconds;

    if (seconds > maxSeconds) {
      maxSeconds = seconds;
    }
  }

  return '${(maxSeconds / 60).toStringAsFixed(1)} min';
}

String shortestDuration(List<SeizureModel> seizures) {
  if (seizures.isEmpty) {
    return '--';
  }

  int minSeconds = 999999;

  for (final seizure in seizures) {
    final seconds = seizure.durationMinutes * 60 + seizure.durationSeconds;

    if (seconds < minSeconds) {
      minSeconds = seconds;
    }
  }

  return '${(minSeconds / 60).toStringAsFixed(1)} min';
}

int automaticCount(List<SeizureModel> seizures) {
  return seizures.where((e) => e.isAutoDetected).length;
}

int manualCount(List<SeizureModel> seizures) {
  return seizures.where((e) => !e.isAutoDetected).length;
}

List<ReportMedication> convertMedications(List<MedicationModel> meds) {
  return meds.map((m) {
    return ReportMedication(
      name: m.name,
      dosage: m.dosage,
      frequency: '${m.frequency} times/day',
      times: m.times.isEmpty
        ? '--'
        : m.times.join(', '),
    );
  }).toList();
}

class ReportBuilder {

  static SeizureReportData weekly({
    required ProfileModel profile,
    required MedicalModel medical,
    required List<MedicationModel> medications,
    required List<SeizureModel> seizures,
    required SummaryModel summary,
  }) {

    final now = DateTime.now();

    final weeklySeizures = seizures.where((s) {
      return s.seizureDateTime.isAfter(
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
      );
    }).toList();

    return SeizureReportData(
      scope: ReportScope.week,

      patient: profileToPatient(profile),

      medical: medicalToInfo(medical),

      reportingPeriod: 'Past 7 days',

      reportDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),

      totalSeizures: weeklySeizures.length,

      averageDuration: summary.averageDuration,

      longestDuration: longestDuration(weeklySeizures),

      shortestDuration: shortestDuration(weeklySeizures),

      seizureFreeStreak: summary.seizureFreeStreak,

      timeSinceLastSeizure: '${summary.lastSeizure} ${summary.lastSeizureMetric}',

      autoDetectedCount: automaticCount(weeklySeizures),

      manualCount: manualCount(weeklySeizures),

      averageFrequency: medical.seizureFrequency ?? '--',

      frequency: List.generate(
        summary.chartLabels.length,
        (index) => FrequencyBucket(
          summary.chartLabels[index],
          summary.chartValues[index],
        ),
      ),

      seizureTypeCounts: seizureTypeCounts(weeklySeizures),

      recentEvents: convertEvents(weeklySeizures),

      medications: convertMedications(medications),

      notes: '',
    );
  }

  static SeizureReportData monthly({
    required ProfileModel profile,
    required MedicalModel medical,
    required List<MedicationModel> medications,
    required List<SeizureModel> seizures,
    required SummaryModel summary,
  }) {
    final now = DateTime.now();

    final monthlySeizures = seizures.where((s) {
      return s.seizureDateTime.isAfter(
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30)),
      );
    }).toList();

    return SeizureReportData(
      scope: ReportScope.month,

      patient: profileToPatient(profile),

      medical: medicalToInfo(medical),

      reportingPeriod: 'Past 30 days',

      reportDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),

      totalSeizures: monthlySeizures.length,

      averageDuration: summary.averageDuration,

      longestDuration: longestDuration(monthlySeizures),

      shortestDuration: shortestDuration(monthlySeizures),

      seizureFreeStreak: summary.seizureFreeStreak,

      timeSinceLastSeizure: '${summary.lastSeizure} ${summary.lastSeizureMetric}',

      autoDetectedCount: automaticCount(monthlySeizures),

      manualCount: manualCount(monthlySeizures),

      averageFrequency: medical.seizureFrequency ?? '--',

      frequency: List.generate(
        summary.chartLabels.length,
        (index) => FrequencyBucket(
          summary.chartLabels[index],
          summary.chartValues[index],
        ),
      ),

      seizureTypeCounts: seizureTypeCounts(monthlySeizures),

      recentEvents: convertEvents(monthlySeizures),

      medications: convertMedications(medications),

      notes: '',
    );
  }

  static SeizureReportData multiMonth({
    required ProfileModel profile,
    required MedicalModel medical,
    required List<MedicationModel> medications,
    required List<SeizureModel> seizures,
    required SummaryModel summary,
  }) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 5, now.day);

    final multiMonthSeizures = seizures.where(
      (s) => !s.seizureDateTime.isBefore(startDate),
    ).toList();

    return SeizureReportData(
      scope: ReportScope.multiMonth,

      patient: profileToPatient(profile),

      medical: medicalToInfo(medical),

      reportingPeriod: 'Past 6 months',

      reportDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),

      totalSeizures: multiMonthSeizures.length,

      averageDuration: summary.averageDuration,

      longestDuration: longestDuration(multiMonthSeizures),

      shortestDuration: shortestDuration(multiMonthSeizures),

      seizureFreeStreak: summary.seizureFreeStreak,

      timeSinceLastSeizure: '${summary.lastSeizure} ${summary.lastSeizureMetric}',

      autoDetectedCount: automaticCount(multiMonthSeizures),

      manualCount: manualCount(multiMonthSeizures),

      averageFrequency: medical.seizureFrequency ?? '--',

      frequency: List.generate(
        summary.chartLabels.length,
        (index) => FrequencyBucket(
          summary.chartLabels[index],
          summary.chartValues[index],
        ),
      ),

      seizureTypeCounts: seizureTypeCounts(multiMonthSeizures),

      recentEvents: convertEvents(multiMonthSeizures),

      medications: convertMedications(medications),

      notes: '',
    );
  }
}