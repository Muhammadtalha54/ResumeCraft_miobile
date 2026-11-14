import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _secondsRemaining = 45;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 45);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp =>
      _otpControllers.map((c) => c.text.trim()).join();

  Future<void> _handleVerify() async {
    final otp = _enteredOtp;
    if (otp.length < 6) {
      AppSnackbar.error(context, 'Please enter the complete 6-digit verification code.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).verifyEmail(
          email: widget.email,
          otpCode: otp,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        AppSnackbar.success(context, 'Email verified successfully! Welcome aboard.');
        AppNavigation.go(context, AppRoutes.home);
      } else {
        final err = ref.read(authNotifierProvider).errorMessage ?? 'Verification failed. Please try again.';
        AppSnackbar.error(context, err);
      }
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() => _isResending = true);

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resendVerificationOtp(email: widget.email);

    setState(() => _isResending = false);

    if (mounted) {
      if (success) {
        AppSnackbar.success(context, 'A new verification code has been sent to your email.');
        _startTimer();
      } else {
        final err = ref.read(authNotifierProvider).errorMessage ?? 'Could not resend code. Try again later.';
        AppSnackbar.error(context, err);
      }
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_enteredOtp.length == 6) {
          _handleVerify();
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              AppNavigation.pop(context);
            } else {
              AppNavigation.go(context, AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.06,
              vertical: context.screenHeight * 0.02,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Center(
                    child: Container(
                      width: context.screenWidth * 0.22,
                      height: context.screenWidth * 0.22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.screenWidth * 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: Offset(0, context.screenHeight * 0.008),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.screenWidth * 0.05),
                        child: Image.asset(
                          AppAssets.appLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.primary,
                            child: const Icon(
                              Icons.mark_email_read_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Title & Description
                  Text(
                    'Verify Your Email',
                    style: AppTextStyles.screenHeading.copyWith(
                      color: AppColors.mainText,
                      fontSize: context.screenWidth * 0.065,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  Text(
                    'We have sent a 6-digit confirmation code to:',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.screenHeight * 0.008),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.email.isNotEmpty ? widget.email : 'your email',
                      style: AppTextStyles.cardHeading.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.04),

                  // 6-digit OTP Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: context.screenWidth * 0.12,
                        height: context.screenWidth * 0.14,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autofocus: index == 0,
                          style: TextStyle(
                            fontSize: context.screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainText,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: AppColors.surface,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (val) => _onDigitChanged(val, index),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: context.screenHeight * 0.04),

                  // Verify Button
                  CustomButton(
                    text: 'Verify Account',
                    isLoading: _isLoading,
                    onPressed: _handleVerify,
                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // Resend Code Section
                  Center(
                    child: _secondsRemaining > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: 6),
                              Text(
                                'Resend code in ${_secondsRemaining}s',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : TextButton.icon(
                            onPressed: _isResending ? null : _handleResend,
                            icon: _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                            label: Text(
                              'Resend Code',
                              style: AppTextStyles.buttonText.copyWith(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: context.screenHeight * 0.02),

                  // Switch to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already verified? ',
                        style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
                      ),
                      GestureDetector(
                        onTap: () => AppNavigation.go(context, AppRoutes.login),
                        child: Text(
                          Lang.signInLink,
                          style: AppTextStyles.cardHeading.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
