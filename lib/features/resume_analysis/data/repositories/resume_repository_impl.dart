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

  @override
  Future<List<int>> exportResumePdfBytes(String resumeIdOrExportPath) async {
    String finalUrl;

    if (resumeIdOrExportPath.startsWith('http://') || resumeIdOrExportPath.startsWith('https://')) {
      finalUrl = resumeIdOrExportPath;
    } else {
      String id = resumeIdOrExportPath;
      if (id.contains('/export/')) {
        id = id.split('/export/').last;
      } else if (id.startsWith('/')) {
        id = id.split('/').last;
      }
      id = id.split('?').first.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '').trim();

      final cleanBase = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      finalUrl = '$cleanBase/resumes/export/$id';
    }

    final token = await _apiClient.authStorage.getAccessToken();
    final queryParams = <String, dynamic>{};
    if (token != null && token.isNotEmpty && !finalUrl.contains('token=')) {
      queryParams['token'] = token;
    }

    final response = await _apiClient.rawDio.get<List<int>>(
      finalUrl,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.data == null || response.data!.isEmpty) {
      throw Exception('Empty PDF response received from server.');
    }
    return response.data!;
  }
}
