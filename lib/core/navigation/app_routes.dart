/// Centralized route paths.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  // Main Tabs (Shell)
  static const String home = '/home';
  static const String createResume = '/build';
  static const String searchJobs = '/jobs';
  static const String profile = '/profile';

  // Sub-screens
  static const String analysisResult = '/analysis-result';
  static const String resumeHistory = '/history';
  static const String support = '/support';
  static const String legal = '/legal/:type';
  static String legalDoc(String type) => '/legal/$type';
  static const String pdfPreview = '/pdf-preview';
}
