import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { primary, secondary, outlined, danger }

/// Reusable CustomButton with responsive sizing, loading spinner, and tactile feedback.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final Widget? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case ButtonType.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case ButtonType.secondary:
        bgColor = AppColors.secondarySurface;
        fgColor = AppColors.mainText;
        break;
      case ButtonType.outlined:
        bgColor = Colors.white;
        fgColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.border, width: 1.2);
        break;
      case ButtonType.danger:
        bgColor = AppColors.error;
        fgColor = Colors.white;
        break;
    }

    final effectiveHeight = height ?? (context.screenHeight * 0.058);

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabledText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
            side: borderSide,
          ),
          padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.04),
        ),
        child: isLoading
            ? SizedBox(
                width: context.screenWidth * 0.05,
                height: context.screenWidth * 0.05,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: context.screenWidth * 0.02),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTextStyles.button.copyWith(color: fgColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
