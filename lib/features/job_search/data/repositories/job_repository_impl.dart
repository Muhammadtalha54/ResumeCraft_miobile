import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../models/job_model.dart';

class JobRepositoryImpl implements JobRepository {
  final ApiClient _apiClient;

  JobRepositoryImpl(this._apiClient);

  @override
  Future<List<JobEntity>> searchJobs({
    required String query,
    String? location,
    String? jobType,
    String? dateFilter,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.jobsSearch,
      queryParameters: {
        'q': query.trim(),
        if (location != null && location.trim().isNotEmpty) 'location': location.trim(),
        if (jobType != null && jobType.trim().isNotEmpty) 'jobType': jobType.trim(),
        if (dateFilter != null && dateFilter.trim().isNotEmpty) 'dateFilter': dateFilter.trim(),
      },
    );

    if (response is Map<String, dynamic> && response['jobs'] is List) {
      return (response['jobs'] as List)
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> trackApplication({
    required String jobTitle,
    required String company,
    required String applyUrl,
  }) async {
    await _apiClient.post(
      ApiEndpoints.jobsApply,
      data: {
        'jobTitle': jobTitle,
        'company': company,
        'applyUrl': applyUrl,
      },
    );
  }
}
