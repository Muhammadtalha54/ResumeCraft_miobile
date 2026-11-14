import 'dart:io';
import '../entities/resume_analysis_entity.dart';

abstract class ResumeRepository {
  Future<ResumeAnalysisEntity> uploadAndAnalyze({
    required File file,
    String? targetTitle,
    String? jobDescription,
  });

  Future<List<Map<String, dynamic>>> getHistory();

  Future<Map<String, dynamic>> tailorResume({
    required String resumeId,
    required String templateId,
    String? jobDescription,
    required String targetMarketStrategy,
  });

  Future<Map<String, dynamic>> createResumeFromScratch(Map<String, dynamic> data);

  Future<Map<String, dynamic>> updateResumeContent({
    required String resumeId,
    required Map<String, dynamic> tailoredContent,
  });

  Future<List<Map<String, dynamic>>> getTemplates();
}
