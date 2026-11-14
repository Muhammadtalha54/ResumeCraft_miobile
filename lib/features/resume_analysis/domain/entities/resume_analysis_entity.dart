/// Domain entity for ATS resume analysis outcome.
class ResumeAnalysisEntity {
  final String resumeId;
  final int overallScore;
  final int formattingScore;
  final int contentScore;
  final int skillsScore;
  final int impactScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final int remainingAtsCredits;

  const ResumeAnalysisEntity({
    required this.resumeId,
    required this.overallScore,
    required this.formattingScore,
    required this.contentScore,
    required this.skillsScore,
    required this.impactScore,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.remainingAtsCredits,
  });
}
