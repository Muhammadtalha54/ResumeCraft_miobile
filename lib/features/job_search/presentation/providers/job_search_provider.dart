import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/repositories/job_repository_impl.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return JobRepositoryImpl(client);
});

class JobSearchState {
  final bool isLoading;
  final List<JobEntity> jobs;
  final String? errorMessage;
  final String lastQuery;
  final String lastLocation;
  final String selectedJobType;
  final String selectedDateFilter;

  const JobSearchState({
    this.isLoading = false,
    this.jobs = const [],
    this.errorMessage,
    this.lastQuery = '',
    this.lastLocation = '',
    this.selectedJobType = 'ALL',
    this.selectedDateFilter = 'all',
  });

  JobSearchState copyWith({
    bool? isLoading,
    List<JobEntity>? jobs,
    String? errorMessage,
    String? lastQuery,
    String? lastLocation,
    String? selectedJobType,
    String? selectedDateFilter,
  }) {
    return JobSearchState(
      isLoading: isLoading ?? this.isLoading,
      jobs: jobs ?? this.jobs,
      errorMessage: errorMessage,
      lastQuery: lastQuery ?? this.lastQuery,
      lastLocation: lastLocation ?? this.lastLocation,
      selectedJobType: selectedJobType ?? this.selectedJobType,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
    );
  }
}

class JobSearchNotifier extends StateNotifier<JobSearchState> {
  final JobRepository _repository;

  JobSearchNotifier(this._repository) : super(const JobSearchState());

  Future<void> search({
    required String query,
    String? location,
    String? jobType,
    String? dateFilter,
  }) async {
    if (query.trim().isEmpty) return;

    final resolvedDate = dateFilter ?? state.selectedDateFilter;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastQuery: query,
      lastLocation: location ?? '',
      selectedJobType: jobType ?? 'ALL',
      selectedDateFilter: resolvedDate,
    );

    try {
      final results = await _repository.searchJobs(
        query: query,
        location: location,
        jobType: jobType == 'ALL' ? null : jobType,
        dateFilter: resolvedDate == 'all' ? null : resolvedDate,
      );

      state = state.copyWith(
        isLoading: false,
        jobs: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> trackApplication(JobEntity job) async {
    try {
      await _repository.trackApplication(
        jobTitle: job.title,
        company: job.company,
        applyUrl: job.applyUrl,
      );
    } catch (_) {}
  }
}

final jobSearchProvider =
    StateNotifierProvider<JobSearchNotifier, JobSearchState>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return JobSearchNotifier(repo);
});
