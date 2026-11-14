class JobEntity {
  final String title;
  final String company;
  final String location;
  final String applyUrl;
  final String source;
  final String? postedAt;

  const JobEntity({
    required this.title,
    required this.company,
    required this.location,
    required this.applyUrl,
    required this.source,
    this.postedAt,
  });
}
