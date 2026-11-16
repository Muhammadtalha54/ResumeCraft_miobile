import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/storage/preferences_storage.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final preferencesStorageProvider = Provider<PreferencesStorage>((ref) => PreferencesStorage());

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _bootstrap();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = ref.read(preferencesStorageProvider);
      final isDoneOnboarding = await prefs.isOnboardingCompleted();
      try {
        await ref.read(authNotifierProvider.notifier).checkAuth();
      } catch (e) {
        debugPrint("Auth check error during bootstrap: $e");
      }

      await Future.delayed(const Duration(milliseconds: 1100));

      if (!mounted) return;

      final authState = ref.read(authNotifierProvider);

      if (!isDoneOnboarding) {
        AppNavigation.replace(context, AppRoutes.onboarding);
      } else if (authState.isAuthenticated) {
        AppNavigation.replace(context, AppRoutes.home);
      } else {
        AppNavigation.replace(context, AppRoutes.login);
      }
    } catch (e) {
      debugPrint("Bootstrap error: $e");
      if (mounted) {
        AppNavigation.replace(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: context.screenWidth * 0.28,
                  height: context.screenWidth * 0.28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: Offset(0, context.screenHeight * 0.01),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.06),
                    child: Image.asset(
                      AppAssets.appLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary,
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white,
                          size: context.screenWidth * 0.12,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.025),
                Text(
                  Lang.appName,
                  style: AppTextStyles.screenHeading.copyWith(
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.008),
                Text(
                  Lang.appTagline,
                  style: AppTextStyles.supporting.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
