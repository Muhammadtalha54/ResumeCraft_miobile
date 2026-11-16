import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../resume_analysis/presentation/providers/resume_analysis_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/resume_content_editor_sheet.dart';

class CreateResumeScreen extends ConsumerStatefulWidget {
  final String? initialResumeId;

  const CreateResumeScreen({super.key, this.initialResumeId});

  @override
  ConsumerState<CreateResumeScreen> createState() => _CreateResumeScreenState();
}

class _CreateResumeScreenState extends ConsumerState<CreateResumeScreen> {
  // Mode selection: 0 = Upload & AI Tailor, 1 = Build from Scratch
  int _selectedMode = 0;

  // Controllers for Mode 0: Upload & Tailor
  final _tailorJobDescController = TextEditingController();
  String? _selectedTailorResumeId;
  String? _selectedTailorResumeTitle;

  // Controllers for Mode 1: Build from Scratch
  final _scratchFullNameController = TextEditingController();
  final _scratchEmailController = TextEditingController();
  final _scratchPhoneController = TextEditingController();
  final _scratchLocationController = TextEditingController();
  final _scratchLinkedinController = TextEditingController();
  final _scratchPortfolioController = TextEditingController();
  final _scratchJobTitleController = TextEditingController();
  final _scratchJobDescController = TextEditingController();
  final _scratchSkillsController = TextEditingController();

  // Dynamic lists for Scratch Mode
  final List<Map<String, TextEditingController>> _scratchExperiences = [];
  final List<Map<String, TextEditingController>> _scratchEducation = [];

  // Carousel & Templates
  final PageController _pageController = PageController(viewportFraction: 0.72);
  List<Map<String, dynamic>> _templates = [];
  bool _isLoadingTemplates = true;
  int _selectedTemplateIndex = 0;
  String _selectedStrategy = 'FAANG';

  // Submission State
  bool _isProcessing = false;
  Map<String, dynamic>? _tailoredResult;

