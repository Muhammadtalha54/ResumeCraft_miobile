import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/lang.dart';
import '../../../../core/extensions/size_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/job_search_provider.dart';

class JobSearchScreen extends ConsumerStatefulWidget {
  const JobSearchScreen({super.key});

  @override
  ConsumerState<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends ConsumerState<JobSearchScreen> {
  final _queryController = TextEditingController(text: 'Software Engineer');
  final _locationController = TextEditingController();
  String _selectedJobType = 'ALL';
  String _selectedDateFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(jobSearchProvider).jobs.isEmpty) {
        _triggerSearch();
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    ref.read(jobSearchProvider.notifier).search(
          query: _queryController.text,
          location: _locationController.text,
          jobType: _selectedJobType,
          dateFilter: _selectedDateFilter,
        );
  }

  Future<void> _handleApply(String urlString, String title, String company) async {
    if (urlString.isEmpty) {
      AppSnackbar.warning(context, 'No apply link available for this vacancy.');
      return;
    }

    final url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      // Track application in user profile
      ref.read(jobSearchProvider.notifier).trackApplication(
            ref.read(jobSearchProvider).jobs.firstWhere((j) => j.applyUrl == urlString),
          );
      if (mounted) {
        AppSnackbar.success(context, 'Application tracked in your profile!');
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Unable to open job apply link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const CustomAppBar(
        title: Lang.searchJobsTitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Controls Container
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenWidth * 0.05,
                vertical: context.screenHeight * 0.016,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _queryController,
                          hint: Lang.searchJobsHint,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.mutedText,
                            size: context.screenWidth * 0.05,
                          ),
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.025),
                      SizedBox(
                        width: context.screenWidth * 0.12,
                        height: context.screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _triggerSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.screenWidth * 0.03),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: context.screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.012),

                  // Location & Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: context.screenHeight * 0.05,
                          child: TextField(
                            controller: _locationController,
                            style: AppTextStyles.supporting.copyWith(color: AppColors.mainText),
                            decoration: InputDecoration(
                              hintText: Lang.locationHint,
                              hintStyle: AppTextStyles.metadata.copyWith(color: AppColors.mutedText),
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.mutedText,
                                size: context.screenWidth * 0.04,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: context.screenWidth * 0.025,
                                vertical: context.screenHeight * 0.01,
                              ),
                              filled: true,
                              fillColor: AppColors.secondarySurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _triggerSearch(),
                          ),
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.02),
                      // Job Type Filter Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.025),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedJobType,
                          underline: const SizedBox(),
                          icon: Icon(Icons.tune_rounded, size: context.screenWidth * 0.04, color: AppColors.primary),
                          style: AppTextStyles.metadata.copyWith(color: AppColors.mainText, fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All Types')),
                            DropdownMenuItem(value: 'REMOTE', child: Text('Remote')),
                            DropdownMenuItem(value: 'HYBRID', child: Text('Hybrid')),
                            DropdownMenuItem(value: 'ONSITE', child: Text('Onsite')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedJobType = val);
                              _triggerSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.01),

                  // Date Posted Filter Row
                  Container(
                    height: context.screenHeight * 0.045,
                    padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySurface,
                      borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedDateFilter,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(Icons.schedule_rounded, size: context.screenWidth * 0.04, color: AppColors.primary),
                      style: AppTextStyles.metadata.copyWith(color: AppColors.mainText, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Date Posted: Any Time')),
                        DropdownMenuItem(value: '24h', child: Text('Date Posted: Past 24 Hours')),
                        DropdownMenuItem(value: 'week', child: Text('Date Posted: Past Week')),
                        DropdownMenuItem(value: 'month', child: Text('Date Posted: Past Month')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDateFilter = val);
                          _triggerSearch();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content List View
            Expanded(
              child: state.isLoading
                  ? const LoadingWidget(message: Lang.searchingJobs)
                  : state.errorMessage != null
                      ? ErrorStateWidget(
                          message: state.errorMessage!,
                          onRetry: _triggerSearch,
                        )
                      : state.jobs.isEmpty
                          ? EmptyStateWidget(
                              title: 'No Jobs Found',
                              description: Lang.noJobsFound,
                              icon: Icons.work_off_outlined,
                              actionText: 'Retry Search',
                              onAction: _triggerSearch,
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.screenWidth * 0.05,
                                vertical: context.screenHeight * 0.02,
                              ),
                              itemCount: state.jobs.length,
                              separatorBuilder: (_, index) => SizedBox(height: context.screenHeight * 0.015),
                              itemBuilder: (context, index) {
                                final job = state.jobs[index];

                                return Container(
                                  padding: EdgeInsets.all(context.screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(context.screenWidth * 0.035),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 8,
                                        offset: Offset(0, context.screenHeight * 0.003),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: context.screenWidth * 0.11,
                                            height: context.screenWidth * 0.11,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(context.screenWidth * 0.025),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.business_rounded,
                                                color: AppColors.primary,
                                                size: context.screenWidth * 0.055,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: context.screenWidth * 0.03),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  job.title,
                                                  style: AppTextStyles.cardHeading.copyWith(fontSize: 15),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: context.screenHeight * 0.003),
                                                Text(
                                                  job.company,
                                                  style: AppTextStyles.supporting.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.mainText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: context.screenHeight * 0.015),

                                      // Tags Row
                                      Wrap(
                                        spacing: context.screenWidth * 0.015,
                                        runSpacing: context.screenHeight * 0.008,
                                        children: [
                                          _TagPill(
                                            icon: Icons.location_on_outlined,
                                            label: job.location,
                                          ),
                                          _TagPill(
                                            icon: Icons.verified_outlined,
                                            label: job.source,
                                            color: AppColors.primary,
                                          ),
                                          if (job.postedAt != null && job.postedAt!.isNotEmpty)
                                            _TagPill(
                                              icon: Icons.access_time_rounded,
                                              label: job.postedAt!,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: context.screenHeight * 0.018),

                                      // Apply Button
                                      CustomButton(
                                        text: Lang.applyNow,
                                        onPressed: () => _handleApply(job.applyUrl, job.title, job.company),
                                        height: context.screenHeight * 0.048,
                                        icon: Icon(
                                          Icons.open_in_new_rounded,
                                          color: Colors.white,
                                          size: context.screenWidth * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _TagPill({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenWidth * 0.02,
        vertical: context.screenHeight * 0.005,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(context.screenWidth * 0.015),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.screenWidth * 0.03, color: color ?? AppColors.secondaryText),
          SizedBox(width: context.screenWidth * 0.01),
          Text(
            label,
            style: AppTextStyles.metadata.copyWith(
              color: color ?? AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
