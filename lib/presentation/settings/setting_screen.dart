import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';

class EnrolledCoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CustomAppBar(title: 'Enrolled Courses'),
        body: Column(
          children: [
            const ScreenHeader(screenName: "Enrolled Courses"),
            const Expanded(
              child: Center(child: Text("Enrolled Courses Screen", style: TextStyle(fontSize: 24))),
            ),
          ],
        ),
      );
}