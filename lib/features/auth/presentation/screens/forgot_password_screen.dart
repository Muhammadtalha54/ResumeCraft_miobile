import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).forgotPassword(
          email: _emailController.text.trim(),
        );

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    if (mounted) {
      AppSnackbar.success(context, Lang.resetSuccessMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
          onPressed: () => AppNavigation.pop(context),
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
                  Text(
                    Lang.forgotPasswordTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenHeading,
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  Text(
                    Lang.forgotPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.supporting,
                  ),
                  SizedBox(height: context.screenHeight * 0.035),

                  Container(
                    padding: EdgeInsets.all(context.screenWidth * 0.06),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: _isSuccess
                        ? Column(
                            children: [
                              Container(
                                width: context.screenWidth * 0.14,
                                height: context.screenWidth * 0.14,
                                decoration: const BoxDecoration(
                                  color: AppColors.successBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.mark_email_read_rounded,
                                  color: AppColors.success,
                                  size: context.screenWidth * 0.07,
                                ),
                              ),
                              SizedBox(height: context.screenHeight * 0.02),
                              Text(
                                'Recovery Instructions Dispatched',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.cardHeading.copyWith(fontSize: 15),
                              ),
                              SizedBox(height: context.screenHeight * 0.01),
                              Text(
                                Lang.resetSuccessMessage,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.supporting.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              SizedBox(height: context.screenHeight * 0.03),
                              CustomButton(
                                text: Lang.backToLogin,
                                onPressed: () => AppNavigation.pop(context),
                              ),
                            ],
                          )
                        : Form(
                            key: _formKey,
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
                                SizedBox(height: context.screenHeight * 0.03),
                                CustomButton(
                                  text: Lang.sendResetButton,
                                  onPressed: _handleReset,
                                  isLoading: _isLoading,
                                ),
                              ],
                            ),
                          ),
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
