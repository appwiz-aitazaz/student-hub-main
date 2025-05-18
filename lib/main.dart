import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_export.dart';
import 'services/auth_service.dart'; // Add this import

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  // Set profile as complete to avoid redirection
  await prefs.setBool('isProfileComplete', true);
  // Set a dummy auth token if needed
  if (prefs.getString('auth_token') == null) {
    await prefs.setString('auth_token', 'dummy_token');
  }

  String initialRoute = AppRoutes.dashboard;
  
  // Determine initial route based on authentication status
  // if (authToken == null) {
  //   initialRoute = AppRoutes.loginScreen;
  // } else if (!isProfileComplete) {
  //   initialRoute = AppRoutes.completeProfile;
  // } else {
  //   initialRoute = AppRoutes.dashboard;
  // }
  
  runApp(MyApp(initialRoute: initialRoute));
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
