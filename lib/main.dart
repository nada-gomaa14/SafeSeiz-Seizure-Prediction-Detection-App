import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safeseiz/navigation/auth_gate.dart';
import 'package:safeseiz/services/watch_service.dart';
import 'package:safeseiz/user/authentication/auth_cubit.dart';
import 'package:safeseiz/core/observer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeseiz/user/contacts/cubit/emergency_contacts_cubit.dart';
import 'package:safeseiz/user/contacts/models/emergency_contacts_model.dart';
import 'package:safeseiz/user/contacts/repository/emergency_contacts_local_repo.dart';
import 'package:safeseiz/user/medical/information/cubit/medical_cubit.dart';
import 'package:safeseiz/user/medical/information/models/medical_model.dart';
import 'package:safeseiz/user/medical/information/repository/medical_local_repo.dart';
import 'package:safeseiz/user/medical/medication/cubit/medication_cubit.dart';
import 'package:safeseiz/user/medical/medication/models/medication_model.dart';
import 'package:safeseiz/user/medical/medication/repository/medication_local_repo.dart';
import 'package:safeseiz/user/profile/cubit/profile_cubit.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/user/seizure/models/seizure_model.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_cubit.dart';
import 'package:safeseiz/user/sos/cubit/sos_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeseiz/services/notification_service.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final watchService = WatchService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  Bloc.observer = MyObserver();

  await Supabase.initialize(
    url: 'https://folgozyexdlqdykxhcvn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvbGdvenlleGRscWR5a3hoY3ZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczNzYzMzksImV4cCI6MjA5Mjk1MjMzOX0.X4-EYlE3SyWhOWbUC2u7RoDgqWSw_0Bv0pMlUCBBkSU',
  );

  await Hive.initFlutter();
  
  Hive.registerAdapter(MedicalModelAdapter());
  Hive.registerAdapter(EmergencyContactsModelAdapter());
  Hive.registerAdapter(SeizureModelAdapter());
  Hive.registerAdapter(MedicationModelAdapter());
  Hive.registerAdapter(SensorReadingModelAdapter());

  await Hive.openBox<MedicalModel>('medical_info_box');
  await Hive.openBox('emergency_contacts_box');
  await Hive.openBox('seizures_box');
  await Hive.openBox<List>('medication_box');
  await Hive.openBox<SensorReadingModel>('sensors_box');  

  // Trigger SOS alert when watch SOS button is pressed
  watchService.sosStream.listen((_) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final sosCubit = context.read<SOSCubit>();
    final contactsCubit = context.read<EmergencyContactsCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final seizureCubit = context.read<SeizureCubit>();
    final medicalCubit = context.read<MedicalCubit>();

    final contacts = contactsCubit.contacts;
    final firstName = profileCubit.profile?.firstName ?? '';
    final lastName = profileCubit.profile?.lastName ?? '';
    final patientName = '$firstName $lastName'.trim().isEmpty ? 'Patient' : '${firstName} ${lastName}'.trim();

    if (contacts.isEmpty) return;

    // Default seizure types from medical profile
    final defaultTypes = medicalCubit.medical?.seizureTypes ?? ['Unknown'];
    seizureCubit.seizureTypes = defaultTypes.isNotEmpty ? defaultTypes : ['Unknown'];

    // Log as manual — user pressed SOS button
    final seizureId = await seizureCubit.addSeizure(isAutoDetected: false);

    sosCubit.startCountdown(contacts: contacts, patientName: patientName, seizureId: seizureId, seizureTime: DateTime.now());
  });

   // AI detected seizure → trigger SOS
    watchService.seizureDetectedStream.listen((_) async {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      final sosCubit = context.read<SOSCubit>();
      final contactsCubit = context.read<EmergencyContactsCubit>();
      final profileCubit = context.read<ProfileCubit>();

      final contacts = contactsCubit.contacts;
      final firstName = profileCubit.profile?.firstName ?? '';
      final lastName = profileCubit.profile?.lastName ?? '';
      final patientName = '$firstName $lastName'.trim().isEmpty ? 'Patient' : '$firstName $lastName'.trim();

      if (contacts.isEmpty) return;

      sosCubit.startCountdown(contacts: contacts, patientName: patientName, seizureId: watchService.lastSeizureId, seizureTime: watchService.lastSeizureTime);
    });

    // Start listening for sensor data and SOS from smartwatch
    await watchService.startListening();

  runApp(const SafeSeiz());
}

class SafeSeiz extends StatefulWidget {
  const SafeSeiz({super.key});

  @override
  State<SafeSeiz> createState() => _SafeSeizState();
}

class _SafeSeizState extends State<SafeSeiz> {
  late final AppLifecycleListener _lifecycleListener;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();

    // Wire SensorsCubit to WatchService after providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    watchService.setSensorsCubit(context.read<SensorsCubit>());
    watchService.setSeizureCubit(context.read<SeizureCubit>());
    watchService.setMedicalCubit(context.read<MedicalCubit>());
  });

    // Sync on app resume
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        final context = navigatorKey.currentContext;
        if (context == null) return;
        context.read<SeizureCubit>().syncToSupabase();
        context.read<SensorsCubit>().syncToSupabase();
      },
    );

    // Sync when connectivity is restored
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (!hasConnection) return;

      final context = navigatorKey.currentContext;
      if (context == null) return;
      context.read<SeizureCubit>().syncToSupabase();
      context.read<SensorsCubit>().syncToSupabase(); 
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => MedicalCubit(MedicalLocalRepo())),
        BlocProvider(create: (context) => EmergencyContactsCubit(EmergencyContactsLocalRepo())),
        BlocProvider(create: (context) => MedicationCubit(MedicationLocalRepo())),
        BlocProvider(create: (context) => SensorsCubit()),
        BlocProvider(create: (context) => SeizureCubit(context.read<SensorsCubit>())),
        BlocProvider(create: (context) => SOSCubit(context.read<SensorsCubit>())),
        BlocProvider(create: (context) => AuthCubit(
          context.read<ProfileCubit>(), 
          context.read<MedicalCubit>(),
          context.read<EmergencyContactsCubit>(),
          context.read<MedicationCubit>(),
          context.read<SeizureCubit>(),
        )),
      ],
      child: ScreenUtilInit(
        designSize: MediaQuery.of(context).size.width >= 600
          ? const Size(800, 1280)
          : const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'SafeSeiz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF25148E),
                primary: const Color(0xFF25148E),
                onSurface: const Color(0xFF6f92f0),
                secondary: const Color(0xFFFFFFFF),
                tertiary: const Color(0xFF9E9E9E),
                error: const Color(0xFF990000),
              ),
              textTheme: GoogleFonts.poppinsTextTheme().copyWith(
                titleMedium: GoogleFonts.libreBaskerville(),
              ),
              useMaterial3: true,
            ),
            home: const AuthGate(),
          );
        },
      ),
    );  
  }
}