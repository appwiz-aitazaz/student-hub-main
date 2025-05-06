import 'package:flutter/material.dart';
import '../core/app_export.dart';

extension on TextStyle {
  TextStyle get inika {
    return copyWith( 
      fontFamily: 'Inika',
    );
  }

TextStyle get mplus1pBold {
return copyWith( fontFamily: 'Mplus 1p Bold', );
}

TextStyle get inder {
return copyWith( fontFamily: 'Inder', );
}
TextStyle get imprima {
return copyWith( fontFamily: 'Imprima', 
);
}
}

  ///A collection of pre-defined text styles for customizing text app
  /// categorized by different font families and weights.
  /// Additionally, this class includes extensions on [TextStyle] to e

class CustomTextStyles {

// Body text style
static TextStyle get bodyMediumImprimaBlack900 =>
theme.textTheme.bodyMedium!.imprima.copyWith( color: appTheme.black900, fontSize: 14.fSize, );

static TextStyle get bodyMediumImprimaBlack90014 =>
 theme.textTheme.bodyMedium!.imprima.copyWith( color: appTheme.black900, fontSize: 14.fSize, );

static TextStyle get bodyMediumTeal400 =>

theme.textTheme.bodyMedium!.copyWith( color: appTheme.teal400, fontSize: 15.fSize, );

// Headline text style

static TextStyle get headlineSmallInikaBlack900 =>
 theme.textTheme.headlineSmall!.inika.copyWith( color: appTheme.black900, fontWeight: FontWeight.w700, );
}