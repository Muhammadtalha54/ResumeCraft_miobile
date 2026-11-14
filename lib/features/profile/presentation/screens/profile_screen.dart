import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/upgrade_plan_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(Lang.logoutConfirmTitle, style: AppTextStyles.cardHeading),
        content: Text(Lang.logoutConfirmMessage, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(Lang.confirmCancel, style: AppTextStyles.supporting),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                AppNavigation.replace(context, AppRoutes.login);
              }
            },
            child: Text(Lang.confirmYes, style: AppTextStyles.button.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CustomAppBar(
        title: Lang.profileTitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: context.screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card Header
              Container(
                padding: EdgeInsets.all(context.screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: Offset(0, context.screenHeight * 0.003),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.screenWidth * 0.15,
                      height: context.screenWidth * 0.15,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: context.screenWidth * 0.08,
                        ),
                      ),
                    ),
                    SizedBox(width: context.screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Candidate Profile',
                            style: AppTextStyles.cardHeading.copyWith(fontSize: 17),
                          ),
                          SizedBox(height: context.screenHeight * 0.003),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.supporting.copyWith(fontSize: 13),
                          ),
                          SizedBox(height: context.screenHeight * 0.008),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.screenWidth * 0.02,
                              vertical: context.screenHeight * 0.003,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(context.screenWidth * 0.015),
                            ),
                            child: Text(
                              user?.isPro == true ? Lang.planPro : Lang.planFree,
                              style: AppTextStyles.metadata.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),

              // Credits Summary Row
              Row(
                children: [
                  Expanded(
                    child: _CreditBox(
                      title: Lang.resumeCredits,
                      count: user?.resumeCredits ?? 0,
                      icon: Icons.edit_document,
                    ),
                  ),
                  SizedBox(width: context.screenWidth * 0.03),
                  Expanded(
                    child: _CreditBox(
                      title: Lang.atsCredits,
                      count: user?.atsCredits ?? 0,
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.screenHeight * 0.02),

              // Upgrade to Pro / Top-up Action Card
              InkWell(
                onTap: () => UpgradePlanSheet.show(context),
                borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.screenWidth * 0.04,
                    vertical: context.screenHeight * 0.018,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: Offset(0, context.screenHeight * 0.004),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: context.screenWidth * 0.07,
                      ),
                      SizedBox(width: context.screenWidth * 0.035),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recharge Credits (Plus & Pro)',
                              style: AppTextStyles.cardHeading.copyWith(
                                color: Colors.white,
                                fontSize: context.screenWidth * 0.038,
                              ),
                            ),
                            SizedBox(height: context.screenHeight * 0.002),
                            Text(
                              '5 to 10 Tailors • 10 to 25 Audits • Never expire',
                              style: AppTextStyles.supporting.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: context.screenWidth * 0.03,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: context.screenWidth * 0.04,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.03),

              // Navigation Options Section
              Text('Account & History', style: AppTextStyles.sectionHeading),
              SizedBox(height: context.screenHeight * 0.012),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.history_edu_rounded,
                      title: Lang.drawerResumeHistory,
                      subtitle: 'View your previously analyzed and generated CVs',
                      onTap: () => AppNavigation.push(context, AppRoutes.resumeHistory),
                    ),
                    Divider(indent: context.screenWidth * 0.13),
                    _SettingsTile(
                      icon: Icons.support_agent_rounded,
                      title: Lang.helpCenter,
                      subtitle: 'Get assistance or submit inquiry tickets',
                      onTap: () => AppNavigation.push(context, AppRoutes.support),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.screenHeight * 0.03),

              // Legal Section
              Text('Legal & Terms', style: AppTextStyles.sectionHeading),
              SizedBox(height: context.screenHeight * 0.012),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: Lang.drawerPrivacy,
                      onTap: () => AppNavigation.push(context, AppRoutes.legalDoc('privacy')),
                    ),
                    Divider(indent: context.screenWidth * 0.13),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: Lang.drawerTerms,
                      onTap: () => AppNavigation.push(context, AppRoutes.legalDoc('terms')),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.screenHeight * 0.035),

              // Sign Out Button
              CustomButton(
                text: Lang.drawerLogout,
                type: ButtonType.danger,
                onPressed: () => _showLogoutDialog(context, ref),
                icon: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: context.screenWidth * 0.045,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditBox extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _CreditBox({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count.toString(),
                style: AppTextStyles.screenHeading.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              Icon(icon, color: AppColors.primary, size: context.screenWidth * 0.05),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.005),
          Text(
            title,
            style: AppTextStyles.metadata.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(context.screenWidth * 0.02),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
        ),
        child: Icon(icon, color: AppColors.primary, size: context.screenWidth * 0.05),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.supporting.copyWith(fontSize: 11))
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.mutedText,
        size: context.screenWidth * 0.035,
      ),
      onTap: onTap,
    );
  }
}
