import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/resume_analysis_entity.dart';
import '../../domain/repositories/resume_repository.dart';
import '../models/resume_analysis_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final ApiClient _apiClient;

  ResumeRepositoryImpl(this._apiClient);

  @override
  Future<ResumeAnalysisEntity> uploadAndAnalyze({
    required File file,
    String? targetTitle,
    String? jobDescription,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(file.path, filename: fileName),
      if (targetTitle != null && targetTitle.trim().isNotEmpty)
        'targetTitle': targetTitle.trim(),
      if (jobDescription != null && jobDescription.trim().isNotEmpty)
        'jobDescription': jobDescription.trim(),
    });

    final response = await _apiClient.postMultipart(
      ApiEndpoints.resumeUpload,
      formData: formData,
    );

    return ResumeAnalysisModel.fromJson(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await _apiClient.get(ApiEndpoints.resumeHistory);
    if (response is Map<String, dynamic> && response['history'] is List) {
      return (response['history'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> tailorResume({
    required String resumeId,
    required String templateId,
    String? jobDescription,
    required String targetMarketStrategy,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeTailor,
      data: {
        'resumeId': resumeId,
        'templateId': templateId,
        if (jobDescription != null && jobDescription.trim().isNotEmpty)
          'jobDescriptionText': jobDescription.trim(),
        'targetMarketStrategy': targetMarketStrategy,
      },
    );

    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createResumeFromScratch(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndpoints.resumeCreateFromScratch,
      data: data,
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateResumeContent({
    required String resumeId,
    required Map<String, dynamic> tailoredContent,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.resumeUpdateContent(resumeId),
      data: {'tailoredContent': tailoredContent},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getTemplates() async {
    final response = await _apiClient.get(ApiEndpoints.templates);
    if (response is Map<String, dynamic> && response['templates'] is List) {
      return (response['templates'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
