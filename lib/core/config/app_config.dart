import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_endpoints.dart';

/// Centralized configuration provider reading from mobile .env
class AppConfig {
  AppConfig._();

  /// Initialize environment variables before app runs
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {
      // Graceful fallback if .env is missing or cannot be read
    }
  }

  /// Stripe Sandbox Publishable Key
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_mock_publishable_key';

  /// Backend API Base URL (reads from .env API_BASE_URL with platform fallback)
  static String get apiBaseUrl => ApiEndpoints.baseUrl;
}
