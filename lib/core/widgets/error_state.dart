import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';
import 'custom_button.dart';

/// Reusable ErrorState widget with error icon, message, and retry button.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
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
              width: context.screenWidth * 0.15,
              height: context.screenWidth * 0.15,
              decoration: const BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: context.screenWidth * 0.075,
              ),
            ),
            SizedBox(height: context.screenHeight * 0.02),
            Text(
              'Something Went Wrong',
              style: AppTextStyles.cardHeading.copyWith(fontSize: 16),
            ),
            SizedBox(height: context.screenHeight * 0.008),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.supporting.copyWith(color: AppColors.secondaryText),
            ),
            if (onRetry != null) ...[
              SizedBox(height: context.screenHeight * 0.025),
              CustomButton(
                text: retryText,
                onPressed: onRetry,
                type: ButtonType.outlined,
                width: context.screenWidth * 0.42,
                height: context.screenHeight * 0.05,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
