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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackbar.error(context, Lang.valPasswordMismatch);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result.requiresVerification) {
        AppSnackbar.success(
          context,
          result.message ?? 'Verification code sent to your email! Please enter it to activate your account.',
        );
        AppNavigation.go(
          context,
          AppRoutes.verifyEmail,
          extra: result.email ?? _emailController.text.trim(),
        );
      } else if (result.isSuccess) {
        AppSnackbar.success(context, 'Account created successfully!');
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
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
      //     onPressed: () => AppNavigation.pop(context),
      //   ),
      // ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.06,
              vertical: context.screenHeight * 0.01,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: context.screenWidth * 0.18,   
                        height: context.screenWidth * 0.18,
                        margin: EdgeInsets.only(bottom: context.screenHeight * 0.02),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: Offset(0, context.screenHeight * 0.006),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                          child: Image.asset(
                            AppAssets.appLogo,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      Lang.registerTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenHeading,
                    ),
                    SizedBox(height: context.screenHeight * 0.01),
                    Text(
                      Lang.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.supporting,
                    ),
                    SizedBox(height: context.screenHeight * 0.02),

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
                            label: Lang.fullNameLabel,
                            hint: Lang.fullNameHint,
                            controller: _nameController,
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.mutedText,
                              size: context.screenWidth * 0.05,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return Lang.valRequired;
                              return null;
                            },
                          ),
                          SizedBox(height: context.screenHeight * 0.018),
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
                          SizedBox(height: context.screenHeight * 0.018),
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
                          SizedBox(height: context.screenHeight * 0.018),
                          CustomTextField(
                            label: Lang.confirmPasswordLabel,
                            hint: Lang.confirmPasswordHint,
                            controller: _confirmPasswordController,
                            isPassword: true,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.mutedText,
                              size: context.screenWidth * 0.05,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return Lang.valRequired;
                              return null;
                            },
                          ),
                          SizedBox(height: context.screenHeight * 0.02),
                          Text(
                            Lang.termsAcceptNotice,
                            style: AppTextStyles.metadata.copyWith(
                              color: AppColors.mutedText,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.screenHeight * 0.025),
                          CustomButton(
                            text: Lang.registerButton,
                            onPressed: _handleRegister,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.025),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Lang.hasAccountPrompt, style: AppTextStyles.supporting),
                        GestureDetector(
                          onTap: () => AppNavigation.pop(context),
                          child: Text(
                            Lang.signInLink,
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
