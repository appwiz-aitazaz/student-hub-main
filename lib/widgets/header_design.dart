import 'package:flutter/material.dart';

import '../core/app_export.dart';

class HeaderDesign extends StatelessWidget {
  const HeaderDesign({super.key});

  @override
  Widget build(context) {
    return SizedBox(
      height: 162.h,
      width: 202.h,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgEllipse2,
            height: 162.h,
            width: 146.h,
            alignment: Alignment.topLeft,
          ),
          CustomImageView(
            imagePath: ImageConstant.imgEllipse3,
            height: 106.h,
            width: double.maxFinite,
            alignment: Alignment.topRight,
          ),
        ],
      ),
    );
  }
}
