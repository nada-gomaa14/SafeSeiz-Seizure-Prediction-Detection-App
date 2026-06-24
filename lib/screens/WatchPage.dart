import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safeseiz/functions/responsive.dart';
import 'package:safeseiz/user/medical/information/cubit/medical_cubit.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/widgets/CustomButton.dart';
import 'package:safeseiz/widgets/ReturnButton.dart';
import '../user/contacts/cubit/emergency_contacts_cubit.dart';
import '../user/sos/cubit/sos_cubit.dart';
import '../user/seizure/seizure_detector.dart';
import '../screens/SOSPage.dart';
import '../services/notification_service.dart';

class WatchPage extends StatefulWidget {
  final String patientName;

  const WatchPage({
    super.key,
    required this.patientName,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  static const _watchChannel = EventChannel('com.example.safeseiz/watch_events');
  StreamSubscription? _watchSubscription;

  String hr        = '--';
  String spo2      = '--';
  String accelX    = '--', accelY = '--', accelZ = '--';
  String gyroX     = '--', gyroY  = '--', gyroZ  = '--';
  String timestamp = '--';
  String status    = 'Waiting for watch...';
  String seizureStatus = 'Monitoring...';
  bool _isTesting = false;
  int _currentEventType = 0; // 0=normal, 1=pre-seizure, 2=seizure

  final SeizureDetector _detector = SeizureDetector();
  bool _detectorInitialized = false;

  @override
  void initState() {
    super.initState();
    _initDetector();
    _listenToWatch();
  }

  Future<void> _initDetector() async {
    await _detector.initialize();
    setState(() => _detectorInitialized = true);
  }

  Future<void> _runSyntheticTest() async {
    if (_isTesting) return;
    setState(() {
      _isTesting = true;
      seizureStatus = '⏳ Running test...';
      _currentEventType = 0;
    });

    _detector.reset();

    try {
      final String jsonStr = await rootBundle.loadString('assets/seizure_test_data.json');
      final Map<String, dynamic> data = json.decode(jsonStr);
      final List<double> ecg  = List<double>.from(data['ecg']);
      final List<double> accX = List<double>.from(data['acc_x']);
      final List<double> accY = List<double>.from(data['acc_y']);
      final List<double> accZ = List<double>.from(data['acc_z']);

      debugPrint('Loaded seizure test data: ${ecg.length} samples');

      for (int i = 0; i < ecg.length; i++) {
        final int prediction = await _detector.addReading(
          ppg:    ecg[i],
          accelX: accX[i],
          accelY: accY[i],
          accelZ: accZ[i],
          gyroX:  0.0,
          gyroY:  0.0,
          gyroZ:  0.0,
        ); 

        if (!mounted) return;

        if (prediction == 1 || prediction == 2) {
          final isSeizure = prediction == 2;
          setState(() => seizureStatus = isSeizure ? '🚨 Seizure Detected!' : '⚠️ Pre-seizure Warning');

          if (_currentEventType != prediction) {
            NotificationService().showSeizureNotification(isSeizure: isSeizure);
            _currentEventType = prediction;
   
            if (isSeizure) {
              // Go through proper flow — SOSCubit from provider tree
              final sosCubit = context.read<SOSCubit>();
              final seizureCubit = context.read<SeizureCubit>();
              final medicalCubit = context.read<MedicalCubit>();
              final contactsCubit = context.read<EmergencyContactsCubit>();
              final profileCubit = context.read<ProfileCubit>();

              final contacts = contactsCubit.contacts;
              final firstName = profileCubit.profile?.firstName ?? '';
              final lastName = profileCubit.profile?.lastName ?? '';
              final patientName = '$firstName $lastName'.trim().isEmpty ? 'Patient' : '$firstName $lastName'.trim();

              if (contacts.isNotEmpty) {
                sosCubit.startCountdown(
                  contacts: contacts,
                  patientName: patientName,
                  seizureTime: DateTime.now(),
                  onAlertConfirmed: () async {
                    final defaultTypes = medicalCubit.medical?.seizureTypes ?? ['Unknown'];
                    seizureCubit.seizureTypes = defaultTypes.isNotEmpty ? defaultTypes : ['Unknown'];
                    return await seizureCubit.addSeizure(isAutoDetected: true);
                  },
                );

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SOSPage()),
                );
              }
              break;
            }
          }
        } else {
          if (_currentEventType == 0) {
            setState(() => seizureStatus = 'Normal Readings ✓');
          }
        }

        if (i % 100 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
    } catch (e) {
      debugPrint('Test error: $e');
      setState(() => seizureStatus = 'Test error: $e');
    }

    setState(() {
      _isTesting = false;
      if (seizureStatus == '⏳ Running test...') {
        seizureStatus = 'Normal Readings ✓ (test complete)';
      }
    });
  }

  void _listenToWatch() {
    _watchSubscription = _watchChannel.receiveBroadcastStream().listen(
      (event) async {
        if (!mounted) return;
        final data = Map<String, dynamic>.from(event);

        if (data['type'] == 'sos') {
          // Watch SOS button — go through startCountdown
          final sosCubit = context.read<SOSCubit>();
          final seizureCubit = context.read<SeizureCubit>();
          final medicalCubit = context.read<MedicalCubit>();
          final contactsCubit = context.read<EmergencyContactsCubit>();
          final profileCubit = context.read<ProfileCubit>();
          final contacts = contactsCubit.contacts;
          final firstName = profileCubit.profile?.firstName ?? '';
          final lastName = profileCubit.profile?.lastName ?? '';
          final patientName = '$firstName $lastName'.trim().isEmpty ? 'Patient' : '$firstName $lastName'.trim();
          if (contacts.isEmpty) return;
          sosCubit.startCountdown(
            contacts: contacts,
            patientName: patientName,
            onAlertConfirmed: () async {
              final defaultTypes = medicalCubit.medical?.seizureTypes ?? ['Unknown'];
              seizureCubit.seizureTypes = defaultTypes.isNotEmpty ? defaultTypes : ['Unknown'];
              return await seizureCubit.addSeizure(isAutoDetected: false);
            },
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SOSPage()),
          );
          return;
        }

        // Parse PPG
        final String ppgStr = data['ppg'] ?? '';
        double ppgValue = 0.0;
        if (ppgStr.isNotEmpty) {
          final parts = ppgStr.split(',');
          if (parts.isNotEmpty) {
            ppgValue = double.tryParse(parts[0].trim()) ?? 0.0;
          }
        }

        // Run inference
        if (_detectorInitialized && !_isTesting) {
          final int prediction = await _detector.addReading(
            ppg:    ppgValue,
            accelX: double.tryParse(data['accel_x'] ?? '0') ?? 0.0,
            accelY: double.tryParse(data['accel_y'] ?? '0') ?? 0.0,
            accelZ: double.tryParse(data['accel_z'] ?? '0') ?? 0.0,
            gyroX:  double.tryParse(data['gyro_x']  ?? '0') ?? 0.0,
            gyroY:  double.tryParse(data['gyro_y']  ?? '0') ?? 0.0,
            gyroZ:  double.tryParse(data['gyro_z']  ?? '0') ?? 0.0,
          );

          if (!mounted) return;

          if (prediction == 2 && _currentEventType != 2) {
            setState(() { seizureStatus = '🚨 Seizure Detected!'; _currentEventType = 2; });
            NotificationService().showSeizureNotification(isSeizure: true);

            final sosCubit = context.read<SOSCubit>();
            final seizureCubit = context.read<SeizureCubit>();
            final medicalCubit = context.read<MedicalCubit>();
            final contactsCubit = context.read<EmergencyContactsCubit>();
            final profileCubit = context.read<ProfileCubit>();
            final contacts = contactsCubit.contacts;
            final firstName = profileCubit.profile?.firstName ?? '';
            final lastName = profileCubit.profile?.lastName ?? '';
            final patientName = '$firstName $lastName'.trim().isEmpty ? 'Patient' : '$firstName $lastName'.trim();

            if (contacts.isNotEmpty) {
              sosCubit.startCountdown(
                contacts: contacts,
                patientName: patientName,
                seizureTime: DateTime.now(),
                onAlertConfirmed: () async {
                  final defaultTypes = medicalCubit.medical?.seizureTypes ?? ['Unknown'];
                  seizureCubit.seizureTypes = defaultTypes.isNotEmpty ? defaultTypes : ['Unknown'];
                  return await seizureCubit.addSeizure(isAutoDetected: true);
                },
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SOSPage()),
              );
            }
          } else if (prediction == 1 && _currentEventType == 0) {
            setState(() { seizureStatus = '⚠️ Pre-seizure Warning'; _currentEventType = 1; });
            NotificationService().showSeizureNotification(isSeizure: false);
          } else if (prediction == 0) {
            setState(() { seizureStatus = 'Normal ✓'; _currentEventType = 0; });
          }
        }

        setState(() {
          hr        = data['hr']      ?? '--';
          spo2      = data['spo2']    ?? '--';
          accelX    = data['accel_x'] ?? '--';
          accelY    = data['accel_y'] ?? '--';
          accelZ    = data['accel_z'] ?? '--';
          gyroX     = data['gyro_x']  ?? '--';
          gyroY     = data['gyro_y']  ?? '--';
          gyroZ     = data['gyro_z']  ?? '--';
          final ts  = data['timestamp'];
          timestamp = ts != null ? ts.toString() : '--';
          status    = 'Receiving data ✓';
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => status = 'Error: $error');
      },
    );
  }

  @override
  void dispose() {
    _watchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: 60.h * Responsive.scale(context),
        title: Text(
          'Watch Data',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 25.sp * Responsive.scale(context),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w * Responsive.scale(context)),
          child: ReturnButton(),
        ),
        leadingWidth: 60.w * Responsive.scale(context),
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30.0.w * Responsive.scale(context),
            vertical: 10.0.h * Responsive.scale(context)
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection status bar
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.r * Responsive.scale(context)),
                  decoration: BoxDecoration(
                    color: status.contains('✓')
                      ? const Color(0xFF22A45D).withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
                    border: Border.all(
                      color: status.contains('✓')
                      ? const Color(0xFF22A45D)
                      : Theme.of(context).colorScheme.primary
                    ),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14.sp * Responsive.scale(context),
                      color: status.contains('✓')
                        ? const Color(0xFF22A45D)
                        : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 10.h * Responsive.scale(context)),
                // Seizure status bar
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.r * Responsive.scale(context)),
                  decoration: BoxDecoration(
                    color: seizureStatus.contains('🚨')
                      ? Theme.of(context).colorScheme.error.withValues(alpha: 0.15)
                      : seizureStatus.contains('⚠️')
                      ? Colors.orange.withValues(alpha: 0.15)
                      : seizureStatus.contains('✓')
                      ? const Color(0xFF22A45D).withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15.0.r * Responsive.scale(context)),
                    border: Border.all(
                      color: seizureStatus.contains('🚨')
                      ? Theme.of(context).colorScheme.error
                      : seizureStatus.contains('⚠️')
                      ? Colors.orange
                      : seizureStatus.contains('✓')
                      ? const Color(0xFF22A45D)
                      : Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                  child: Text(
                    seizureStatus,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14.sp * Responsive.scale(context),
                      color: seizureStatus.contains('🚨')
                        ? Theme.of(context).colorScheme.error
                        : seizureStatus.contains('⚠️')
                        ? Colors.orange
                        : seizureStatus.contains('✓')
                        ? const Color(0xFF22A45D)
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 20.h * Responsive.scale(context)),
                    
                // Vitals card
                _buildCard(
                  title: 'Vitals',
                  icon: Icons.favorite,
                  color: Colors.red,
                  children: [
                    _buildRow('Heart Rate', '$hr bpm'),
                    _buildRow('SpO2', '$spo2 %'),
                  ],
                ),
                    
                const SizedBox(height: 12),
                    
                // Accelerometer card
                _buildCard(
                  title: 'Accelerometer',
                  icon: Icons.speed,
                  color: Colors.blue,
                  children: [
                    _buildRow('X', accelX),
                    _buildRow('Y', accelY),
                    _buildRow('Z', accelZ),
                  ],
                ),
                    
                const SizedBox(height: 12),
                    
                // Gyroscope card
                _buildCard(
                  title: 'Gyroscope',
                  icon: Icons.rotate_right,
                  color: Colors.purple,
                  children: [
                    _buildRow('X', gyroX),
                    _buildRow('Y', gyroY),
                    _buildRow('Z', gyroZ),
                  ],
                ),
                    
                SizedBox(height: 20.h * Responsive.scale(context)),
                // Test Seizure Detection button
                CustomButton(
                  text: _isTesting ? 'Testing...' : 'Test Seizure Detection',
                  width: double.infinity,
                  onTap: _isTesting ? null : _runSyntheticTest,
                  child: _isTesting 
                    ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                      )
                    )
                    : null
                ),
                SizedBox(height: 10.h * Responsive.scale(context)),
                Center(
                  child: Text(
                    'Last update: $timestamp',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 12.sp * Responsive.scale(context),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color)),
            ]),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}