  final List<Map<String, String>> _strategies = const [
    {
      'id': 'FAANG',
      'title': 'FAANG / Silicon Valley',
      'desc': 'Single-column high density with measurable engineering metrics.',
    },
    {
      'id': 'EUROPEAN_CV',
      'title': 'European Standard CV',
      'desc': 'Standardized Europass compliant structure for UK & EU positions.',
    },
    {
      'id': 'SAUDI_GULF',
      'title': 'Saudi & Gulf Executive',
      'desc': 'Tailored for Middle East / Gulf corporate recruitment standards.',
    },
    {
      'id': 'GENERAL_ATS',
      'title': 'General ATS Compatible',
      'desc': 'Universal format maximizing readability across Workday, Greenhouse & Lever.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTailorResumeId = widget.initialResumeId;
    _fetchTemplates();
    _addInitialScratchFields();
  }

  void _addInitialScratchFields() {
    _scratchExperiences.add({
      'role': TextEditingController(),
      'company': TextEditingController(),
      'period': TextEditingController(),
      'description': TextEditingController(),
    });

    _scratchEducation.add({
      'degree': TextEditingController(),
      'institution': TextEditingController(),
      'year': TextEditingController(),
    });
  }

  @override
  void dispose() {
    _tailorJobDescController.dispose();
    _scratchFullNameController.dispose();
    _scratchEmailController.dispose();
    _scratchPhoneController.dispose();
    _scratchLocationController.dispose();
    _scratchLinkedinController.dispose();
    _scratchPortfolioController.dispose();
    _scratchJobTitleController.dispose();
    _scratchJobDescController.dispose();
    _scratchSkillsController.dispose();

    for (final exp in _scratchExperiences) {
      for (final c in exp.values) {
        c.dispose();
      }
    }
    for (final edu in _scratchEducation) {
      for (final c in edu.values) {
        c.dispose();
      }
    }

    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTemplates() async {
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final list = await repo.getTemplates();
      setState(() {
        _templates = list;
        _isLoadingTemplates = false;
      });
    } catch (_) {
      setState(() => _isLoadingTemplates = false);
    }
  }

  void _addExperienceItem() {
    setState(() {
      _scratchExperiences.add({
        'role': TextEditingController(),
        'company': TextEditingController(),
        'period': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeExperienceItem(int index) {
    if (_scratchExperiences.length <= 1) return;
    setState(() {
      final item = _scratchExperiences.removeAt(index);
      for (final c in item.values) {
        c.dispose();
      }
    });
  }

  void _addEducationItem() {
    setState(() {
      _scratchEducation.add({
        'degree': TextEditingController(),
        'institution': TextEditingController(),
        'year': TextEditingController(),
      });
    });
  }

  void _removeEducationItem(int index) {
    if (_scratchEducation.length <= 1) return;
    setState(() {
      final item = _scratchEducation.removeAt(index);
      for (final c in item.values) {
        c.dispose();
      }
    });
  }

  void _showResumeSelector() {
    final recentResumes = ref.read(resumeAnalysisProvider).recentResumes;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.screenWidth * 0.05)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(context.screenWidth * 0.04),
                child: Text('Select Base Resume', style: AppTextStyles.cardHeading),
              ),
              ListTile(
                leading: Icon(Icons.upload_file, color: AppColors.primary),
                title: Text('Upload New Resume', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _uploadNewResumeForTailoring();
                },
              ),
              const Divider(),
              if (recentResumes.isEmpty)
                Padding(
                  padding: EdgeInsets.all(context.screenWidth * 0.04),
                  child: Text('No recent resumes found.', style: AppTextStyles.supporting),
                )
              else
                ...recentResumes.map((r) => ListTile(
                  leading: Icon(Icons.description_outlined, color: AppColors.primary),
                  title: Text(r['title']?.toString() ?? 'Resume', style: AppTextStyles.bodyMedium),
                  subtitle: Text('Score: ${r['overallAtsScore'] ?? r['atsScore'] ?? '--'}', style: AppTextStyles.metadata),
                  onTap: () {
                    setState(() {
                      _selectedTailorResumeId = r['id']?.toString();
                      _selectedTailorResumeTitle = r['title']?.toString();
                    });
                    Navigator.pop(ctx);
                  },
                )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadNewResumeForTailoring() async {
    final notifier = ref.read(resumeAnalysisProvider.notifier);
    await notifier.pickResumeFile();
    
    final state = ref.read(resumeAnalysisProvider);
    if (state.selectedFile != null) {
      setState(() => _isProcessing = true);
      final result = await notifier.analyzeResume();
      setState(() => _isProcessing = false);
      
      if (result != null) {
        setState(() {
          _selectedTailorResumeId = result.resumeId;
          _selectedTailorResumeTitle = state.selectedFileName ?? 'Uploaded Resume';
        });
        if (mounted) AppSnackbar.success(context, 'Resume uploaded successfully!');
      }
    }
  }

  Future<void> _handleTailorExisting() async {
    final resumeId = _selectedTailorResumeId;

    if (resumeId == null) {
      AppSnackbar.warning(context, 'Please select or upload a base resume first.');
      return;
    }

    if (_templates.isEmpty) {
      AppSnackbar.error(context, 'No templates available. Please check backend connection.');
      return;
    }

    final selectedTemplate = _templates[_selectedTemplateIndex];
    final templateId = selectedTemplate['id']?.toString() ?? selectedTemplate['slug']?.toString() ?? '';

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(resumeRepositoryProvider);
      final res = await repo.tailorResume(
        resumeId: resumeId,
        templateId: templateId,
        jobDescription: _tailorJobDescController.text,
        targetMarketStrategy: _selectedStrategy,
      );
      
      if (res['remainingCredits'] != null) {
        ref.read(authNotifierProvider.notifier).updateCredits(
          resumeCredits: res['remainingCredits']['resumeCredits'],
          atsCredits: res['remainingCredits']['atsCredits'],
        );
      }

      setState(() {
        _isProcessing = false;
        _tailoredResult = res;
      });

      if (mounted) {
        AppSnackbar.success(context, 'Resume tailored successfully with optimized keywords!');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  Future<void> _handleBuildFromScratch() async {
    // Validate Compulsory Fields
    final fullName = _scratchFullNameController.text.trim();
    final email = _scratchEmailController.text.trim();
    final phone = _scratchPhoneController.text.trim();
    final jobTitle = _scratchJobTitleController.text.trim();
    final jobDesc = _scratchJobDescController.text.trim();
    final skillsRaw = _scratchSkillsController.text.trim();

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty) {
      AppSnackbar.error(context, 'Full Name, Email, and Phone Number are compulsory.');
      return;
    }

    if (jobTitle.isEmpty || jobDesc.isEmpty) {
      AppSnackbar.error(context, 'Target Job Title and Job Description are compulsory.');
      return;
    }

    final skillsList = skillsRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (skillsList.isEmpty) {
      AppSnackbar.error(context, 'Please specify at least one skill or technology.');
      return;
    }

    final experiences = _scratchExperiences
        .where((exp) => exp['role']!.text.trim().isNotEmpty)
        .map((exp) => {
              'role': exp['role']!.text.trim(),
              'company': exp['company']!.text.trim(),
              'period': exp['period']!.text.trim(),
              'description': exp['description']!.text.trim(),
            })
        .toList();

    final education = _scratchEducation
        .where((edu) => edu['degree']!.text.trim().isNotEmpty)
        .map((edu) => {
              'degree': edu['degree']!.text.trim(),
              'institution': edu['institution']!.text.trim(),
              'year': edu['year']!.text.trim(),
            })
        .toList();

    final templateId = _templates.isNotEmpty
        ? (_templates[_selectedTemplateIndex]['id']?.toString() ??
            _templates[_selectedTemplateIndex]['slug']?.toString() ??
            '')
        : '';

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(resumeRepositoryProvider);
      final payload = {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'location': _scratchLocationController.text.trim(),
        'linkedinUrl': _scratchLinkedinController.text.trim(),
        'portfolioUrl': _scratchPortfolioController.text.trim(),
        'targetJobTitle': jobTitle,
        'jobDescriptionText': jobDesc,
        'skills': skillsList,
        'experiences': experiences,
        'education': education,
        'targetMarketStrategy': _selectedStrategy,
        'templateId': templateId,
      };

      final res = await repo.createResumeFromScratch(payload);

      if (res['remainingCredits'] != null) {
        ref.read(authNotifierProvider.notifier).updateCredits(
          resumeCredits: res['remainingCredits']['resumeCredits'],
          atsCredits: res['remainingCredits']['atsCredits'],
        );
      }

      setState(() {
        _isProcessing = false;
        _tailoredResult = res;
      });

      if (mounted) {
        AppSnackbar.success(context, 'ATS resume generated from scratch with Gemini AI!');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  Future<void> _handlePreviewPdf() async {
    final id = _tailoredResult?['resumeId']?.toString() ??
        _tailoredResult?['resume']?['id']?.toString();
    if (id == null) {
      AppSnackbar.warning(context, 'Resume ID not found for preview.');
      return;
    }

    final title = _selectedMode == 1
        ? (_scratchJobTitleController.text.trim().isNotEmpty
            ? '${_scratchJobTitleController.text.trim()} Resume'
            : 'Generated Resume')
        : (_selectedTailorResumeTitle ?? 'Tailored Resume');

    AppNavigation.push(context, AppRoutes.pdfPreview, extra: {
      'pdfUrl': id,
      'resumeTitle': title,
    });
  }

  void _openContentEditor() {
    final resumeId = _tailoredResult?['resumeId']?.toString() ??
        _tailoredResult?['resume']?['id']?.toString();
    final tailoredContent = _tailoredResult?['tailoredContent'] as Map<String, dynamic>?;

    if (resumeId == null || tailoredContent == null) {
      AppSnackbar.warning(context, 'No editable resume content found.');
      return;
    }

    ResumeContentEditorSheet.show(
      context,
      resumeId: resumeId,
      initialContent: tailoredContent,
      repository: ref.read(resumeRepositoryProvider),
      onUpdated: (newContent) {
        setState(() {
          _tailoredResult!['tailoredContent'] = newContent;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CustomAppBar(
        title: Lang.builderTitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dual Mode Switcher
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedMode = 0),
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: context.screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedMode == 0 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  size: context.screenWidth * 0.045,
                                  color: _selectedMode == 0 ? Colors.white : AppColors.secondaryText,
                                ),
                                SizedBox(width: context.screenWidth * 0.02),
                                Text(
                                  Lang.modeUploadTailor,
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: context.screenWidth * 0.035,
                                    color: _selectedMode == 0 ? Colors.white : AppColors.secondaryText,
                                    fontWeight: _selectedMode == 0 ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedMode = 1),
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: context.screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedMode == 1 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_document,
                                  size: context.screenWidth * 0.045,
                                  color: _selectedMode == 1 ? Colors.white : AppColors.secondaryText,
                                ),
                                SizedBox(width: context.screenWidth * 0.02),
                                Text(
                                  Lang.modeBuildScratch,
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: context.screenWidth * 0.035,
                                    color: _selectedMode == 1 ? Colors.white : AppColors.secondaryText,
                                    fontWeight: _selectedMode == 1 ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),

              // ================= MODE 0: UPLOAD & TAILOR =================
              if (_selectedMode == 0) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Base Resume', style: AppTextStyles.sectionHeading),
                      SizedBox(height: context.screenHeight * 0.012),
                      GestureDetector(
                        onTap: _showResumeSelector,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.04, vertical: context.screenHeight * 0.018),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined, color: AppColors.primary, size: context.screenWidth * 0.055),
                              SizedBox(width: context.screenWidth * 0.03),
                              Expanded(
                                child: Text(
                                  _selectedTailorResumeTitle ?? 'Tap to select or upload a resume',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: _selectedTailorResumeId == null ? AppColors.mutedText : AppColors.mainText,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.03),
                _buildTemplateCarousel(),
                SizedBox(height: context.screenHeight * 0.03),
                _buildStrategySelector(),
                SizedBox(height: context.screenHeight * 0.025),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Lang.pasteJobDescTitle,
                        style: AppTextStyles.sectionHeading,
                      ),
                      SizedBox(height: context.screenHeight * 0.012),
                      CustomTextField(
                        controller: _tailorJobDescController,
                        hint: Lang.pasteJobDescHint,
                        maxLines: 4,
                      ),
                      SizedBox(height: context.screenHeight * 0.03),
                      CustomButton(
                        text: _isProcessing ? 'Optimizing with Gemini AI...' : Lang.tailorAction,
                        onPressed: _handleTailorExisting,
                        isLoading: _isProcessing,
                        icon: Icon(
                          Icons.auto_fix_high_rounded,
                          color: Colors.white,
                          size: context.screenWidth * 0.045,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
              // ================= MODE 1: BUILD FROM SCRATCH =================
              else ...[
                _buildScratchForm(),
                SizedBox(height: context.screenHeight * 0.025),
                _buildStrategySelector(),
                SizedBox(height: context.screenHeight * 0.025),
                _buildTemplateCarousel(),
                SizedBox(height: context.screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
                  child: CustomButton(
                    text: _isProcessing ? Lang.generatingScratch : Lang.generateScratchAction,
                    onPressed: _handleBuildFromScratch,
                    isLoading: _isProcessing,
                    icon: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: context.screenWidth * 0.045,
                    ),
                  ),
                ),
              ],

              // ================= TAILORED RESULT OUTCOME & LIVE EDIT =================
              if (_tailoredResult != null) ...[
                SizedBox(height: context.screenHeight * 0.035),
                _buildOutcomeCard(),
              ],
              SizedBox(height: context.screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
          child: Text(
            Lang.selectTemplateTitle,
            style: AppTextStyles.sectionHeading,
          ),
        ),
        SizedBox(height: context.screenHeight * 0.015),
        if (_isLoadingTemplates)
          SizedBox(
            height: context.screenHeight * 0.36,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          )
        else if (_templates.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
            child: Container(
              padding: EdgeInsets.all(context.screenWidth * 0.05),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text('No templates loaded from server.'),
            ),
          )
        else
          SizedBox(
            height: context.screenHeight * 0.38,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _templates.length,
              onPageChanged: (idx) => setState(() => _selectedTemplateIndex = idx),
              itemBuilder: (context, index) {
                final item = _templates[index];
                final isSelected = _selectedTemplateIndex == index;
                final thumbnailUrl = item['thumbnailUrl']?.toString() ?? '';
                final name = item['name']?.toString() ?? 'Template';
                final category = item['category']?.toString() ?? 'Tech';

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(
                    horizontal: context.screenWidth * 0.02,
                    vertical: isSelected ? context.screenHeight * 0.005 : context.screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: isSelected ? 14 : 6,
                        offset: Offset(0, context.screenHeight * 0.005),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: AppColors.secondarySurface,
                            child: Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (_, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.description_outlined,
                                  color: AppColors.mutedText,
                                  size: context.screenWidth * 0.12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(context.screenWidth * 0.03),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.cardHeading.copyWith(
                                        fontSize: context.screenWidth * 0.034,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(category, style: AppTextStyles.metadata),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: context.screenWidth * 0.045,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStrategySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
          child: Text(
            Lang.targetStrategyTitle,
            style: AppTextStyles.sectionHeading,
          ),
        ),
        SizedBox(height: context.screenHeight * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
          child: Column(
            children: _strategies.map((strat) {
              final isSelected = _selectedStrategy == strat['id'];
              return Padding(
                padding: EdgeInsets.only(bottom: context.screenHeight * 0.01),
                child: InkWell(
                  onTap: () => setState(() => _selectedStrategy = strat['id']!),
                  borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                  child: Container(
                    padding: EdgeInsets.all(context.screenWidth * 0.035),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.mutedText,
                          size: context.screenWidth * 0.05,
                        ),
                        SizedBox(width: context.screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strat['title']!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.mainText,
                                ),
                              ),
                              Text(
                                strat['desc']!,
                                style: AppTextStyles.supporting.copyWith(
                                  fontSize: context.screenWidth * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScratchForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Personal Details
          Text(Lang.scratchPersonalInfo, style: AppTextStyles.sectionHeading),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.fullNameLabel,
            hint: Lang.fullNameHint,
            controller: _scratchFullNameController,
          ),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.emailLabel,
            hint: Lang.emailHint,
            controller: _scratchEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.phoneLabel,
            hint: Lang.phoneHint,
            controller: _scratchPhoneController,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.locationLabel,
            hint: Lang.scratchLocationHint,
            controller: _scratchLocationController,
          ),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.linkedinLabel,
            hint: Lang.linkedinHint,
            controller: _scratchLinkedinController,
          ),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.portfolioLabel,
            hint: Lang.portfolioHint,
            controller: _scratchPortfolioController,
          ),
          SizedBox(height: context.screenHeight * 0.03),

          // Section 2: Target Role & JD
          Text(Lang.scratchJobTarget, style: AppTextStyles.sectionHeading),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.targetJobTitleLabel,
            hint: Lang.targetJobTitleHint,
            controller: _scratchJobTitleController,
          ),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.pasteJobDescTitle,
            hint: Lang.pasteJobDescHint,
            controller: _scratchJobDescController,
            maxLines: 4,
          ),
          SizedBox(height: context.screenHeight * 0.03),

          // Section 3: Skills
          Text(Lang.scratchSkills, style: AppTextStyles.sectionHeading),
          SizedBox(height: context.screenHeight * 0.012),
          CustomTextField(
            label: Lang.skillsLabel,
            hint: Lang.skillsHint,
            controller: _scratchSkillsController,
            maxLines: 2,
          ),
          SizedBox(height: context.screenHeight * 0.03),

          // Section 4: Work Experience
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  Lang.scratchExperience,
                  style: AppTextStyles.sectionHeading,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _addExperienceItem,
                icon: Icon(Icons.add, size: context.screenWidth * 0.045, color: AppColors.primary),
                label: Text(
                  Lang.addExperience,
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primary,
                    fontSize: context.screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.01),
          ..._scratchExperiences.asMap().entries.map((entry) {
            final idx = entry.key;
            final exp = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: context.screenHeight * 0.015),
              padding: EdgeInsets.all(context.screenWidth * 0.035),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Position #${idx + 1}', style: AppTextStyles.cardHeading),
                      if (_scratchExperiences.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: context.screenWidth * 0.05, color: AppColors.error),
                          onPressed: () => _removeExperienceItem(idx),
                        ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.roleLabel, hint: Lang.roleHint, controller: exp['role']!),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.companyLabel, hint: Lang.companyHint, controller: exp['company']!),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.periodLabel, hint: Lang.periodHint, controller: exp['period']!),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.achievementsLabel, hint: Lang.achievementsHint, controller: exp['description']!, maxLines: 2),
                ],
              ),
            );
          }),
          SizedBox(height: context.screenHeight * 0.02),

          // Section 5: Education
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  Lang.scratchEducation,
                  style: AppTextStyles.sectionHeading,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _addEducationItem,
                icon: Icon(Icons.add, size: context.screenWidth * 0.045, color: AppColors.primary),
                label: Text(
                  Lang.addEducation,
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primary,
                    fontSize: context.screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.01),
          ..._scratchEducation.asMap().entries.map((entry) {
            final idx = entry.key;
            final edu = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: context.screenHeight * 0.015),
              padding: EdgeInsets.all(context.screenWidth * 0.035),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Education #${idx + 1}', style: AppTextStyles.cardHeading),
                      if (_scratchEducation.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: context.screenWidth * 0.05, color: AppColors.error),
                          onPressed: () => _removeEducationItem(idx),
                        ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.degreeLabel, hint: Lang.degreeHint, controller: edu['degree']!),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.schoolLabel, hint: Lang.schoolHint, controller: edu['institution']!),
                  SizedBox(height: context.screenHeight * 0.008),
                  CustomTextField(label: Lang.graduationYearLabel, hint: Lang.graduationYearHint, controller: edu['year']!),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOutcomeCard() {
    final atsScore = _tailoredResult?['atsScore'] ?? _tailoredResult?['newScore'] ?? 92;
    final improvements = _tailoredResult?['improvementsMade'] ?? _tailoredResult?['improvementSummary'];
    final improvementText = improvements is List
        ? improvements.map((i) => '• $i').join('\n')
        : (improvements?.toString() ?? 'Formulated ATS-compliant executive bullets and keyword alignment.');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
        onTap: _handlePreviewPdf,
        child: Container(
          padding: EdgeInsets.all(context.screenWidth * 0.05),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.screenWidth * 0.04),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: Offset(0, context.screenHeight * 0.006),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: AppColors.successBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: context.screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: context.screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATS Resume Ready ($atsScore/100)',
                          style: AppTextStyles.cardHeading.copyWith(
                            color: AppColors.mainText,
                            fontSize: context.screenWidth * 0.042,
                          ),
                        ),
                        Text(
                          'Optimized with STAR framework & keywords (Tap to view)',
                          style: AppTextStyles.metadata,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: context.screenWidth * 0.04,
                  ),
                ],
              ),
              SizedBox(height: context.screenHeight * 0.015),
              Text(
                improvementText,
                style: AppTextStyles.supporting.copyWith(
                  color: AppColors.mainText,
                  fontSize: context.screenWidth * 0.033,
                  height: 1.4,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),

              // Action Buttons: Edit Content & Preview/Download PDF
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.016),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                        ),
                      ),
                      onPressed: _openContentEditor,
                      icon: Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: context.screenWidth * 0.05,
                      ),
                      label: Text(
                        Lang.editResumeContent,
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.primary,
                          fontSize: context.screenWidth * 0.036,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.screenWidth * 0.03),
                  Expanded(
                    child: CustomButton(
                      text: 'Preview & Download',
                      onPressed: _handlePreviewPdf,
                      icon: Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                        size: context.screenWidth * 0.045,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




