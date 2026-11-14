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

    return ResumeAnalysisModel(
      resumeId: json['resumeId']?.toString() ??
          json['id']?.toString() ??
          (json['resume'] is Map ? json['resume']['id']?.toString() : null) ??
          '',
      overallScore: json['atsScore'] is int ? json['atsScore'] : 70,
      formattingScore: breakdown['formatting'] is int ? breakdown['formatting'] : 75,
      contentScore: breakdown['content'] is int ? breakdown['content'] : 70,
      skillsScore: breakdown['skills'] is int ? breakdown['skills'] : 70,
      impactScore: breakdown['impact'] is int ? breakdown['impact'] : 70,
      strengths: json['strengths'] is List
          ? (json['strengths'] as List).map((e) => e.toString()).toList()
          : [],
      weaknesses: json['weaknesses'] is List
          ? (json['weaknesses'] as List).map((e) => e.toString()).toList()
          : [],
      recommendations: json['recommendations'] is List
          ? (json['recommendations'] as List).map((e) => e.toString()).toList()
          : [],
      remainingAtsCredits: json['remainingAtsCredits'] is int ? json['remainingAtsCredits'] : 0,
    );
  }
}
