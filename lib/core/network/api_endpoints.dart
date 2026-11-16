import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API Endpoints Contract matching ResumeCraft backend exactly.
class ApiEndpoints {
  ApiEndpoints._();

  /// API Base URL:
  /// 1. Reads API_BASE_URL from .env if defined and initialized
  /// 2. Fallback: 127.0.0.1:5000 for Android (works directly with adb reverse)
  /// 3. Fallback: localhost:5000 for iOS Simulator, Desktop, or Web
  static String get baseUrl {
    if (dotenv.isInitialized) {
      final envUrl = dotenv.env['API_BASE_URL'];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        return envUrl.trim();
      }
    }

    return 'https://resumecraft-backend-tffi.onrender.com/api';
  }

  // Auth
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerificationOtp = '/auth/resend-verification-otp';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/auth/profile';

  // Resumes & ATS
  static const String resumeUpload = '/resumes/upload';
  static const String resumeTailor = '/resumes/tailor';
  static const String resumeCreateFromScratch = '/resumes/create-from-scratch';
  static String resumeUpdateContent(String id) => '/resumes/$id/content';
  static const String resumeHistory = '/resumes/history';
  static String resumeExport(String id) => '/resumes/export/$id';

  // Templates
  static const String templates = '/templates';

  // Jobs
  static const String jobsSearch = '/jobs/search';
  static const String jobsApply = '/jobs/apply';

  // Support
  static const String supportTickets = '/support/tickets';

  // Payments & Stripe Plans
  static const String paymentPlans = '/payments/plans';
  static const String createPaymentIntent = '/payments/create-payment-intent';
  static const String confirmPayment = '/payments/confirm-payment';
}
