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
import '../../../../core/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      imagePath: AppAssets.onboarding1,
      icon: Icons.analytics_outlined,
      title: Lang.obTitle1,
      description: Lang.obDesc1,
    ),
    _OnboardingPageData(
      imagePath: AppAssets.onboarding2,
      icon: Icons.dashboard_customize_outlined,
      title: Lang.obTitle2,
      description: Lang.obDesc2,
    ),
    _OnboardingPageData(
      imagePath: AppAssets.onboarding3,
      icon: Icons.work_outline_rounded,
      title: Lang.obTitle3,
      description: Lang.obDesc3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(preferencesStorageProvider);
    await prefs.setOnboardingCompleted(true);
    if (mounted) {
      AppNavigation.replace(context, AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                Lang.onboardingSkip,
                style: AppTextStyles.supporting.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: context.screenWidth * 0.75,
                          height: context.screenWidth * 0.75,
                          constraints: BoxConstraints(
                            maxHeight: context.screenHeight * 0.35,
                            maxWidth: context.screenHeight * 0.35,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              page.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primaryLight,
                                  child: Icon(
                                    page.icon,
                                    size: context.screenWidth * 0.15,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.04),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.screenHeading.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.016),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Indicators
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenWidth * 0.06,
                vertical: context.screenHeight * 0.03,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.01),
                        width: _currentPage == index ? context.screenWidth * 0.06 : context.screenWidth * 0.02,
                        height: context.screenHeight * 0.009,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.01),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),
                  CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? Lang.onboardingGetStarted
                        : Lang.onboardingNext,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String imagePath;
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.description,
  });
}
