import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../resume_analysis/presentation/providers/resume_analysis_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _targetTitleController = TextEditingController();
  final _jobDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resumeAnalysisProvider.notifier).fetchHistory();
    });
  }

  @override
  void dispose() {
    _targetTitleController.dispose();
    _jobDescController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Lang.homeGreetingMorning;
    if (hour < 17) return Lang.homeGreetingAfternoon;
    return Lang.homeGreetingEvening;
  }

  Future<void> _handleAnalyze() async {
    final notifier = ref.read(resumeAnalysisProvider.notifier);
    final analysis = await notifier.analyzeResume(
      targetTitle: _targetTitleController.text,
      jobDescription: _jobDescController.text,
    );

    if (mounted) {
      if (analysis != null) {
        _targetTitleController.clear();
        _jobDescController.clear();
        AppNavigation.push(context, AppRoutes.analysisResult, extra: analysis);
      } else {
        final err = ref.read(resumeAnalysisProvider).errorMessage ?? Lang.genericError;
        AppSnackbar.error(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final resumeState = ref.watch(resumeAnalysisProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: CustomAppBar(
        showDrawer: true,
        showProfile: true,
        onProfileTap: () => AppNavigation.go(context, AppRoutes.profile),
      ),
      drawer: AppDrawer(
        userName: user?.name ?? 'Candidate',
        userEmail: user?.email ?? '',
        onLogout: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) {
            AppNavigation.replace(context, AppRoutes.login);
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(resumeAnalysisProvider.notifier).fetchHistory(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.05,
              vertical: context.screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting & Headline
                Text(
                  '${_getGreeting()} ${user?.name.split(' ').first ?? 'Candidate'}',
                  style: AppTextStyles.supporting.copyWith(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.005),
                Text(
                  'Optimize Your Resume For ATS',
                  style: AppTextStyles.screenHeading.copyWith(fontSize: 22),
                ),
                SizedBox(height: context.screenHeight * 0.025),

                // Upload & Target Details Card
                Container(
                  padding: EdgeInsets.all(context.screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: Offset(0, context.screenHeight * 0.005),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (resumeState.selectedFile == null)
                        InkWell(
                          onTap: () => ref.read(resumeAnalysisProvider.notifier).pickResumeFile(),
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: context.screenHeight * 0.035,
                              horizontal: context.screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySurface,
                              borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_outlined,
                                  color: AppColors.primary,
                                  size: context.screenWidth * 0.09,
                                ),
                                SizedBox(height: context.screenHeight * 0.012),
                                Text(
                                  Lang.selectFileButton,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: context.screenHeight * 0.005),
                                Text(
                                  'Tap to browse device files (PDF / DOCX)',
                                  style: AppTextStyles.metadata,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(context.screenWidth * 0.035),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file_rounded,
                                color: AppColors.primary,
                                size: context.screenWidth * 0.065,
                              ),
                              SizedBox(width: context.screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ready for ATS Scan',
                                      style: AppTextStyles.metadata.copyWith(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      resumeState.selectedFileName ?? 'resume.pdf',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.secondaryText,
                                  size: context.screenWidth * 0.05,
                                ),
                                onPressed: () => ref.read(resumeAnalysisProvider.notifier).clearSelectedFile(),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: context.screenHeight * 0.03),
                      
                      CustomTextField(
                        label: Lang.targetJobTitleLabel,
                        hint: Lang.targetJobTitleHint,
                        controller: _targetTitleController,
                      ),
                      SizedBox(height: context.screenHeight * 0.02),
                      CustomTextField(
                        label: Lang.targetJobDescLabel,
                        hint: Lang.targetJobDescHint,
                        controller: _jobDescController,
                        maxLines: 4,
                      ),
                      SizedBox(height: context.screenHeight * 0.025),

                      CustomButton(
                        text: resumeState.isAnalyzing ? Lang.analyzingProgress : Lang.analyzeResumeButton,
                        onPressed: resumeState.selectedFile != null ? _handleAnalyze : null,
                        isLoading: resumeState.isAnalyzing,
                        icon: Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: context.screenWidth * 0.045,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.035),

                // Recent Analyses Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Lang.recentAnalysesTitle, style: AppTextStyles.sectionHeading),
                    if (resumeState.recentResumes.isNotEmpty)
                      GestureDetector(
                        onTap: () => AppNavigation.push(context, AppRoutes.resumeHistory),
                        child: Text(
                          'View All (${resumeState.recentResumes.length})',
                          style: AppTextStyles.supporting.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.screenHeight * 0.015),

                // Recent Resumes List
                if (resumeState.isLoadingHistory)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.screenWidth * 0.06),
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                else if (resumeState.recentResumes.isEmpty)
                  Container(
                    padding: EdgeInsets.all(context.screenWidth * 0.06),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: AppColors.mutedText,
                          size: context.screenWidth * 0.09,
                        ),
                        SizedBox(height: context.screenHeight * 0.012),
                        Text(
                          Lang.noResumesYet,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.supporting.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: resumeState.recentResumes.take(3).length,
                    separatorBuilder: (_, index) => SizedBox(height: context.screenHeight * 0.012),
                    itemBuilder: (context, index) {
                      final item = resumeState.recentResumes[index];
                      final score = item['overallAtsScore'] as int? ?? 0;
                      final title = item['title']?.toString() ?? 'Software Resume';
                      final strategy = item['targetMarketStrategy']?.toString() ?? 'FAANG';

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.screenWidth * 0.04,
                          vertical: context.screenHeight * 0.018,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: context.screenWidth * 0.11,
                              height: context.screenWidth * 0.11,
                              decoration: BoxDecoration(
                                color: (score >= 75 ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$score%',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: score >= 75 ? AppColors.success : AppColors.warning,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.screenWidth * 0.035),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: context.screenHeight * 0.003),
                                  Text(
                                    'Strategy: $strategy',
                                    style: AppTextStyles.metadata,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.mutedText,
                              size: context.screenWidth * 0.035,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
