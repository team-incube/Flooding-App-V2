import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class FloatingActionLocations {
  static FloatingActionButtonLocation get aiFloatingLocation =>
      _AiFloatingLocation();
}

class _AiFloatingLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final x =
        scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        AppSpacing.s24;

    final y =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        79;

    return Offset(x, y);
  }
}
