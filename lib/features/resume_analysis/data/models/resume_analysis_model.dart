import '../../domain/entities/resume_analysis_entity.dart';

class ResumeAnalysisModel extends ResumeAnalysisEntity {
  const ResumeAnalysisModel({
    required super.resumeId,
    required super.overallScore,
    required super.formattingScore,
    required super.contentScore,
    required super.skillsScore,
    required super.impactScore,
    required super.strengths,
    required super.weaknesses,
    required super.recommendations,
    required super.remainingAtsCredits,
  });

  factory ResumeAnalysisModel.fromJson(Map<String, dynamic> json) {
    final breakdown = json['scoreBreakdown'] is Map<String, dynamic>
        ? json['scoreBreakdown'] as Map<String, dynamic>
        : <String, dynamic>{};

    int toInt(dynamic val, int defaultVal) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    List<String> toList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return ResumeAnalysisModel(
      resumeId: json['resumeId']?.toString() ??
          json['id']?.toString() ??
          (json['resume'] is Map ? json['resume']['id']?.toString() : null) ??
          '',
      overallScore: toInt(json['atsScore'] ?? json['overallScore'] ?? json['overallAtsScore'], 70),
      formattingScore: toInt(breakdown['formatting'] ?? breakdown['structure'], 75),
      contentScore: toInt(breakdown['content'] ?? breakdown['readability'], 70),
      skillsScore: toInt(breakdown['skills'] ?? breakdown['keywords'], 70),
      impactScore: toInt(breakdown['impact'], 70),
      strengths: toList(json['strengths'] ?? json['improvementSummary']),
      weaknesses: toList(json['weaknesses'] ?? json['missingSections']),
      recommendations: toList(json['recommendations'] ?? json['actionVerbSuggestions'] ?? json['improvementSummary']),
      remainingAtsCredits: toInt(
        json['remainingAtsCredits'] ?? (json['remainingCredits'] is Map ? json['remainingCredits']['atsCredits'] : null),
        0,
      ),
    );
  }
}
