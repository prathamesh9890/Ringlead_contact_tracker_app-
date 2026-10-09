import 'package:flutter/material.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_repository.dart';
import 'services/reminder_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up local notifications for callback reminders (best-effort).
  ReminderService.instance.init();
  runApp(const RingleadApp());
}

class RingleadApp extends StatelessWidget {
  const RingleadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ringlead',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue, brightness: Brightness.light),
        fontFamily: 'Roboto',
      ),
      home: const _SessionGate(),
    );
  }
}

/// Restores any cached session before deciding whether to show the login
/// screen or drop straight into the app.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  @override
  void initState() {
    super.initState();
    AuthRepository.instance.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthRepository.instance,
      builder: (context, _) {
        switch (AuthRepository.instance.status) {
          case AuthStatus.initializing:
            return const Scaffold(
              backgroundColor: AppColors.bg,
              body: Center(child: CircularProgressIndicator(color: AppColors.blue)),
            );
          case AuthStatus.signedIn:
            return const AppShell();
          case AuthStatus.signedOut:
            return const LoginScreen();
        }
      },
    );
  }
}
