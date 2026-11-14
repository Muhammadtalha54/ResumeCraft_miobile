import 'package:flutter/material.dart';

/// Mandatory Responsive Sizing System via BuildContext Extensions.
/// Enables responsive proportions across all screen densities and form factors.
extension SizeExtensions on BuildContext {
  /// Total screen height in logical pixels
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Total screen width in logical pixels
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Top padding (status bar safe area)
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Bottom padding (home indicator / gesture safe area)
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Checks if device is a tablet / large screen
  bool get isTablet => screenWidth >= 600;

  /// Checks if device is a small screen phone
  bool get isSmallPhone => screenWidth < 360;

  /// Height proportion: context.heightPercent(0.05) = 5% of screen height
  double heightPercent(double percent) => screenHeight * percent;

  /// Width proportion: context.widthPercent(0.9) = 90% of screen width
  double widthPercent(double percent) => screenWidth * percent;

  /// Responsive font sizing with safety boundaries to prevent extreme typography
  double responsiveFontSize(double factor, {double min = 10, double max = 32}) {
    final computed = screenWidth * factor;
    if (computed < min) return min;
    if (computed > max) return max;
    return computed;
  }

  // Preset Common Responsive Dimensions
  double get pageHorizontalPadding => isTablet ? 32.0 : 20.0;
  double get cardCornerRadius => 14.0;
  double get buttonHeight => 50.0;
  double get inputHeight => 48.0;
}
