import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.title,
    required super.company,
    required super.location,
    required super.applyUrl,
    required super.source,
    super.postedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      title: json['title']?.toString() ?? 'Job Opportunity',
      company: json['company']?.toString() ?? 'Confidential',
      location: json['location']?.toString() ?? 'Remote',
      applyUrl: json['applyUrl']?.toString() ?? '',
      source: json['source']?.toString() ?? 'Job Feed',
      postedAt: json['postedAt']?.toString(),
    );
  }
}
