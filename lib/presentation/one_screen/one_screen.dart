import 'package:flutter/material.dart';
import 'package:student_hub/presentation/login_screen/login_screen.dart';
import 'package:student_hub/widgets/header_design.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';

class OneScreen extends StatelessWidget {
  const OneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderDesign(),
              SizedBox(height: 30.h),
              _buildContentSection(context),
              SizedBox(height: 70.h),
            ],
          ),
        ),
      ),
    );
  }



  /// Builds the main content section
  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildImage(),
          SizedBox(height: 40.h),
          _buildTitle(),
          SizedBox(height: 40.h),
          _buildDescription(),
          SizedBox(height: 74.h),
          _buildGetStartedButton(context),
        ],
      ),
    );
  }

  /// Builds the main descriptive image
  Widget _buildImage() {
    return Align(
      alignment: Alignment.center,
      child: CustomImageView(
        imagePath: ImageConstant.imgOffice,
        height: 230.h,
        width: 232.h,
        radius: BorderRadius.circular(12.h),
      ),
    );
  }

  /// Builds the title text
  Widget _buildTitle() {
    return Text(
      "Student Hub",
      style: CustomTextStyles.headlineSmallInikaBlack900,
    );
  }

  /// Builds the descriptive paragraph
  Widget _buildDescription() {
    return Text(
      "StudentHub is designed to streamline and automate administrative processes for university students, significantly reducing the need for in-person interactions and enhancing operational efficiency.",
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: CustomTextStyles.bodyMediumImprimaBlack900,
    );
  }

  /// Builds the "Get Started" button
  Widget _buildGetStartedButton(BuildContext context) {
    return CustomElevatedButton(
      text: "Get Started",
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      onPressed: () => onTapGetStartedButton(context),
    );
  }

  /// Navigates to the login screen when triggered
  void onTapGetStartedButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
