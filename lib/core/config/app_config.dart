import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_endpoints.dart';

/// Centralized configuration provider reading from mobile .env
class AppConfig {
  AppConfig._();

  /// Initialize environment variables before app runs
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: "assets/.env");
    } catch (_) {
      try {
        await dotenv.load(fileName: ".env");
      } catch (_) {
        // Fallback in-memory initialization so dotenv is never uninitialized
        try {
          dotenv.loadFromString(
            envString:
                'API_BASE_URL=http://192.168.100.43:5000/api\nSTRIPE_PUBLISHABLE_KEY=pk_test_51TVTXbIsIPShicSX3INxjHx2sdYmINlyIximLmE09NdxHliA2nRpFMgihBdbGPUZRoXta0fpSKUfBg7d23oooXZu00C7We1Gv8',
          );
        } catch (_) {}
      }
    }
  }

  /// Stripe Sandbox Publishable Key
  static String get stripePublishableKey {
    if (dotenv.isInitialized) {
      final key = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
      if (key != null && key.isNotEmpty) return key;
    }
    return 'pk_test_51TVTXbIsIPShicSX3INxjHx2sdYmINlyIximLmE09NdxHliA2nRpFMgihBdbGPUZRoXta0fpSKUfBg7d23oooXZu00C7We1Gv8';
  }

  /// Backend API Base URL (reads from .env API_BASE_URL with platform fallback)
  static String get apiBaseUrl => ApiEndpoints.baseUrl;
}
