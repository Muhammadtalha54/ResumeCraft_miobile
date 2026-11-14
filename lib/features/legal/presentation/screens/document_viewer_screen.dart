import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String type; // 'privacy' or 'terms'

  const DocumentViewerScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type.toLowerCase() == 'privacy';
    final title = isPrivacy ? Lang.drawerPrivacy : Lang.drawerTerms;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: CustomAppBar(
        title: title,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: context.screenHeight * 0.02,
          ),
          child: Container(
            padding: EdgeInsets.all(context.screenWidth * 0.06),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.screenHeading.copyWith(fontSize: 20),
                ),
                SizedBox(height: context.screenHeight * 0.008),
                Text(
                  'Last Updated: October 2026 • ResumeCraft AI',
                  style: AppTextStyles.metadata,
                ),
                Divider(height: context.screenHeight * 0.035),
                if (isPrivacy) ...[
                  const _Section(
                    title: '1. Information We Collect',
                    content:
                        'ResumeCraft AI processes resume documents (PDF/DOCX), career history, contact details, and application data strictly to perform ATS scoring, resume tailoring via AI models, and relevant job aggregation.',
                  ),
                  const _Section(
                    title: '2. Artificial Intelligence & Processing',
                    content:
                        'Your resume text is parsed in memory and analyzed against ATS best practices. User data is never sold or utilized to train general public models without explicit organizational consent.',
                  ),
                  const _Section(
                    title: '3. Data Security & Storage',
                    content:
                        'All network communication utilizes TLS encryption. Sensitive session credentials are encrypted in local hardware storage on your device.',
                  ),
                ] else ...[
                  const _Section(
                    title: '1. Acceptance of Terms',
                    content:
                        'By using ResumeCraft AI, you agree to comply with standard platform usage guidelines, credit deductions for generative operations, and responsible career application practices.',
                  ),
                  const _Section(
                    title: '2. User Accounts & Credits',
                    content:
                        'Accounts receive starter resource credits for resume tailoring and ATS analysis. Pro subscriptions unlock unlimited templates and elevated AI processing limits.',
                  ),
                  const _Section(
                    title: '3. Limitation of Liability',
                    content:
                        'ResumeCraft AI provides optimization recommendations and job links as an informational service. We do not guarantee employment offers from external hiring companies.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardHeading.copyWith(fontSize: 15)),
          SizedBox(height: context.screenHeight * 0.008),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
