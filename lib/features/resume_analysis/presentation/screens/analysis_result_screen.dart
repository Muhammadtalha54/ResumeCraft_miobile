import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ats_score_gauge.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/resume_analysis_entity.dart';

class AnalysisResultScreen extends StatelessWidget {
  final ResumeAnalysisEntity analysis;

  const AnalysisResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CustomAppBar(
        title: Lang.atsResultTitle,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: context.screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overall Score Card with Gauge
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: context.screenHeight * 0.03,
                  horizontal: context.screenWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: Offset(0, context.screenHeight * 0.005),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AtsScoreGauge(score: analysis.overallScore, size: context.screenWidth * 0.35),
                    SizedBox(height: context.screenHeight * 0.02),
                    Text(
                      analysis.overallScore >= 75
                          ? 'Excellent ATS Compatibility!'
                          : 'Optimization Recommended',
                      style: AppTextStyles.cardHeading.copyWith(fontSize: 17),
                    ),
                    SizedBox(height: context.screenHeight * 0.005),
                    Text(
                      analysis.overallScore >= 75
                          ? 'Your resume possesses strong keyword density and clean section structures.'
                          : 'Your resume has formatting gaps or missing tech keywords that scanners might drop.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.supporting.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),

              // 2. Sub-Score Breakdown Cards
              Text('Detailed Score Breakdown', style: AppTextStyles.sectionHeading),
              SizedBox(height: context.screenHeight * 0.015),
              Row(
                children: [
                  Expanded(
                    child: _ScorePill(
                      label: Lang.scoreFormat,
                      score: analysis.formattingScore,
                      icon: Icons.view_quilt_outlined,
                    ),
                  ),
                  SizedBox(width: context.screenWidth * 0.025),
                  Expanded(
                    child: _ScorePill(
                      label: Lang.scoreContent,
                      score: analysis.contentScore,
                      icon: Icons.article_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.screenHeight * 0.012),
              Row(
                children: [
                  Expanded(
                    child: _ScorePill(
                      label: Lang.scoreSkills,
                      score: analysis.skillsScore,
                      icon: Icons.psychology_outlined,
                    ),
                  ),
                  SizedBox(width: context.screenWidth * 0.025),
                  Expanded(
                    child: _ScorePill(
                      label: Lang.scoreImpact,
                      score: analysis.impactScore,
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.screenHeight * 0.03),

              // 3. Key Strengths
              if (analysis.strengths.isNotEmpty) ...[
                Text(Lang.keyStrengthsTitle, style: AppTextStyles.sectionHeading),
                SizedBox(height: context.screenHeight * 0.012),
                Container(
                  padding: EdgeInsets.all(context.screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: analysis.strengths
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.008),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: context.screenWidth * 0.045,
                                ),
                                SizedBox(width: context.screenWidth * 0.025),
                                Expanded(
                                  child: Text(item, style: AppTextStyles.body.copyWith(fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.03),
              ],

              // 4. Actionable Improvements
              if (analysis.recommendations.isNotEmpty) ...[
                Text(Lang.improvementRecommendationsTitle, style: AppTextStyles.sectionHeading),
                SizedBox(height: context.screenHeight * 0.012),
                Container(
                  padding: EdgeInsets.all(context.screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: analysis.recommendations
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.008),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: AppColors.warning,
                                  size: context.screenWidth * 0.045,
                                ),
                                SizedBox(width: context.screenWidth * 0.025),
                                Expanded(
                                  child: Text(item, style: AppTextStyles.body.copyWith(fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.035),
              ],

              // 5. Tailor Now Action
              CustomButton(
                text: Lang.tailorNowButton,
                onPressed: () {
                  AppNavigation.go(context, AppRoutes.createResume, extra: analysis.resumeId);
                },
                icon: Icon(
                  Icons.auto_fix_high_rounded,
                  color: Colors.white,
                  size: context.screenWidth * 0.045,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;

  const _ScorePill({
    required this.label,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 75) {
      color = AppColors.scoreHigh;
    } else if (score >= 50) {
      color = AppColors.scoreMedium;
    } else {
      color = AppColors.scoreLow;
    }

    return Container(
      padding: EdgeInsets.all(context.screenWidth * 0.035),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primary, size: context.screenWidth * 0.045),
              Text(
                '$score%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.01),
          Text(
            label,
            style: AppTextStyles.metadata.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
