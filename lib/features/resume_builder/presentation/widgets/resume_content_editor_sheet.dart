import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../resume_analysis/domain/repositories/resume_repository.dart';

class ResumeContentEditorSheet extends StatefulWidget {
  final String resumeId;
  final Map<String, dynamic> initialContent;
  final ResumeRepository repository;
  final ValueChanged<Map<String, dynamic>> onUpdated;

  const ResumeContentEditorSheet({
    super.key,
    required this.resumeId,
    required this.initialContent,
    required this.repository,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String resumeId,
    required Map<String, dynamic> initialContent,
    required ResumeRepository repository,
    required ValueChanged<Map<String, dynamic>> onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResumeContentEditorSheet(
        resumeId: resumeId,
        initialContent: initialContent,
        repository: repository,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ResumeContentEditorSheet> createState() => _ResumeContentEditorSheetState();
}

class _ResumeContentEditorSheetState extends State<ResumeContentEditorSheet> {
  late TextEditingController _summaryController;
  late TextEditingController _skillsController;
  late List<Map<String, dynamic>> _experiences;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final content = widget.initialContent;

    _summaryController = TextEditingController(
      text: content['summary']?.toString() ?? '',
    );

    final skillsRaw = content['skills'];
    final skillsText = (skillsRaw is List)
        ? skillsRaw.join(', ')
        : (skillsRaw?.toString() ?? '');
    _skillsController = TextEditingController(text: skillsText);

    final expRaw = content['experience'] ?? content['experiences'];
    if (expRaw is List) {
      _experiences = expRaw.map((e) {
        final bulletsRaw = e['bulletPoints'] ?? e['bullets'];
        final bulletsList = bulletsRaw is List
            ? bulletsRaw.map((b) => b.toString()).toList()
            : [e['description']?.toString() ?? ''];
        return {
          'role': TextEditingController(text: e['role']?.toString() ?? ''),
          'company': TextEditingController(text: e['company']?.toString() ?? ''),
          'period': TextEditingController(text: e['period']?.toString() ?? ''),
          'bullets': TextEditingController(text: bulletsList.join('\n')),
        };
      }).toList();
    } else {
      _experiences = [];
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _skillsController.dispose();
    for (final exp in _experiences) {
      (exp['role'] as TextEditingController).dispose();
      (exp['company'] as TextEditingController).dispose();
      (exp['period'] as TextEditingController).dispose();
      (exp['bullets'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      final updatedSkills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final updatedExperiences = _experiences.map((exp) {
        final bulletsText = (exp['bullets'] as TextEditingController).text;
        final bulletList = bulletsText
            .split('\n')
            .map((b) => b.trim())
            .where((b) => b.isNotEmpty)
            .toList();

        return {
          'role': (exp['role'] as TextEditingController).text.trim(),
          'company': (exp['company'] as TextEditingController).text.trim(),
          'period': (exp['period'] as TextEditingController).text.trim(),
          'bulletPoints': bulletList,
        };
      }).toList();

      final updatedPayload = Map<String, dynamic>.from(widget.initialContent);
      updatedPayload['summary'] = _summaryController.text.trim();
      updatedPayload['skills'] = updatedSkills;
      updatedPayload['experience'] = updatedExperiences;

      await widget.repository.updateResumeContent(
        resumeId: widget.resumeId,
        tailoredContent: updatedPayload,
      );

      widget.onUpdated(updatedPayload);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, Lang.updateSuccess);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * 0.88,
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.screenWidth * 0.05),
        ),
      ),
      child: Column(
        children: [
          // Header handle & title
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.05,
              vertical: context.screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.screenWidth * 0.05),
              ),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lang.resumeEditorTitle,
                        style: AppTextStyles.cardHeading.copyWith(
                          fontSize: context.screenWidth * 0.045,
                        ),
                      ),
                      SizedBox(height: context.screenHeight * 0.003),
                      Text(
                        'Directly modify executive bullets and skills before export',
                        style: AppTextStyles.metadata,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.secondaryText,
                    size: context.screenWidth * 0.055,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Scrollable Editor Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Professional Summary
                  Text(
                    Lang.summaryLabel,
                    style: AppTextStyles.sectionHeading.copyWith(
                      fontSize: context.screenWidth * 0.042,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  CustomTextField(
                    controller: _summaryController,
                    hint: Lang.summaryHint,
                    maxLines: 4,
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // 2. Skills
                  Text(
                    Lang.skillsLabel,
                    style: AppTextStyles.sectionHeading.copyWith(
                      fontSize: context.screenWidth * 0.042,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  CustomTextField(
                    controller: _skillsController,
                    hint: Lang.skillsHint,
                    maxLines: 2,
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // 3. Work Experience Bullets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Lang.scratchExperience,
                        style: AppTextStyles.sectionHeading.copyWith(
                          fontSize: context.screenWidth * 0.042,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.012),

                  ..._experiences.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exp = entry.value;

                    return Container(
                      margin: EdgeInsets.only(bottom: context.screenHeight * 0.02),
                      padding: EdgeInsets.all(context.screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Experience #${index + 1}',
                                  style: AppTextStyles.cardHeading.copyWith(
                                    fontSize: context.screenWidth * 0.038,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.screenHeight * 0.01),
                          CustomTextField(
                            label: Lang.roleLabel,
                            controller: exp['role'] as TextEditingController,
                          ),
                          SizedBox(height: context.screenHeight * 0.01),
                          CustomTextField(
                            label: Lang.companyLabel,
                            controller: exp['company'] as TextEditingController,
                          ),
                          SizedBox(height: context.screenHeight * 0.01),
                          CustomTextField(
                            label: Lang.periodLabel,
                            controller: exp['period'] as TextEditingController,
                          ),
                          SizedBox(height: context.screenHeight * 0.01),
                          CustomTextField(
                            label: Lang.editBulletPoints,
                            controller: exp['bullets'] as TextEditingController,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: context.screenHeight * 0.02),
                ],
              ),
            ),
          ),

          // Bottom Bar Action
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.05,
              vertical: context.screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: Offset(0, -context.screenHeight * 0.005),
                ),
              ],
            ),
            child: CustomButton(
              text: _isSaving ? Lang.updatingContent : Lang.saveChanges,
              onPressed: _handleSave,
              isLoading: _isSaving,
              icon: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: context.screenWidth * 0.045,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
