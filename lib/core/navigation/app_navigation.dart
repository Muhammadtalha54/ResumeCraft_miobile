import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation facade fulfilling Section 16 of Master Prompt.
/// Avoids scattering raw GoRouter calls or route string literals across screens.
class AppNavigation {
  AppNavigation._();

  static void go(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  static Future<T?> push<T>(BuildContext context, String route, {Object? extra}) {
    return context.push<T>(route, extra: extra);
  }

  static void replace(BuildContext context, String route, {Object? extra}) {
    context.replace(route, extra: extra);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    if (context.canPop()) {
      context.pop<T>(result);
    }
  }
}
