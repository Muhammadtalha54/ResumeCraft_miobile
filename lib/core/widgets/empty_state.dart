import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';
import 'custom_button.dart';

/// Reusable EmptyState widget with icon, title, description, and optional action.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenWidth * 0.08,
          vertical: context.screenHeight * 0.03,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.screenWidth * 0.16,
              height: context.screenWidth * 0.16,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: context.screenWidth * 0.075,
              ),
            ),
            SizedBox(height: context.screenHeight * 0.02),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardHeading.copyWith(fontSize: 16),
            ),
            SizedBox(height: context.screenHeight * 0.01),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.supporting.copyWith(color: AppColors.secondaryText),
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: context.screenHeight * 0.025),
              CustomButton(
                text: actionText!,
                onPressed: onAction,
                width: context.screenWidth * 0.45,
                height: context.screenHeight * 0.05,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
