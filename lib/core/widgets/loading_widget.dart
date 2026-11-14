import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';

/// Reusable LoadingWidget with modern indicator and optional status message.
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: context.screenWidth * 0.09,
            height: context.screenWidth * 0.09,
            child: const CircularProgressIndicator(
              strokeWidth: 2.8,
              color: AppColors.primary,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: context.screenHeight * 0.02),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.supporting.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
