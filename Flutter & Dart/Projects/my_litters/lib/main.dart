import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'state/session.dart';
import 'views/screens/dashboard_screen.dart';
import 'views/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire-and-forget: prepare the reminder channel and ask for permission.
  NotificationService.init().then((_) => NotificationService.requestPermission());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Session(AuthService())..bootstrap(),
        ),
      ],
      child: MaterialApp(
        title: 'My Litters',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A3A8A),
            brightness: Brightness.light,
          ),
        ),
        home: const _RootGate(),
      ),
    );
  }
}

/// Picks Dashboard or Login based on the bootstrapped session.
/// Shows a small spinner while we resolve the stored token.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    if (!session.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return session.isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
