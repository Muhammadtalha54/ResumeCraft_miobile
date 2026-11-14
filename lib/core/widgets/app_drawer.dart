import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/lang.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';

/// Reusable AppDrawer fulfilling Section 7.L of Master Prompt.
class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.mainBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Summary
            Container(
              padding: EdgeInsets.all(context.screenWidth * 0.05),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.screenWidth * 0.12,
                    height: context.screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: context.screenWidth * 0.065,
                      ),
                    ),
                  ),
                  SizedBox(width: context.screenWidth * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Candidate',
                          style: AppTextStyles.cardHeading.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.screenHeight * 0.003),
                        Text(
                          userEmail,
                          style: AppTextStyles.metadata.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.01),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: Lang.tabHome,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.edit_document,
                    label: Lang.tabCreateResume,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/build');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline_rounded,
                    label: Lang.tabSearchJobs,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/jobs');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.history_edu_rounded,
                    label: Lang.drawerResumeHistory,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/history');
                    },
                  ),
                  Divider(
                    indent: context.screenWidth * 0.04,
                    endIndent: context.screenWidth * 0.04,
                    height: context.screenHeight * 0.02,
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: Lang.drawerSupport,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/support');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    label: Lang.drawerPrivacy,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/legal/privacy');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    label: Lang.drawerTerms,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/legal/terms');
                    },
                  ),
                ],
              ),
            ),

            // Sign Out Option at Bottom
            Padding(
              padding: EdgeInsets.all(context.screenWidth * 0.04),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                ),
                tileColor: AppColors.errorBackground,
                leading: Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: context.screenWidth * 0.05,
                ),
                title: Text(
                  Lang.drawerLogout,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: context.screenWidth * 0.055),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.screenWidth * 0.05,
        vertical: context.screenHeight * 0.003,
      ),
    );
  }
}
