import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../resume_analysis/presentation/providers/resume_analysis_provider.dart';
import '../../../resume_builder/presentation/widgets/resume_content_editor_sheet.dart';

class ResumeHistoryScreen extends ConsumerStatefulWidget {
  const ResumeHistoryScreen({super.key});

  @override
  ConsumerState<ResumeHistoryScreen> createState() => _ResumeHistoryScreenState();
}

class _ResumeHistoryScreenState extends ConsumerState<ResumeHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resumeAnalysisProvider.notifier).fetchHistory();
    });
  }

  Future<void> _handlePreviewPdf(String id, String title) async {
    final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.resumeExport(id)}';
    
    AppNavigation.push(context, AppRoutes.pdfPreview, extra: {
      'pdfUrl': url,
      'resumeTitle': title,
    });
  }

  void _handleEditContent(Map<String, dynamic> resume) {
    final id = resume['id']?.toString() ?? '';
    final rawContent = resume['tailoredContent'] ?? resume['parsedContent'];
    Map<String, dynamic>? parsed;
    if (rawContent is Map<String, dynamic>) {
      parsed = rawContent;
    } else if (rawContent is String && rawContent.isNotEmpty) {
      try {
        parsed = jsonDecode(rawContent) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (parsed == null || id.isEmpty) {
      AppSnackbar.warning(context, 'This resume does not have editable structured content.');
      return;
    }

    ResumeContentEditorSheet.show(
      context,
      resumeId: id,
      initialContent: parsed,
      repository: ref.read(resumeRepositoryProvider),
      onUpdated: (_) {
        ref.read(resumeAnalysisProvider.notifier).fetchHistory();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeAnalysisProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CustomAppBar(
        title: Lang.drawerResumeHistory,
        showBack: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(resumeAnalysisProvider.notifier).fetchHistory(),
          color: AppColors.primary,
          child: state.isLoadingHistory
              ? const LoadingWidget(message: 'Loading your resume archive...')
              : state.recentResumes.isEmpty
                  ? EmptyStateWidget(
                      title: 'No Resumes In Archive',
                      description: 'Upload your resume or build a tailored draft to see it saved here.',
                      icon: Icons.history_edu_rounded,
                      actionText: 'Go to Home',
                      onAction: () => Navigator.pop(context),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenWidth * 0.05,
                        vertical: context.screenHeight * 0.02,
                      ),
                      itemCount: state.recentResumes.length,
                      separatorBuilder: (_, index) => SizedBox(height: context.screenHeight * 0.015),
                      itemBuilder: (context, index) {
                        final resume = state.recentResumes[index];
                        final id = resume['id']?.toString() ?? '';
                        final title = resume['title']?.toString() ?? 'Software Resume';
                        final score = resume['overallAtsScore'] as int? ?? 0;
                        final strategy = resume['targetMarketStrategy']?.toString() ?? 'FAANG';
                        final template = resume['template'] as Map<String, dynamic>?;
                        final templateName = template?['name']?.toString() ?? 'ATS Standard';

                        final isHighScore = score >= 75;

                        return InkWell(
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                          onTap: () => _handlePreviewPdf(id, title),
                          child: Container(
                            padding: EdgeInsets.all(context.screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                              // Circular Score indicator
                              Container(
                                width: context.screenWidth * 0.12,
                                height: context.screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  color: (isHighScore ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$score%',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isHighScore ? AppColors.success : AppColors.warning,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.screenWidth * 0.035),

                              // Metadata
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: AppTextStyles.cardHeading.copyWith(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: context.screenHeight * 0.003),
                                    Text(
                                      'Layout: $templateName',
                                      style: AppTextStyles.metadata.copyWith(fontSize: 11),
                                    ),
                                    Text(
                                      'Strategy: $strategy',
                                      style: AppTextStyles.metadata.copyWith(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Edit Resume Action
                              IconButton(
                                icon: Icon(
                                  Icons.edit_note_rounded,
                                  color: AppColors.primary,
                                  size: context.screenWidth * 0.06,
                                ),
                                tooltip: Lang.editResumeContent,
                                onPressed: () => _handleEditContent(resume),
                              ),

                              // Export PDF Action
                              IconButton(
                                icon: Icon(
                                  Icons.download_rounded,
                                  color: AppColors.primary,
                                  size: context.screenWidth * 0.055,
                                ),
                                tooltip: 'Preview PDF',
                                onPressed: () => _handlePreviewPdf(id, title),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    ),
        ),
      ),
    );
  }
}
