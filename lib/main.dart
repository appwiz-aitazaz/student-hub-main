import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_export.dart';
import 'services/auth_service.dart'; 
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  String initialRoute = AppRoutes.loginScreen;
  
  // Get auth token and profile completion status
  final authToken = prefs.getString('auth_token');
  final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
  final isFirstLogin = prefs.getBool('is_first_login') ?? true;
  
  // Determine initial route based on authentication status
  if (authToken != null) {
    if (isFirstLogin || !isProfileComplete) {
      // First time login or profile not completed - go to complete profile
      initialRoute = AppRoutes.completeProfile;
      // Set first login to false for next time
      await prefs.setBool('is_first_login', false);
    } else {
      // Returning user with completed profile - go to dashboard
      initialRoute = AppRoutes.dashboard;
    }
  } else {
    // No auth token - go to login screen
    initialRoute = AppRoutes.loginScreen;
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: theme,
          title: 'studenthub',
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: AppRoutes.routes,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
