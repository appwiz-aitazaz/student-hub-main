import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_export.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  bool isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
  String? authToken = prefs.getString('auth_token');

  String initialRoute;
  //initialRoute = AppRoutes.dashboard; // Default route
  // if (authToken == null) {
  initialRoute = AppRoutes.loginScreen;
  // } else if (!isProfileComplete) {
  //   initialRoute = AppRoutes.completeProfile;
  // } else {
  //   initialRoute = AppRoutes.dashboard; // Add this route to `AppRoutes`
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
