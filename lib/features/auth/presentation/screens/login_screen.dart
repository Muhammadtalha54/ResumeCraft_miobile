import 'package:flutter/material.dart';
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
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result.requiresVerification) {
        AppSnackbar.warning(
          context,
          result.message ?? 'Please verify your email address to access your account.',
        );
        AppNavigation.go(
          context,
          AppRoutes.verifyEmail,
          extra: result.email ?? _emailController.text.trim(),
        );
      } else if (result.isSuccess) {
        AppNavigation.go(context, AppRoutes.home);
      } else {
        final err = result.message ?? ref.read(authNotifierProvider).errorMessage ?? Lang.genericError;
        AppSnackbar.error(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.06,
              vertical: context.screenHeight * 0.03,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo
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
                              child: Icon(
                                Icons.description_rounded,
                                color: Colors.white,
                                size: context.screenWidth * 0.10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.025),

                    // Headings
                    Text(
                      Lang.loginTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenHeading,
                    ),
                    SizedBox(height: context.screenHeight * 0.01),
                    Text(
                      Lang.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.supporting,
                    ),
                    SizedBox(height: context.screenHeight * 0.035),

                    // Inputs Card
                    Container(
                      padding: EdgeInsets.all(context.screenWidth * 0.06),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: Offset(0, context.screenHeight * 0.004),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: Lang.emailLabel,
                            hint: Lang.emailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.mutedText,
                              size: context.screenWidth * 0.05,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return Lang.valRequired;
                              if (!val.contains('@') || !val.contains('.')) return Lang.valEmailInvalid;
                              return null;
                            },
                          ),
                          SizedBox(height: context.screenHeight * 0.02),
                          CustomTextField(
                            label: Lang.passwordLabel,
                            hint: Lang.passwordHint,
                            controller: _passwordController,
                            isPassword: true,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.mutedText,
                              size: context.screenWidth * 0.05,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return Lang.valRequired;
                              if (val.length < 6) return Lang.valPasswordLength;
                              return null;
                            },
                          ),
                          SizedBox(height: context.screenHeight * 0.012),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => AppNavigation.push(context, AppRoutes.forgotPassword),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                Lang.forgotPasswordLink,
                                style: AppTextStyles.supporting.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.025),
                          CustomButton(
                            text: Lang.loginButton,
                            onPressed: _handleLogin,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.025),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Lang.noAccountPrompt, style: AppTextStyles.supporting),
                        GestureDetector(
                          onTap: () => AppNavigation.push(context, AppRoutes.register),
                          child: Text(
                            Lang.signUpLink,
                            style: AppTextStyles.supporting.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
