import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'services/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/assigned_deliveries_screen.dart';
import 'screens/delivery_details_screen.dart';
import 'screens/address_verification_screen.dart';
import 'screens/verification_result_screen.dart';
import 'screens/verification_history_screen.dart';
import 'screens/submit_feedback_screen.dart';
import 'screens/delivery_filters_screen.dart';
import 'screens/sync_deliveries_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';

final themeProvider = ThemeProvider();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AlgeoVerifyApp());
}

class AlgeoVerifyApp extends StatefulWidget {
  const AlgeoVerifyApp({super.key});

  @override
  State<AlgeoVerifyApp> createState() => _AlgeoVerifyAppState();
}

class _AlgeoVerifyAppState extends State<AlgeoVerifyApp> {
  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algeo-Verify Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeShell(),
        '/delivery-details': (context) => const DeliveryDetailsScreen(),
        '/verify-address': (context) => const AddressVerificationScreen(),
        '/verification-result': (context) => const VerificationResultScreen(),
        '/submit-feedback': (context) => const SubmitFeedbackScreen(),
        '/filters': (context) => const DeliveryFiltersScreen(),
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AssignedDeliveriesScreen(),
    VerificationHistoryScreen(),
    SyncDeliveriesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      // FAB for manual address verification on the deliveries tab
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/verify-address');
              },
              icon: const Icon(Icons.pin_drop_outlined),
              label: const Text('Verify'),
            )
          : null,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
