import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';

/// Reusable CustomAppBar fulfilling Section 8 of Master Prompt.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showDrawer;
  final bool showBack;
  final bool showProfile;
  final Widget? trailing;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showDrawer = false,
    this.showBack = false,
    this.showProfile = false,
    this.trailing,
    this.onProfileTap,
    this.onBackTap,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.mainBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: showDrawer
          ? IconButton(
              icon: Icon(Icons.menu_rounded, color: AppColors.mainText, size: context.screenWidth * 0.06),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Navigation Menu',
            )
          : showBack
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: context.screenWidth * 0.05),
                  onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                )
              : null,
      title: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title!,
                  style: AppTextStyles.cardHeading.copyWith(
                    fontSize: 18,
                    color: AppColors.mainText,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.supporting.copyWith(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
              ],
            )
          : null,
      actions: [
        ?trailing,
        if (showProfile)
          Padding(
            padding: EdgeInsets.only(right: context.screenWidth * 0.04),
            child: GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: context.screenWidth * 0.09,
                height: context.screenWidth * 0.09,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: context.screenWidth * 0.05,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
