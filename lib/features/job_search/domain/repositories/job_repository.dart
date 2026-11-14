import '../entities/job_entity.dart';

abstract class JobRepository {
  Future<List<JobEntity>> searchJobs({
    required String query,
    String? location,
    String? jobType,
  });

  Future<void> trackApplication({
    required String jobTitle,
    required String company,
    required String applyUrl,
  });
}
