import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class AppTheme {
  static ThemeData theme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return ThemeData.light().copyWith(
        primaryColor: Colors.green,
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.transparent,
          elevation: 0.0,
        ),
      );
    }

    return ThemeData.dark().copyWith(
      // TODO(cbonello): TBD.
      primaryColor: const Color(0xFF1C3F80),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.transparent,
        elevation: 0.0,
      ),
    );
  }

  /// Not used yet, look into implementing
  static CardTheme get newsArticleListCardThemeStyle {
    return const CardTheme(
      elevation: 10,
      color: Color(0xFFF3F3AA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(1.0),
        ),
      ),
    );
  }

  static TextStyle get buttonEnabledTextStyle {
    return const TextStyle(
      color: Colors.white,
      // fontFamily: 'OpenSans',
      fontSize: 16,
    );
  }

  static TextStyle get buttonDisabledTextStyle {
    return const TextStyle(
      color: Colors.black54,
      // fontFamily: 'OpenSans',
      fontSize: 16,
    );
  }

  // static LinearGradient get blueGradient {
  //   return LinearGradient(
  //     colors: const <Color>[
  //       LEFT_DRAWER_GRADIENT_START,
  //       PRIMARY_COLOR,
  //     ],
  //     begin: FractionalOffset.topLeft,
  //     end: FractionalOffset.bottomRight,
  //   );
  // }

  static SnackBarThemeData get snackBarError {
    return const SnackBarThemeData(
      backgroundColor: Color(0xFFEB3A37),
      actionTextColor: Colors.white,
    );
  }
}
