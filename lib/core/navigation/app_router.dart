import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/job_search/presentation/screens/job_search_screen.dart';
import '../../features/legal/presentation/screens/document_viewer_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/resume_analysis/domain/entities/resume_analysis_entity.dart';
import '../../features/resume_analysis/presentation/screens/analysis_result_screen.dart';
import '../../features/resume_builder/presentation/screens/create_resume_screen.dart';
import '../../features/resume_builder/presentation/screens/pdf_preview_screen.dart';
import '../../features/resume_history/presentation/screens/resume_history_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Public Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          final extra = state.extra;
          String email = '';
          if (extra is String) {
            email = extra;
          } else if (extra is Map) {
            email = extra['email']?.toString() ?? '';
          }
          if (email.isEmpty) {
            email = state.uri.queryParameters['email'] ?? '';
          }
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Shell with 4 Persistent Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // 1. Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // 2. Build Resume Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.createResume,
                builder: (context, state) {
                  final extra = state.extra;
                  String? resumeId;
                  if (extra is String && extra.isNotEmpty) {
                    resumeId = extra;
                  } else if (extra is Map) {
                    resumeId = extra['resumeId']?.toString() ?? extra['id']?.toString();
                  }
                  resumeId ??= state.uri.queryParameters['resumeId'];
                  return CreateResumeScreen(initialResumeId: resumeId);
                },
              ),
            ],
          ),

          // 3. Search Jobs Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.searchJobs,
                builder: (context, state) => const JobSearchScreen(),
              ),
            ],
          ),

          // 4. Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Sub-Routes
      GoRoute(
        path: AppRoutes.analysisResult,
        builder: (context, state) {
          final analysis = state.extra as ResumeAnalysisEntity;
          return AnalysisResultScreen(analysis: analysis);
        },
      ),
      GoRoute(
        path: AppRoutes.resumeHistory,
        builder: (context, state) => const ResumeHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.legal,
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'privacy';
          return DocumentViewerScreen(type: type);
        },
      ),
      GoRoute(
        path: AppRoutes.pdfPreview,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PdfPreviewScreen(
            pdfUrl: extra?['pdfUrl'] as String? ?? '',
            resumeTitle: extra?['resumeTitle'] as String? ?? 'Resume',
          );
        },
      ),
    ],
  );
});
